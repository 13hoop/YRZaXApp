/**
 * Created by jess on 15/1/23.
 */


! function( window ){

    var bridgeXXX = window.bridgeXXX;
    var Dialog = window.Dialog;

    var app = {

        $avatar : null,
        $userName : null,
        $balance : null,
        $modifyInfoBtn : null,

        $actionList : null,

        init : function(){

            this.$avatar = $('.avatar-img');
            this.$userName = $('.user-name');
            this.$balance = $('.balance');
            this.$modifyInfoBtn = $('.modify-info-btn');


            this.$actionList = $('.action-list');

            var that = this;

            bridgeXXX.getUserInfo( function( data ){
                try{
                    data = JSON.parse( data );
                }catch(e){
                    Dialog.alert({
                        content : '解析用户信息失败啦 :('
                    });
                    return;
                }

                that.$avatar.attr( 'src', data.avatar_src );
                that.$userName.text( data.user_name );
                that.$balance.text( '余额：' + data.balance + ' 咋学币');

            });

            //点击 修改账户信息
            this.$modifyInfoBtn.on( 'tap', function(){
                bridgeXXX.showAppPageByAction({
                    target : 'activity',
                    action : 'modify_user_info'
                });
            } );

            this.$actionList.on( 'tap', '.action-item', function(e){
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
        }

    };

    window.app = app;


}( window );