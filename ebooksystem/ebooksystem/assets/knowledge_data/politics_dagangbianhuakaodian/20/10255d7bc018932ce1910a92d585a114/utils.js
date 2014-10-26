/**
 * Created by jess on 14-9-16.
 */


var utils = window.utils || {};

//把JSON转换成URL中的参数，不进行 encodeURIComponent
utils.json2Query = function( args ){
    var out = '';
    for( var i in args ){
        if( i && args.hasOwnProperty(i) ){
            out += i + '=' + args[i] + '&';
        }
    }
    return out;
};

//获取URL中search部分的参数，转换成JSON，自动 decodeURIComponent
utils.getSearchConf = function(){
    var out = {};
    var s = location.search.substring(1);
    var arr1 = s.split('&');
    for( var i = 0, len = arr1.length; i < len; i++ ){
        var temp1 = arr1[i];
        var arr2 = temp1.split('=');
        if( arr2.length === 2 ){
            try{
                out[ arr2[0] ] = decodeURIComponent( arr2[1] );
            }catch(e){
                console.info( 'utils.getSearchConf decodeURIComponent error---' + arr2.join(':') );
            }
        }
    }

    return out;
};

//获取当前页面对应的数据ID
utils.getPageID = function(){
    var s = location.search.substring(1);
    var reg = /(?:^|&)id=([^&]+)/g;
    var out = reg.exec( s );
    var id = null;
    if( out ){
        id = out[1];
    }
    return id;
};


//初始化页面头部点击事件处理
var isHeaderInited = false;
utils.initPageHeader = function( selector ){
    if( isHeaderInited ){
        return;
    }
    isHeaderInited = true;
    selector = selector || '.page-header .common-back';

    var commonBack = document.querySelector( selector );
    if( commonBack ){
        alert('common back inited' );
        commonBack.addEventListener( 'touchend', function(){                                    
            bridgeIOS.finish();
        }, false );
    }
};