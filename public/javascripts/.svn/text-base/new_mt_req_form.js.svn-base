var currentVisiblePlaceDiv = null;
var currentVisibleAssigneeDiv = null;
var currentVisibleBusinessSelect = null;

// update the visibility if the controls depending on the building selected.
function updatePlaceVisibility() {
	if ( currentVisiblePlaceDiv == null ) {
		currentVisiblePlaceDiv = $('place_div_'+$('initial_visible_place_div').value + "_");
		currentVisibleAssigneeDiv = $('assignee_div_'+$('initial_visible_place_div').value);
		currentVisibleBusinessSelect = $('biz_select_'+$('initial_visible_place_div').value);
	}
	currentVisiblePlaceDiv.hide();
	currentVisibleAssigneeDiv.hide();
	currentVisibleBusinessSelect.hide();
	
	var building_id = $('mt_req_building_id').value;
	var business_id = $('biz_select_' + building_id ).value;
	if ( ! business_id.match(/^[0-9]+$/)) {
		business_id = "";
	}
	var placeDivId = 'place_div_' + building_id + '_' + business_id;
	placeDivId = placeDivId.strip();

	emt = $( placeDivId );
	emt.show();
	currentVisiblePlaceDiv = emt;
	
	emt = $('assignee_div_' + building_id );
	emt.show();
	currentVisibleAssigneeDiv = emt;
	
	emt = $('biz_select_' + building_id );
	emt.show();
	currentVisibleBusinessSelect = emt;
}