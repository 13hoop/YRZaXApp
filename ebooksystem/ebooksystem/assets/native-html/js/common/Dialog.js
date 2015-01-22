/**
 * 自定义对话框相关类
 * Created by jess on 15/1/19.
 */



! function( window ){

    'use strict';

    var $ = window.Zepto;

    var EventEmitter = window.EventEmitter;


    var html = '<div class="dialog-wrap dialog-mask">' +
                '<div class="dialog">' +
                    '<div class="dialog-content"></div>' +

                    '<div class="dialog-btns"></div>' +
                '</div>' +
        '</div>';

    function Dialog( args ){
        args = $.extend( {
            showClass : 'dialog-show'
        }, args || {} );
        this.config = args;
        var $el = $( html );
        this.$dialogBody = $el.find('.dialog');
        this.$dialogContent = $el.find('.dialog-content');
        this.$dialogBtnCon = $el.find('.dialog-btns');

        this.$el = $el;

        $el.appendTo( document.body );

        this._setupDOM();

        this._setupEvent();
    }

    $.extend( Dialog.prototype, EventEmitter.prototype );

    $.extend( Dialog.prototype, {

        _setupDOM : function(){},

        _setupEvent : function(){

            this.$dialogBody.on( 'tap', function(e){
                e.stopPropagation();
            }, false );

            this.$el.on( 'tap', this.maskClick.bind( this ) );
        },

        show : function(){
            this.$el.addClass( this.config.showClass );
            this.trigger('show', [ this ]);
        },
        hide : function(){
            this.$el.removeClass( this.config.showClass );
            this.trigger('hide', [ this ]);
        },
        isVisible : function(){
            return this.$el.hasClass( this.config.showClass );
        },
        setContentHTML : function( html ){
            this.$dialogContent.html( html );
        },
        maskClick : function(){
            this.hide();
        }
    } );


    ///////////////////////  AlertDialog  单例存在  ///////////

    function AlertDialog( args ){

        Dialog.apply( this, arguments );

        this.onOK = this.config.onOK || null;

        this.$btnOK = null;

    }

    $.extend( AlertDialog.prototype, Dialog.prototype );

    $.extend( AlertDialog.prototype, {
        _setupDOM : function(){

            Dialog.prototype._setupDOM.call( this );

            this.$dialogBtnCon.html( '<span class="btn btn-ok">确定</span>');
            this.$btnOK = this.$dialogBtnCon.find('.btn-ok');
        },
        _setupEvent : function(){

            Dialog.prototype._setupEvent.call( this );

            if( this.$btnOK ){
                this.$btnOK.on( 'tap', this.ok.bind( this ) );
            }
        },
        ok : function(){
            if( typeof this.onOK === 'function' ){
                this.onOK();
            }
            this.hide();
        }
    } );

    var alertDialog;

    /**
     * 显示一个 alert  对话框
     * @param args {JSON}
     * @param args.content {String} 要显示的HTML字符串
     * @returns {boolean}
     */
    Dialog.alert = function( args ){
        if( ! alertDialog ){
            alertDialog = new AlertDialog();
        }
        if( alertDialog.isVisible() ){
            return false;
        }

        alertDialog.setContentHTML( args.content );
        alertDialog.show();
    };


    //////////////////////////////////  ConfirmDialog  单例 ///////
    function ConfirmDialog( args ){
        AlertDialog.call( this , args );

        this.onCancel = this.config.onCancel || null;
        this.$btnCancel = null;


    }

    $.extend( ConfirmDialog.prototype, AlertDialog.prototype );

    $.extend( ConfirmDialog.prototype, {
        _setupDOM : function(){

            AlertDialog.prototype._setupDOM.call( this );

            this.$btnCancel = $('<span class="btn btn-cancel">取消</span>');
            this.$btnOK.before( this.$btnCancel );
        },
        _setupEvent : function(){
            AlertDialog.prototype._setupEvent.call( this );

            this.$btnCancel.on( 'tap', this.cancel.bind( this ) );
        },
        cancel : function(){
            if($.isFunction( this.onCancel ) ){
                this.onCancel();
            }
            this.hide();
        },
        maskClick : function(){
            this.cancel();
        }
    } );

    var confirmDialog;

    Dialog.confirm = function( args ){
        if( ! args ){
            return false;
        }
        if( ! confirmDialog ){
            confirmDialog = new ConfirmDialog({});
        }
        if( confirmDialog.isVisible() ){
            return false;
        }
        confirmDialog.onOK = args.onOK;
        confirmDialog.onCancel = args.onCancel;
        confirmDialog.setContentHTML( args.content );
        confirmDialog.show();

        return true;
    };


    /////////////////////////////////////

    window.Dialog = Dialog;


}( window );
