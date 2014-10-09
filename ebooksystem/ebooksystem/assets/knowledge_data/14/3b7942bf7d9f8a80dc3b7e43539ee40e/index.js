!function(){
	    // native暴露给JS的接口对象
	    var bridge = (window.bridgeIOS ? window.bridgeIOS : window.bridgeAndroid);
	    
	    
	    window.app = window.app || {};
	    
	    //当前渲染页面对应的ID，通过ID来找到该页面内要显示的数据
	    var currentID = '';
	    
	    //政治书籍列表页的统计事件名
	    var eventName = 'politics_book_list';
	    //当前正在下载中的书籍ID数组
	    var downloadingIDArray = [];
	    //轮训获取下载进度的计时器
	    var downloadProgressTimer;
	    //书籍正在下载中的class
	    var bookDownloadingClass = 'book-downloading';
	    //最大下载错误个数
	    var MAX_PROGRESS_NUM = 10;
	    //节点已经下载到APP本地了
	    var NODE_HAS_DOWNLOADED = "1";
	    //夜间模式的 class
	    var pageDisplayMode = 'page-mode-night';
	    
	    
	    // 渲染书籍列表
	    var renderChildList = function(data) {
	    	var bookListEl = document.querySelector('#book-list-con');

	    	try{
	    		data = JSON.parse( data );
	    	}catch(e){
	    		bridge.pageError( '数据出错！');
	    		return;
	    	}

	    	data = data.book_arr;

	    	var html = '';

	    	data.forEach( function( item, index ){

	    		var isOnline = item.is_online === '1';
	    		var extraClass = '';
	    		if( ! isOnline ){
	    			extraClass = ' book-item-not-ready ';
	    		}

	    		html += '<div class="book-item common-hoverable-item common-split-border ' + extraClass + '" ' +
	    		' data-is_online="' + item.is_online + '" ' +
	    		' data-update_id="' + item.update_id + '" ' +
	    		' data-page_id="' + item.page_id + '" ' +
	    		'data-data_id="' + item.id + '" data-name_ch="' + item.name_ch + '">' +
	    		'<img src="./assets/' + item.book_cover + '.png" />' +
	    		'<div class="book-name-wrap">' + item.name_ch + '</div>' +
	    		'<div class="download-mask">' +
	    		'<div class="download-progress">' +
	    		'<span class="download-progress-inner"></span>' +
	    		'<div class=" download-progress-text"></div>' +
	    		'</div></div>' +
	    		'</div>';
	    	});

	    	bookListEl.innerHTML = html;

	        // 绑定书籍点击事件
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
 	                var bookName = target.getAttribute('data-name_ch');

 	                var args = {
 	                    //政治科目根节点的ID
 	                    subject_id : encodeURIComponent( currentID ),
 	                    //渲染该节点所需要 data.json 的节点ID
 	                    data_id : encodeURIComponent( id ),
 	                    //用户选择书籍对应节点的ID
 	                    book_id : encodeURIComponent( id ),
 	                    //用户选择书籍的中文名
 	                    book_name_ch : encodeURIComponent( bookName )
 	                };
 	                args = utils.json2Query( args );

 	                bridge.hasNodeDownloaded(pageID, function(out) {
 	                	if( out == NODE_HAS_DOWNLOADED ){
 	                		var postArgsStr = '{}';
 	                		bridge.showPageById( pageID, args, postArgsStr );
 	                		return;
 	                	}
 	                	else if( out !== NODE_HAS_DOWNLOADED ){
 	                		var currentDownloadEl = bookListEl.querySelectorAll('.' + bookDownloadingClass);
 	                		if( currentDownloadEl.length > 0 ){
 	                			alert('请等待当前书籍下载完成:)');
 	                			return;
 	                		}

 	                        // 该书籍还没有下载到APP本地，尝试下载
 	                        bridge.tryDownloadNodeById(updateID, bookName, function(isDownloading) {
 	                        	if( isDownloading === '1' ){
 	                                //如果已经明确开始下载了，则显示下载进度
 	                                beginDownload( updateID, target, pageID, args );
 	                            }
 	                            return;
 	                        });

 						}});
                                         }

 }, false );
}

	    // 绑定搜索框点击事件
	    var searchBoxInited = false;
	    function initSearchBox(){
	    	if( searchBoxInited ){
	    		return;
	    	}
	    	searchBoxInited = true;
	    	var el = document.querySelector('.search-entrance-wrap');
	    	if( el ){
	    		el.addEventListener( 'touchend', function(){
	    			bridge.goSearchPage();
	    		}, false );
	    	}
	    }
	    
	    // 页面启动入口函数
	    app.run = function(){
	    	var searchConf = utils.getSearchConf();

	        //获取数据ID
	        currentID = searchConf.data_id;
	        if (!currentID){
	        	bridge.pageError('页面迷路了，找不到ID');
	        	return;
	        }
	        
	        document.documentElement.classList.add( pageDisplayMode);
	        utils.initPageHeader();
	        
	        initSearchBox();
	        
	        // 渲染页面
	        bridge.getNodeDataById(currentID, renderChildList);
	        
	        window.addEventListener('unload', function(e){
	        	console.info('book_list_page unload');
	        }, false);
	        
	        // 统计页面展现PV
	        var args = {
	        	type : 'pv'
	        };
	        args = JSON.stringify( args );
	        bridge.pageStatistic( eventName, args );
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
	    		progress : 0,
	                                //下载完之后，等待这么长的时间，再提示用户书籍准备完毕
	                                extraTime : 0
	                            } );
	    	if( ! downloadProgressTimer ){
	    		downloadProgressTimer = setTimeout( updateDownloadProgress, 1000 );
	    	}
	    	return true;
	    }
	    
	    function updateDownloadProgress(){
	    	var hasUnloaded = false;
	    	for( var i = 0; i < downloadingIDArray.length; ){
	    		var temp = downloadingIDArray[i];
	    		if( temp.loaded ){
	    			continue;
	    		}
	    		var el = temp.el;
	    		var loaded = bridgeAndroid.getDownloadProgress( temp.id );
	            //            if( ! utils.isString(loaded) && ! loaded ){
	            //                temp.error_num++;
	            //                if( temp.error_num >= MAX_PROGRESS_NUM ){
	            //                    console.error( '下载进度返回异常， 节点ID：' + temp.id + '; APP返回进度值： ' + loaded);
	            //                    el.classList.remove( bookDownloadingClass );
	            //                    downloadingIDArray.splice( i, 1 );
	            //                    continue;
	            //                }
	            //
	            //            }
	            i++;
	            temp.progress++;
	            temp.extraTime++;
	            loaded = parseInt( loaded, 10 ) || 0;
	            loaded = Math.max( loaded, temp.progress );
	            loaded = Math.min( loaded, 100 );
	            console.info( '书籍下载进度：' + loaded );
	            var progressBgEl = el.querySelector('.download-progress-inner');
	            var progressTextEl = el.querySelector('.download-progress-text');
	            if( temp.progress >= 100 ){
	            	if( temp.extraTime < 120 ){
	            		progressTextEl.innerHTML = '正在解析' + new String('...').substr(0, temp.extraTime % 4);
	            		hasUnloaded = true;
	            	}else{
	            		el.classList.remove( bookDownloadingClass );
	            		temp.loaded = true;
	            	}

	            }else if( loaded ){
	            	temp.progress = loaded;
	            	progressBgEl.style.width = loaded + '%';

	                //是否下载完成
	                if( loaded === 100 ){
	                	progressTextEl.innerHTML = '正在解析';
	                }else{
	                	progressTextEl.innerHTML = loaded + '%';
	                }
	                hasUnloaded = true;
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


	!function(){

	//    //native暴露给JS的接口对象
	//    var bridgeAndroid = window.bridgeAndroid;
	//    
	//    window.app = window.app || {};
	//    
	//    //当前渲染页面对应的ID，通过ID来找到该页面内要显示的数据
	//    var currentID = '';
	//    
	//    //政治书籍列表页的统计事件名
	//    var eventName = 'politics_book_list';
	//    //当前正在下载中的书籍ID数组
	//    var downloadingIDArray = [];
	//    //轮训获取下载进度的计时器
	//    var downloadProgressTimer;
	//    //书籍正在下载中的class
	//    var bookDownloadingClass = 'book-downloading';
	//    //最大下载错误个数
	//    var MAX_PROGRESS_NUM = 10;
	//    //节点已经下载到APP本地了
	//    var NODE_HAS_DOWNLOADED = "1";
	//    //夜间模式的 class
	//    var pageDisplayMode = 'page-mode-night';


	//    //渲染书籍列表
	//    function renderChildList(){
	//        var bookListEl = document.querySelector('#book-list-con');
	//        
	//    var data = bridgeAndroid.getNodeDataById( currentID );
	//        
	//
	//
	//        try{
	//            data = JSON.parse( data );
	//        }catch(e){
	//            bridgeAndroid.pageError( '数据出错！');
	//            return;
	//        }
	//        
	//        data = data.book_arr;
	//        
	//        var html = '';
	//        
	//        data.forEach( function( item, index ){
	//                     
	//                     var isOnline = item.is_online === '1';
	//                     var extraClass = '';
	//                     if( ! isOnline ){
	//                     extraClass = ' book-item-not-ready ';
	//                     }
	//                     
	//                     html += '<div class="book-item common-hoverable-item common-split-border ' + extraClass + '" ' +
	//                     ' data-is_online="' + item.is_online + '" ' +
	//                     ' data-update_id="' + item.update_id + '" ' +
	//                     ' data-page_id="' + item.page_id + '" ' +
	//                     'data-data_id="' + item.id + '" data-name_ch="' + item.name_ch + '">' +
	//                     '<img src="./assets/' + item.book_cover + '.png" />' +
	//                     '<div class="book-name-wrap">' + item.name_ch + '</div>' +
	//                     '<div class="download-mask">' +
	//                     '<div class="download-progress">' +
	//                     '<span class="download-progress-inner"></span>' +
	//                     '<div class=" download-progress-text"></div>' +
	//                     '</div></div>' +
	//                     '</div>';
	//                     });
	//        
	//        bookListEl.innerHTML = html;
	//        
	//        //绑定书籍点击事件
	//        bookListEl.addEventListener( 'click', function(e){
	//                                    e.preventDefault();
	//                                    var target  = e.target;
	//                                    while( target && target != bookListEl && ! target.classList.contains( 'book-item') ){
	//                                    target = target.parentNode;
	//                                    }
	//                                    if( target && target != bookListEl && target.classList.contains('book-item') ){
	//                                    if( target.classList.contains(bookDownloadingClass) ){
	//                                    //该书籍正在下载
	//                                    return;
	//                                    }
	//                                    var isOnline = target.getAttribute('data-is_online');
	//                                    if( isOnline !== '1' ){
	//                                    //书籍未上线
	//                                    target.blur();
	//                                    return;
	//                                    }
	//                                    
	//                                    var updateID = target.getAttribute('data-update_id');
	//                                    var pageID = target.getAttribute('data-page_id');
	//                                    var id = target.getAttribute('data-data_id');
	//                                    var bookName = target.getAttribute('data-name_ch');
	//                                    
	//                                    var args = {
	//                                    //政治科目根节点的ID
	//                                    subject_id : encodeURIComponent( currentID ),
	//                                    //渲染该节点所需要 data.json 的节点ID
	//                                    data_id : encodeURIComponent( id ),
	//                                    //用户选择书籍对应节点的ID
	//                                    book_id : encodeURIComponent( id ),
	//                                    //用户选择书籍的中文名
	//                                    book_name_ch : encodeURIComponent( bookName )
	//                                    };
	//                                    args = utils.json2Query( args );
	//                                    var out = bridgeAndroid.hasNodeDownloaded( pageID );
	//                                    if( out !== NODE_HAS_DOWNLOADED ){
	//                                    var currentDownloadEl = bookListEl.querySelectorAll('.' + bookDownloadingClass );
	//                                    if( currentDownloadEl.length > 0 ){
	//                                    alert('请等待当前书籍下载完成:)');
	//                                    return;
	//                                    }
	//                                    //该书籍还没有下载到APP本地，尝试下载
	//                                    var isDownloading = bridgeAndroid.tryDownloadNodeById( updateID, bookName );
	//                                    if( isDownloading === '1' ){
	//                                    //如果已经明确开始下载了，则显示下载进度
	//                                    beginDownload( updateID, target, pageID, args );
	//                                    }
	//                                    return;
	//                                    }
	//                                    var postArgsStr = '{}';
	//                                    bridgeAndroid.showPageById( pageID, args, postArgsStr );
	//                                    }
	//                                    
	//                                    }, false );
	//    }

	//    //绑定搜索框点击事件
	//    var searchBoxInited = false;
	//    function initSearchBox(){
	//        if( searchBoxInited ){
	//            return;
	//        }
	//        searchBoxInited = true;
	//        var el = document.querySelector('.search-entrance-wrap');
	//        if( el ){
	//            el.addEventListener( 'touchend', function(){
	//                                bridgeAndroid.goSearchPage();
	//                                }, false );
	//        }
	//    }


	//    //页面启动入口函数
	//    app.run = function(){
	//        
	//        var searchConf = utils.getSearchConf();
	//        
	//        //获取数据ID
	//        currentID = searchConf.data_id;
	//        
	//        if( ! currentID ){
	//            bridgeAndroid.pageError('页面迷路了，找不到ID');
	//            return;
	//        }
	//        
	//        document.documentElement.classList.add( pageDisplayMode);
	//        utils.initPageHeader();
	//        
	//        initSearchBox();
	//        
	//        renderChildList();
	//        
	//        window.addEventListener('unload', function(e){
	//                                console.info('book_list_page unload');
	//                                }, false);
	//        
	//        //统计页面展现PV
	//        var args = {
	//            type : 'pv'
	//        };
	//        args = JSON.stringify( args );
	//        bridgeAndroid.pageStatistic( eventName, args );
	//    };

	//    function beginDownload(id, el, pageID, getArgs, postArgs){
	//        var found = false;
	//        for( var i = 0, len = downloadingIDArray.length; i < len; i++ ){
	//            var temp = downloadingIDArray[i];
	//            if( temp.id === id ){
	//                found = true;
	//                break;
	//            }
	//        }
	//        if( found ){
	//            return false;
	//        }
	//        el.classList.add( bookDownloadingClass );
	//        downloadingIDArray.push( {
	//                                id : id,
	//                                el : el,
	//                                page_id : pageID,
	//                                get_args : getArgs,
	//                                post_args : ( postArgs || '{}' ),
	//                                error_num : 0,
	//                                progress : 0,
	//                                //下载完之后，等待这么长的时间，再提示用户书籍准备完毕
	//                                extraTime : 0
	//                                } );
	//        if( ! downloadProgressTimer ){
	//            downloadProgressTimer = setTimeout( updateDownloadProgress, 1000 );
	//        }
	//        return true;
	//    }
	//    function updateDownloadProgress(){
	//        var hasUnloaded = false;
	//        for( var i = 0; i < downloadingIDArray.length; ){
	//            var temp = downloadingIDArray[i];
	//            if( temp.loaded ){
	//                continue;
	//            }
	//            var el = temp.el;
	//            var loaded = bridgeAndroid.getDownloadProgress( temp.id );
	//            //            if( ! utils.isString(loaded) && ! loaded ){
	//            //                temp.error_num++;
	//            //                if( temp.error_num >= MAX_PROGRESS_NUM ){
	//            //                    console.error( '下载进度返回异常， 节点ID：' + temp.id + '; APP返回进度值： ' + loaded);
	//            //                    el.classList.remove( bookDownloadingClass );
	//            //                    downloadingIDArray.splice( i, 1 );
	//            //                    continue;
	//            //                }
	//            //
	//            //            }
	//            i++;
	//            temp.progress++;
	//            temp.extraTime++;
	//            loaded = parseInt( loaded, 10 ) || 0;
	//            loaded = Math.max( loaded, temp.progress );
	//            loaded = Math.min( loaded, 100 );
	//            console.info( '书籍下载进度：' + loaded );
	//            var progressBgEl = el.querySelector('.download-progress-inner');
	//            var progressTextEl = el.querySelector('.download-progress-text');
	//            if( temp.progress >= 100 ){
	//                if( temp.extraTime < 120 ){
	//                    progressTextEl.innerHTML = '正在解析' + new String('...').substr(0, temp.extraTime % 4);
	//                    hasUnloaded = true;
	//                }else{
	//                    el.classList.remove( bookDownloadingClass );
	//                    temp.loaded = true;
	//                }
	//                
	//            }else if( loaded ){
	//                temp.progress = loaded;
	//                progressBgEl.style.width = loaded + '%';
	//                
	//                //是否下载完成
	//                if( loaded === 100 ){
	//                    progressTextEl.innerHTML = '正在解析';
	//                }else{
	//                    progressTextEl.innerHTML = loaded + '%';
	//                }
	//                hasUnloaded = true;
	//            }else{
	//                hasUnloaded = true;
	//            }
	//            
	//        }
	//        
	//        if( ! hasUnloaded ){
	//            //所有书籍都下载完成，停止轮训
	//            clearTimeout( downloadProgressTimer );
	//            downloadProgressTimer = null;
	//            downloadingIDArray = [];
	//        }else{
	//            downloadProgressTimer = setTimeout( updateDownloadProgress, 500 );
	//        }
	//    }

}();




