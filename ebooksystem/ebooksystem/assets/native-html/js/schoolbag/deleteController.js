/**
 * Created by jess on 15/3/17.
 */

! function(){

    var $ = window.Zepto;
    var EventEmitter = window.EventEmitter;
    var bridgeXXX = window.bridgeXXX;

    var singleton = {

        $selectAllBtn : null,
        $editAllBtn : null,
        $opBar : null,
        $delBtn : null,
        $cancelBtn : null,
        //当前是否处于编辑状态
        editing : false,
        //是否正在与native通信
        //
        isSelectAll : true,
        isQuery : false,
        app : null,

        init : function( args ){

            this.app = args.app;

            this.$selectAllBtn = $('#select-all-btn');
            this.$editAllBtn = $('#toggle-edit-btn');
            this.$opBar = $('#book-edit-con');
            this.$delBtn = $('#del-all-btn');
            this.$cancelBtn = $('#cancel-all-btn');

            this._setupEvent();
        },

        _setupEvent : function(){

            var that = this;

            this.$selectAllBtn.on('click', function(){
                var isSelectAll = that.isSelectAll;
                if( isSelectAll ){
                    isSelectAll = false;
                    that.trigger('select-all', [ that ] );
                    that.$selectAllBtn.text('取消全选');
                }else{
                    isSelectAll = true;
                    that.trigger('unselect-all', [ that ] );
                    that.$selectAllBtn.text('全选');
                }
                that.isSelectAll = isSelectAll;

            } );

            this.$editAllBtn.on('click', function(){

                var event =  !that.editing ? 'enter-edit' : 'exit-edit';
                that.trigger( event, [ that ] );
            });

            this.$delBtn.on('click', function(e){
                if( that.isQuery ){
                    return;
                }
                that.handleDeleteClick();
            } );

            this.$cancelBtn.on('click', function(e){
                that.trigger('exit-edit', []);
            });

        },

        enterEditMode : function(){
            this.editing = true;
            this.$selectAllBtn.show();
            this.$editAllBtn.text('取消');
            this.$delBtn.text('删除');
            this.$opBar.show();
        },
        exitEditMode : function(){
            this.isQuery = false;
            this.editing = false;
            this.isSelectAll = true;
            this.$selectAllBtn.hide().text('全选');
            this.$editAllBtn.text('编辑');
            this.$opBar.hide();
        },
        handleDeleteClick : function(){
            var idArray = this.app.getSelectedIDs();
            if( idArray.length < 1 ){
                return;
            }
            var that = this;
            Dialog.confirm({
                content : '您是否确认删除已选图书?',
                onOK : function(){
                    that.deleteIDArray( idArray );
                }
            });
        },
        deleteIDArray : function( idArray ){
            this.isQuery = true;
            var that = this;
            bridgeXXX.removeLocalBooks( idArray, function( out ){
                that.isQuery = false;
                if( out !== '1' ){
                    Dialog.alert({
                        content : '删除书籍出错，请稍后再试'
                    });
                }else{
                    that.trigger('delete-success');
                }
            } );
        },
        updateDelBtn : function(){
            var idArray = this.app.getSelectedIDs();
            var text = '删除';
            if( idArray.length > 0 ){
                text += '(' + idArray.length + ')';
            }
            this.$delBtn.text( text );
        }
    };

    $.extend( singleton, EventEmitter.prototype );


    window.deleteController = singleton;

}();