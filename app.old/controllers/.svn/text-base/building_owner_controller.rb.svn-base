require "date"
class BuildingOwnerController < ApplicationController
    include NewMtReqFormModule, ActionStateModule
    
    before_filter :ensure_owner_exists, :except=>["login"];
    
    # GETs should be safe (see http://www.w3.org/2001/tag/doc/whenToUseGet.html)
    verify :method => :post, :only => [ :ut_destroy, :ut_create, :ut_update,
                                        :building_update, :bu_destroy, :bu_create, :bu_update,
                                        :biz_create, :biz_update, :biz_destroy,
                                        :uc_add_wizard_2, :uc_add_wizard_3, :uc_add_wizard_4, :uc_add_wizard_5, :uc_add_wizard_finalize,
                                        :uc_destroy ],
            :redirect_to => { :action => :index }
    
    # key for holding query about mt_requests in the report builder in the session
    REPORT_BUILDER_MT_REQ_QUERY_KEY = "#{__FILE__}.REPORT_BUILDER_MT_REQ_QUERY_KEY";
    
    # key for holding the mt_req list from which we "broke out" to watch details about mt_reqs and fix them
    MT_REQ_LIST_ACTION = "#{__FILE__}.MT_REQ_LIST_ACTION";

    # key for holding query about mt_requests in the pending mt reqs list builder in the session
    PENDING_MT_REQ_QUERY_KEY = "#{__FILE__}.PENDING_MT_REQ_QUERY_KEY";
    
    TOUCHED_PAGER_KEY = "#{__FILE__}.TOUCHED_PAGER_KEY"
    
    def index
        # TODO localize
        @global_list = [];
        @global_list << KVObj.new("ALL", "כולם");
        @global_list << KVObj.new("BUILDINGS", "כל הבניינים");
        @global_list << KVObj.new("BUSINESSES", "כל העסקים");
        @global_list << KVObj.new("MT_COMPANIES", "כל חברות האחזקה");

        @buildings    = current_user().buildings;
        @businesses   = @buildings.collect{ |b| b.businesses }.flatten;
        @mt_companies = @buildings.collect{ |b| b.mt_company }.uniq.compact;
        
        # TODO make an efficient version.
        @mt_reqs = MaintenanceRequest.find_for_owner( current_user() );
        @mt_reqs = @mt_reqs.sort{|e1,e2| - (e1.created_on <=> e2.created_on) }
        @mt_reqs = @mt_reqs[0..4];
        
        @contracts = current_user().contracts.collect{|e| (e.end_date != nil && e.end_date > DateTime.now) ? e : nil }.compact;  # get all rent contracts
        @contracts = @contracts.collect{|e| e if ((e.end_date-DateTime.now).ceil < 90) }.compact;  # that end in less than 90 days
        @contracts = @contracts.sort{ |e1, e2| e1.end_date <=> e2.end_date }[0..4];         # and get the 5 most urgent.
        
        pgr = RSPager.new(TouchedByQuery.new( current_user ));
        pgr.page_size = 7
        @touched_mt_reqs = pgr.get_current_page();
        
        @tasks = MtCompanyTask.find(:all,
                                 :conditions=>"building_owner_id=#{current_user().id} AND 
                                               NOT ( status=#{MtCompanyTask::DONE} OR status=#{MtCompanyTask::CANCELLED})",
                                  :order=>"until_date ASC",
                                  :limit=>5);
        @refresh = true;
    end
    
    def login
        if request.post? 
            owner = BuildingOwner.authenticate(params[:username], params[:password]);
            if ( ! owner.nil? )
                set_current_user( owner );
                log_user_login( params[:username], BuildingOwner.name, true )
                redirect_to(:action => "index");
            else 
                log_user_login( params[:username], BuildingOwner.name, false )
                add_error "WRONG USERNAME PASSWORD";
            end 
        end
    end
    
    def logout
        log_user_logout( current_user.username, BuildingOwner.name );
        clear_user_session();
        redirect_to :action=>"login";
    end
    
    def show_my_details
    end
    
    def edit_my_details
        if request.post?
            if current_user().update_attributes( params[:owner] )
                add_info "SAVED SUCCESSFULLY";
                redirect_to :action=>"show_my_details";
            else
                add_errors_of( current_user() );
            end
        end
    end
    
    def unimplemented
        render :template=>"/shared/unimplemented";
    end
    
    def mt_company_show
        @building = Building.find(params[:building_id]);
        redirect_to :action=>"index" unless @building.has_mt_company?
        @mt_company = @building.mt_company;
        if @building.mt_building_manager_id != nil
            @worker = MtCompanyWorker.find( @building.mt_building_manager_id );
        end
    end
    
    
    #############
    # Buildings #
    #############
    def my_buildings
        
    end
    
    def building_show
        @building = Building.find(params[:id]);
        security_breach() if @building.building_owner != current_user()
    end
    
    def building_edit
        @building = Building.find(params[:id]);
        security_breach() if @building.building_owner != current_user()
    end
    
    def building_update
        @building = Building.find(params[:id]);
        if @building.building_owner != current_user()
            security_breach()
            return
        end
            
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
            
            add_info "BUILDING_GENERAL_INFO_SAVED";
            redirect_to(:action=>"building_show", :id=>@building);
        else
            add_errors_of( @building );
            render(:action=>"building_edit");
        end
    end
    
    ##############
    # businesses #
    ##############
    
    def biz_list
        @buildings = current_user().buildings;
        
        begin
            @current_building = Building.find(params[:current_building][:id])
        rescue
            @current_building = nil
        end
        
        @all_buildings = (params[:all_buildings].nil? || params[:all_buildings]=="true");
        
        if @current_building.nil? || @all_buildings
            pagee = AROPagee.new(current_user(), :businesses)
        else
            pagee = AROPagee.new(@current_building, :businesses)
        end
        pagee.sort_by = params[:sort_by] unless params[:sort_by].nil?
        @pgr = RSPager.new( pagee );
        @pgr.current_page = params[:page] unless params[:page].nil?
        @pgr.page_size = 15;
        @businesses = @pgr.get_current_page();
    end

    def biz_show
        @business = Business.find(params[:id]);
        security_breach if @business.building.building_owner != current_user() 
    end

    def biz_new
        @buildings = current_user().buildings;
        @business ||= Business.new;
    end

    def biz_create
        params[:business][:site] = fix_link(params[:business][:site]);
        
        @business = Business.new(params[:business])

        user_data = params[:new_user];
        if ( user_data[:password] != user_data[:password_confirmation])
            add_error("PASSWORDS DO NOT MATCH");
            biz_new();
            render :action => 'biz_new';
            return;
        end
        begin
            #create the new user
            @new_user = User.new();
            @new_user.password = user_data[:password];
            @new_user.password_confirmation = user_data[:password_confirmation];
            @new_user.username = user_data[:username];
            @new_user.role = "UR_BIZ_MANAGER";
            @new_user.business = @business;

            # add the user
            @business.users << ( @new_user );
            @business.save!
            
            # report and redirect
            add_confirmation 'BUSINESS SAVED SUCCESSFULLY';
            add_confirmation 'USER CREATED SUCCESSFULLY'
            redirect_to :action => 'biz_list';
            
        rescue ActiveRecord::RecordInvalid => inv_err
            add_errors_of @business;
            add_errors_of @new_user;
            biz_new();
            render :action => 'biz_new'
        end
    end

    def biz_edit
        @buildings = current_user().buildings;
        @business = Business.find(params[:id])
        security_approve @business
    end

    def biz_update
        @business = Business.find(params[:id])
        
        return unless security_approve @business
        
        params[:business][:site] = fix_link(params[:business][:site]);
        
        if @business.update_attributes(params[:business])
            add_confirmation 'BUSINESS SAVED SUCCESSFULLY';
            redirect_to :action => 'biz_show', :id => @business
        else
            add_errors_of @business
            @buildings = current_user().buildings;
            render :action => 'biz_edit';
        end
    end

    def biz_destroy
        b = Business.find(params[:id])
        return unless security_approve b
        b.destroy
        redirect_to :action => 'biz_list'
    end
    
    def biz_add_user
        @business = Business.find(params[:id]);
        
        return unless security_approve @business
        
        if request.post?
            @new_user = User.new();
            if ( params[:new_user][:password] != params[:new_user][:password_confirm])
                @new_user.errors.add_to_base("PASSWORDS DO NOT MATCH");
                return;
            end
            
            @new_user.password = params[:new_user][:password];
            @new_user.username = params[:new_user][:username];
            @new_user.role = "UR_BIZ_MANAGER";
            @new_user.business = @business;
            if @new_user.save
                redirect_to :action=>"biz_show", :id=>@business;
            else
                add_errors_of( @new_user )
            end
        end
    end
    
    #################
    # unit_contract #
    #################
    # TODO localize
    @@UC_ADD_STAGES = ["בניין", "עסק", "תאריכים","יחידות" ,"אישור", "קבצים"];
    
    def uc_list
        @buildings = current_user().buildings;
        
        begin
            unless ( params[:building_id].nil? )
                @current_building = Building.find(params[:building_id].to_i)
            else
                @current_building = Building.find(params[:current_building][:id])
            end
        rescue
            @current_building = nil;
        end

        @page_hash = {}        
        
        @all_buildings = (@current_building.nil? || params[:all_buildings]=="true");
        if @current_building.nil? || @all_buildings
            pagee = UnitContractsByOwnerPagee.new(current_user())
        else
            pagee = UnitContractsByBuildingPagee.new(@current_building)
            @page_hash[:building_id] = @current_building.id
        end
        
        @pgr = RSPager.new( pagee );
        @pgr.current_page = params[:page] unless params[:page].nil?
        @pgr.page_size = 15;
        @contracts = @pgr.get_current_page();
    
    end

    def uc_add_wizard_1
        # stage 1: get the building
        
        session[:uc_add_wizard] = {}; # clean any former mess
        @stages = @@UC_ADD_STAGES;
        
        @buildings = current_user().buildings;
    end
    
    def uc_add_wizard_2
        # stage 2: get the business
        if ( params[:building] != nil )
            session[:uc_add_wizard][:building_id] = params[:building][:id];
        end
        @stages = @@UC_ADD_STAGES;
        
        @building = Building.find(session[:uc_add_wizard][:building_id]);
        @businesses = current_user().businesses(session[:uc_add_wizard][:building_id]);
    end

    def uc_add_wizard_3
        # stage 3: specify the dates
        if ( params[:business] != nil )
            session[:uc_add_wizard][:business_id] = params[:business][:id];
        end

        @stages = @@UC_ADD_STAGES;
        
        @uc = UnitContract.new();
        @uc.start_date = Localization.localizer().now();
        @uc.end_date = @uc.start_date;
        @uc.mode = UnitContract::MODE_RENT;
        
        @modes = { UnitContract::MODE_RENT => "השכרה", 
                   UnitContract::MODE_SELL => "מכירה" }

        @js_files ||= ["unit_contract"];
        
        
        @building = Building.find(session[:uc_add_wizard][:building_id]);
        @business = Business.find(session[:uc_add_wizard][:business_id]);
        
        @units = @building.building_units;
        @units = @units.sort;
    end
    
    def uc_add_wizard_4
        # stage 4: parse the dates and get the units
        
        # put all the stuff from the session to an object
        if ( params[:uc] != nil )
            params[:uc][:business_id] = session[:uc_add_wizard][:business_id];
            @uc = UnitContract.new( params[:uc] );

            session[:uc_add_wizard][:uc] = @uc;

        elsif ( !session[:uc_add_wizard].nil? && session[:uc_add_wizard][:uc] != nil )
            @uc = session[:uc_add_wizard][:uc];
        else
            redirect_to :action=>"uc_list";
            return;
        end
        
        @stages = @@UC_ADD_STAGES;

        @building = Building.find(session[:uc_add_wizard][:building_id]);
        @business = @uc.business;
        @units = @building.building_units;
        
        @js_files ||= ["unit_contract"];
    end
    
    def uc_add_wizard_5
        # parse the units and add files
        if ( !session[:uc_add_wizard].nil? && session[:uc_add_wizard][:uc] != nil )
            @uc = session[:uc_add_wizard][:uc];            
        else
            add_error( "UNIT CONTRACT NOT IN SESSION")
            redirect_to :action=>"uc_list";
            return;
        end
        
        if ( params[:units] != nil )
            for id_pair in params[:units]
                @uc.add_unit( BuildingUnit.find(id_pair[0]) );
            end
        end
        
        @stages = @@UC_ADD_STAGES;

    end
    
    def uc_add_wizard_finalize
        # confirm that the contract has been saved, offer to upload files.
        if ( session[:uc_add_wizard].nil? || session[:uc_add_wizard][:uc].nil? )
            add_error "UNIT CONTRACT NOT IN SESSION";
            redirect_to :action=>:uc_list;
            return;
        end
        
        if ( session[:uc_add_wizard][:uc] != nil ) 
            session[:uc_add_wizard][:uc].save!
        end
        add_confirmation "CONTRACT_SAVED";
        
        @uc = session[:uc_add_wizard][:uc];
        @files = [];
        3.times do
            @files << UploadedFile.new
        end
        @stages = @@UC_ADD_STAGES;
    end
    
    def uc_add_wizard_upload
        if ( session[:uc_add_wizard].nil? || session[:uc_add_wizard][:uc].nil? )
            add_error "UNIT CONTRACT NOT IN SESSION";
            redirect_to :action=>:uc_list;
            return;
        end
        
        @uc = session[:uc_add_wizard][:uc];
        
        for file in params[:file]
            file = file.last;

            unless ( file[:file].blank? )
                uf = UploadedFile.new();
                if uf.init_from_file_field(file[:file])
                    uf.title = file[:title];
                    uf.part_of = @uc;
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
        add_info "FILES UPLOADED SUCCESSFULY";

        redirect_to :action=>:uc_show, :id=>@uc;

    end
    
    def uc_show
        @uc = UnitContract.find( params[:id] );
        security_approve @uc.business
    end
    
    def uc_edit
        @uc = UnitContract.find( params[:id] );

        return unless security_approve @uc.business

        @building = @uc.building;
        @businesses = @building.businesses;
        @units = @building.building_units;
        @units = @units.sort;

        @js_files ||= ["unit_contract"];

        @modes = { UnitContract::MODE_RENT => "השכרה", 
                  UnitContract::MODE_SELL => "מכירה" }

    end
    
    def uc_update
        @uc = UnitContract.find(params[:id]);
        
        return unless security_approve @uc.business
        
        @uc.update_attributes( params[:uc] );
        
        @uc.building_units = [];
        for id_pair in params[:units]
            @uc.building_units << BuildingUnit.find(id_pair[0]);
        end 
        
        if @uc.save
            redirect_to :action=>"uc_show", :id=>@uc
            add_confirmation "SAVED SUCCESSFULLY";
        else
            add_info "ERROR SAVING UNIT CONTRACT";
            uc_edit();
            render :action=>"uc_edit";
            return;
        end
        
        # delete any unwanted files
        for hash_entry in params
            name = hash_entry.first
            if /uploaded_file_[0-9]+/.match(name) != nil
                uf_param = hash_entry.last;
                begin
                    uf = UploadedFile.find(uf_param[:id]);
                    if ( ! uf_param[:delete].nil? )
                        # need to delete file
                        uf.destroy;
                    else
                        uf.title = uf_param[:title];
                        uf.save;
                    end
                rescue Exception => e
                    add_warning( e.to_s );
                end
            end
        end
            
        # deal with the newly uploaded files
        for hash_entry in params[:file]
            file = hash_entry.last;
            unless ( file[:file].blank? )

                uf = UploadedFile.new();
                if uf.init_from_file_field(file[:file])
                    uf.title = file[:title];
                    uf.part_of = @uc;
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
    end
       
    def uc_destroy
        
        begin
            uc = UnitContract.find(params[:id]);
            
            return unless security_approve uc.business
            
            uc.destroy;
            
        rescue Exception => e
            add_error e.message;
        end
        redirect_to :action=>"uc_list";
    end
    
    def uc_get_uploaded_file
        uf = UploadedFile.find(params[:id]);
        if ( uf.nil? )
            add_error "UPLOADED FILE NOT FOUND";
            return;
        end
        
        # TODO make sure the current user can access this file. Also in other places for this.
        
        send_data( uf.data,
                    :filename => uf.name,
                    :type => uf.mime_type,
                    :disposition => "attachment" );
        
    end
    
    ############
    # UnitType #
    ############

    def ut_list
        @unit_types = current_user().unit_types;
    end

    def ut_show
        @unit_type = UnitType.find(params[:id])
        throw "UNIT_TYPE DOES NOT BELONG TO OWNER" if ( @unit_type.building_owner != current_user() );
    end

    def ut_new
        @unit_type = UnitType.new
    end

    def ut_create
        cb_to_bool( params[:unit_type], :is_public );
        @unit_type = UnitType.new(params[:unit_type])
        @unit_type.building_owner = current_user()
        
        if @unit_type.save
            add_info 'UnitType was successfully created.'
            redirect_to :action => 'ut_list'
        else
            add_errors_of( @unit_type )
            render :action => 'ut_new'
        end
    end

    def ut_edit
        @unit_type = UnitType.find(params[:id])
        security_approve @unit_type
        @units = @unit_type.building_units;
    end

    def ut_update
        @unit_type = UnitType.find(params[:id])
        return unless security_approve @unit_type;
        
        cb_to_bool(params[:unit_type], :is_public ); 
        
        if @unit_type.update_attributes(params[:unit_type])
            add_confirmation 'UnitType updated'
            redirect_to :action => 'ut_list'
        else
            add_errors_of( @unit_type )
            render :action => 'ut_edit'
        end
    end

    def ut_destroy
        
        @unit_type = UnitType.find(params[:id]);
        return unless security_approve @unit_type;
        
        # array for holding possible reasons why we can't delete the unit
        @reason = [];
        @deletable
        
        if ( params[:solution] == nil )
            # first time around. make sure we can delete the unit type
            if ( current_user().unit_types.size == 1 ) 
                @reason << "LAST_UNIT_TYPE"; # TODO use constants!!!
                return;
            end
            
            if ( current_user().public_unit_types().size == 1 )
                @reason << "LAST_PUBLIC_UNIT_TYPE";
                return;
            end
            
            if ( @unit_type.building_units.size > 0 )
                @reason << "BUILDING_UNITS_EXIST";
                @types_left = current_user().unit_types.collect{|e| e!=@unit_type ? e : nil }.compact;
            end

            @buildings = @unit_type.buildings
            if ( ! @buildings.empty? )
               @reason << "DEFAULT_UNIT";
            end
            
            return; #prevent further processing and server the screen
            
        else 
            # second time, find what the user wants and do it
            sol = params[:solution];
            begin
                if sol == "DELETE" 
                    for unit in @unit_type.building_units
                        unit.destroy
                    end
                elsif sol == "MOVE"
                    new_type = UnitType.find(params[:new_type][:id]);
                    for unit in @unit_type.building_units
                        unit.unit_type = new_type;
                        unit.save!
                    end
                end
            rescue Exception => exp
               add_error exp.message;
            end
        end
        
        # try to delete, handle exceptions
        begin
            @unit_type.destroy
        rescue Exception=>e
            add_error e.message;
        end
        redirect_to :action => 'ut_list';
        
    end
    
    #################
    # Building Unit #
    #################
    def bu_list
        @buildings = current_user().buildings;
        @units = [];
        
        begin
            @current_building = Building.find(params[:current_building][:id])
        rescue
            @current_building = nil
        end
        
        @all_buildings = (params[:all_buildings].nil? || params[:all_buildings]=="true");
        
        if @current_building.nil? || @all_buildings
            pagee = AROPagee.new(current_user(), :building_units)
        else
            pagee = AROPagee.new(@current_building, :building_units)
        end        
                
        @pgr = RSPager.new( pagee );
        @pgr.current_page = params[:page] unless params[:page].nil?
        @pgr.page_size = 15
        @units = @pgr.get_current_page();
        
    end

    def bu_show
        @building_unit = BuildingUnit.find(params[:id])
        security_approve @building_unit
    end

    def bu_new
        @building_unit = BuildingUnit.new;
        begin
            @building_unit.building = Building.find(params[:building_id]);
        rescue
        end
        @buildings = current_user().buildings;
        @unit_types = current_user().unit_types;
    end

    def bu_create
        @building_unit = BuildingUnit.new(params[:building_unit])
        if @building_unit.save
            add_info 'BuildingUnit created.'
            redirect_to :action => 'bu_list'
        else
            add_errors_of @building_unit
            render :action => 'bu_new'
        end
    end

    def bu_edit
        @building_unit = BuildingUnit.find(params[:id])
        return unless security_approve @building_unit
        
        @buildings = current_user().buildings;
        @unit_types = current_user().unit_types;
    end

    def bu_update
        @building_unit = BuildingUnit.find(params[:id])
        
        return unless security_approve @building_unit
        
        if @building_unit.update_attributes(params[:building_unit])
            add_info 'BuildingUnit updated.'
            redirect_to :action => 'bu_show', :id => @building_unit
        else
            add_errors_of @building_unit
            render :action => 'bu_edit'
        end
    end

    def bu_destroy
        b = BuildingUnit.find(params[:id])
        if ( b.nil? )
            add_error "CANT FIND BUILDING UNIT";
            redirect_to :action=>:index
            return;
        end
        return unless security_approve b
        b.destroy
        add_confirmation "BUIDING UNIT DELETED"
        #TODO deal with mt-reqs of this bu, if any (delete, move to)
        redirect_to :action => 'bu_list'
    end
    
    
    ########################
    # maintenance requests #
    ########################
    
    def mt_req_new
        if ( request.post? )
            # create the maintenance request
            # CONTPOINT the name of the new place is "-1" 
            @mt_req = parse_new_mt_req_form();
            unless ( @mt_req.nil? ) 
                add_files_to_mt_req( @mt_req )
                redirect_to :action=>:mt_req_list;
            end
        else
            # setup the data for the form
            @mt_req = MaintenanceRequest.new();
            @buildings = current_user().buildings;
        end
    end
    
    def mt_req_list
        if ( session[PENDING_MT_REQ_QUERY_KEY].nil? )
            session[PENDING_MT_REQ_QUERY_KEY] = MtRequestQuery.create_pending_query( current_user() );
        end
        @query = session[PENDING_MT_REQ_QUERY_KEY];
        @query.update_sort_by params[:sort_by]
        @pages, @mt_requests = paginate( :maintenance_requests, @query.conditions_hash() );
        session[MT_REQ_LIST_ACTION] = params[:action];
    end
    
    def mt_req_show
        @mt_req = MaintenanceRequest.find(params[:id]);
        if ( params[:popup] == true.to_s )
            @popup_mode = true
            render :layout=>"popup"
        end
    end
    
    def mt_req_edit
        @mt_req = MaintenanceRequest.find(params[:id]);
        if request.post?
            if @mt_req.update_attributes(params[:mt_req])
                add_confirmation "CHANGES SAVED";
                redirect_to :action=>"mt_req_show", :id=>@mt_req;
            end
        end
    end
    
    def mt_req_list_control
        # get the requests
        if ( session[PENDING_MT_REQ_QUERY_KEY].nil? )
            session[PENDING_MT_REQ_QUERY_KEY] = MtRequestQuery.create_pending_query( current_user() );
            session[PENDING_MT_REQ_QUERY_KEY].sort_by=MtRequestQuery::KEY_URGENCY;
        end
        @query = session[PENDING_MT_REQ_QUERY_KEY];
        @query.update_sort_by params[:sort_by] unless params[:sort_by].blank?
        @reqs = @query.execute
        
        render :layout=>false;
    end
    
    def touched_mt_reqs
        @pgr = get_state(){ RSPager.new(TouchedByQuery.new( current_user )) }
        @pgr.current_page = params[@pgr.name] unless params[@pgr.name].blank?
        @pgr.pagee.update_order_by( params[:order_by] ) unless params[:order_by].blank?
        @reqs = @pgr.get_current_page();
    end
    
    def mt_req_report_build
        @buildings = current_user().buildings;
        
        if ! session[REPORT_BUILDER_MT_REQ_QUERY_KEY].blank?
            # load last query data
            @query = session[REPORT_BUILDER_MT_REQ_QUERY_KEY];
        else
            # enter default data
            @query = MtRequestQuery.new
            #@query.from_date = Localization::localizer().now().to_date() - 10;
            @query.until_date = Localization::localizer().now().to_date();
            @query.building_ids = @buildings.collect{ |bld| bld.id };
            @query.add_state( MaintenanceRequest::OPEN );
            @query.add_state( MaintenanceRequest::IN_PROGRESS );
            @query.add_service_type( MaintenanceRequest::SERVICE_TYPE_FIX );
        end
        
    end
    
    def mt_req_report_show
        @query = MtRequestQuery.new
        if ( ! params[:query].nil?)
            # a new query has been asked
            @query.parse( params[:query] )

            # if there is only one mt_company, choose it.
            if ( current_user().mt_companies.size == 1 )
                @query.add_mt_company( current_user().mt_companies.first.id );
            end
            # ditto with buildings
            if ( current_user().buildings.size == 1)
                @query.add_building( current_user().buildings.first.id );
            end

            session[REPORT_BUILDER_MT_REQ_QUERY_KEY] = @query
            unless @query.valid?
                # query is not valid. complain using the report building screen
                add_messages @query.error_list, :error, false
                redirect_to :action=>"mt_req_report_build"
                return
            end
            
        elsif ! session[REPORT_BUILDER_MT_REQ_QUERY_KEY].blank?
            # we were already asked a question, now probably paging.
            @query = session[REPORT_BUILDER_MT_REQ_QUERY_KEY];

            unless params[:sort_by].blank?
                begin
                    @query.update_sort_by(params[:sort_by]);
                    if @query.valid?
                        session[REPORT_BUILDER_MT_REQ_QUERY_KEY] = @query
                    else
                        @query.sort_by = nil
                    end
                rescue
                    @query.sort_by = nil
                end
            end
        end
        
        
        conds = @query.conditions_hash();

        conds[:per_page] = (params[:show_all].blank?) ? 10 : 1000000;
        @pages, @mt_requests = paginate( :maintenance_requests, conds );        
        if params[:print]=="true"
            @print_mode = true
            render :template=>"shared/mt_request/mt_req_report_show", :layout=>"print"
        else
            session[MT_REQ_LIST_ACTION] = params[:action];
            add_messages @query.warnings, :warning
            render :template=>"shared/mt_request/mt_req_report_show";
        end

    end
    
    def mt_req_print
        @mt_req = MaintenanceRequest.find(params[:id])
        render :layout=>"print"
    end
    
    
    #############################
    # Maintenance Company Tasks #
    #############################
    
    def mt_tsk_list
        @tasks = current_user().mt_company_tasks.sort
    end
    
    def mt_tsk_new
        @task = MtCompanyTask.new;
        @task.until_date = DateTime.now;
        @task.from_date = nil
        @buildings = current_user().buildings;
    end
    
    def mt_tsk_create
        cb_to_bool(params[:task],"no_from_date");
        params[:task][:building]  = nil if params[:task][:building_id]=="";
        
        @task = MtCompanyTask.new(params[:task]);
        @task.building_owner = current_user();
        @task.creator = current_user();
        @task.status = MtCompanyTask::CREATED;

        @task.from_date = nil if params[:task][:no_from_date] == true;
        if @task.save
            redirect_to :action=>"mt_tsk_list";
            add_confirmation "TASK CREATED";
        else
            render :action=>"mt_task_new";
        end
    end
    
    def mt_tsk_show
        @task = MtCompanyTask.find(params[:id]);
    end
    
    def mt_tsk_edit
        @task = MtCompanyTask.find(params[:id]);
        @buildings = current_user().buildings;
        if request.post?
            cb_to_bool(params[:task],"no_from_date");
            params[:task][:building]  = nil if params[:task][:building_id]==""

            @task.update_attributes(params[:task]);
            @task.from_date = nil if params[:task][:no_from_date] == true;

            if @task.save
                redirect_to :action=>"mt_tsk_show", :id=>@task;
                add_confirmation "TASK UPDATED";
            end
        end        
    end
    
    def mt_tsk_destroy
        
        if request.post?
            task = MtCompanyTask.find(params[:id]);
        
            # make sure the user can delete the task
            if ( task.building_owner == current_user() )
                task.destroy
                add_confirmation "TASK DELETED";
            end
        end
        
        redirect_to :action=>"mt_tsk_list";
        
    end
        
    #--< private >-----------------------------------
    private
    
    def ensure_owner_exists( redirect=true )
        logger.warn "**** ensure"
        if ( current_user().nil? )
            logger.warn "**** is nil"
            add_error( "NO USER LOGGED IN" ) unless params[:action]=="index";
            redirect_to(:action=>"login") if redirect;
            return false;
        end
        if ( ! current_user().kind_of?(BuildingOwner) )
            logger.warn "**** is not BO"
            add_error "CURRENT USER IS NOT A BUILDING OWNER";
            redirect_to(:action=>"login") if redirect;
            return false;
        end
        logger.warn "**** :-)"
        return true;
    end
    
    def security_approve( obj )
        if obj.respond_to?( :building )
            obj=obj.building
        end
        if obj.building_owner != current_user()
            security_breach
            return false;
        end
        return true;
    end
end
