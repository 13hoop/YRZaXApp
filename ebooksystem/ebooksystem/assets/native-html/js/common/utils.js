/**
 * Created by jess on 15/1/15.
 */


! function( window ){

    var samaConfig = window.samaConfig;
    var bridgeXXX = window.bridgeXXX;

    window.utils = window.utils || {};

    var utils = window.utils;

    var toString = Object.prototype.toString;


    //判断参数是否是 {} 对象
    utils.isObject = function(obj) {
        return toString.call( obj ) === '[object Object]';
    };

    //判断参数是否为 string
    utils.isString = function( str ){
        return toString.call( str ) === '[object String]';
    };

    //判断参数是否为 array
    utils.isArray = function( args ){
        return toString.call( args ) === '[object Array]';
    };

    utils.parseJSON = function( str ){
        var out = null;
        if( utils.isString(str) ){
            try{
                out = JSON.parse( str );
            }catch(e){

            }
        }
        return out;
    };


    utils.query2json = function( str ){
        str = str || '';
        str = str.replace( /^\?+/, '');
        var out = {};
        var arr1 = str.split('&');
        for( var i = 0, len = arr1.length; i < len; i++ ){
            var frag = arr1[i];
            var innerArr = frag.split('=');
            if( innerArr && innerArr.length === 2 ){
                try{
                    out[ innerArr[0] ] = decodeURIComponent( innerArr[1] );
                }catch(e){
                    if( window.console ){
                        console.error( 'utils.query2json decodeURIComponent fail!. Fragment: [' + frag + '] . query : [' + str + ']');
                    }
                }
            }
        }
        return out;
    };

    utils.json2query = function( obj ){
        var out = [];
        if( utils.isObject(obj) ){
            for( var i in obj ){
                if( i && obj.hasOwnProperty(i) ){
                    out.push( i + '=' + encodeURIComponent( obj[i] ) );
                }
            }
        }
        return out.join('&');
    };


    //将  htmlStr  转换成 DOM 返回
    var div;
    utils.str2dom = function( htmlStr ){
        if( ! utils.isString(htmlStr) ){
            return null;
        }
        if( ! div ){
            div = document.createElement('div');
        }
        div.innerHTML = htmlStr;
        return div.childNodes[0];
    };


    /**
     * 计算图片在规定区域 [viewWidth, viewHeight] 内的显示尺寸，默认居中
     * @param viewWidth
     * @param viewHeight
     * @param imgWidth
     * @param imgHeight
     * @returns {{width: *, height: *, left: number, top: number}}
     */
    utils.zoomLimitMax = function( viewWidth, viewHeight, imgWidth, imgHeight ){
        var outWidth, outHeight, left, top ;
        if( viewWidth / viewHeight > imgWidth / imgHeight ){
            outHeight = Math.min( viewHeight, imgHeight );
            outWidth = outHeight * imgWidth / imgHeight;
        }else{
            outWidth = Math.min( viewWidth, imgWidth);
            outHeight = imgHeight / imgWidth * outWidth;
        }

        top = ( viewHeight - outHeight ) / 2;
        left = ( viewWidth - outWidth ) / 2;

        return {
            width : outWidth,
            height : outHeight,
            left : left,
            top : top
        };
    };

    //读取之前设置的 白天、夜间 模式
    utils.restoreRenderMode = function(){
        bridgeXXX.getOneGlobalData( samaConfig.RENDER_MODE, function( mode ){
            mode = mode || 'day';
            if( mode ){
                document.body.setAttribute('data-mode', mode );
            }
        } );


    };

}( window );