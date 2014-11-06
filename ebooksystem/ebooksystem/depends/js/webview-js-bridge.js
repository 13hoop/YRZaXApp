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
    
	bridgeIOS.share = function(data){
		bridgeIOS.callOC( 'share', data );
	};
    
	bridgeIOS.goBack = function(data){
		bridgeIOS.callOC( 'goBack', data );
	};

       
}();

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

// test
function test() {
//    bridgeIOS.connectWebViewJavascriptBridge(
//                                             function(bridge) {
////                                             // init the bridge
////                                             bridge.init(function(message, responseCallback) {
////                                                         //                                                         alert('Received message from obj-c: ' + message);
////                                                         if (responseCallback) {
////                                                         responseCallback("[test()] This is response data from js");
////                                                         }
////                                                         });
////                                             
////                                             // register handlers, for obj-c call
////                                             bridge.registerHandler("showAlert", function(data) { alert('showAlert(): ' + data) });
////                                             bridge.registerHandler("getCurrentPageUrl", function(data, responseCallback) {
////                                                                    responseCallback(document.location.toString())
////                                                                    });
//                                             
//                                             // call obj-c method
//                                             bridge.callHandler("testObjCCallback", "jsjsjsjs", function(responseData){
//                                                                alert('[test()] Received responce from obj-c::testObjCCallback(), response data: ' + responseData)
//                                             });
//                                             bridge.callHandler("getNodeDataById", "dataId", function(responseData){
//                                                                alert('[test()] Received responce from obj-c::getNodeDataById(), response data: ' + responseData)
//                                             });
//                                             
//                                             // send message to obj-c
//                                             bridge.send('Please respond to this', function responseCallback(responseData) {
//                                                         alert('[test()] Received message from obj-c: ' + responseData)
//                                             });
//                                             
//                                             });
    
    bridgeIOS.callOC("getNodeDataById", "dataId", function(responseData){
                     alert('[test()] Received responce from obj-c::getNodeDataById(), response data: ' + responseData)
                     data = responseData;
                     alert(data)
    });

}


!function run() {
    // init
    init();
    
    var data;
    
    // native暴露给JS的接口对象
    var bridgeIOS = window.bridgeIOS;
    //alert(dump(bridgeIOS));
    
    
//    test();
}();
