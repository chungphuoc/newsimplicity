function selectTab( tabpanelId, tabId ) {
	var tabpanel = document.getElementById( tabpanelId );
	if ( tabpanel == null ) {
		alert( tabpanel + " doesn't exist.");
		return;
	}
	
	var tabs = tabpanel.getElementsByTagName("th");

	for ( t = 0; t<tabs.length; t++ ) {		
		if ( tabs[t].className == "spacer" ) continue;
		
		if ( tabs[t].id == tabId+"_tab" ) {
			tabs[t].className="selected";
		} else {
			tabs[t].className="";
		}
	}
	var cid = tabpanelId + "_contents";
	var contentsTD = document.getElementById(cid);
	var panels = contentsTD.getElementsByTagName("div");
	
	for ( t = 0; t<panels.length; t++ ) {		
		if ( panels[t].id == tabId+"_div" ) {
			panels[t].style.display="block";
		} else {
			panels[t].style.display="none";
		}
	}
	
	var value = document.getElementById( tabpanelId + "_value" );
	value.value = tabId;
	
}

function getElementsByClass(node,searchClass,tag) {
	 var classElements = new Array();
	 var els = node.getElementsByTagName(tag);
	 var elsLen = els.length;
	 var pattern = new RegExp("\b"+searchClass+"\b");
	 for (i = 0, j = 0; i < elsLen; i++) {
	   	if ( pattern.test(els[i].className) ) {
	     	classElements[j] = els[i];
	     	j++;
	   	}
	 }
	return classElements;
}