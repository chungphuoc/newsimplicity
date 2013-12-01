# Module that deals with the parsing of 
# the new_mt_req_form.
# TODO change name to a beter one, once the "old" module has been phased out.
module NewMtReqFormModule
    
    # Returns a the place specified by the name and the building.
    # If the place does not exist, a new building unit is created.
    def get_create_place(building, place_name)
        place_name.strip!
        if ( building.kind_of? Building )
            building_id = building.id
        elsif ( building.kind_of? Fixnum )
            building_id = building;
            building = Building.find( building_id )
        end
        place = BuildingUnit.find_by_name_and_building_id( place_name, building_id );
        if ( place.nil? )
            # need to create a new place
            place = BuildingUnit.new();
            place.building = building;
            place.name = place_name;
            place.unit_type = building.default_public_unit_type;
            place.save!;
        end
        return place;
    end
    
    # parses the form and returns the mt_request, if sucessful.
    def parse_new_mt_req_form()
        mt_req = MaintenanceRequest.new;
        mt_req_params = params[:mt_req];
        building_id = mt_req_params[:building_id];
        
        mt_req.title = mt_req_params[:title].strip();
        mt_req.body  = mt_req_params[:body].strip();
        mt_req.urgency = mt_req_params[:urgency];
        mt_req.remarks = mt_req_params[:remarks];
        mt_req.reporter = current_user();
        
        mt_req.building = Building.find( building_id.to_i );
        mt_req.place_free_text = mt_req_params[:place_free_text];
        
        biz_id_str = mt_req_params["biz_select_#{building_id}"].strip;
        if ( biz_id_str.to_i != 0 )
            mt_req.business = Business.find( biz_id_str.to_i() );
        else
            biz_id_str = "";
        end
        
        other_place_sym = "place_#{building_id}_#{biz_id_str}".intern;
        other_place_name = "other_place_#{building_id}_#{biz_id_str}".intern;
        if ( mt_req_params[other_place_sym]=="-1")
            # try to use an existing place
            new_place = get_create_place( mt_req.building, mt_req_params[other_place_name].strip  )
        else
            new_place = obj_from_unique_id( mt_req_params[other_place_sym] );
        end

        mt_req.place = new_place;
        
        mt_req.assignee = obj_from_unique_id( params[:mt_req]["assignee_#{building_id}".intern] );
        mt_req.mt_company = mt_req.assignee.mt_company;
        
        mt_req.budget_name = params[:mt_req][:budget_name].strip();
        if ( ! params[:mt_req][:service_type].blank? )
           mt_req.service_type = params[:mt_req][:service_type].to_i;
        end
        
        if ( mt_req.save ) 
            add_confirmation( "MAITENANCE_REQUEST_CREATED" );
            return mt_req;        
        else
            add_error( "ERROR SAVING MAINTENANCE REQUEST" );
            return;
        end
    end
    
    # adds the files from the form. Pass in the mt_req to make those part of it.
    def add_files_to_mt_req( mt_req )
        # mt_request is done. time to deal with the files.
        for file in params[:file]
            file = file.last;
            confirmed = false;
            
            unless ( file[:file].blank? )
                uf = UploadedFile.new();
                if uf.init_from_file_field(file[:file])
                    uf.title = file[:title];
                    uf.part_of = mt_req;
                    uf.uploader = current_user();
                    uf.upload_date = Localization.localizer.now();
                    if uf.save
                        uf.save_file( file[:file] )
                        add_confirmation( "FILES SAVED" ) unless confirmed;
                        confirmed = true;
                    else
                        add_error "ERROR SAVING FILE";
                        return;
                    end
                end
            end
        end
    end
end