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
        title : '马原1：世界的物质统一性原理及其意义. 世界物质统一性原理是马克思主义关于世界本质问题的一个基本原理',
        desc : '世界物质统一性原理是马克思主义关于世界本质问题的一个基本原理。这一原理的内容包括：其一，世界是统一的，即世界的本原是一个；其二，世界的统一性在于它的物质性，即世界统一的基础是物质，而不是某种“始基”的物体；其三，物质世界的统一性是多样性的统一，而不是单一的无差别的统一。马克思主义关于世界物质统一性原理具有重大的理论意义和实践意义。其理论意义在于，它是马克思主义哲学的基石，马克思主义哲学的一系列原理和原则都是以此为根据和前提的，从而成为彻底的唯物主义一元论的世界观。其实践意义在于，它是我们从事一切工作的立足点，是一切从实际出发的思想路线的哲学基础。',
        mingti_xingshi : '这里显示的是  命题形式  ，但木有数据，只能搞点假的文字在这里，见谅！！！',
        mingti_jiaodu : '世界物质统一性是从追根溯源的意义上来说的。该考点的命题角度非常单一，只有当材料中出现“本原”、“始基”、“万物……”这样的词句时，才适用该考点。',
        analysis : '所谓“本原”，是指万物由它产生，最后又复归于它。比如，如果说物质是世界的本原，就说明世界上的一切归根到底是由物质“生”的，最后又转化为别的“物质”。如果是上帝创造的，则最后回到上帝那里去。',
        weike_url : 'http://s-115744.gotocdn.com:8096/video/fukua.mp4',
        exercise : [],

        //当前知识点所属书籍的ID
        book_id : '000',
        pre_sibling_id : '',
        next_sibling_id : '201'
    }
};
var knowledgeIndex = 0;
//通过 id 来获取该页面内需要显示的数据
bridgeIOS.getNodeDataByIdAndQueryId = function( args, callback ){

    var id = args.dataId;

    var out = {};

    var arr = [];

    var exerciseNum = 9;

    for( var i = 0; i < exerciseNum; i++ ){
        var question = '题干-世界物质统一性原理是马克思主义关于世界本质问题的一个基本原理。这一原理的内容包括：其一，世界是统一的，即世界的本原是一个；其二，世界的统一性在于它的物质性，即世界统一的基础是物质，而不是某种“始基”的物体；其三，物质世界的统一性是多样性的统一，而不是单一的无差别的统一。马克思主义关于世界物质统一性原理具有重大的理论意义和实践意义。其理论意义在于，它是马克思主义哲学的基石，马克思主义哲学的一系列原理和原则都是以此为根据和前提的，从而成为彻底的唯物主义一元论的世界观。其实践意义在于，它是我们从事一切工作的立足点，是一切从实际出发的思想路线的哲学基础。'
            + ( i + 1 );
        var answers = i % 2 === 0 ? [ 'A'] : [ 'A', 'C'];
        var analysis = '题目解析-所谓“本原”，是指万物由它产生，最后又复归于它。比如，如果说物质是世界的本原，就说明世界上的一切归根到底是由物质“生”的，最后又转化为别的“物质”。如果是上帝创造的，则最后回到上帝那里去。-' + ( i + 1 );
        var options = [
            '这里显示选项 A 对应的内容',
            '有可能一个选项跨域多行的情况，试试看，多行显示O不O。再加几个字，免得不够多行。。。。',
            'xxxxxxx',
            '最后一个选项，老命了！！！这里来个两行的试试效果，看是神马情况'
        ];

        arr.push({
            question : question,
            answers : answers,
            analysis : analysis,
            options : options
        });
    }

    out.data = arr;
    //out.index = '9';

    if( typeof callback === 'function' ){
        callback( JSON.stringify(out) );
    }

    return JSON.stringify( out );
};

//跳转到搜索页面
bridgeIOS.goSearchPage = function(){
    alert('进入搜索页面');
};

//点击了某个子节点ID，进入对应页面
bridgeIOS.showPageById = function( id, args ){
    alert( '点击了ID： ' + id + ' ; 参数： ' + args );
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

bridgeIOS.canFixedHeightBoxScroll = function(){
    return "1";
};