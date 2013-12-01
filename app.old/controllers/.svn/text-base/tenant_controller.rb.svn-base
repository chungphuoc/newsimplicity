class TenantController < ApplicationController

    before_filter :ensure_building_exists;
    before_filter :authorize_tenant, :except=>["login"];
    before_filter :load_user;
    
    def login
        if @tenant != nil
            redirect_to :action=>"index"
        else
            if request.post? 
                tenant = Tenant.authenticate(params[:username], params[:password], @building.id) 
                if ! tenant.nil?
                    set_session_tenant( tenant );

                    redirect_to(:action => "index");
                else 
                    add_error( "WRONG_USERNAME_PASSWORD" );
                    redirect_to(:action => "login_tenant", :controller=>"guest");
                end 
            end 
        end
    end

    def logout
        clear_session( Tenant.name );
        clear_user_session();;
        redirect_to :controller=>"guest";
    end

    def index
        @js_files ||= ["maintenance_report"]
        @places = @building.get_place_list_items();

        @display_other = (@places.empty?) ? "inline" : "none";

        @places = @places.collect {|p| [ p.place, p.id ] }
        @places << ["אחר...", "-1"];

        @anns = @building.get_announcements( true );
        @ann_count = @anns.size>5 ? 5 : @anns.size;
        @psts = @building.get_tenant_posts( true );
        @pst_count = @psts.size>12 ? 5 : @psts.size;
    end


    def directions
        #nothing to do - just show the page.
    end

    def my_details
        if @tenant.id.nil?
            redirect_to :action=>"index";
            return
        end
        @tenant.reload();
        @tenant = @tenant
    end


    def edit_my_details
        if @tenant.id.nil?
            redirect_to :action=>"index";
            return
        end

        @tenant.reload();
        if request.post?
            # update the tenant
            @tenant = Tenant.find_by_id( @tenant.id );
            new_atts = params[:tenant];

            if @tenant.update_attributes(new_atts);
                add_confirmation 'TENANT_SUCCESSFULY_UPDATED';
                @tenant = @tenant;
                redirect_to :action=>"my_details";
            else
                add_errors_of( @tenant );
            end
        else
            # just show the details
            @tenant = @tenant;
        end
    end

    def my_flat
        @states = getFlatStates;
        @flat = @tenant.flat(true);
        if @flat.nil?
            redirect_to :action=>"index";
            return
        end

    end

    def update_my_flat

    end

    #############
    ## announcements
    #############    

    def announcements
        @css_files = ["tables"]
        @anns = @building.get_announcements( true );
    end

    def show_single_announcement
        @post = Announcement.find(params[:id]);
    end

    #############
    ## posts
    #############

    def tenant_posts
        @css_files = ["tables"];
        @psts = @building.get_tenant_posts( true );
    end

    def new_post
        @tenant_post = TenantPost.new
        @tenant_post.display_on_site = true
    end

    def create_new_post
        if params[:tenant_post][:display_on_site] != nil
            params[:tenant_post][:display_on_site] = "true" 
        else
            params[:tenant_post][:display_on_site] = "false" 
        end
        @tenant_post = TenantPost.new(params[:tenant_post])

        @tenant_post.published_on = DateTime.now
        @tenant_post.link = fix_link(@tenant_post.link)
        @tenant_post.tenant = @tenant
        @tenant_post.building = @building

        # handle an uploaded file (if any)
        if ( params['afile'] != "" ) 
            @tenant_post.file_suffix = params['afile'].original_filename.split(".").last
        end

        if @tenant_post.save  
            if ( params['afile'] != "" ) 
                File.open( @tenant_post.local_file_path, "wb" ) do |f| 
                    f.write( @params['afile'].read )
                end
            end
            add_info 'TENANT_POST_SAVE_SUCCESSFUL'
            redirect_to :action=>"tenant_posts"
        else
            add_errors_of( @tenant_post );
            render :action=>"new_post"
        end
    end

    def update_tenant_post
        @tenant_post = TenantPost.find(params[:id])

        if params['remove_file'] != nil
            File.delete( @tenant_post.local_file_path )
        end

        # handle an uploaded file (if any)
        if params['afile'] != nil && params['afile'] != ""
            File.delete( @tenant_post.local_file_path ) if @tenant_post.has_file

            @tenant_post.file_suffix = params['afile'].original_filename.split(".").last
            File.open( @tenant_post.local_file_path, "wb" ) do |f| 
                f.write( @params['afile'].read )
            end
        end

        if params[:tenant_post][:display_on_site] != nil
            params[:tenant_post][:display_on_site] = "true" 
        else
            params[:tenant_post][:display_on_site] = "false" 
        end

        params[:tenant_post][:link] = fix_link(params[:tenant_post][:link])

        if @tenant_post.update_attributes(params[:tenant_post])
            add_confirmation 'TenantPost was successfully updated.'
            redirect_to :action => 'tenant_posts'
        else
            add_errors_of( @tenant_post );
            render :action => 'edit_post'
        end

    end


    def show_single_post
        @post = TenantPost.find(params[:id])
    end

    def edit_post
        @tenant_post = TenantPost.find(params[:id])

        # security
        if @tenant_post.tenant != @tenant
            add_error "ACTION_NOT_ALLOWED"
            redirect_to :action=>"tenant_posts"
        end
    end


    def destroy_post
        if request.post?
            post = TenantPost.find(params[:id])

            # security
            if post.tenant == @tenant
                post.destroy
            else
                add_error "ACTION_NOT_ALLOWED"
            end
        end

        redirect_to :action=>"tenant_posts"
    end

    ###########
    # Maintenance Company
    ###########
    def mt_company
        redirect_to :action=>"index" unless @building.has_mt_company?
        @mt_company = @building.mt_company;
        if @building.mt_building_manager_id != nil
            @worker = MtCompanyWorker.find( @building.mt_building_manager_id );
        end
    end

    ########
    # cars #
    ########

    def car_add
        @car = Car.new;
    end

    def car_create
        @car = Car.new(params[:car]);
        @car.tenant = @tenant;
        if @car.save
            redirect_to( :action=>"my_details" );
        else
            render( :action=>"car_add");
        end
    end

    def car_edit
        @car = Car.find(params[:id]);
        if @car.tenant != @tenant 
            add_error "CAR DOES NOT BELONG TO TENANT";
            redirect_to( :action=>"my_details");
        else
        end
    end

    def car_update
        @car = Car.find(params[:id]);
        if @car.tenant != @tenant 
            add_error "CAR DOES NOT BELONG TO TENANT";
            redirect_to( :action=>"my_details");
        else
            redirect_to(:action=>"my_details") if @car.update_attributes(params[:car]);
        end
    end

    def car_destroy
        car = Car.find(params[:id]);
        if car.tenant != @tenant 
            add_error "CAR DOES NOT BELONG TO TENANT";
        else
            add_confirmation "CAR DELETED";
            car.destroy();
        end
        redirect_to( :action=>"my_details");
    end

    def car_finder
    end

    def car_finder_result
        @car_num = params[:car][:number];
        @car = Car.find_by_number( @car_num );
    end

    ########################
    # maintenance requests #
    ########################

    def new_maintenance_request
        @js_files  ||= ["maintenance_report"]
        @css_files ||= ["tables"]
        @places = @building.get_place_list_items();
        @display_other = (@places.empty?) ? "inline" : "none";

        @recents = @building.recent_maintenance_requests(5);
        @maintenance_request = MaintenanceRequest.new { |r| }
    end

    def create_maintenance_request

        @maintenance_request = MaintenanceRequest.new(params[:maintenance_request])

        if ( params[:place]=="-1")
            # try to use an existing place
            new_place = PlaceListItem.find_by_place(params[:other_place].strip);
            if ( new_place.nil? )
                # need to create a new place
                new_place = PlaceListItem.new();
                building_id = session[Building.name];
                building_id ||= session[BusinessBuilding.name];
                new_place.building = Building.find(building_id);
                new_place.place = params[:other_place].strip;
                new_place.save;
            end
        else
            new_place = obj_from_unique_id( params[:place] );
        end
        @maintenance_request.place = new_place;
        @maintenance_request.place_free_text = params[:maintenance_request][:place_free_text].strip;
        
        # set the default options
        @maintenance_request.reporter = @tenant;
        @maintenance_request.building_id = @building.id;

        if @maintenance_request.title.blank?
            # invent the title, if none was given
            @maintenance_request.title = abbreviate( @maintenance_request.body, 4 );
        end
        
        @maintenance_request.assignee = @building.mt_company;
        
        # save
        if @maintenance_request.save
            add_info 'MAITENANCE_REQUEST_CREATED'
            redirect_to :action => 'maintenance_requests'
        else
            add_errors_of @maintenance_request
            render :action => 'new_maintenance_request'
        end
    end

    def show_single_request
        @req = MaintenanceRequest.find(params[:id])
    end

    def edit_maintenance_request
        @js_files ||= ["maintenance_report"];
        @places = PlaceListItem.find( :all, :order=>"place" );
        @display_other = "none";
        @maintenance_request = MaintenanceRequest.find( params[:id] );
    end

    def update_maintenance_request

        @maintenance_request = MaintenanceRequest.find(params[:id]);

        # handle the "other..." part of the request
        if params[:place] == "-1"
            pli = PlaceListItem.new;
            pli.place = params[:other_place];
            pli.building_id = @building.id;
            unless pli.save
                add_error "ERR_CANT_SAVE_PLACE_LINE_ITEM";
            end
            @maintenance_request.place = pli;
        else
            @maintenance_request.place = PlaceListItem.find(params[:place]);
        end

        # set the default options
        @maintenance_request.reporter = @tenant;
        @maintenance_request.building_id = @building.id;

        if @maintenance_request.title.blank?
            # invent the title, if none was given
            @maintenance_request.title = abbreviate( @maintenance_request.body, 4 );
        end

        if @maintenance_request.update_attributes(params[:maintenance_request])
            @maintenance_request.save!;
            add_info 'MAITENANCE_REQUEST_CHANGED';
            redirect_to :action=>'show_single_request', :id=>@maintenance_request;
        else
            add_errors_of( @maintenance_request );
            render :action => 'edit_maintenance_request';
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

        else
            add_warning "get?"
        end

        redirect_to :action=>"maintenance_requests"
    end

    def maintenance_requests
        @css_files ||= ["tables"]
        @requests = @building.get_maintenance_requests( true );
    end

    ###################
    # CONDO QUESTIONS #
    ###################

    def legal_faq
        @css_files ||="qa";
        @questions = CondoQuestion.find_all_displayed();
    end

    def add_condo_question
        cq = CondoQuestion.new;
        cq.update_attributes(params[:condo_question]);
        if cq.save 
            add_info "CONDO_QUESTION_SAVED";
        else
            add_errors_of cq;
        end
        redirect_to :action=>:legal_faq;

    end

    ####################
    # Shared Documents #
    ####################

    def shared_documents_list
        @css_files ||= "tables";
        @doc_pages, @docs = paginate :shared_documents, :per_page => 10, :conditions=>["building_id=?", @building.id]
    end

    def shared_documents_show
        @shared_document = SharedDocument.find(params[:id]);
    end

    def get_shared_document
        sdoc = SharedDocument.find(params[:id]);
        #send_file(sdoc.local_file_path, :filename=>sdoc.title + "." + sdoc.file_suffix, :type=>"application/#{sdoc.file_suffix}" );
        redirect_to( sdoc.web_file_path );
    end
    
    private
    
    def load_user
        @user = current_user
    end
end
