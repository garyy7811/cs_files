package com.customshow.build;

import org.springframework.http.*;
import org.springframework.http.converter.HttpMessageConverter;
import org.springframework.http.converter.StringHttpMessageConverter;
import org.springframework.web.client.RestClientException;
import org.springframework.web.client.RestTemplate;
import org.springframework.web.util.UriComponentsBuilder;
import org.w3c.dom.Node;
import org.w3c.dom.NodeList;
import org.xml.sax.InputSource;

import javax.xml.xpath.XPathConstants;
import javax.xml.xpath.XPathExpressionException;
import javax.xml.xpath.XPathFactory;
import java.io.StringReader;
import java.util.ArrayList;
import java.util.Collection;
import java.util.Date;
import java.util.Iterator;

/**
 * User: flashflexpro@gmail.com
 * Date: 4/27/2015
 * Time: 10:41 AM
 */
public class UtrackNewBuild{

    public static final String YOUTRACK_BASE_URL = "http://intranet.sg.com:8880";

    public static void main( String args[] ) throws XPathExpressionException{
        sessionV = loginForSessionId( args[ 0 ], args[ 1 ] );
        projectName = args[ 2 ];
        bundleName = args[ 3 ];
        newBuildName = args[ 4 ];
        boolean createBuildEvenNothingToUpdate = false;
        try{
            createBuildEvenNothingToUpdate = ( "true".equals( args[ 5 ] ) );
        }
        catch( Exception e ){
        }
        try{
            disableNotifications = !"false".equals( args[ 6 ] );
        }
        catch( Exception e ){
        }

        if( projectName == null ){
            throw new RuntimeException( "Need a project name on the 3rd Argument!" );
        }
        if( bundleName == null ){
            throw new RuntimeException( "Need a bundle name on the 4rd Argument!" );
        }
        if( newBuildName == null ){
            throw new RuntimeException( "Need a build name on the 5rd Argument!" );
        }

        NodeList nodeList = findToDoLst();
        if( nodeList.getLength() == 0 && ! createBuildEvenNothingToUpdate ){
            throw new RuntimeException(
                    "No issue found by filter: [" + filterStr + "], input 'true' on 6th param to create build anyway." );
        }

        addNewBuildValue();

        for( int j = 0; j < nodeList.getLength(); j++ ){
            Node n = nodeList.item( j );
            updateEachFixedBuild( n.getTextContent() );
        }
        System.out.println( nodeList.getLength() + " issues updated");

    }

    private static String filterStr;

    private static NodeList findToDoLst() throws XPathExpressionException{

        UriComponentsBuilder uriComponentsBuilder = UriComponentsBuilder.fromHttpUrl( YOUTRACK_BASE_URL );
        uriComponentsBuilder.path( "/rest" );
        uriComponentsBuilder.path( "/issue" );
        filterStr = "project: " + projectName + "  State: Fixed  Fixed in build:{Next Build} ";
        uriComponentsBuilder.queryParam( "filter", filterStr );
        uriComponentsBuilder.queryParam( "with", "Subversion" );
        uriComponentsBuilder.queryParam( "max", "2000" );

        System.out.println( "filter str:" + filterStr );

        RestTemplate restTemplate = new RestTemplate();

        HttpHeaders headers = new HttpHeaders();
        headers.add( "Cookie", sessionV );
        ResponseEntity<String> rslt = restTemplate.exchange( uriComponentsBuilder.build().toUri(), HttpMethod.GET,
                new HttpEntity<Object>( null, headers ), String.class );

        NodeList nodeList = ( NodeList )XPathFactory.newInstance().newXPath()
                .evaluate( "/issueCompacts/issue/@id", new InputSource( new StringReader( rslt.getBody() ) ),
                        XPathConstants.NODESET );
        return nodeList;
    }

    private static void updateEachFixedBuild( String issueId ){
        UriComponentsBuilder uriComponentsBuilder = UriComponentsBuilder.fromHttpUrl( YOUTRACK_BASE_URL );
        uriComponentsBuilder.path( "/rest" );
        uriComponentsBuilder.path( "/issue" );
        uriComponentsBuilder.path( "/" + issueId );
        uriComponentsBuilder.path( "/execute" );

        uriComponentsBuilder.queryParam( "command", "Fixed in build " + newBuildName );
        uriComponentsBuilder.queryParam( "disableNotifications", disableNotifications );

        RestTemplate restTemplate = new RestTemplate();

        HttpHeaders headers = new HttpHeaders();
        headers.add( "Cookie", sessionV );
        restTemplate.exchange( uriComponentsBuilder.build().toUri(), HttpMethod.POST,
                new HttpEntity<Object>( null, headers ), String.class );
    }

    private static String loginForSessionId( String user, String passwd ){

        RestTemplate restTemplate = new RestTemplate();

        UriComponentsBuilder uriComponentsBuilder = UriComponentsBuilder.fromHttpUrl( YOUTRACK_BASE_URL );
        uriComponentsBuilder.path( "/rest" );
        uriComponentsBuilder.path( "/user" );
        uriComponentsBuilder.path( "/login" );
        uriComponentsBuilder.queryParam( "login", user);
        uriComponentsBuilder.queryParam( "password", passwd );


        HttpHeaders headers = new HttpHeaders();

        ArrayList<MediaType> supportedMediaTypes = new ArrayList<MediaType>();
        ArrayList<MediaType> acceptableMediaTypes = supportedMediaTypes;
        acceptableMediaTypes.add( MediaType.APPLICATION_XML );
        headers.setAccept( acceptableMediaTypes );

        headers.setContentType( MediaType.APPLICATION_FORM_URLENCODED );

        ArrayList<HttpMessageConverter<?>> messageConverters = new ArrayList<HttpMessageConverter<?>>();
        StringHttpMessageConverter e = new StringHttpMessageConverter();
        e.setSupportedMediaTypes( supportedMediaTypes );
        messageConverters.add( e );
        restTemplate.setMessageConverters( messageConverters );

        ResponseEntity<String> rt = restTemplate
                .postForEntity( uriComponentsBuilder.build().toUriString(),
                        new HttpEntity( headers ), String.class );


        Collection<String> sessionAndCookie = rt.getHeaders().get( "Set-Cookie" );

        Iterator<String> iterator = sessionAndCookie.iterator();
        String sessionV = null;
        while( iterator.hasNext() ){
            String next = iterator.next();
            if( next.indexOf( "YTJSESSIONID" ) == 0 ){
                sessionV = next.substring( 0, next.indexOf( ";Path=/" ) );
                break;
            }
        }
        return sessionV;
    }

    private static String projectName;
    private static String sessionV;
    private static String bundleName;
    private static String newBuildName;
    private static boolean disableNotifications = true;

    private static void addNewBuildValue(){
        RestTemplate restTemplate;
        UriComponentsBuilder uriComponentsBuilder = UriComponentsBuilder.fromHttpUrl( YOUTRACK_BASE_URL );
        uriComponentsBuilder.path( "/rest" );
        uriComponentsBuilder.path( "/admin" );
        uriComponentsBuilder.path( "/customfield" );
        uriComponentsBuilder.path( "/buildBundle" );
        uriComponentsBuilder.path( "/" + bundleName );
        uriComponentsBuilder.path( "/" + newBuildName );
        uriComponentsBuilder.queryParam( "assembleDate", new Date().getTime() );


        restTemplate = new RestTemplate();
        HttpHeaders headers = new HttpHeaders();
        headers.add( "Cookie", sessionV );
        try{
            restTemplate.put( uriComponentsBuilder.build().toUri(), new HttpEntity( null, headers ) );
            System.out.println( "new bundle name[" + newBuildName + "] added" );
        }
        catch( RestClientException e ){
            if( "409 Conflict".equals( e.getMessage() ) ){
                System.out.println( "build name '" + newBuildName + "' exist already! will continue with it" );
                return;
            }
            throw e;
        }
    }
}
