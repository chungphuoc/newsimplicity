// (c) Copyright 2006 Michael Bar-Sinai (Vaadnet.com). All Rights Reserved. 

var displayModes = Array(); // the correct display property of the style of the elements, _when_they_are_visible._
var isVisible    = Array(); // the known visibility state of elements

function toggleCheckBox( id ) {

	var emt = $(id);
	//var emt = document.getElementById( id );
	
	if (emt == null ) {
		alert( id + " is null.");
		return;
	}
	
	if ( emt.checked == true ) {
		emt.checked = false;
	} else {
		emt.checked = true;
	}
	
	// speciality code for FireFox. God knows why this is needed.
	if ( isFF() ) {
		if ( emt.checked == true ) {
			emt.checked = false;
		} else {
			emt.checked = true;
		}
	}	
}

function toggleVisibility( id ) {
	
	var emt = document.getElementById( id );
	
	if ( emt == null ) {
		alert( id + " is null.");
		return;
	}
	
	// if we don't have any info about the visibility of the element, use heuristics.
	if ( isVisible[id] == null ) {
		if ( (emt.style.display == "none") ||
		 	 (emt.className.indexOf("hidden") != -1) ) {
			isVisible[id] = false;
		} else {
			isVisible[id] = true;
		}
	}
	
//	alert( "isVisible:" + isVisible[id] );
	// establish next display mode
	var nextDisplay = ""
	if ( isVisible[id] ) {
		nextDisplay = "none";
		isVisible[id] = false;
	} else {
		if ( displayModes[id] == null ) {
			// heuristic of new display mode
 			if ( emt.tagName == "TR" ) {
				displayModes[id] = isIE() ? "block" : "table-row";
			} else {
				displayModes[id] = "block";
			}
		}
		nextDisplay = displayModes[id];
		isVisible[id] = true;
	}
//	alert( "nextDisplay: " + nextDisplay );
	
	emt.style.display = nextDisplay;
}

function setVisibility( id, isVisible ) {
	// TODO replace with prorotype code
	var emt = document.getElementById( id );
	
	if ( emt == null ) {
		alert( "setVisibility: " + id + " is null.");
		return;
	}
	
	if ( isVisible ) {
		// heuristic of new display mode
		if ( emt.tagName == "TR" ) {
			emt.style.display = isIE() ? "block" : "table-row";
		} else {
			emt.style.display = "block";
		}
	} else {
		emt.style.display = "none";
	}
}

function popWindow(url) {
	newwindow = window.open(url,'popupWindow','height=400,width=400');
	if (window.focus) {newwindow.focus();}
}

function popResizableWindow(url) {
	newwindow = window.open(url,'popupWindow','height=400,width=400,scrollbars=yes, resizeable=yes');
	if (window.focus) {newwindow.focus();}
}

function nowText() {
	var d = new Date();
	mts = d.getMinutes();
	if ( mts<10 ) {
		mts = "0" + mts;
	} else {
		mts = "" + mts;
	}
	outStr = d.getDate() + "/" + (d.getMonth()+1) + "/" + d.getFullYear() + " " + d.getHours() + ":" + mts;
	
	return outStr;
}

function updateElement( emtID, text ) {
	var emt = document.getElementById( emtID );
	
	if (emt == null ) {
		alert( id + " is null.");
		return;
	}
	
	emt.innerHTML = text;
}

function navigateTo( url ) {
	document.location.href = url;
}

function isIE() {
	return ( navigator.userAgent.indexOf( "MSIE" ) != -1 );
}

function isFF() {
	return ( (navigator.userAgent.indexOf( "Fire" ) != -1) || navigator.userAgent.indexOf( "Camino" ) != -1 );
}
