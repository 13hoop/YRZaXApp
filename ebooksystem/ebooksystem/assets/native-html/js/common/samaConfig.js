/**
 * 预定义的常量
 * Created by jess on 15/1/16.
 */



! function( window ){

    //一本书的状态
    var bookStatus = {
        //书籍已经下载，可以离线使用
        BOOK_READY : '0',
        //书籍未下载
        BOOK_NOT_DOWNLOAD : '1',
        //书籍正在下载中
        BOOK_IS_DOWNLOADING : '2',
        //书籍有更新
        BOOK_NEED_UPDATE : '3',
        //书籍正在更新中
        BOOK_IS_UPDATING : '4',
        //书籍有更新，当时当前APP版本太低，已经不能下载最新的书籍数据
        APP_TOO_LOW : '5',
        //APP更新太快，书籍内容不能在当前APP上run起来
        APP_TOO_HIGH : '6'
    };

    var singleton = {
        BOOK_STATUS : bookStatus
    };

    window.samaConfig = singleton;

}( window );
