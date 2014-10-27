
!function(){

    // native暴露给JS的接口对象
    var bridge = (window.bridgeIOS ? window.bridgeIOS : window.bridgeIOS);    

    window.app = window.app || {};

//当前渲染页面对应的ID，通过ID来找到该页面内要显示的数据
    var currentID = '';

//政治书籍列表页的统计事件名
    var eventName = 'politics_book_list';
    //当前正在下载中的书籍ID数组
    var downloadingIDArray = [];
    //轮训获取下载进度的计时器
    var downloadProgressTimer;
    //书籍还没下载
    var bookCanDownload = 'book-can-download';
    //书籍正在下载中的class
    var bookDownloadingClass = 'book-downloading';
    //书籍完全就绪
    var bookCanRead = 'book-can-read';
    //最大下载错误个数
    var MAX_PROGRESS_NUM = 10;
    //节点已经下载到APP本地了
    var DATA_STATUS_AVAIL = "0";
    //夜间模式的 class
    var pageDisplayMode = 'page-mode-night';
    //政治搜索入口页面的page_id
    var searchPageID = '08713289f9a7eb4edf10e80b44fe3c1b';

//渲染书籍列表
    function renderChildList( data, bookStatusMap ){
        var bookListEl = document.querySelector('#book-list-con');

        var html = '';
        var downloadArr = [];       //当前正在下载、解压中的书籍ID数组
        var updateID = null;

        data.forEach( function( item, index ){

            var isOnline = item.is_online === '1';
            var extraClass = '';
            if( ! isOnline ){
                extraClass = ' book-item-not-ready ';
            }
            var elemID = 'book-item-' + index;

            // var bookStatusStr = bookStatusMap[item.update_id];
            // var statusArray = bookStatusStr.split('##');

            // var bookStatus = statusArray[0];
            // var bookStatusDesc = statusArray[1];
            //IOS上，政治所有书籍都放在APP内，全部默认就是可用的
            var bookStatus = DATA_STATUS_AVAIL;

            var downloadProgress = -1;
            var unzipProgress = -1;

            switch (bookStatus){
                case  '-1' :
                    extraClass += ' ' + bookCanDownload;
                    break;
                case '1' :
                    extraClass += ' ' + bookDownloadingClass;
                    downloadProgress = 0;
                    downloadArr.push( elemID );
                    updateID = item.update_id;
                    break;
                case '2' :
                    extraClass += ' ' + bookDownloadingClass;
                    unzipProgress = 0;
                    downloadArr.push( elemID );
                    break;
                case DATA_STATUS_AVAIL :
                    extraClass += '  ' + bookCanRead;
                    break;

            }

            html += '<div class="book-item common-hoverable-item common-split-border ' + extraClass + '" ' +
                ' data-is_online="' + item.is_online + '" ' +
                ' data-update_id="' + item.update_id + '" ' +
                ' data-file_size="' + ( item.file_size || 2 ) + '" ' +
                ' data-page_id="' + item.page_id + '" ' +
                'data-data_id="' + item.id + '" ' + 
                'data-query_id="' + item.query_id + '" ' + 
                '" data-name_ch="' + item.name_ch + '" id="' + elemID + '">' +
                '<img src="./assets/' + item.book_cover + '.png" />' +
                '<div class="update-indicator-wrap"><span class="update-indicator-text">新</span></div>' +
                '<div class="book-name-wrap">' + item.name_ch  + '</div>' +
                '<div class="download-mask">' +
                '<div class="download-progress">' +
                '<span class="download-progress-inner"></span>' +
                '<div class=" download-progress-text"></div>' +
                '</div></div>' +
                '<div class="download-arrow"></div>' +
                '</div>';


        });

        bookListEl.innerHTML = html;

        //绑定书籍点击事件
        bookListEl.addEventListener( 'click', function(e){
            e.preventDefault();
            var target  = e.target;
            while( target && target != bookListEl && ! target.classList.contains( 'book-item') ){
                target = target.parentNode;
            }
            if( target && target != bookListEl && target.classList.contains('book-item') ){
                if( target.classList.contains(bookDownloadingClass) ){
                    //该书籍正在下载
                    return;
                }
                var isOnline = target.getAttribute('data-is_online');
                if( isOnline !== '1' ){
                    //书籍未上线
                    target.blur();
                    return;
                }

                var updateID = target.getAttribute('data-update_id');
                var pageID = target.getAttribute('data-page_id');
                var id = target.getAttribute('data-data_id');
                var queryID = target.getAttribute('data-query_id');
                var bookName = target.getAttribute('data-name_ch');

                var args = {
                    //政治科目根节点的ID
                    subject_id : encodeURIComponent( currentID ),
                    //渲染该节点所需要 data.json 的节点ID
                    data_id : encodeURIComponent( id ),
                    query_id : encodeURIComponent( queryID ), 
                    //用户选择书籍对应节点的ID
                    book_id : encodeURIComponent( id ),
                    //用户选择书籍的中文名
                    book_name_ch : encodeURIComponent( bookName )
                };
                args = utils.json2Query( args );
                // var out = bridgeIOS.hasNodeDownloaded( updateID );
                var out = DATA_STATUS_AVAIL;
                if( out !== DATA_STATUS_AVAIL ){
                    var currentDownloadEl = bookListEl.querySelectorAll('.' + bookDownloadingClass );
                    if( currentDownloadEl.length > 0 ){
                        alert('请等待当前书籍下载完成:)');
                        return;
                    }
                    var network = bridgeIOS.getNetworkType();
                    if( network === '0' ){
                        alert('当前没有网络，请打开网络');
                        return;
                    }
//                    var isUserLogin = bridgeIOS.isUserLogin();
//                    if( isUserLogin !== '1' ){
//                        bridgeIOS.toast('登录用户才能离线下载书籍哦', 'long');
//                        bridgeIOS.goLoginPage();
//                        return;
//                    }
                    if( network !== '4' ){
                        var fileSize = target.getAttribute('data-file_size');
                        if( ! fileSize ){
                            fileSize = '2';
                        }
                        //none wifi
                        var ret = window.confirm('即将下载 ' + fileSize + 'MB 的数据文件##您正在使用非Wi-Fi网络，将耗费相应的流量，是否继续下载？##继续##暂不下载');
                        if( ! ret ){
                            return ;
                        }
                    }

                    //该书籍还没有下载到APP本地，尝试下载
                    var isDownloading = bridgeIOS.tryDownloadNodeById( updateID, bookName );
                    if( isDownloading === '1' ){
                        //如果已经明确开始下载了，则显示下载进度
                        beginDownload( updateID, target, pageID, args );
                    }
                    return;
                }
                var postArgsStr = '{}';
                bridgeIOS.showPageById( pageID, args, postArgsStr );
            }

        }, false );

        if( updateID ){
            bridgeIOS.tryDownloadNodeById( updateID, '' );
        }
        setTimeout( function(){
            recoverProgress(downloadArr);
        }, 15 );
    }

//绑定搜索框点击事件
    var searchBoxInited = false;
    function initSearchBox(){
        if( searchBoxInited ){
            return;
        }
        searchBoxInited = true;
        var el = document.querySelector('.search-entrance-wrap');
        if( el ){
            el.addEventListener( 'touchend', function(){
                bridgeIOS.showPageById( searchPageID, 'subject=politics', '{}' );
            }, false );
        }
    }


//页面启动入口函数
    app.run = function(){

        var searchConf = utils.getSearchConf();

        //获取数据ID
        currentID = '2a8ceed5e71a0ff16bafc9f082bceeec';
        var queryID = 'book_list';

        if( ! currentID ){
            bridgeIOS.pageError('页面迷路了，找不到ID');
            return;
        }

        document.documentElement.classList.add( pageDisplayMode);
        utils.initPageHeader();

        initSearchBox();

        // 渲染页面
        bridge.getNodeDataByIdAndQueryId( { dataId : currentID, queryId : queryID}, function( dataStr ){

            var data;
            try{
                data = JSON.parse( dataStr );
            }catch(e){
                data = null;
            }
            if( ! data ){
                alert('数据出错！');
                return;
            }
            var book_arr = data.book_arr;
            renderChildList( book_arr, {} );
            // var updateIDArr = [];
            // book_arr.forEach(function(item){
            //     updateIDArr.push( item.update_id );
            // });
            // var searchStr = updateIDArr.join('##');
            // bridge.getBookArrayStatus( searchStr, function( statusHash ){
            //     var origin = statusHash;
            //     try{
            //         statusHash = JSON.parse( statusHash );
            //     }catch(e){
            //         statusHash = null;
            //     }
            //     if( ! statusHash ){
            //         alert('获取书籍当前状态，解析出错');
            //         console.error( origin );
            //         return;
            //     }

            //     renderChildList( book_arr, statusHash );
            //     book_arr = null;
            //     statusHash = null;
            // } );
        } );

        window.addEventListener('unload', function(e){
            console.info('book_list_page unload');
        }, false);

        //统计页面展现PV
        var args = {
            type : 'pv'
        };
        args = JSON.stringify( args );
        bridgeIOS.pageStatistic( eventName, args );
    };
    //停止各种计时器
    app.stop = function(){
        if( downloadProgressTimer ){
            clearTimeout( downloadProgressTimer );
            downloadProgressTimer = null;
        }
    };

    function beginDownload(id, el, pageID, getArgs, postArgs){
        var found = false;
        for( var i = 0, len = downloadingIDArray.length; i < len; i++ ){
            var temp = downloadingIDArray[i];
            if( temp.id === id ){
                found = true;
                break;
            }
        }
        if( found ){
            return false;
        }
        el.classList.add( bookDownloadingClass );
        downloadingIDArray.push( {
            id : id,
            el : el,
            page_id : pageID,
            get_args : getArgs,
            post_args : ( postArgs || '{}' ),
            error_num : 0,
            //下载进度
            downloadProgress : 0,
            //解压进度
            analyzeProgress : 0,
            //解压前期比较慢，加上计数器，自动增加假的进度百分比，最大不超过10%
            analyzeCounter : 0,
            //下载完之后，等待这么长的时间，再提示用户书籍准备完毕
            extraTime : 0
        } );
        if( ! downloadProgressTimer ){
            clearTimeout( downloadProgressTimer );
            downloadProgressTimer = setTimeout( updateDownloadProgress, 1000 );
        }
        return true;
    }
    function recoverProgress( downloadingArr ){
        if( downloadingArr && downloadingArr.length > 0 ){
            clearTimeout( downloadProgressTimer );
            downloadingArr.forEach( function( domID ){
                var el = document.querySelector('#' + domID);
                if( el ){
                    var updateID = el.getAttribute('data-update_id');

                    downloadingIDArray.push({
                        id : updateID,
                        el : el,
                        downloadProgress:0,
                        analyzeProgress:0,
                        analyzeCounter : 0
                    });
                }
            });

            downloadProgressTimer = setTimeout( updateDownloadProgress, 500 );
        }
    }
    function updateDownloadProgress(){
        var hasUnloaded = false;
        for( var i = 0; i < downloadingIDArray.length; i++ ){
            var temp = downloadingIDArray[i];
            if( temp.loaded ){
                continue;
            }
            var el = temp.el;
            var progressBgEl = el.querySelector('.download-progress-inner');
            var progressTextEl = el.querySelector('.download-progress-text');
            if( temp.downloadProgress >= 100 ){
                //已经下载完了，当前在解压，获取解压进度
                var analyzeProgress = bridgeIOS.getAnalyzeProgress( temp.id );
                analyzeProgress = parseInt( analyzeProgress, 10 ) || 0;
                if( analyzeProgress < 10 && analyzeProgress <= temp.analyzeProgress ){
                    temp.analyzeCounter++;
                    if( temp.analyzeCounter >= 10 ){
                        temp.analyzeCounter = 0;
                        temp.analyzeProgress++;
                        temp.analyzeProgress = Math.min( temp.analyzeProgress, 10 );
                    }
                }
                analyzeProgress = Math.max( analyzeProgress, temp.analyzeProgress );
                analyzeProgress = Math.min( analyzeProgress, 100 );
                temp.analyzeProgress = analyzeProgress;
                console.info( '书籍解压进度：' + temp.analyzeProgress );
            }else{
                //当前正在下载，获取下载进度
                var loaded = bridgeIOS.getDownloadProgress( temp.id );
                loaded = parseInt( loaded, 10 ) || 0;
                if( loaded === 99 ){
                    var bookStatus = bridgeIOS.getBookStatus( temp.id );
                    if( bookStatus === '2' ){
                        loaded = 100;
                    }
                }
                loaded = Math.max( loaded, temp.downloadProgress );
                loaded = Math.min( loaded, 100 );
                temp.downloadProgress = loaded;
                progressBgEl.style.width = loaded + '%';
                progressTextEl.innerHTML = '下载进度：' + temp.downloadProgress + '%';
                console.info( '书籍下载进度：' + loaded );
            }

            if( temp.downloadProgress >= 100 ){

                if( temp.analyzeProgress <= 0 ){
                    var analyzeProgress = bridgeIOS.getAnalyzeProgress( temp.id );
                    analyzeProgress = parseInt( analyzeProgress, 10 ) || 0;
                    analyzeProgress = Math.max( analyzeProgress, temp.analyzeProgress );
                    analyzeProgress = Math.min( analyzeProgress, 100 );
                    temp.analyzeProgress = analyzeProgress;
                }

                if( temp.analyzeProgress < 100 ){
                    progressTextEl.innerHTML = '正在解压：' + temp.analyzeProgress + '%';
                    hasUnloaded = true;
                }else{
                    el.classList.remove( bookDownloadingClass );
                    el.classList.remove( bookCanDownload );
                    temp.loaded = true;
                }

            }else{
                hasUnloaded = true;
            }

        }

        if( ! hasUnloaded ){
            //所有书籍都下载完成，停止轮训
            clearTimeout( downloadProgressTimer );
            downloadProgressTimer = null;
            downloadingIDArray = [];
        }else{
            downloadProgressTimer = setTimeout( updateDownloadProgress, 500 );
        }
    }



}();
