class DispatcherController < ApplicationController
    
    def index
        building_not_found
        redirect_to :action=>"building_not_found";
    end
    
    
    def create_building_session
        bld = Building.find_by_address( params[:eng_city], params[:eng_street], params[:eng_number] );
        
        #debug code
        # @params = params
#         @bld = bld
#         return;
        #/debug code
        if bld.nil?
            give_up;
            return;
        else
            clear_session( Building.name );
            start_session( bld );
            
            # replace with visitor when we have time, money and nothing to do
            if bld.class == BusinessBuilding
                redirect_to :action=>"index", :controller=>"business_building";
            elsif bld.class == Building
                redirect_to :action=>"index", :controller=>"guest";
            end
            
            # TODO add cookie-related routing here
        end 
    end
    
    # route the browser to the business building and the business.
    def create_business_building_session
        # get the building
        bld = Building.find_by_address( params[:eng_city], params[:eng_street], params[:eng_number] );
        if bld.nil? 
            give_up
            return;
        end
        
        # get the business
        unless bld.respond_to?(:businesses)
            add_error("BUILDING HAS NO BUSINESSES");
            give_up;
            return;
        end
        bld.businesses.each do |a_biz|
            if a_biz.eng_name == params[:business_eng_name]
                @biz = a_biz;
                break;
            end
        end
        
        if @biz.nil?
            give_up;
            return;
        end
        
        # at this point, we have the building and the business. start the session 
        # and redirect to the business index. redirection to login will be done from there, if needed.
        clear_session( Building.name );
        clear_session( Business.name );
        start_session( bld );
        start_session( @biz );
        
        redirect_to :action=>:index, :controller=>"business_building"
        
        
    end
    
    def create_mt_company_session
        mt_company = MtCompany.find_by_eng_name( params[:eng_name] );
        if mt_company.nil?
            clear_session( MtCompany );
            @eng_name = params[ :eng_name ];
            render :action=>"not_found"
        else
            start_session( mt_company );
            redirect_to :controller => "mt_company";
        end
    end
    
    def building_not_found
    end
    
    def not_found
    end
    
    def system_outage
        # TODO do a dedicated outage page.
        redirect_to "#{request.relative_url_root}/500.html";
    end
    
    def delete_session
        session.delete
        redirect_to :action=>"index"
    end
    
    def reset_loc
        reset_localization
        info("LOCALIZATION RESETED");
        redirect_to :controller=>"general";
    end
    
    # entry point for direct links from emails etc.
    # we look in params[:link]
    def direct_link
        link = params[:link];
        if ( link.blank? )
            add_error("EMPTY DIRECT LINK");
            redirect_to :controller=>"general";
            return;
        end
        begin
            as = ApplicationState.unmarshal(link.strip);
            logger.info "******* as=#{as.to_hash().to_s}"
            logger.info "******* as=#{as.redirect_to_hash().to_s}"
            # TODO see that as.user equals the current user, and hadle in-equality.
            redirect_to :controller=>"mt_company", :action=>"mt_req_show", :id=>"330" #as.redirect_to_hash();
            return;
        rescue Exception => e
            add_error( e.message );
            add_error( "<pre>#{params[:link]}</pre>")
            add_error("BAD DIRECT LINK");
           redirect_to :controller=>"general";
        end
    end
    
    def direct_link_test
        @as = ApplicationState.new()
        @as.user = MtCompanyWorker.find(47);
        @as.controller = "mt_company";
        @as.action = "mt_req_show";
        @as.url_params[:id] = "330";
    end
    
    # ==< Privacy >=======================================
    private
    
    # stop everything and redirect to the error page. dump parameters as needed.
    def give_up
        @eng_city = params[:eng_city];
        @eng_street = params[:eng_street];
        @eng_number = params[:eng_number];
        @business_eng_name = params[:business_eng_name];
        
        clear_session( Building.name );
        render :action=>"building_not_found";
    end
    
end
