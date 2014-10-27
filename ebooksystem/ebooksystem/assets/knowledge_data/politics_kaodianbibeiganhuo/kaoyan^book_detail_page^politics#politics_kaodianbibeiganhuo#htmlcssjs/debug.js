/**
 * 这个JS，仅仅是为了在开发调试阶段使用，上线的时候，需要删除！！
 * Created by jess on 14-9-16.
 */


console.info( 'debug.js loaded');

var bridgeIOS = window.bridgeIOS || {};


//页面内部错误消息
bridgeIOS.pageError = function( msg ){
    alert( msg );
};

//用户点击页面的 “返回”
bridgeIOS.finish = function(){
    history.back();
};


//假数据map
var dataMap = {
    '000' : {
        subcolumn_arr : [
            {
                id : '100',
                name_ch : '马原',
                name_en : '',
                kaodian_num : '99',
                desc : '书籍描述'
            },
            {
                id : '101',
                name_ch : '毛特',
                name_en : '',
                kaodian_num : '3',
                desc : '书籍描述'
            },
            {
                id : '102',
                name_ch : '史纲',
                name_en : '',
                kaodian_num : '76',
                desc : '书籍描述'
            },
            {
                id : '103',
                name_ch : '思修',
                name_en : '',
                kaodian_num : '23',
                desc : '书籍描述'
            },
            {
                id : '104',
                name_ch : '当代',
                name_en : '',
                kaodian_num : '10',
                desc : '书籍描述'
            }
        ]
    },

    '200' : {
        id : '知识点ID',
        search_index : '123456',
        title : '世界的物质性及其发展规律',
        kaodian_name : '考点的名字考点的名字考点的名字考点的名字考点的名字考点的名字考点的名字考点的名字考点的名字考点的名字考点的名字考点的名字考点的名字考点的名字考点的名字考点的名字考点的名字考点的名字考点的名字考点的名字考点的名字',
        kaodian_explain : '考点的详细解析内容、测试多行的情况，可能还不够，这里应该差不多框有两行的高度了吧，再加几个字试试！！',
        kaodian_num : '3',
        //要渲染的练习页ID
        exercise_page_id : '500',
        //对应练习题的数据节点ID
        exercise_data_id : '500',

        //当前知识点所属书籍的ID
        book_id : '000',
        book_name_ch : '当前知识点所属书籍名',
        topic_name_ch : '马原 第三章',
        pre_sibling_id : '',
        next_sibling_id : '201'
    }
};
var knowledgeIndex = 0;
//通过 id 来获取该页面内需要显示的数据
bridgeIOS.getNodeDataById = function( id, callback ){

    var out = dataMap[id];

    if( ! out  ){
        if( id.indexOf('0') === 0 ){
            out = dataMap['000'];
        }else if( id.indexOf('2') === 0 ){

            out = dataMap['200'];
            out = JSON.stringify( out );
            out = JSON.parse( out );
            var index = knowledgeIndex++;
            out.title = out.title + '--' + index ;
            out.kaodian_name += '--' + index;
            out.kaodian_explain += '--' + index;

            var temp = parseInt( id, 10 );
            if( temp > 200 ){
                out.pre_sibling_id = temp - 1 + '';
            }
            if( temp < 206){
                out.next_sibling_id = temp + 1 + '';
            }else{
                out.next_sibling_id = '';
            }
            dataMap[id] = out;
        }

    }
    var searchConf = utils.getSearchConf();
    out.book_name_ch = searchConf.book_name_ch;
    out.topic_id = searchConf.topic_id;

    if( typeof callback === 'function' ){
        callback( JSON.stringify( out ) );
    }

    return JSON.stringify( out );
};

//跳转到搜索页面
bridgeIOS.goSearchPage = function(){
    alert('进入搜索页面');
};

//点击了某个子节点ID，进入对应页面
bridgeIOS.showPageById = function( id, args ){
    var url = '../politics_exercise_page/index.html?' + args + '&debug=1' ;
    location.href = url;
};

//播放视频
bridgeIOS.playVideo = function(url){
    alert('播放视频：' + url );
};

//统计函数
bridgeIOS.pageStatistic = function( eventName, jsonArgsStr ){
    var json = JSON.parse( jsonArgsStr );
    console.info( '点击统计参数: ' + eventName, json );
};