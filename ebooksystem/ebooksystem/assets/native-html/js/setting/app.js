/**
 * Created by jess on 15/1/29.
 */


! function( window ){

    var $ = window.Zepto;
    var bridgeXXX = window.bridgeXXX;
    var Dialog = window.Dialog;

    var app = {

        init : function(){

            var $backBtn = $('.common-back');

            var $voteBtn = $('#vote-btn');
            var $shareBtn = $('#share-btn');
            var $faqBtn = $('#faq-btn');
            var $checkUpdateBtn = $('#check-update-btn');
            var $aboutBtn = $('#about-btn');

            $backBtn.on('tap', function(){
                bridgeXXX.goBack();
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
                    url : 'http://test.zaxue100.com/index.php?c=discover_ctrl&m=faq_page'
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