/**
 * 负责管理、维护下载队列，更新下载进度
 * Created by jess on 15/1/19.
 */


! function( window ){

    'use strict';

    var utils = window.utils;
    var bridgeXXX = window.bridgeXXX;

    var singleton = {

        //检查书籍下载进度的频率
        delay : 1000,

        list : {},

        checkTimer : null,
        //是否主动停止检查
        stopped : false,

        downloadBook : function( bookView ){
            if( ! bookView || this.list[ bookView.getBookID() ] ){
                return;
            }
            bridgeXXX.startDownload( bookView.getBookID(), function(data){
                if( data === '1' ){
                    this.list[ bookView.getBookID() ] = bookView;
                }
                this.startCheck();
            }.bind( this ) );


        },

        addDownloadingBook : function( bookView ){
            if( ! bookView || this.list[ bookView.getBookID() ] ){
                return;
            }
            this.list[ bookView.getBookID() ] = bookView;
        },

        startCheck : function(){
            if( this.checkTimer ){
                return false;
            }
            this.stopped = false;
            this.checkTimer = window.setTimeout( this._doCheck.bind( this ), this.delay );
        },

        _doCheck : function(){
            var viewList = this.list;
            var idArray = [];
            for( var id in viewList ){
                if( id && viewList.hasOwnProperty(id) ){
                    idArray.push( id );
                }
            }

            if( idArray.length < 1 ){
                this.checkTimer = null;
                return;
            }

            bridgeXXX.queryBookStatus( idArray, this.handleDownloadResult.bind( this ) );
        },

        handleDownloadResult : function( infoArray ){

            this.checkTimer = null;

            if( ! utils.isArray(infoArray) ){
                try{
                    infoArray = JSON.parse( infoArray );
                }catch(e){
                    alert('获取下载进度失败！');
                    return;
                }
            }

            if( infoArray.length < 1 ){
                return;
            }

            var hasDownloading = false;
            var viewList = this.list;
            for( var i = 0, len = infoArray.length; i < len; i++ ){
                var info = infoArray[i];
                var bookID = info.book_id;
                if( ! bookID || ! viewList[bookID] ){
                    continue;
                }
                var bookView = viewList[bookID];
                bookView.setDownloadProgress( info );
                if( bookView.isBookStatusReady() || bookView.isBookFail() ){
                    try{
                        delete viewList[bookID];
                    }catch(e){

                    }
                    viewList[bookID] = null;
                }else{
                    hasDownloading = true;
                }
            }

            if( hasDownloading && ! this.stopped ){
                this.checkTimer = window.setTimeout( this._doCheck.bind( this ), this.delay );
            }
        },

        stop : function(){
            this.list = {};
            this.stopped = true;
            clearTimeout( this.checkTimer );
            this.checkTimer = null;
        }
    };




    window.downloadManager = singleton;

}( window );
