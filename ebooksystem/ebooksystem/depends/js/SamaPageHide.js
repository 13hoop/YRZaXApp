
! function(){
	var event;
	var eventName = 'SamaPageHide';

	if( window.Event ){
	       event = new Event( eventName );
	       document.dispatchEvent( event );      
	}else if( document.createEvent ){
	       event = document.createEvent('HTMLEvents');
	       event.initEvent( eventName, false, false  );
	       document.dispatchEvent( event );
	}
}();

