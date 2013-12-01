require 'KVObj'
require 'r_s_pager/r_s_pager'
require 'r_s_pager/pagee'
require 'r_s_pager/sql_pagee'
require 'r_s_pager/unit_contract_sql_pagee'
require 'r_s_pager/a_r_pagee'
require 'r_s_pager/a_r_o_pagee'
require 'r_s_pager/touched_by_query'
require 'r_s_pager/user_related_mt_reqs_query'
require "r_s_pager/unit_contracts_by_owner_pagee"
require "r_s_pager/unit_contracts_by_building_pagee"

# Filters added to this controller will be run for all controllers in the application.
# Likewise, all the methods added will be available for all controllers.
class ApplicationController < ActionController::Base
    include HashMarshaler, UniqueIdModule
    
    helper :r_s_pagination;
    helper_method :add_error, :add_warning, :add_info;
    
    # keys for the session object.
    KEY_CURRENT_USER_ID    = "ApplicationController::CURRENT_USER_ID";
    KEY_CURRENT_USER_CLASS = "ApplicationController::CURRENT_USER_CLASS";


    def unimplemented
        render :template=>"/shared/unimplemented";
    end
    
    # return the logged-in user. Lazy-eval.
    def current_user
        if @current_user.nil?
            if ( ! session[KEY_CURRENT_USER_ID].blank? )
                user_class = session[KEY_CURRENT_USER_CLASS];
                return nil if user_class.blank?
                @current_user = user_class.instance_eval( "#{user_class}.find(#{session[KEY_CURRENT_USER_ID]})" );
            end
        end
        return @current_user;
    end
    
    # set the logged in user. Note that we can't user read/write session as the user class might change.
    def set_current_user( a_new_user ) 
        @current_user=a_new_user;
        if ( @current_user != nil )
            session[KEY_CURRENT_USER_ID]    = @current_user.id;
            session[KEY_CURRENT_USER_CLASS] = @current_user.class.to_s;
        else
            session[KEY_CURRENT_USER_ID]    = nil;
            session[KEY_CURRENT_USER_CLASS] = nil;
        end
    end
    
    ## <PRIVACY> ##################################
    private
    
    def reset_localization
        HebrewLocalization.instance().reset;
    end
    
    # converts the values stored by check-boxes 
    # to those understood by rails.
    def cb_to_bool( hash, key_arr ) 
        key_arr = [key_arr] unless key_arr.kind_of?( Array );
        
    	key_arr.each { |key|
    		if hash[key].nil?
    			hash[key] = false;
    		else
    			hash[key] = true;
    		end
    	}

    	return hash;
    end
    
    def is_numeric( a_string ) 
        return ! a_string.strip.match(/^[0-9]+(.[0-9]*)$/).nil?
    end
    
    # returns the list of flat state in a popup-menu ready mode
    def getFlatStates
      arr = []
      Flat::STATES.each do |name|
          p = KVObj.new( name, name )
          arr << p
      end
      arr
    end
    
    def fix_link( aLink )
        return aLink if (aLink.length == 0 )
        
        comps = aLink.split("://")
        if comps.size == 1 
            if (aLink =~ /[a-zA-Z]*:\/\/$/) == nil
                # no protocol decleration, assume it's http
                aLink = "http://" + aLink
            else
                # we have only the protocol declaration. ignore.
            end
        end
        
        @link = aLink; # TODO do we need this?
        return aLink;
    end
    
    # abbreviates the text to the maximum of wordcount, and appends elipsis if needed.
    def abbreviate( text, wordcount )
        return "" if (text == nil);
        comps = text.gsub(/(\s)+/, " ").split(" ");
        res = "";
        limit = wordcount;
        limit = comps.size if limit > comps.size;
        limit = 0 if limit < 2 

        for i in 0..(limit-2)
            res = res + comps[i] + " ";
        end
        res += comps[limit-1] if comps[limit-1] != nil;

        res += "..." if comps.size > wordcount;

        return res;
    end
    
    def authorize_vaad_admin
        
        return false unless ensure_building_exists();
        
        unless ( ensure_tenant_exists( false ) || ensure_user_exists( false ) )            
            add_error "NO_USER_AND_NO_TENANT";
            redirect_to :controller=>"guest";
            return false;
        end
        

        # invariant: we have a tenant/user and a building
        @human = @tenant;
        @human ||= @user;
        
        if (@human.building_id != @building.id)
            redirect_to( :controller=>"guest" );
            add_error "WRONG_BUILDING";
            return false;
        end
        
        if ( ! @human.can_manage_site? )
            add_error "FORBIDDEN_FOR_USER"
            redirect_to(:controller => "guest", :action => "index");
            return false;
        end

    end
    
    def authorize_tenant
        
        return false unless ensure_tenant_exists();
        return false unless ensure_building_exists();

        if ( @tenant.building_id != @building.id )
            redirect_to( :controller=>"guest" );
            return false;
        end
    end
    
    # makes sure that the session contains a building, or redirects the response to 
    # the no-building page
    def ensure_building_exists( redirect=true )
        begin
            building_id = session[Building.name];
            building_id ||= session[BusinessBuilding.name];
            
            @building = Building.find(building_id);
            throw Exception if @building.nil?
        rescue
            add_error "NONEXISTANT BUILDING";
            logger.error("NONEXISTANT BUILDING");
            redirect_to(:controller=>"dispatcher") if redirect;
            return false;
        end
        
        return true;
    end

    # makes sure the tenant exists (or redirects to guests). fills @tenant
    def ensure_tenant_exists( redirect=true )       
        begin
            @tenant = Tenant.find(session[Tenant.name]);
            throw Exception if @tenant.nil?
        rescue
            redirect_to(:controller=>"guest") if redirect;
            return false;
        end
        
        return true;        
    end

    # makes sure the user exists (or redirects to guests). fills @user
    def ensure_user_exists( redirect=true )    
        begin
            @user = User.find(session[User.name]);
            throw Exception if @user.nil?
        rescue
            redirect_to(:controller=>"guest") if redirect;
            return false;
        end
        
        return true;        
    end
    
    # generic session-control
    # TODO deprecate and move to write_session
    def start_session( obj ) 
        session[ obj.class.name ] = obj.id;
    end
    
    def write_session( obj )
        session[ obj.class.name ] = obj.id;
    end
    
    
    def read_session( class_name )
        if class_name.class == Class
            class_name = class_name.name;
        end
        
        if class_name.class != String
            throw "clear_session invoked with a non-string/class object";
        end
        
        return session[class_name];
    end
    
    def clear_session( class_name )
        if class_name.class == Class
            class_name = class_name.name;
        end
        
        if class_name.class != String
            throw "clear_session invoked with a non-string object";
        end
        
        session[ class_name ] = nil;
    end
    
    # clear all user-related data in the session.
    def clear_user_session()
        set_current_user( nil );
    end
    
    # fills the session object with tenant-relevant data
    def set_session_tenant( aTenant )
        start_session( aTenant );
        set_current_user( aTenant );
        session[:msg_nituk] = "התנתק";
    	session[:msg_nituk] +="י" unless aTenant.is_male;
    	
    	# TODO localize
    	if aTenant.is_male
    		session[:msg_login_status] =  "הנך מחובר כדייר";
    		session[:msg_login_status] += " וכמנהל" if aTenant.can_manage_site?;
    	else
    		session[:msg_login_status] = "הנך מחוברת כדיירת";
    		session[:msg_login_status] += " וכמנהלת" if aTenant.can_manage_site?;		
    	end
    end
    
    def clear_session_tenant
        clear_session( Tenant.name );
        set_current_user( nil );
        session[:msg_nituk] = nil;
		session[:msg_login_status] = nil;
    end

    # sort the request array according to the request string.
    # TODO depricate! this should be implemented using the keys in MtRequestQuery
    def sort_mt_requests( request_array, sort_string )
        case (sort_string)
           when "bld"
               return request_array.sort{ |a,b| a.building.hr_address <=> b.building.hr_address };
           when "urg"
               return request_array.sort{ |a,b| -(a.urgency <=> b.urgency) };
           when "dte"
               return request_array.sort{ |a,b| -(a.created_on <=> b.created_on) };
           when "dsc"
               return request_array.sort{ |a,b| a.title <=> b.title };
           when "stt"
               return request_array.sort{ |a,b| a.state <=> b.state };
           when "stp"
                return request_array.sort{ |a,b| a.service_type <=> b.service_type };
           else
               #default: sort according to urgency
               return request_array.sort{ |a,b| -(a.urgency <=> b.urgency) };
        end
    end
    
    # TODO move to an ARPagee
    def sort_businesses( biz_array, criteria )
        case criteria    
        when "NAME", nil
            return biz_array.sort{|e1,e2| e1.name <=> e2.name }
        when "BUILDING"
            return biz_array.sort{|e1,e2| e1.building <=> e2.building }
        when "UNIT_NUM"
            return biz_array.sort{|e1,e2| e1.building_units.size <=> e2.building_units.size }
        when "EMAIL"   
            return biz_array.sort{|e1,e2| e1.email <=> e2.email  }
        when "PHONE"   
            return biz_array.sort{|e1,e2| e1.phone <=> e2.phone   }
        when "FAX"     
            return biz_array.sort{|e1,e2| e1.fax <=> e2.fax }
        end
    end
    
    # adds a message to the flash messaging system. 
    # now=true means that the message will be kept for a single action only
    def add_to_message_list( symbol, message  )
        session[:messages] = {} if ( session[:messages].nil? )
        session[:messages][symbol] = [] if (session[:messages][symbol].nil?)
        session[:messages][symbol] << message;
    end

    # add a message with an info sign
    def add_info( message )
        add_to_message_list :notice, message;
    end
    
    # add a message with a warning sign
    def add_warning( message )
        add_to_message_list :warning, message;
    end
    
    # add a message with an error sign
    def add_error( message )
        add_to_message_list :error, message;
    end
    
    # add a message with an error sign
    def add_confirmation( message )
        add_to_message_list :confirmation, message;
    end
    
    # add the errors of an ActiveRecord object to the general error messages
    def add_errors_of(ac_obj)
        if ac_obj && !ac_obj.errors.empty?
            msgs = ac_obj.errors.collect{|mh| mh[1] }
            add_messages msgs, :error
        end
    end
    
    # add the strings as messages
    def add_messages( string_arr, key )
        string_arr.each { |msg| 
            add_to_message_list key, msg
        }
    end
    
    # Add a security breach warning, and redirect somewhere else (index by default)
    def security_breach( action=:index )
       add_warning( "SECURITY.BREACH");
       redirect_to :action=>action
    end
    
    # todo deprecate!
    def paginate_collection(collection, options = {})
        default_options = {:per_page => 10, :page => 1}
        options = default_options.merge options

        pages = Paginator.new self, collection.size, options[:per_page], options[:page]
        first = pages.current.offset
        last = [first + options[:per_page], collection.size].min
        slice = collection[first...last]
        return [pages, slice]
      end
    
    def log_user_login( username, user_type, successful )
        log "USER_ACTION, LOGIN, #{username}, #{user_type}, #{successful}"
    end
    
    def log_user_logout( username, user_type )
        log "USER_ACTION, LOGOUT, #{username}, #{user_type}"
    end
    
    def log( string )
        logger.info( "[RS] #{HebrewLocalization.instance().now}, #{string}")
    end
    
end

