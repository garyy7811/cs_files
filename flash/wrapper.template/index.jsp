<%@ page import="java.net.URLEncoder" %>
<%
    response.setHeader( "Cache-Control", "no-cache" );
    response.setHeader( "Pragma", "no-cache" );
    response.setDateHeader( "Expires", 1 );

    String swfId = "${swf}";
    String cdnUrl = "${build_cdn_url}";
%>
<html>
<head>
    <title>${title}</title>
    <meta http-equiv="Content-Type" content="text/html; charset=utf-8"/>
    <style type="text/css" media="screen">
        html, body {
            width: 100%;
            height: 100%;
        }

        body {
            margin: 0;
            padding: 0;
            overflow: hidden;
            text-align: center;
            background-color: ${bgcolor};
        }

        object:focus {
            outline: none;
        }

        #plzInstallFlash {
            display: none;
        }
    </style>
    <script type="text/javascript" src="<%=cdnUrl%>swfobject.js"></script>
    <script type="text/javascript">
        var swfVersionStr = "${version_major}.${version_minor}.${version_revision}";
        var xiSwfUrlStr = "<%=cdnUrl%>expressInstall.swf";

        var flashvars = {};
        <%
                String flashVarStrWithQ = "?";
                java.util.Enumeration paramNames = request.getParameterNames();
                while(paramNames.hasMoreElements()){
                    String paramName = (String)paramNames.nextElement();
                    String paramValue = request.getParameter(  paramName );
                    if( flashVarStrWithQ.length() > 1 ){
                        flashVarStrWithQ += "&";
                    }
                    flashVarStrWithQ += URLEncoder.encode( paramName, "UTF-8") + "=" + URLEncoder.encode( paramValue, "UTF-8" );
        %>
        flashvars.<%=paramName%> = "<%=paramValue%>";
        <%
                }

                if( flashVarStrWithQ.length() > 1 ){
                    flashVarStrWithQ += "&";
                }
                flashVarStrWithQ += "pagesessionid=" + URLEncoder.encode( request.getSession().getId(), "UTF-8" );
                flashVarStrWithQ += "&pageurl=" + URLEncoder.encode( request.getRequestURL().toString(), "UTF-8" );
                flashVarStrWithQ += "&timestamp=" + System.currentTimeMillis();
        %>
        flashvars.pagesessionid = "<%=request.getSession().getId()%>";
        flashvars.pageurl = "<%=request.getRequestURL().toString()%>";

        var params = {};
        params.quality = "high";
        params.bgcolor = "${bgcolor}";
        params.allowscriptaccess = "sameDomain";
        params.allowFullScreenInteractive = "true";
        params.renderMode = "gpu";
        params.wmode = "direct";
        var attributes = {};
        attributes.id = "<%=swfId%>";
        attributes.name = "<%=swfId%>";
        attributes.align = "middle";
        swfobject.embedSWF(
                "<%=cdnUrl%><%=swfId%>.swf", "plzInstallFlash",
                "100%", "100%",
                swfVersionStr, xiSwfUrlStr,
                flashvars, params, attributes);
        swfobject.createCSS("#plzInstallFlash", "display:block;text-align:left;");

        //f**k all the bullies!
        var unloaded = false;
        function onunloading() {
            var exitUrl = "${exit.url}";
            if (!unloaded && exitUrl != null) {
                var ajaxRequest = new XMLHttpRequest();
                ajaxRequest.open("GET", exitUrl + "/<%=request.getSession().getId()%>", false);
                ajaxRequest.send("dummy");
                unloaded = true;
            }
        }

    </script>
</head>
<body onload="document.getElementById( '<%=swfId%>' ).focus();" onunload="onunloading();" onbeforeunload="onunloading();"
      beforeunload="onunloading();">
<div id="plzInstallFlash" style="color:#ffffff">
    <p>
        ${title} requires Adobe Flash Player version
        ${version_major}.${version_minor}.${version_revision} or greater, click on the icon below to install:
    </p>
    <script type="text/javascript">
        var pageHost = ((document.location.protocol == "https:") ? "https://" : "http://");
        document.write("<a href='http://www.adobe.com/go/getflashplayer'><img src='" + pageHost +
                "www.adobe.com/images/shared/download_buttons/get_flash_player.gif' alt='Get Adobe Flash player' /></a>");
    </script>
</div>

<noscript>
    <object classid="clsid:D27CDB6E-AE6D-11cf-96B8-444553540000" width="100%" height="100%" id="<%=swfId%>">
        <param name="movie" value="<%=cdnUrl%><%=swfId%>.swf<%=flashVarStrWithQ%>"/>
        <param name="quality" value="high"/>
        <param name="bgcolor" value="${bgcolor}"/>
        <param name="allowScriptAccess" value="sameDomain"/>
        <param name="allowFullScreenInteractive" value="true"/>
        <param name="renderMode" value="gpu"/>
        <param name="wmode" value="direct"/>
        <!--[if !IE]>-->
        <object type="application/x-shockwave-flash" data="<%=cdnUrl%><%=swfId%>.swf<%=flashVarStrWithQ%>" width="100%" height="100%">
            <param name="quality" value="high"/>
            <param name="bgcolor" value="${bgcolor}"/>
            <param name="allowScriptAccess" value="sameDomain"/>
            <param name="allowFullScreenInteractive" value="true"/>
            <param name="renderMode" value="gpu"/>
            <param name="wmode" value="direct"/>
            <!--<![endif]-->
            <!--[if gte IE 6]>-->
            <p>
                Either scripts and active content are not permitted to run or Adobe Flash Player
                ${title} requires Adobe Flash Player version
                ${version_major}.${version_minor}.${version_revision} or greater, click on the icon below to install:
            </p>
            <!--<![endif]-->
            <a href="http://www.adobe.com/go/getflashplayer">
                <img src="http://www.adobe.com/images/shared/download_buttons/get_flash_player.gif"
                     alt="Get Adobe Flash Player"/>
            </a>
            <!--[if !IE]>-->
        </object>
        <!--<![endif]-->
    </object>
</noscript>
</body>
</html>