/**
 * 预定义的常量
 * Created by jess on 15/1/16.
 */



! function( window ){

    //一本书的状态
    var bookStatus = {
        //书籍已经下载，可以离线使用
        BOOK_READY : '完成',
        //书籍未下载
        BOOK_NOT_DOWNLOAD : '未下载',
        //书籍正在下载中
        BOOK_IS_DOWNLOADING : '下载中',
        //书籍上一次下载过程被异常中断，需要自动重新启动下载进程
        LAST_DOWNLOAD_INTERRUPTED : '下载暂停',
        //本次下载失败
        DOWNLOAD_FAIL : '下载失败',
        //书籍有更新
        BOOK_NEED_UPDATE : '可更新',
        //书籍正在更新中
        BOOK_IS_UPDATING : '更新中',
        //书籍有更新，当时当前APP版本太低，已经不能下载最新的书籍数据
        APP_TOO_LOW : 'APP版本过低',
        //APP更新太快，书籍内容不能在当前APP上run起来
        APP_TOO_HIGH : 'APP版本过高'
    };

    var networkType = {
        WIFI : 'wifi',
        '3G' : '3g',
        '2G' : '2g',
        'WAP' : 'wap',
        'OFFLINE' : 'offline'
    };

    var singleton = {
        BOOK_STATUS : bookStatus,
        SERVER : {
            HOST : 'test.zaxue100.com'
        },
        NETWORK_TYPE : networkType
    };

    window.samaConfig = singleton;

}( window );
