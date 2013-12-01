// updates the visibility of the end-date section accordiong to the mode menu (id="uc_mode")
// relays on setVisibility in application.js
function updateVisibility() {
	// what is the mode of the contract?
	var modeMenu = document.getElementById("uc_mode");
	if ( modeMenu == null ) {
		alert( "update_visibility: Can't get mode menu" );
		return; 
	}
	
	var mode = modeMenu.value;

	if ( mode == 0 ) {
		setVisibility( "date_finish", true );		
	} else  {
		setVisibility( "date_finish", false );
	}
}