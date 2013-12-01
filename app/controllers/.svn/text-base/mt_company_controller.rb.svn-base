class MtCompanyController < ApplicationController
    include NewMtReqFormModule, ActionStateModule
    
    before_filter :ensure_mt_company_exists, :only=>[:login, :logout];
    before_filter :authorize_worker, :except => [:login, :logout];
    
    # key for holding the MtRequestQuery this controller uses
    MT_REQ_QUERY_KEY = __FILE__+".MT_REQ_QUERY_KEY";

    # key for holding the mt_req list from which we "broke out" to watch details about mt_reqs and fix them
    MT_REQ_LIST_ACTION = "#{__FILE__}.MT_REQ_LIST_ACTION";    
    
    # key for storing invoicing requests in the session. Used when getting back to an
    # invoice report from a view of a single request.
    INVOICE_QUERY_KEY = "#{__FILE__}.INVOICE_QUERY_KEY";
    
    # key for pager in touched by mt reqs screen
    TOUCHED_PAGER_KEY = "#{__FILE__}.TOUCHED_PAGER_KEY"
    
    def login
        if request.post?
            wkr = MtCompanyWorker.authenticate( params[:username], params[:password], @mt_company.id );
            if ( wkr.nil? )
                add_error "WRONG USERNAME PASSWORD";
                log_user_login( params[:username], MtCompanyWorker.name, false )
            else
                start_session( wkr );
                set_current_user( wkr );
                log_user_login( params[:username], MtCompanyWorker.name(), true )
                redirect_to :action=>"index";
            end
        end
    end
    
    def logout
        log_user_logout( current_user.username, MtCompanyWorker.name() )
        clear_session( MtCompanyWorker.name );
        clear_user_session();
        redirect_to :action => "login";
    end
    
    # ===[ ALL ]================================================================================
    
    def index
        @workers = @mt_company.workers;
        
        # find the relevant mt_requests
        qry = MtRequestQuery.create_pending_query( @worker.role.admin? ? @mt_company : @worker );
        qry.from_date = 1.week.ago
        qry.limit = 5;
        qry.sort_by = MtRequestQuery::KEY_CREATED_ON;
        qry.descending = true;
        @mt_requests = MaintenanceRequest.find( :all, qry.conditions_hash );
        
        @new_task_count = @mt_company.new_tasks.size();
        @tasks = @mt_company.pending_tasks().sort{|a,b| a.until_date <=> b.until_date }[0..9];
        
        if @worker.role.admin?
            @req_action = "mt_requests_list";
        elsif @worker.role.professional? 
            @req_action = "pending_mt_requests";
        else
             "my_mt_requests";
        end
        
        @buildings_action = @worker.role.admin? ? "building_list" : "my_buildings";
        
        @delivery_methods = [];
        @delivery_methods << KVObj.new( "sms", "sms" );
        @delivery_methods << KVObj.new( "mail", "e-mail" );
        
        pgr = RSPager.new(TouchedByQuery.new( current_user ));
        pgr.page_size = 7
        @touched_mt_reqs = pgr.get_current_page();
        
        @refresh = true;
    end
    
    def contacts_list        
        @sort_by = params[:sort_by];
        @sort_by ||= "nam";
        @workers = sort_workers(@mt_company.workers(), @sort_by);
        
        @print_mode = (params[:print] == "true");
        if (params[:print] == "true")
            
            render :layout=>"print";
        end
    end
        
    def mt_req_show
        @req = MaintenanceRequest.find(params[:id]);
        @back = params[:back];        
        
        if ( params[:popup] == true.to_s )
            @popup_mode = true;
            render :layout=>"popup";
        end
        
    end

    def mt_req_print
        @req = MaintenanceRequest.find(params[:id]);
        render :layout=>"print";
        @do_not_close = true;
    end
    
    def change_mt_request_state
        @req = MaintenanceRequest.find(params[:id]);
        @workers = @mt_company.workers();
        @back = params[:back]
        
        if request.post?
           if ( @req.update_attributes(params[:req]) ) 
               add_info "CHANGES_SAVED SUCCESSFULLY";
               redirect_to :action=>"mt_req_show", :id=>params[:id], :back=>@back;
            else
                add_errors_of( @req );
           end
        end
    end
    
    def mt_req_report_build
        if @worker.role.admin?
            @buildings = @mt_company.buildings;
        else
            @buildings = @worker.buildings;
        end
        
        #@query = get_state()
        if ! session[MT_REQ_QUERY_KEY].blank?
            # load last query data
            @query = session[MT_REQ_QUERY_KEY]; 
        else
            # enter default data
            @query = MtRequestQuery.new
            @query.from_date = Localization::localizer().now().to_date() - 10;
            @query.until_date = Localization::localizer().now().to_date();
            @query.building_ids = @buildings.collect{ |bld| bld.id };
            @query.add_state( MaintenanceRequest::OPEN );
            @query.add_state( MaintenanceRequest::IN_PROGRESS );
        end
        
        @js_files = ['date-picker'];
    end
    
    def mt_req_report_show

        if ( ! params[:query].nil? )
            # a new query has been asked
            @query = MtRequestQuery.new
            @query.parse( params[:query] )
            
            @query.add_mt_company( @mt_company.id )

            if @worker.role.admin?
              buildings = @mt_company.buildings;
            else
              buildings = @worker.buildings;
            end
            
            # if there is only one building, add it.
            if ( buildings.size == 1)
              @query.add_building( buildings.first.id );
            end
            
            session[MT_REQ_QUERY_KEY] = @query
            unless @query.valid?
              # query is not valid. complain using the report building screen
              redirect_to :action=>"mt_req_report_build"
              return
            end
            
            @query.warnings.each {|wrn| add_warning(wrn) }

        elsif ! session[MT_REQ_QUERY_KEY].blank?
            # we were already asked a question, now probably paging.
            @query = session[MT_REQ_QUERY_KEY];

            unless params[:sort_by].blank?
                begin
                    @query.update_sort_by(params[:sort_by].to_i)
                    if @query.valid?
                        session[MT_REQ_QUERY_KEY] = @query
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
            render :template=>"shared/mt_request/mt_req_report_show";
        end
    
    end
    
    def mt_req_new
        if ( request.post? )
            # create the maintenance request 
            @mt_req = parse_new_mt_req_form();
            unless ( @mt_req.nil? ) 
                add_files_to_mt_req( @mt_req )
                redirect_to :action=>:mt_requests_list;
            end
        else
            # setup the data for the form
            @mt_req = MaintenanceRequest.new();
            @buildings = @mt_company.buildings;
        end
    end
    
    ####################
    # mt company tasks #
    ####################
    
    def mt_tsk_new
        @task = MtCompanyTask.new();
        @task.until_date = DateTime.now;
        @task.from_date = nil;
        @buildings = @mt_company.buildings;
    end
    
    def mt_tsk_create
        cb_to_bool(params[:task],"no_from_date");
        params[:task][:building]  = nil if params[:task][:building_id]=="";
        
        @task = MtCompanyTask.new(params[:task]);
        @task.creator = @worker
        @task.mt_company = @mt_company
        @task.status = MtCompanyTask::CREATED;

        @task.from_date = nil if params[:task][:no_from_date] == true;
        if @task.save
            redirect_to :action=>"mt_tsk_list";
            add_confirmation "TASK CREATED";
        else
            render :action=>"mt_task_new";
        end
    end
    
    def mt_tsk_destroy
    end
    
    def mt_tsk_list
        @new = false
        @tasks = @mt_company.pending_tasks
        render :action=>"mt_tsk_list";
    end
    
    def mt_tsk_new_list
        @new = true
        @tasks = @mt_company.new_tasks
        render :action=>"mt_tsk_list";
    end
    
    def mt_tsk_accept
        @task = MtCompanyTask.find(params[:id]);
        @task.status = MtCompanyTask::ACCEPTED;
        @task.save!
        redirect_to :action=>params[:return_to]
    end
    
    def mt_tsk_show
        @task = MtCompanyTask.find(params[:id]);
        security_breach() if @task.mt_company != @mt_company
    end
    
    def mt_tsk_edit
        @task = MtCompanyTask.find(params[:id]);
        if @task.mt_company != @mt_company
            security_breach() 
            return
        end
        if request.post?
            if @task.update_attributes(params[:task])
                add_confirmation "TASK UPDATED";
                redirect_to :action=>"mt_tsk_show", :id => @task; 
            end
        end
    end
    
    # create an mt_request from the passed mt_company_task id
    # TODO make this a POST request.
    def mt_tsk_create_request
        task = MtCompanyTask.find( params[:id] );
        req = MaintenanceRequest.new();
        
        req.title = task.title;
        req.remarks = task.description;        
        unless ( task.building.nil? )
            req.building = task.building;
        end
        req.reporter = @worker;
                
        req.mt_company_task = task;
        req.mt_company = @mt_company
        task.maintenance_request = req;
        
        begin
            req.save!
            task.save!
            add_confirmation "MT_REQ CREATED"
            redirect_to :action=>:mt_req_show, :id=>req.id, :back=>:mt_tsk_list;
        rescue Exception=>e
            add_error e.message
            redirect_to :action=>:mt_tsk_show, :id=>params[:id];
        end
    end
    
    def touched_mt_reqs
        @pgr = get_state(){ RSPager.new(TouchedByQuery.new( current_user )) }
        @pgr.current_page = params[@pgr.name] unless params[@pgr.name].blank?
        @pgr.pagee.update_order_by( params[:order_by] ) unless params[:order_by].blank?
        @reqs = @pgr.get_current_page();
    end
    
    # ===[ Professionals ]=======================================================================
    def pending_mt_requests
                
        if session[MT_REQ_QUERY_KEY].blank? || params[:fresh]==true.to_s
            # first time around, create the query and store in the session
            @query = MtRequestQuery.create_pending_query( @worker );
            @query.sort_by = params[:sort_by] unless params[:sort_by].blank?
            session[MT_REQ_QUERY_KEY] = @query;
        else
            # start copy-paste from mt_req_report_show
            # we were already asked a question, now probably paging / re-sorting.
            @query = session[MT_REQ_QUERY_KEY];

            unless params[:sort_by].blank?
                begin
                    @query.update_sort_by(params[:sort_by].to_i)
                    if @query.valid?
                        session[MT_REQ_QUERY_KEY] = @query
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
            @edit_action = :mt_req_report_build;
            render :template=>"shared/mt_request/mt_req_report_show";
        end
        # end copy-paste from mt_req_report_show
    end
    
    # ===[ Building Manager ]====================================================================
    def my_buildings
        
    end

    def my_mt_requests
        @back = :my_mt_requests;
        
        # sort
        @sort_by = params[:sort_by];
        @reqs = sort_mt_requests(@mt_company.find_relvant_mt_requests(true, @worker), @sort_by);
        
        @page_title = @mt_company.name + " - " + "תקלות ";
        @print_mode = (params[:print] == "true");
        if (params[:print] == "true")
            render :layout=>"print";
        end
    end
    
    
    # ===[ ADMIN ]===============================================================================
   
    def mt_requests_list
        
        @pgr = get_state(){ RSPager.new(MtRequestQuery.create_pending_query( current_user )) }
        @pgr.current_page = params[@pgr.name] unless params[@pgr.name].blank?
        if ( params[:order_by].blank? )
            @pgr.pagee.update_order_by( MtRequestQuery::KEY_UPDATED_ON )
            @pgr.pagee.descending = true;
        else
            @pgr.pagee.update_order_by( params[:order_by] )
        end

        @reqs = @pgr.get_current_page();

        @print_mode = (params[:print] == "true");        

        if (params[:print] == "true")
            render :layout=>"print";
        end
    end
    
    def mt_requests_list_control
        # get the requests
        @sort_by = params[:sort_by];
                
        if ( request.post? )
           if params[:command] == "accept"
               a_req = MaintenanceRequest.find(params[:id]);
               a_req.accepted = true;
               a_req.save!
          end
        end
        
        @reqs = sort_mt_requests(@mt_company.find_relvant_mt_requests(), @sort_by);
        
        render :layout=>false;
    end
    
    
    ###################
    # invioce reports #
    ###################
    
    def invoice_reports
        @start = Date.today
        @end = Date.today+30;
    end
    
    def invoice_report_monthly
        unless params[:date].nil?
           @query = MtRequestQuery.new;
          
           start_date = Time.mktime(params[:date][:year].to_i, params[:date][:month].to_i, 1,0,0,0,0)
           end_date = start_date.end_of_month.at_midnight
       
           @query.fixed_from_date = start_date;
           @query.fixed_until_date = end_date.change({:hour=>23,:min=>59,:sec=>59});
       end
       invoice_report_show
    end
    
    def invoice_report_yearly
        unless params[:date].nil?
            @query = MtRequestQuery.new;
            
            start_date = Time.mktime(params[:date][:year].to_i, 1, 1,0,0,0,0)
            end_date = Time.mktime(params[:date][:year].to_i, 12, 31,23,59,59,0)

            @query.fixed_from_date = start_date;
            @query.fixed_until_date = end_date;
        end
        invoice_report_show
    end
    
    def invoice_report_periodic
        unless params[:start].nil?
            @query = MtRequestQuery.new;
            
            start_date = Time.mktime(params[:start]["clone(1i)"].to_i, params[:start]["clone(2i)"].to_i, params[:start]["clone(3i)"].to_i,0,0,0,0)
            end_date = Time.mktime(params[:end]["clone(1i)"].to_i, params[:end]["clone(2i)"].to_i, params[:end]["clone(3i)"].to_i,23,59,59,0)

            @query.fixed_from_date = start_date;
            @query.fixed_until_date = end_date;
        end
        
        invoice_report_show
    end
    
    def invoice_report_show
        if ( @query.nil? )
            @query = session[ INVOICE_QUERY_KEY ]
        else
            @query.add_mt_company( @mt_company );
            @query.sort_by = MtRequestQuery::KEY_SOLVED_ON;
            @query.add_state( MaintenanceRequest::DEBIT_PENDING );
            
            session[ INVOICE_QUERY_KEY ] = @query
        end
        conds = @query.conditions_hash();
        
        if ( params[:report_type].blank? )
            conds[:per_page] = 1000000;
            @pages, @mt_requests = paginate( :maintenance_requests, conds );
            @print_mode = false;
            render( :action=>:invoice_report_show );
            
        elsif ( params[:report_type]=="print")
            conds[:per_page] = 1000000;
            @pages, @mt_requests = paginate( :maintenance_requests, conds );
            @print_mode = true;
            render( :action=>:invoice_report_show, :layout=>"print");
            
        else
            @mt_requests = MaintenanceRequest.find(:all, conds );
            type = nil;
            if ( params[:report_type]=="text" )
                xls_report = render_to_string( :action=>:invoice_report_tsv, :layout=>false )
                type = "application/text";
                suffix = "txt"
            elsif ( params[:report_type]=="xls" )
                xls_report = render_to_string( :action=>:invoice_report_xls, :layout=>false )
                type = "application/excel"
                suffix = "xls"
            else
                add_error("UNSUPPRTED_FILE_TYPE")
            end
            if ( type != nil )
                title = "invoice report.#{suffix}";
                send_data( xls_report, {:filename=>title, :type=>type, :disposition=>"attachment"  })
            else
               render( :action=>:invoice_report_show )
            end
        end
    end
    
    def mark_as_debited
        if ( params[:request].nil? )
            add_warning( "NO_REQUESTS_SELECTED ")
        else
            params[:request].each do |num, id |
                begin
                    mreq = MaintenanceRequest.find(id)
                    mreq.state = MaintenanceRequest::DEBIT_DONE
                    mreq.save!
                rescue Exception=>e
                    add_error( e.message )
                end
           end
           add_confirmation("REQUESTS_MAKRED_AS_DEBITED");
       end
       redirect_to :action=>:invoice_report_show
    end
    
    # personal details #-------------------------------------------------------------------------
    def personal_details
    end
    
    def edit_personal_details
        @roles = @mt_company.roles();
        @urgencies = MaintenanceRequest.urgencies.clone();
        @urgencies << KVObj.new( 5, "NEVER" );
        
    end
    
    def update_personal_details
        if @worker.update_attributes(params[:worker])
            add_confirmation "SAVED SUCCESSFULLY";
            redirect_to( :action=>"personal_details" );
        else
            add_errors_of @worker;
            edit_personal_details;
            render( :action=>:edit_personal_details, :id=>params[:id] );
        end
    end
    
    # company details #--------------------------------------------------------------------------
    def company_details
    end
    
    def edit_company_details
    end

    def company_details_update
        @mt_company = MtCompany.find(params[:id]);
        params[:mt_company][:site] = fix_link( params[:mt_company][:site] );
        if @mt_company.update_attributes(params[:mt_company]);
            add_confirmation 'CHANGES SAVED';
            redirect_to :action => 'company_details';
        else
            render :action => 'mt_company_edit';
        end
    end
    
    # roles #------------------------------------------------------------------------------------    
    def role_list
        @roles = @mt_company.roles();
    end
    
    def show_role
        @role = MtCompanyWorkerRole.find(params[:id]);
        security_breach() if @role.mt_company != @mt_company 
    end
     
    def edit_role
        @role = MtCompanyWorkerRole.find(params[:id]);
        security_breach() if @role.mt_company != @mt_company
    end
    
    def new_role
        @role = MtCompanyWorkerRole.new();
        @role.name = "תפקיד חדש";
        @role.admin = false;
        @role.building_manager = true;
    end
    
    def update_role
        
        cb_to_bool(params[:role], [:building_manager, :admin, :professional]);
        
        if params[:id].nil?
            @role = MtCompanyWorkerRole.new();
            @role.mt_company = @mt_company;
        else
            @role = MtCompanyWorkerRole.find(params[:id]);
            if @role.mt_company != @mt_company
                security_breach()
                return
            end
        end
        
        begin    
            if @role.update_attributes(params[:role])
                add_confirmation "CHANGES SAVED";
                redirect_to(:action=>"role_list");
            else
                add_errors_of( @role );
                redirect_to(:action=>"edit_role", :id=>@role);
            end
        rescue Exception=>e
            add_error e.message;
            add_errors_of @role;
            redirect_to(:action=>"edit_role", :id=>@role);
        end
    end
    
    def role_destroy
        @role = MtCompanyWorkerRole.find(params[:id]);
        if @role.mt_company != @mt_company
            security_breach()
            return
        end
        if (params[:solution] == nil )
            # first time around. make sure we can delete the role
            if ( @mt_company.roles.size == 0 ) 
                @reason = "LAST_ROLE";
                return;
            end
        
            if ( @mt_company.workers(@role).size > 0 )
                @reason = "WORKERS_EXIST"
                @roles_left = @mt_company.roles;
                @roles_left.delete(@role);
                return;
            end        
        else 
            # second time, find what the user wants and do it
            sol = params[:solution];
            begin
                if sol == "DELETE_WORKERS" 
                    for wkr in @mt_company.workers(@role)
                        wkr.destroy
                    end
                elsif sol == "MOVE_TO_ROLE"
                    new_role = MtCompanyWorkerRole.find(params[:new_role][:id]);
                    for wkr in @mt_company.workers(@role)
                        wkr.mt_company_role = new_role;
                        wkr.save!
                    end
                end
            rescue Exception => exp
               add_error exp;
            end
        end
        
        # try to delete, handle exceptions
        begin
            @role.destroy
            add_confirmation "role deleted"
        rescue Exception=>e
            add_error e.message;
        end
        redirect_to(:action=>"role_list");
        
    end
    
    # workers #----------------------------------------------------------------------------------
    
    def worker_list
        @pgr = get_state() do 
            RSPager.new( ARPagee.new(MtCompanyWorker, :conditions=>["mt_company_id=?", @mt_company.id], :order=>"surname") ) 
        end
        @pgr.current_page = params[@pgr.name] unless params[@pgr.name].blank?
        @workers = @pgr.get_current_page
    end
    
    def new_worker
        @fresh_worker = MtCompanyWorker.new();
        @fresh_worker.mt_company_role = @mt_company.roles().first;
    end
    
    def edit_worker
        @fresh_worker = MtCompanyWorker.find(params[:id]);
        security_breach( @return_to) if (@fresh_worker.mt_company != @mt_company )
    end
    
    # shows a single worker. When called with "ref"=>"action", returns to the action.
    # default value for ref is :worker_list.
    def view_worker
        @fresh_worker = MtCompanyWorker.find(params[:id]);
        @return_to = params[:ref];
        @return_to ||= "worker_list";
        security_breach( @return_to) if (@fresh_worker.mt_company != @mt_company )
        if ( request.post? )
           if ( params[:reason] == "send_sms" )
               begin
                   SMS::deliver_sms(@fresh_worker.mobile, params[:sms_text]);
                   add_confirmation "SMS SENT";
                rescue Exception=>e
                    add_error e
                end
           end 
        end
    end
    
    def update_worker
        if params[:id].nil?
            @fresh_worker = MtCompanyWorker.new();
            @fresh_worker.mt_company = @mt_company;
        else
            @fresh_worker = MtCompanyWorker.find(params[:id]);
            if (@fresh_worker.mt_company != @mt_company )
                security_breach( @return_to) 
                return
            end
            
        end
        
        begin    
            if @fresh_worker.update_attributes(params[:fresh_worker])
                add_confirmation "CHANGES SAVED";
                redirect_to(:action=>"worker_list");
            else
                add_errors_of( @fresh_worker );
                if params[:id]==nil
                    render(:action=>"new_worker");
                else
                    render(:action=>"edit_worker", :id=>@fresh_worker);
                end
            end
        rescue ActiveRecord::InvalidException=>e
            add_errors_of e.record;
            if params[:id]==nil
                render(:action=>"new_worker");
            else
                redirect_to(:action=>"edit_worker", :id=>@fresh_worker);
            end
        end
    end
    
    def destroy_worker
        return unless request.post?
        
        @fresh_worker = MtCompanyWorker.find(params[:id]);
        if @fresh_worker.mt_company != @mt_company
            security_breach()
            return
        end
        begin
            @fresh_worker.destroy();
        rescue Exception => e
            add_error e.message;
        end
        redirect_to(:action=>"worker_list");
        
    end
    
    # buildings #----------------------------------------------------------------------------------
    
    def building_list
        @buildings = @mt_company.buildings();
    end
    
    def show_building
        @building = Building.find(params[:id]);
        security_breach if (@building.mt_company != @mt_company)
        
        @back_action = params[:back_action];
        @back_action ||= "building_list";
    end
    
    def edit_building
        @building = Building.find(params[:id]);
        security_breach if (@building.mt_company != @mt_company)
        @managers = @mt_company.house_managers();
        @managers << KVObj.new(nil, "[none]");
    end
    
    def update_building
        
        @building = Building.find(params[:id]);
        if (@building.mt_company != @mt_company)
            security_breach 
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
            redirect_to(:action=>"show_building", :id=>@building );
        else
            add_errors_of( @building );
            render(:action=>"edit_building", :id=>@building );
        end
        
    end
    
    ### privacy #################################################################################
    private
    
    # makes sure we have an mt_company. fills @mt_company, or redirects
    def ensure_mt_company_exists
        begin
            @mt_company = MtCompany.find(session[MtCompany.name]);
            throw Exception if @mt_company.nil? 
        rescue
            redirect_to :action=>"mt_companies", :controller=>"general";
            return false;
        end
        
        return true;
    end

    # makes sure we have an mt_company worker. fills @worker, or redirects    
    def ensure_mt_company_worker_exists
        begin
            @worker = MtCompanyWorker.find(session[MtCompanyWorker.name]);
            throw Exception if current_user.nil?
            throw Exception if @worker.nil? 
        rescue
            redirect_to :action=>"login";
            return false;
        end
        
        return true;
    end
    
    def authorize_worker
        return false unless ensure_mt_company_exists();
        return false unless ensure_mt_company_worker_exists();
        
        if @worker.mt_company_id != @mt_company.id
            add_error "MT_COMPANY AND WORKER DO NOT MATCH";
            redirect_to :action=>"login";
            return false;
        end
        
        return true;
    end
        
    def sort_workers(wkr_arr, sort_string)
        case (sort_string)
           when "nam"
               return wkr_arr.sort{ |a,b| a.hr_name <=> b.hr_name };
           when "phn"
               return wkr_arr.sort{ |a,b| a.mobile <=> b.mobile };
           when "eml"
               return wkr_arr.sort{ |a,b| a.email <=> b.email };
           when "rol"
               return wkr_arr.sort{ |a,b| a.role.name <=> b.role.name };
           when "bpr"
               return wkr_arr.sort{ |a,b| a.beeper <=> b.beeper };
           else
               #default: sort according to nam
               return wkr_arr.sort{ |a,b| a.hr_name <=> b.hr_name };
        end
    end
    
end
