/**
 * Created by jess on 15/3/12.
 */

! function(){

    var $ = window.Zepto;
    var utils = window.utils;

    var isInited = false;

    var singleton = {

        init : function(){
            if( isInited ){
                return;
            }
            isInited = true;

            utils.restoreRenderMode();

            var $backBtn = $('.common-back');
            $backBtn.on('tap', function(){
                bridgeXXX.goBack();
            });

            var $refreshBtn = $('#refresh-btn');
            $refreshBtn.on('tap', function(){
                bridgeXXX.refreshOnlinePage();
            } );
        }
    };

    window.app = singleton;

}();