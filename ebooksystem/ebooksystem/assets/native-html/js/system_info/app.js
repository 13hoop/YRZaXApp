/**
 * Created by jess on 15/1/28.
 */


! function( window ){

    var $ = window.Zepto;
    var bridgeXXX = window.bridgeXXX;
    var Dialog = window.Dialog;

    var app = {

        $infoList : null,

        init : function(){

            var $backBtn = $('.common-back');
            $backBtn.on('tap', function(){
                bridgeXXX.goBack();
            } );

            this.$infoList = $('.info-list');

            this.$infoList.on( 'tap', '.info-item', function(e){
                var $target = $(e.currentTarget);
                var url = $target.attr('data-url');
                if( url ){
                    bridgeXXX.showURL({
                        url : url,
                        target : 'activity'
                    });
                }
            } );

            var that = this;

            bridgeXXX.getSystemInfoList( function( data ){

                try{
                    data = JSON.parse( data );
                }catch(e){
                    Dialog.alert({
                        content : '解析系统消息数据失败'
                    });
                    return;
                }

                var html = '';
                for( var i = 0, len = data.length; i < len; i++ ){
                    var obj = data[i];
                    html += '<li class="info-item" data-url="' + obj.url + '">' +
                        '<h2 class="info-title">' + obj.title + '</h2>' +
                        '<div class="info-desc">' + obj.desc + '</div>' +
                        '<div class="info-time">' + ( new Date(obj.timestamp * 1000) ).toLocaleString() + '</div>' +
                    '</li>';
                }

                that.$infoList.html( html );

            } );
        }

    };



    window.app = app;

}( window );