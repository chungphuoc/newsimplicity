class GeneralController < ApplicationController
    
    GENERAL_CONFIG_FILE = "#{RAILS_ROOT}/config/general_controller_defaults.yml";
    
    before_filter :detect_defaults
    
    def buildings
        @buildings = Building.find(:all, :conditions=>"type='Building'")
    end
    
    def mt_companies
        @companies = MtCompany.find_all();
    end
    
    def about_us
    end
    
    def contact
    end
    
    def index
        if ( @defaults_mode )
            @building = Building.find( @defaults["building"] );
            @mt_company = MtCompany.find( @defaults["mt_company"] );
            render :action=>@defaults["index_action"];
        end
    end
    
    def send_contact
        sender  = params[:email];
        subject = params[:subject];
        body    = params[:body]
        
        ContactMailer.deliver_contact(sender, subject, body); 
        add_confirmation "Message sent. Thanks!";
        redirect_to( :action=>:contact );
    end
    
    
    def businesses
        # stage 1: find your building
        @buildings = Building.find(:all, :conditions=>"type='BusinessBuilding'", :order=>"city, street, number");
    end
    
    ###########
    # PRIVACY #
    ###########
    
    private
    
    def detect_defaults
        file_read = false;
        @defaults_mode = false;
        begin
            @defaults = YAML.load_file( GENERAL_CONFIG_FILE );
            file_read = true;
            @defaults_mode = true;
        rescue Exception => e
            add_error e.to_s if file_read;
            @defaults_mode = false;
            @defaults = nil;
        end
    end
end
