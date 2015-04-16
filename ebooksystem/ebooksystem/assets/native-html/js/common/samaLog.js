/**
 * Created by jess on 15/3/20.
 */

! function(){

    var utils = window.utils;

    var SERVER = 'http://log.zaxue100.com/';

    function request(url){
        var id = '__SAMA_LOG_' + ( new Date()).getTime();
        var img = document.createElement('img');
        window[id] = img;
        img.onload = img.onerror = function(){
            img.onload = img.onerror = null;
            window[id] = null;
            img = null;
            delete window[id];
        };
        img.src = url + '&ran=' + ( new Date()).getTime();
    }

    var samaLog = {

        send : function( args ){
            var logFile = 'pv.gif';
            args = utils.json2query( args );
            var url = SERVER + logFile + '?' + args;
            request( url );
        }

    };


    window.samaLog = samaLog;
}();