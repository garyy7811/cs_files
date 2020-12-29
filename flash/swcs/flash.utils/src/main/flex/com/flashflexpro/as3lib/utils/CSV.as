/**
 * Created by gary.yang.customshow on 8/13/2015.
 */
package com.flashflexpro.as3lib.utils {
import spark.components.DataGrid;
import spark.components.gridClasses.GridColumn;

public class CSV {
    public function CSV(){
    }

    private static const replaceQuote:RegExp = /"/g;
    public static function filterCsvCellForExcel( cell:String ):String{
        if( cell == null ){
            return "";
        }
        var q:Boolean = false;
        if( cell.indexOf( "\"" ) >= 0 ){
            cell = cell.replace( replaceQuote, "\"\"" );
            q = true;
        }

        if( q || cell.indexOf( "," ) >= 0 || cell.indexOf( "\n" ) >= 0 ){
            cell = "\"" + cell + "\"";
        }
        return cell;
    }

    public static function exportDataGrid( rsltGrid:DataGrid, includeHeaders:Boolean = false, selectionOnly:Boolean = false ):String{

        var cellRaw:String;
        var item:Object;
        var csvStr:String;
        var col:GridColumn;
        var csvRow:Array = [];
        var i:int = 0;

        if( includeHeaders ){
            for( ; i < rsltGrid.columns.length; i ++ ){
                col = rsltGrid.columns.getItemAt( i ) as GridColumn;
                csvRow.push( col.headerText );
            }
            csvStr = csvRow.join( "," );
        }

        if( selectionOnly ){
            var dgRows:Vector.<Object> = rsltGrid.selectedItems;
            for each( item in dgRows ){
                csvRow = [];
                for( i = 0; i < rsltGrid.columns.length; i ++ ){
                    col = rsltGrid.columns.getItemAt( i ) as GridColumn;
                    cellRaw = (col.labelFunction == null ) ? item[ col.dataField ] : col.labelFunction.apply( null, [ item, col ] );
                    csvRow.push( CSV.filterCsvCellForExcel( cellRaw ) );
                }
                if( csvStr == null ){
                    csvStr = "";
                }
                else{
                    csvStr += "\n";
                }
                csvStr += csvRow.join( "," );
            }
        }
        else{
            for( var j:int = 0; j < rsltGrid.dataProvider.length; j ++ ){
                item = rsltGrid.dataProvider.getItemAt( j );
                csvRow = [];
                for( i = 0; i < rsltGrid.columns.length; i ++ ){
                    col = rsltGrid.columns.getItemAt( i ) as GridColumn;
                    cellRaw = (col.labelFunction == null ) ? item[ col.dataField ] : col.labelFunction.apply( null, [ item, col ] );
                    csvRow.push( CSV.filterCsvCellForExcel( cellRaw ) );
                }
                if( csvStr == null ){
                    csvStr = "";
                }
                else{
                    csvStr += "\n";
                }
                csvStr += csvRow.join( "," );
            }

        }
        return csvStr;
    }
}
}
