//alert("webview-js-bridge.js");

/**
 * Function : dump()
 * Arguments: The data - array,hash(associative array),object
 *    The level - OPTIONAL
 * Returns  : The textual representation of the array.
 * This function was inspired by the print_r function of PHP.
 * This will accept some data as the argument and return a
 * text that will be a more readable version of the
 * array/hash/object that is given.
 * Docs: http://www.openjs.com/scripts/others/dump_function_php_print_r.php
 */
function dump(arr,level) {
    var dumped_text = "";
    if(!level) level = 0;
    
    //The padding given at the beginning of the line.
    var level_padding = "";
    for(var j=0;j<level+1;j++) level_padding += "    ";
    
    if(typeof(arr) == 'object') { //Array/Hashes/Objects
        for(var item in arr) {
            var value = arr[item];
            
            if(typeof(value) == 'object') { //If it is an array,
                dumped_text += level_padding + "'" + item + "' ...\n";
                dumped_text += dump(value,level+1);
            } else {
                dumped_text += level_padding + "'" + item + "' => \"" + value + "\"\n";
            }
        }
    } else { //Stings/Chars/Numbers etc.
        dumped_text = "===>"+arr+"<===("+typeof(arr)+")";
    }
    return dumped_text;
}

// window.bridgeIOS def
!function(){
    window.bridgeIOS = window.bridgeIOS || {};
    
    // function: connect webview and js
    bridgeIOS.connectWebViewJavascriptBridge = function(callback) {
        if (window.WebViewJavascriptBridge) {
            callback(WebViewJavascriptBridge);
        } else {
            document.addEventListener('WebViewJavascriptBridgeReady', function() {
                                      callback(WebViewJavascriptBridge)
                                      }, false);
        }
    }
    
    // function: call obj-c method
    bridgeIOS.callOC = function(methodName, arg, callback) {
        bridgeIOS.connectWebViewJavascriptBridge(
                                                 function(bridge) {
                                                 bridge.callHandler(methodName, arg,
                                                                    function(responseData){
                                                                    if (callback) {
                                                                    callback(responseData);
                                                                    }
                                                                    });
                                                 });
    }
    
    //////////////// useful functions ////////////////
    
    bridgeIOS.shareApp = function(data){
        bridgeIOS.callOC( 'shareApp', data );
    };
    
//    bridgeIOS.goBack = function(data){
//        bridgeIOS.callOC( 'goBack', data );
//    };
    //goBack
    bridgeIOS.goBack = function(data, callback) {
        bridgeIOS.callOC('goBack', data, function(responseData){
                         if (callback) {
                         callback(responseData);
                         }
                         });
    };

    
    // playVideo() you
    bridgeIOS.playVideo = function(data, callback) {
        bridgeIOS.callOC('playVideo', data, function(responseData){
                         if (callback) {
                            callback(responseData);
                         }
        });
    };
    
    bridgeIOS.setStatusBarBackground = function(data){
        bridgeIOS.callOC( 'setStatusBarBackground', data );
    };
    //wu   getCurStudyType
    bridgeIOS.getCurStudyType = function(callback){
        bridgeIOS.callOC( 'getCurStudyType',data,function(responseData){
                         if (callback) {
                         callback(responseData);
                         }
                         }  );
    };
    
    //getData
    bridgeIOS.getData = function(data,callback){
        
        bridgeIOS.callOC( 'getData',data,function(responseData){
                         if (callback) {
                         callback(responseData);
                         }
                         }  );
        
    };
    
    //renderPage
    bridgeIOS.renderPage = function(data,callback){
        bridgeIOS.callOC( 'renderPage',data,function(responseData){
                         if (callback) {
                         callback(responseData);
                         }
                         }  );
    };
    //setCurStudyType
    bridgeIOS.setCurStudyType = function(data,callback){
        bridgeIOS.callOC( 'setCurStudyType',data,function(responseData){
                         if (callback) {
                         callback(responseData);
                         }
                         }  );
    };
    
    //getBookList
    bridgeIOS.getBookList = function(data,callback){
        bridgeIOS.callOC( 'getBookList',data,function(responseData){
                         if (callback) {
                         callback(responseData);
                         }
                         }  );
    };

    //checkUpdate
    bridgeIOS.checkDataUpdate = function(data,callback){
        bridgeIOS.callOC( 'checkDataUpdate',data,function(responseData){
                         if (callback) {
                         callback(responseData);
                         }
                         }  );
    };
    
    //startDownload
    bridgeIOS.startDownload = function(data,callback){
        bridgeIOS.callOC( 'startDownload',data,function(responseData){
                         if (callback) {
                         callback(responseData);
                         }
                         }  );
    };
    //queryDownloadProgress
    bridgeIOS.queryDownloadProgress = function(data,callback){
        bridgeIOS.callOC( 'queryDownloadProgress',data,function(responseData){
                         if (callback) {
                         callback(responseData);
                         }
                         }  );
    };
    //getCoverSrc
    bridgeIOS.getCoverSrc = function(data,callback){
        bridgeIOS.callOC( 'getCoverSrc',data,function(responseData){
                         if (callback) {
                         callback(responseData);
                         }
                         }  );
    };
    //goDiscoverPage
    bridgeIOS.goDiscoverPage = function(data,callback){
        bridgeIOS.callOC( 'goDiscoverPage',function(responseData){
                         if (callback) {
                         callback(responseData);
                         }
                         }  );
    };
    //goUserSettingPage
    bridgeIOS.goUserSettingPage = function(data,callback){
        bridgeIOS.callOC( 'goUserSettingPage',function(responseData){
                         if (callback) {
                         callback(responseData);
                         }
                         });
    };
    
    //queryBookStatus
    bridgeIOS.queryBookStatus = function(data,callback){
        bridgeIOS.callOC( 'queryBookStatus',data,function(responseData){
                         if (callback) {
                         callback(responseData);
                         }
                         }  );
    };
    
    
    //showURL
    bridgeIOS.showURL = function(data,callback){
        bridgeIOS.callOC( 'showURL',data,function(responseData){
                         if (callback) {
                         callback(responseData);
                         }
                         }  );
    };
    
    //addToNative
    bridgeIOS.addToNative = function(data,callback){
        bridgeIOS.callOC( 'addToNative',data,function(responseData){
                         if (callback) {
                         callback(responseData);
                         }
                         }  );
    };
    
    //showAppPageByAction
    bridgeIOS.showAppPageByAction = function(data,callback){
        bridgeIOS.callOC( 'showAppPageByAction',data,function(responseData){
                         if (callback) {
                         callback(responseData);
                         }
                         }  );
    };
    
    //getCurUserInfo
    bridgeIOS.getCurUserInfo = function(callback){
        bridgeIOS.callOC( 'getCurUserInfo', null, function(responseData){
//                         alert('in bridge js');
                         if (callback) {
                         callback(responseData);
                         }
                         }  );
    };
    
    
    
    //setCurUserInfo
    bridgeIOS.setCurUserInfo = function(data,callback){
        bridgeIOS.callOC( 'setCurUserInfo',data,function(responseData){
//                         alert(responseData);
                         if (callback) {
                         
                         callback(responseData);
                         }
                         }  );
    };
    
    //voteForZaxue
    bridgeIOS.voteForZaxue = function(data,callback){
        bridgeIOS.callOC( 'voteForZaxue',data,function(responseData){
                         if (callback) {
                         callback(responseData);
                         }
                         }  );
    };
    
    //checkAppUpdate
    bridgeIOS.checkAppUpdate = function(callback){
        bridgeIOS.callOC( 'checkAppUpdate',null,function(responseData){
                         if (callback) {
                         callback(responseData);
                         }
                         }  );
    };
    
    
     //showAboutPage
    bridgeIOS.showAboutPage = function(callback){
        bridgeIOS.callOC( 'showAboutPage',null,function(responseData){
                         if (callback) {
                         callback(responseData);
                         }
                         }  );
    };
    
    
    //addBookmark
    bridgeIOS.addBookmark = function(data,callback){
        bridgeIOS.callOC( 'addBookmark',data,function(responseData){
                         if (callback) {
                         callback(responseData);
                         }
                         }  );
    };
    
    //removeBookmark
    bridgeIOS.removeBookmark = function(data,callback){
        bridgeIOS.callOC( 'removeBookmark',data,function(responseData){
                         if (callback) {
                         callback(responseData);
                         }
                         }  );
    };
    //updateBookmark
    bridgeIOS.updateBookmark = function(data,callback){
        bridgeIOS.callOC( 'updateBookmark',data,function(responseData){
                         if (callback) {
                         callback(responseData);
                         }
                         }  );
    };
    
    
    //getBookmarkList
    bridgeIOS.getBookmarkList = function(data,callback){
        bridgeIOS.callOC( 'getBookmarkList',data,function(responseData){
                         if (callback) {
                         callback(responseData);
                         }
                         }  );
    };
    
    //addCollection
    bridgeIOS.addCollection = function(data,callback){
        bridgeIOS.callOC( 'addCollection',data,function(responseData){
                         if (callback) {
                         callback(responseData);
                         }
                         }  );
    };
    
    //getCollectionList
    bridgeIOS.getCollectionList = function(data,callback){
        bridgeIOS.callOC( 'getCollectionList',data,function(responseData){
                         if (callback) {
                         callback(responseData);
                         }
                         }  );
    };
    
    //removeCollectionList
    bridgeIOS.removeCollectionList = function(data,callback){
        bridgeIOS.callOC( 'removeCollectionList',data,function(responseData){
                         if (callback) {
                         callback(responseData);
                         }
                         }  );
    };
    
    //startQRCodeScan
    bridgeIOS.startQRCodeScan = function(data,callback){
        bridgeIOS.callOC( 'startQRCodeScan',data,function(responseData){
                         if (callback) {
                         callback(responseData);
                         }
                         }  );
    };
    //curUserLogout
    bridgeIOS.curUserLogout = function(data,callback){
        bridgeIOS.callOC( 'startQRCodeScan',data,function(responseData){
                         if (callback) {
                         callback(responseData);
                         }
                         }  );
    };
    //openCam
    bridgeIOS.openCam = function(data,callback){
        bridgeIOS.callOC( 'openCam',data,function(responseData){
                         if (callback) {
                         callback(responseData);
                         }
                         }  );
    };
    //openAlbum
    bridgeIOS.openAlbum = function(data,callback){
        bridgeIOS.callOC( 'openAlbum',data,function(responseData){
                         if (callback) {
                         callback(responseData);
                         }
                         }  );
    };
    //uploadImage
    bridgeIOS.uploadImage = function(data,callback){
        bridgeIOS.callOC( 'uploadImage',data,function(responseData){
                         if (callback) {
                         callback(responseData);
                         }
                         }  );
    };
    //curUserLogout
    bridgeIOS.curUserLogout = function(callback){
        //responseCallBack 回调时走下面的方法
        bridgeIOS.callOC( 'curUserLogout',null,function(responseData){
                         if (callback) {
                         callback(responseData);
                         }
                         }  );
    };
    //refreshOnlinePage
    bridgeIOS.refreshOnlinePage = function(callback){
        //responseCallBack 回调时走下面的方法
        bridgeIOS.callOC( 'refreshOnlinePage',null,function(responseData){
                         if (callback) {
                         callback(responseData);
                         }
                         }  );
    };
    
    //getNetworkType
    bridgeIOS.getNetworkType = function(callback){
        bridgeIOS.callOC( 'getNetworkType',null,function(responseData){
                         if (callback) {
                         callback(responseData);
                         }
                         }  );
    };
    
    
    
}();





!function run() {
    
    // init
    function init() {
        // native暴露给JS的接口对象
        var bridgeIOS = window.bridgeIOS;
        
        // register handlers
        bridgeIOS.connectWebViewJavascriptBridge(
                                                 function(bridge) {
                                                 // init the bridge
                                                 bridge.init(function(message, responseCallback) {
                                                             //                                                         alert('Received message from obj-c: ' + message);
                                                             if (responseCallback) {
                                                             responseCallback("This is response data from js");
                                                             }
                                                             });
                                                 
                                                 // register handlers, for obj-c call
                                                 bridge.registerHandler("showAlert", function(data) { alert('showAlert(): ' + data) });
                                                 bridge.registerHandler("getCurrentPageUrl", function(data, responseCallback) {
                                                                        responseCallback(document.location.toString())
                                                                        });
                                                 
                                                 // call obj-c method
                                                 // bridge.callHandler("testObjCCallback", "jsjsjsjs", function(responseData){
                                                 //                    alert('Received responce from obj-c::testObjCCallback(), response data: ' + responseData)
                                                 // });
                                                 // bridge.callHandler("getNodeDataById", "dataId", function(responseData){
                                                 //                    alert('Received responce from obj-c::getNodeDataById(), response data: ' + responseData)
                                                 // });
                                                 
                                                 // send message to obj-c
                                                 // bridge.send('Please respond to this', function responseCallback(responseData) {
                                                 //             alert('Received message from obj-c: ' + responseData)
                                                 // });
                                                 
                                                 });
        
    }
    
    // init
    init();
    
    // native暴露给JS的接口对象
//    var bridgeIOS = window.bridgeIOS;
//    alert(dump(bridgeIOS));
}();

!function(){

    
    window.samaBridgeReady = true;
    
    
    var event;
    var eventName = 'SamaBridgeReady';
    
    if( window.Event ){
        event = new Event( eventName );
        document.dispatchEvent( event );
    }else if( document.createEvent ){
        event = document.createEvent('HTMLEvents');
        event.initEvent( eventName, false, false  );
        document.dispatchEvent( event );
    }
    
//    alert('after bridge inject');
}();




