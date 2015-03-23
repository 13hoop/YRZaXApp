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
        //下载失败
        DOWNLOAD_FAIL : '下载失败',
        //解压中
        EXTRACTING : '解压中',
        //本次解压失败
        EXTRACT_FAIL : '解压失败',
        //校验中
        INVALIDATING : '校验中',
        //校验失败
        INVALIDATE_FAIL : '校验失败',
        //应用中
        APPLYING : '应用中',
        //应用失败
        APPLY_FAIL : '应用失败',

//以下两个状态，不在一本书的正常下载流程中，需要从  book_avail 字段中读取
        //书籍已经下线到本地，可以正常打开
        BOOK_AVAILABLE : '1',
        //本地没有书籍数据，需要下载
        BOOK_NOT_AVAILABLE : '0'
    };
//书籍更新的相关状态
    var bookUpdateStatus = {
        //无更新
        BOOK_NO_UPDATE : '无更新',
        //书籍有更新
        BOOK_NEED_UPDATE : '有更新',
        //书籍有更新，当时当前APP版本太低，已经不能下载最新的书籍数据
        APP_TOO_LOW : '有更新但APP版本过低',
        //APP更新太快，书籍内容不能在当前APP上run起来
        APP_TOO_HIGH : '有更新APP版本过高'
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
        BOOK_UPDATE_STATUS : bookUpdateStatus,

        SERVER : {
            HOST : 'www.zaxue100.com'
        },
        NETWORK_TYPE : networkType,
        //白天、夜间模式的key
        RENDER_MODE : 'render-mode'
    };

    window.samaConfig = singleton;

}( window );
