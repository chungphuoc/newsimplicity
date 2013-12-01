class BusinessBuildingController < ApplicationController
    include ActionStateModule, NewMtReqFormModule
    
    # TODO deprecate @user and use current_user()
    before_filter :ensure_user_exists, :except=>[ :login, :logout, :biz_list, :guest_index ];
    
    # types of ready reports.
    MT_QUERY_TYPE_PENDING = "pnd";
    MT_QUERY_TYPE_TO_BE_DEBITED = "tbd";
    MT_QUERY_TYPE_DEBITED = "dbt";
    MT_QUERY_TYPE_REPORTED_BY_USER = "rbu";
    
    def index
        if @user==nil
           redirect_to :action=>:login;
           return; 
        end

        pgr = RSPager.new( UserRelatedMtReqsQuery.new(@user) );
        pgr.page_size=9;
        @mt_requests = pgr.get_current_page;
        
        @users = @user.business.users.sort
        @delivery_methods = [];
        @delivery_methods << KVObj.new( "sms", "sms" );
        @delivery_methods << KVObj.new( "mail", "e-mail" );
        
        @mt_req = MaintenanceRequest.new
        @refresh = true;
    end

    def unimplemented
        render :template=>"/shared/unimplemented";
    end

    def directions

    end
    
    # TODO is this used??
    def biz_list
        @businesses = @building.businesses();
        @businesses = @businesses.sort();
        
        if @user.nil? 
            @action = "login";
        else          
            @action = "biz_show";
        end
    end
    
    # TODO is this used??
    def biz_show
        begin
            @business = Business.find(params[:id]);
        rescue
            add_error "Can't find business";
            redirect_to :index;
        end
    end
    
    def login
        begin
            ensure_building_exists
            if ! @building.kind_of?(BusinessBuilding)
               add_error "NOT A BUSINESS BUILDING";
               redirect_to :controller=>"general", :action=>"businesses";
               return;
            end
            
            if ! params[:biz_id].blank?
                @business = Business.find(params[:biz_id]);
            elsif ! read_session( Business.name ).nil?
                @business = Business.find( read_session( Business.name ));
            end
            
            @username = params[:username];
            @username ||= "";
            
            if request.post? 
                # try to log a user in
                if ( @building.is_user_login_unique )
                    user = User.authenticate( params[:username],params[:password], @building.id );
                    business = user.business unless user.nil?
                else
                    business = Business.find(params[:business][:id]);
                    user = User.biz_authenticate( params[:username], params[:password], business.id );
                end
                
                if user != nil
                    # login successful.
                    start_session( user );
                    set_current_user( user );
                    write_session( business );
                    log_user_login( user.username, User.name, true )
                    redirect_to :action=>"index";
                    return;
                end
                
                add_error "WRONG USERNAME PASSWORD";
                log_user_login( params[:username], User.name, false )
            end            
            @businesses = @building.businesses().sort();
       rescue Exception => e
            add_error e.message;
       end
        

    end
    
    def logout
        if ( current_user != nil )
            log_user_logout( current_user.username, User.name )
        else
            log_user_logout( "user is nil", User.name )
        end
        clear_user_session();
        clear_session( Business );
        clear_session( User );
        redirect_to :action=>"login";
    end
    
    ##############
    # my details #
    ##############
    
    def my_details
    end
    
    def my_details_edit
        if request.post?
            if @user.update_attributes(params[:user_form])
                redirect_to :action=>"my_details";
            else
                add_errors_of( @user );
            end
        end
    end
    
    ####################
    # Business Details #
    ####################
    def business_details
        @business = @user.business
    end
    
    def business_edit
        @business = @user.business
    end
    
    def business_update
        @business = Business.find(params[:id]);
        if ( @business != @user.business )
            # user not allowed to change other business
            add_error "BUSINESS / USER MISMATCH"
            redirect_to :action=>:business_details;
            return;
        end
        if @business.update_attributes(params[:business])
            add_info "CHANGES SAVED";
            redirect_to :action=>:business_details;
        else
            add_errors_of( @business );
            render :action=>:business_edit;
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
        @car.business = @user.business;
        if @car.save
            redirect_to( :action=>"business_details" );
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
            redirect_to( :action=>"business_details");
        else
            redirect_to(:action=>"business_details") if @car.update_attributes(params[:car]);
        end
    end
    
    def car_destroy
        car = Car.find(params[:id]);
        if car.business != @user.business 
            add_error "CAR DOES NOT BELONG TO USER BUSINESS";
        else
            add_confirmation "CAR DELETED";
            car.destroy();
        end
        redirect_to( :action=>"business_details");
    end
    
    def car_finder
        unless @building.show_whose_car
            redirect_to :action=>:index
        end
    end
    
    def car_finder_result
        unless @building.show_whose_car
            redirect_to :action=>:index
        end
        @car_num = params[:car][:number];
        @car = Car.find_by_number( @car_num );
    end
    
    ##################
    # unit contracts #
    ##################
    
    def uc_list
        @contracts = @user.business.unit_contracts;
    end
    
    def uc_show
        @contract = UnitContract.find(params[:id]);
    end 
    
    def uc_get_uploaded_file
        uf = UploadedFile.find(params[:id]);
        if ( uf.nil? )
            add_error "UPLOADED FILE NOT FOUND";
            return;
        end
        
        send_data( uf.data,
                    :filename => uf.name,
                    :type => uf.mime_type,
                    :disposition => "attachment" );
        
    end
    
    
    #########
    # users #
    #########
    
    def user_list
        @users = @user.business.users.sort;
    end
    
    def user_show
        @cur_user = User.find(params[:id]);
        security_breach() if @cur_user.business != @business
    end
    
    def user_add
        if request.post?            
            if @user.business != @business
                security_breach() 
                return
            end
            
            # must-have options for stage 1
            @cur_user = User.new(params[:user_form]);
            @cur_user.role = "UR_BIZ_MANAGER";
            @cur_user.business = @user.business;
            
            if @cur_user.save
                add_confirmation "USER SAVED";
                redirect_to :action=>"user_list";
            else
                @cur_user.errors.each_full{ |msg| add_error( msg ) }
            end
        else
            @cur_user = User.new();
        end
    end
    
    def user_edit
        begin
            @cur_user = User.find(params[:id]);
            
            if @cur_user.business != @business
                security_breach() 
                return
            end
            
            if request.post?
               if @cur_user.update_attributes( params[:user_form] );
                   add_confirmation "USER SAVED";
                   redirect_to :action=>"user_show", :id=>@cur_user;
               else
                      add_errors_of @cur_user
               end
           end
        rescue Exception=>e
            add_error e.message;
            redirect_to :action=>"user_list";
        end 
    end

    def user_destroy
        if request.post?
            begin
                cur_user = User.find(params[:id]);
                if cur_user.business != @business
                    security_breach() 
                    return
                end
                if (cur_user == @user )
                    add_error "USER CANNOT DELETE HIMSELF"
                    user_list
                    render :action=>"user_list"
                    return;
                end
                cur_user.destroy;
                add_confirmation "USER_DELETED";
            rescue Exception=>e
                add_error e.message
            end    
        end
        
        redirect_to :action=>"user_list"
    end    
    
    ########################
    # maintenance requests #
    ########################
    
    def mt_req_list
        # get report type
        @type = params[:type];
        @type = MT_QUERY_TYPE_PENDING if @type.blank? # set default option
        
        case ( @type )
        when MT_QUERY_TYPE_PENDING:
            @pgr = get_state( MT_QUERY_TYPE_PENDING ) do
                RSPager.new(UserRelatedMtReqsQuery.new( current_user )) 
            end
            @cols = [:title, :place, :reporter, :service_type, :created_on, :budget_name, :urgency, :state ]

        when MT_QUERY_TYPE_TO_BE_DEBITED:
            @pgr = get_state( MT_QUERY_TYPE_TO_BE_DEBITED ) do
               qry =  UserRelatedMtReqsQuery.new( current_user );
               qry.clear_states();
               qry.add_state( MaintenanceRequest::DEBIT_PENDING );
               RSPager.new( qry )
            end
            @cols = [:title, :place, :service_type, :budget_name, :created_on, :solved_on, :solving_worker, :total_cost ]

        when MT_QUERY_TYPE_DEBITED:
            @pgr = get_state( MT_QUERY_TYPE_DEBITED ) do
               qry =  UserRelatedMtReqsQuery.new( current_user );
               qry.clear_states();
               qry.add_state( MaintenanceRequest::DEBIT_DONE );
               RSPager.new( qry )
            end
            @cols = [:title, :place, :service_type, :budget_name, :created_on, :solved_on, :solving_worker, :total_cost]
        
        when MT_QUERY_TYPE_REPORTED_BY_USER:
            @pgr = get_state( MT_QUERY_TYPE_REPORTED_BY_USER ) do
                qry = MtRequestQuery.new();
                qry.add_reporter( current_user );
                qry.clear_states;
                RSPager.new( qry );
            end
            @cols = [:title, :place, :service_type, :created_on, :total_cost, :state]
        end
        
        @pgr.current_page=params[:page] unless params[:page].blank?
        @pgr.pagee.update_order_by( params[:order_by] ) unless params[:order_by].blank?
        @reqs = @pgr.get_current_page;
    end
    
    def mt_req_report
        
    end
    
    def mt_req_print
        @req = MaintenanceRequest.find(params[:id]);
        render :layout=>"print";
    end
    
    def mt_req_add
       if request.post?
            # try to save
            @mt_req = MaintenanceRequest.new( params[:mt_req] );
            @mt_req.business = @user.business;
            @mt_req.building = @building;
            @mt_req.reporter = @user;
                        
            if parse_mt_req_form
                add_confirmation "MAITENANCE_REQUEST_CREATED";
                if params[:from_action] == "index"
                    redirect_to :action=>"index";
                else
                    redirect_to :action=>"mt_req_list", :type=>MT_QUERY_TYPE_PENDING, :clean_state=>true.to_s()
                end
            else
                add_errors_of( @mt_req )
            end
        else
            @mt_req = MaintenanceRequest.new();
            @mt_req.urgency=2;
        end
    end
    
    def mt_req_show
        @mt_req = MaintenanceRequest.find(params[:id]);
        @find = params[:find];
        
        if params[:back].blank?
            @back_hash = {:action=>"mt_req_list", :find=>@find}
        else
           @back_hash = {:action=>params[:back]} 
           @back_hash.update( HashMarshaler.unmarshal_hash(params[:back_params])) unless params[:back_params].blank?
        end
    end
    
    def mt_req_edit
        @find = params[:find];
        @mt_req = MaintenanceRequest.find(params[:id]);
        
        if request.post?
            @mt_req.update_attributes( params[:mt_req] );
            if parse_mt_req_form
                add_confirmation "MAITENANCE_REQUEST_CREATED";
                redirect_to :action=>"mt_req_show", :id=>@mt_req, :find=>@find;
            end
        end
    end
    
    def mt_req_destroy
        @find = params[:find];
        @mt_req = MaintenanceRequest.find(params[:id]);
        
        if request.post?
            if @mt_req.reporter == @user
                if @mt_req.destroy
                    add_confirmation "MAINTENANCE REQUEST DELETED";
                end
            end
        end
        redirect_to :action=>"mt_req_list", :find=>@find;        
    end
    
    def mt_company
        redirect_to :action=>"index" unless @building.has_mt_company?
        @mt_company = @building.mt_company;
        if @building.mt_building_manager_id != nil
            @worker = MtCompanyWorker.find( @building.mt_building_manager_id );
        end
    end
    
    
    ###########
    # private #
    ###########
    
    private
    
    # loads the user into @user. if no user exists in the session, @user is set to null.
    def attempt_to_load_user
        begin
            @user = User.find( read_session(User) );
        rescue
            @user = nil
        end
    end
    
    # redirects to index if no user is logged in, or if the user and the building do not match
    # populates @user and @business
    def ensure_user_exists
        
        return false unless ensure_building_exists;
        
        attempt_to_load_user();
        
        if @user == nil
            redirect_to :action=>:login and return false;
        elsif @user.business.building != @building
            add_error "USER AND BUILDING DON'T MATCH";
            logout and return false;
        end
        
        @business = @user.business;
        
        return true;
    end
    
    def parse_mt_req_form
        #######
        # Place
        
        if ( params[:place]=="-1")
            # try to use an existing place, in case the user put an existing name of a place
            new_place = get_create_place( @building, params[:other_place])
        else
            new_place = obj_from_unique_id( params[:place] );
        end
        
        @mt_req.place = new_place;
        @mt_req.place_free_text = params[:mt_request_data][:place_free_text].strip;
        
        if new_place.unit_type.is_public
            @find = "public";
        else
            @find = "biz_only";
        end
        
        ###########
        # Assignee
        if ( params[:mtreq_assignee] != nil )
            assignee = obj_from_unique_id(params[:mtreq_assignee]);
            unless assignee.nil?
               @mt_req.assignee = assignee; 
            end
        end
        
        return @mt_req.save
    end
end
