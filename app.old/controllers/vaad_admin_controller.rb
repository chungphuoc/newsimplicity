class VaadAdminController < ApplicationController
    
    before_filter :authorize_vaad_admin, :except => [:login];
    before_filter :ensure_building_exists;
    
    def index
        stt = @building.get_stats();
        @tenant_count = stt[:tenant_count];
        @flat_count   = stt[:flat_count];
        @ann_count    = stt[:announcement_count];
        @tp_count     = stt[:tenant_post_count];
        @cp_count     = stt[:contact_person_count];
        @user_count   = stt[:user_count]
        @m_req_count  = stt[:unsolved_mreq_count];

    end
    
    def login
        if @tenant != nil
            redirect_to :action=>"index"
        else
            if request.post?
                tenant = Tenant.authenticate(params[:username], params[:password], @building.id);
                if tenant 
                    set_session_tenant(tenant);
                    redirect_to(:action => "index");
                else 
                    add_error "ERR_WRONG_USER_PASSWORD";
                    redirect_to(:action => "login_vaad", :controller=>"guest");
                end 
            end 
        end
    end
    
    def logout
        clear_session(@human.class.name);
        clear_user_session();;
        redirect_to :controller=>'guest', :action=>'index';
    end
    
    def show_general_info        
    end
    
    def edit_general_info
    end
    
    
    def update_general_info
        
        if ! params['afile'].blank?     
            params[:building]["map_extension"] = params['afile'].original_filename.split(".").last;
        end
        
        if @building.update_attributes( params[:building] )
            
            if (params['remove_file'] != nil) || ! params['afile'].blank?
                if @building.has_map?
                    File.delete( @building.local_map_path );
                end
            end
            
            if ! params['afile'].blank?
                File.open( @building.local_map_path, "wb" ) do |f| 
                    f.write( @params['afile'].read );
                end
            end
            
            add_info "BUILDING GENERAL INFO SAVED";
            redirect_to(:action=>"show_general_info");
        else
            add_errors_of( @building )
            render(:action=>"edit_general_info");
        end
    end
    
    
    ###########
    # maintenance requests
    ###########
    
    def maintenance_requests
        css_files ||= ["tables"]
        @requests = @building.get_maintenance_requests( true );
    end
    
    def show_single_request
        @req = MaintenanceRequest.find(params[:id])
    end
    
    def show_single_request
        @req = MaintenanceRequest.find(params[:id])
    end
    
    def edit_maintenance_request
        @js_files ||= ["maintenance_report"];
        @places = @building.get_place_list_items().sort;
        
        @maintenance_request = MaintenanceRequest.find(params[:id]);
    end
    
    def update_maintenance_request

        @maintenance_request = MaintenanceRequest.find(params[:id])

        # handle the "other..." part of the request
        if params[:place] == "-1"
            pli = PlaceListItem.new
            pli.place = params[:other_place]
            pli.building_id = @building.id;
            unless pli.save
                add_error "ERR_CANT_SAVE_PLACE_LINE_ITEM"
            end
        else
            pli = PlaceListItem.find(params[:place]);
        end
        
        @maintenance_request.place = pli;
        if @maintenance_request.update_attributes(params[:maintenance_request]) 
            add_info 'MAINTENANCE_REQUEST_CHANGED';
            redirect_to :action => 'maintenance_requests';
        else
            add_errors_of @maintenance_request
            render :action => 'edit_maintenance_request', :id=>params[:id];
        end
    
    end
    
    def destroy_maintenance_request
        if request.post?
            post = MaintenanceRequest.find(params[:id])        
            # security
            if post.reporter == @tenant
                post.destroy
            else
                add_error "ACTION_NOT_ALLOWED"
            end
        end
        
        redirect_to :action=>"maintenance_requests"
    end
    
    ###########
    # MT Company
    ###########
      def mt_company
          redirect_to :action=>"index" unless @building.has_mt_company?;
          @mt_company = @building.mt_company;
          @worker = @building.mt_manager;
          @tenants = @building.tenants;
          if request.post?
              if @building.update_attributes(params[:building])
                  add_info "SAVED SUCCESSFULLY";
              else
                  add_error "ERROR SAVING";
              end
          end
      end
      
end
