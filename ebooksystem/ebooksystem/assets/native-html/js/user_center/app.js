/**
 * Created by jess on 15/1/23.
 */


! function( window ){

    var bridgeXXX = window.bridgeXXX;
    var Dialog = window.Dialog;
    var samaConfig = window.samaConfig;

    var loginClass = 'user-log-in';
    var notLoginClass = 'not-log-in';

    var app = {

        $userInfoCon : null,
        $avatar : null,
        $userName : null,
        $balance : null,
        $modifyInfoBtn : null,

        $loginBtn : null,

        $actionList : null,

        init : function(){

            this.$userInfoCon = $('#user-info-con');
            this.$avatar = $('.avatar-img');
            this.$userName = $('.user-name');
            this.$balance = $('.balance');
            this.$modifyInfoBtn = $('.modify-info-btn');
            this.$loginBtn = $('.login-btn');


            this.$actionList = $('.action-list');

            var that = this;

            this.updateUserInfo();

            //点击 修改账户信息
            this.$modifyInfoBtn.on( 'click', function(){
                bridgeXXX.showAppPageByAction({
                    target : 'activity',
                    action : 'modify_user_info'
                });
            } );

            this.$actionList.on( 'click', '.action-item', function(e){
                var $target = $(e.currentTarget);
                var action = $target.attr('data-action');
                if( action ){
                    // 打开对应页面
                    bridgeXXX.showAppPageByAction({
                        target : 'activity',
                        action : action
                    });
                }
            } );

            this.$loginBtn.on('click', function(){
                bridgeXXX.showURL({
                    target : 'activity',
                    url : 'http://' + samaConfig.SERVER.HOST +  '/index.php?c=passportctrl&m=show_login_page&back_to_app=1'
                });
            } );

            //补齐最后一行的格子
            var cellNum = this.$actionList.children('.action-item').length;
            var lastRowNum = cellNum % 3;
            if( cellNum > 0 && lastRowNum > 0 ){
                var html = '<div class="action-item empty-holder"></div>';
                if( 3 - lastRowNum > 1 ){
                    html += '<div class="action-item empty-holder"></div>';
                }
                this.$actionList.append( html );
            }

            document.addEventListener('SamaPageShow', function(){
                console.log('user_center: SamaPageShow');
                that.updateUserInfo();
            }, false );

            document.addEventListener('SamaPageHide', function(){
                console.log('user_center: SamaPageHide');
                that.resetUserInfo();
            }, false );
        },

        resetUserInfo : function(){
            this.$userInfoCon.removeClass( loginClass + ' ' + notLoginClass);
        },

        updateUserInfo : function(){
            var that = this;
            bridgeXXX.getCurUserInfo( function( data ){

                var isNotLogin = data === '{}';
                if( isNotLogin ){
                    //用户未登录
                    that.$userInfoCon.removeClass( loginClass).addClass( notLoginClass );
                    return;
                }

                try{
                    data = JSON.parse( data );
                }catch(e){
                    Dialog.alert({
                        content : '解析用户信息失败啦 :('
                    });
                    return;
                }

                that.$avatar.attr( 'src', data.avatar_src);
                that.$userName.text( data.user_name);
                that.$balance.text( '余额：' + data.balance + ' 咋学币');

                that.$userInfoCon.removeClass( notLoginClass).addClass( loginClass );

            });
        }

    };

    window.app = app;


}( window );