/**
 * Created by jess on 15/1/29.
 */


! function( window ){

    var $ = window.Zepto;
    var bridgeXXX = window.bridgeXXX;
    var utils = window.utils;
    var Dialog = window.Dialog;
    var samaConfig = window.samaConfig;

    //当前的白天、夜间模式
    var renderMode = 'night';

    var app = {

        inited : false,

        init : function(){

            if( this.inited ){
                return;
            }
            this.inited = true;

            utils.restoreRenderMode();

            var $backBtn = $('.common-back');

            var $voteBtn = $('#vote-btn');
            var $shareBtn = $('#share-btn');
            var $faqBtn = $('#faq-btn');
            var $checkUpdateBtn = $('#check-update-btn');
            var $aboutBtn = $('#about-btn');

            $backBtn.on('tap', function(){
                bridgeXXX.goBack();
            });

            //切换夜间模式
            var $body = $(document.body);
            var $modeToggleBtn = $('#render-mode-btn');
            $modeToggleBtn.on('tap', function(){
                var current = $body.attr('data-mode');
                if( current == 'night' ){
                    current = 'day';
                }else{
                    current = 'night';
                }
                $body.attr('data-mode', current);
                bridgeXXX.setOneGlobalData( samaConfig.RENDER_MODE, current );
            });

            //给咋学打分
            $voteBtn.on('tap', function(){
                bridgeXXX.voteForZaxue();
            } );

            //分享APP
            $shareBtn.on('tap', function(){
                var args = {
                    title : '',
                    content : '我找到了可以随时看名书，听微课、问名师的神器！',
                    image_url : 'http://sdata.zaxue100.com/kaoyan/webstatic/20141115/weixin-icon.png',
                    target_url : 'http://zaxue100.com/'
                };
                bridgeXXX.shareApp( args );
            } );

            //常见问题
            $faqBtn.on( 'tap', function(){
                bridgeXXX.showURL({
                    target : 'activity',
                    url : 'http://' + samaConfig.SERVER.HOST +  '/index.php?c=discover_ctrl&m=faq_page'
                });
            } );

            //检查更新
            var $updateIndicator = $('#update-indicator');
            var isChecking = false;
            $checkUpdateBtn.on( 'tap', function(){
                if( isChecking ){
                    return;
                }
                isChecking = true;
                $updateIndicator.text('正在检查更新');
                bridgeXXX.checkAppUpdate( function( data ){
                    isChecking = false;
                    try{
                        data = JSON.parse( data );
                    }catch(e){
                        Dialog.alert({
                            content : '检查更新出错:('
                        });
                        return;
                    }

                    var text = '已经是最新版本';
                    if( data.has_update === '1' ){
                        //有更新
                        text = '发现新版';
                    }
                    $updateIndicator.text( text );

                } );
            } );

            //关于
            $aboutBtn.on('tap', function(){
                bridgeXXX.showAboutPage();
            } );
        }

    };

    window.app = app;

}( window );