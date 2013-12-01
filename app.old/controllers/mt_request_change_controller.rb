class MtRequestChangeController < ApplicationController
include ApplicationHelper, NewMtReqFormModule

before_filter :get_mt_req;

def change_assignee
    @change.old_state_data = pp_assignee(@mt_req.assignee)
    @change.action_type = MaintenanceRequestHistoryItem::TYPE_ASSIGNEE_CHANGE;
    @mt_req.assignee = obj_from_unique_id(params[:mtreq_assignee]);
    
    @change.new_state_data = pp_assignee(@mt_req.assignee);
    
    save_and_return;
end

def change_title
    @change.old_state_data = @mt_req.title;
    @change.action_type = MaintenanceRequestHistoryItem::TYPE_TITLE_CHANGE;
    
    @mt_req.title = params[:mt_request_data][:title];
    
    @change.new_state_data = @mt_req.title;
    
    save_and_return;
end

def change_service_type
    @change.old_state_data = @mt_req.service_type.to_s
    @change.action_type = MaintenanceRequestHistoryItem::TYPE_SERVICE_TYPE_CHANGE;
   
    if ( ! params[:mt_request_data].nil? &&  ! params[:mt_request_data][:service_type].blank? )
       @mt_req.service_type = params[:mt_request_data][:service_type].to_i;
    end
    
    @change.new_state_data = @mt_req.service_type.to_s
    save_and_return;
    
end

def change_urgency
   @change.old_state_data = @mt_req.urgency.to_s;
   @change.action_type = MaintenanceRequestHistoryItem::TYPE_URGENCY_CHANGE;
   
   @mt_req.urgency = params[:mt_request_data][:urgency].to_i
   @change.new_state_data = @mt_req.urgency.to_s;
   
   save_and_return;
end

def change_body
   @change.old_state_data = @mt_req.body;
   @change.action_type = MaintenanceRequestHistoryItem::TYPE_BODY_CHANGE;
   @mt_req.body = params[:mt_request_data][:body];
   @change.new_state_data = @mt_req.body;
   save_and_return;
end

def change_state
   @change.old_state_data = @mt_req.state;
   @change.action_type = MaintenanceRequestHistoryItem::TYPE_STATE_CHANGE;
   @mt_req.state = params[:mt_request_data][:state].to_i;
   @change.new_state_data = @mt_req.state;
   save_and_return; 
end

def add_remark
   @change.action_type = MaintenanceRequestHistoryItem::TYPE_ADD_REMARK;
   save_and_return; 
end

def change_place
    @change.old_state_data = describe_place(@mt_req.place);
    @change.old_state_data += ", " + @mt_req.place_free_text unless @mt_req.place_free_text.blank?
    @change.action_type = MaintenanceRequestHistoryItem::TYPE_PLACE_CHANGE;
    
    if ( params[:place]=="-1")
        # try to use an existing place
        new_place = get_create_place( @mt_req.building, params[:other_place])
    else
        new_place = obj_from_unique_id( params[:place] );
    end
    @mt_req.place = new_place;
    @mt_req.place_free_text = params[:mt_request_data][:place_free_text].strip;
    
    @change.new_state_data = describe_place(@mt_req.place);
    @change.new_state_data += ", " + @mt_req.place_free_text unless @mt_req.place_free_text.blank?
    
    save_and_return;
end

def change_building
    @change.action_type = MaintenanceRequestHistoryItem::TYPE_BUILDING_CHANGE;
    if ( params[:mt_request_data][:building_id].blank? )
        new_bld = nil;
    else
        new_bld = Building.find( params[:mt_request_data][:building_id] );
    end
    @change.old_state_data = @mt_req.building.hr_address unless @mt_req.building.nil?
    @mt_req.building = new_bld;
    @mt_req.place = nil;
    @change.new_state_data = @mt_req.building.hr_address unless @mt_req.building.nil?
    
    save_and_return;
end

def add_cost_data
    @change.action_type = MaintenanceRequestHistoryItem::TYPE_ADD_COST_DATA;
    
    @change.new_state_data = describe_cost_data( params[:mt_request_data] );
    @mt_req.update_attributes( params[:mt_request_data] );
    
    save_and_return;
end

def change_hrs
    @change.action_type = MaintenanceRequestHistoryItem::TYPE_HOURS_OF_FIX_CHANGE;

    begin
        @change.old_state_data = @mt_req.hours_of_fix.to_s;
        @mt_req.hours_of_fix = params[:mt_request_data][:hours_of_fix].to_i;
        @change.new_state_data = @mt_req.hours_of_fix.to_s;
        save_and_return;
    rescue
       error_and_return "INVALID DATA"; 
    end

end

def change_pph
    @change.action_type = MaintenanceRequestHistoryItem::TYPE_PRICE_PER_HOUR_CHANGE;

    begin
        @change.old_state_data = @mt_req.price_per_hour.to_s;
        @mt_req.price_per_hour = params[:mt_request_data][:price_per_hour].to_i;
        @change.new_state_data = @mt_req.price_per_hour.to_s;
        save_and_return;
    rescue
       error_and_return "INVALID DATA"; 
    end

end

def change_pc
    @change.action_type = MaintenanceRequestHistoryItem::TYPE_PARTS_COST_CHANGE;

    begin
        @change.old_state_data = @mt_req.parts_cost_of_fix.to_s;
        @mt_req.parts_cost_of_fix = params[:mt_request_data][:parts_cost_of_fix].to_i;
        @change.new_state_data = @mt_req.parts_cost_of_fix.to_s;
        save_and_return;
    rescue
       error_and_return "INVALID DATA"; 
    end

end

def change_fx
    @change.action_type = MaintenanceRequestHistoryItem::TYPE_FIXED_PRICE_CHANGE;

    begin
        @change.old_state_data = @mt_req.fixed_price_of_fix.to_s;
        @mt_req.fixed_price_of_fix = params[:mt_request_data][:fixed_price_of_fix].to_i;
        @change.new_state_data = @mt_req.fixed_price_of_fix.to_s;
        save_and_return;
    rescue
       error_and_return "INVALID DATA"; 
    end
end

def add_files
    filenames = [];
    for file in params[:file]
        file = file.last;

        unless ( file[:file].blank? )
            uf = UploadedFile.new();
            if uf.init_from_file_field(file[:file])
                uf.title = file[:title] unless file[:title].blank?
                filenames << uf.title;
                uf.part_of = @mt_req;
                uf.uploader = current_user();
                uf.upload_date = Localization.localizer.now();
                if uf.save
                    uf.save_file( file[:file] )
                else
                    add_error "ERROR SAVING FILE";
                    return;
                end
            end
        end
    end
    @change.action_type = MaintenanceRequestHistoryItem::TYPE_ADD_FILES
    @change.new_state_data = filenames.join(", ");
    save_and_return;
    
end

def change_budget
    @change.action_type = MaintenanceRequestHistoryItem::TYPE_BUDGET_CHANGE;
    @change.old_state_data = @mt_req.budget_name
    @mt_req.budget_name = params[:mt_request_data][:budget_name].strip();
    @change.new_state_data = @mt_req.budget_name
    
    save_and_return
end

def remove_files
    @change.action_type = MaintenanceRequestHistoryItem::TYPE_REMOVE_FILES
    filenames = [];
    params[:file].each do |file_id| 
        uf = UploadedFile.find( file_id.first );
        filenames << uf.title
        uf.destroy
    end
    @change.new_state_data = filenames.join(", ");
    save_and_return;
end

# ====== [ privacy ] =======================================
private

# load the mt req into @mt_req, init @change
def get_mt_req  
    @mt_req = MaintenanceRequest.find(params[:id]);
    @change = MaintenanceRequestHistoryItem.new;
    @change.maintenance_request = @mt_req;
    @change.remarks = params[:remarks];
    @change.acting_user = current_user();
end

def save_and_return
    if ( @mt_req.save )
        @change.save;
        add_confirmation( "CHANGES SAVED SUCCESSFULY" );
    else
        add_errors_of( @mt_req )
    end
    redirect_to( HashMarshaler.unmarshal_hash(params[:origin]) ); 
end

def error_and_return( msg )
    add_error( msg );
    redirect_to( unmarshal_hash(params[:origin]) );
end

def describe_place( location )
    if location.kind_of? BuildingUnit
        return location.hr_name;
        
    elsif location.respond_to?(:hr_address)
        return location.hr_address;
        
    else
    	return location.to_s;
    	
    end
end

def describe_cost_data( params )
    desc_str = [];
    desc_str << "hrs=" + params[:hours_of_fix];
    desc_str << "pph=" + params[:price_per_hour];
    desc_str << "pc="  + params[:parts_cost_of_fix];
    desc_str << "fp="  + params[:fixed_price_of_fix];
    return desc_str.join("|");
end



end
