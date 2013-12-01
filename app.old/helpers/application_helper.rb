# Methods added to this helper will be available to all templates in the application.
module ApplicationHelper
    include DatePickerHelper
    include HashMarshaler
    include UniqueIdModule
    
public
    
    def loc
        return HebrewLocalization::instance();
        #return Localization::localizer();
    end
    
    def button_link(name, image_name="", options = {}, html_options = {})
        html_options ||= {}
        html_options[:class] = "button_link"
        if image_name != ""
            image_name = image_tag("/images/#{image_name}.png") + "&nbsp;"
        end
        link_to image_name+name, options, html_options
    end
    
    # creates a button with javascript url navigation
    def button_tag( title, url_hash, image="", image_in_own_line=true, popup=false, class_name="" )
        url = popup ? "popWindow(\"#{url_for url_hash}\")" : "navigateTo(\"#{url_for url_hash}\")";
        button_function_tag( title, url, image, image_in_own_line, class_name );
    end

    def button_function_tag( title, function, image="", image_in_own_line=true, class_name="" )
        strBld = [];
        
        # open tag
        strBld << "<button ";
        strBld << "class='#{class_name}' " unless class_name.blank?
        strBld << "onClick='#{function};'>";
        
        # add icon (sometimes)
        if ( ! image.blank? )
            strBld << image_tag(image);
            strBld << "<br/>" if image_in_own_line
        end
        
        strBld << title;
        
        # close tag
        strBld << "</button>";
        
        return strBld.join();
    end


    # returns an un-editable label with the passed str as data
    def data_label( str )
        '<input type="text" disabled="disabled" value="' +h(str) +'" size="30" />'
    end

    def data_text_area( str, rows )
        "<textarea disabled='disabled' rows='#{rows}' />" + h(str) + "</textarea>"
    end

    # create a checkbox whose text affects it.
    def labeled_checkbox( text, checked, object, property )
        tag_id = object.to_s.gsub(/[\[,\]]/, "_") + "_" + property.to_s
        adds = "checked='checked'" if checked

        str = "<input type='checkbox' name='#{object+"["+property.to_s+"]"}' value='#{property}' id='#{tag_id}' #{adds} />&nbsp;"
        str += "<label for='#{tag_id}'><a class='hidden_link' style='display: inline' href=\"javascript:toggleCheckBox('#{tag_id}')\">#{h(text)}</a></label>\n" 

        return str
    end

    def labeled_checkbox_tag( text, id, name, value, checked )
        adds = "checked='checked'" if checked

        str = "<input type='checkbox' name='#{name}' value='#{value}' id='#{id}' #{adds} />&nbsp;"
        str += "<label for='#{id}'><a class='hidden_link' style='display: inline' href=\"javascript:toggleCheckBox('#{id}')\">#{h(text)}</a></label>\n" 

        return str
    end
    
    def icon_service_type( s_type )
        case s_type
            when MaintenanceRequest::SERVICE_TYPE_FIX
              image_name = "fix"
            when MaintenanceRequest::SERVICE_TYPE_QOUTE
                image_name = "qoute"
        end
        
        alt = loc.mt_req_service_type( s_type );
        return image_tag("service_types/#{image_name}.png")
    end
    
    def urgency_icon( urg )
        return image_tag("urgency/#{urg.to_s}.gif");
    end
    
    # return a poppup menu that lists who can be assinged with the maintenance_request
    def assignee_menu( mt_req, building, tag_name = "mtreq_assignee" )
        # build the array from which we will build the select
        arr = [];
        if building!=nil && building.has_mt_company?
            
            if building.has_mt_manager?
                arr << [ "#{building.mt_manager.hr_name} (#{ loc.term(Localization::BUILDING_MANAGER)})",
                        unique_obj_id(building.mt_manager) ];
            else
                #arr << [ "mt_building_manager == nil", "xxx"];
            end
            
            building.mt_company.workers.each do | wkr | 
               if ( wkr.role.professional? )
                   arr << [ "#{wkr.role.name} (#{wkr.hr_name})", unique_obj_id(wkr) ];
               end
            end
            
            arr << [ "#{building.mt_company.name} (#{loc.term(Localization::MT_COMPANY)})", 
                     unique_obj_id(building.mt_company) ];
        else
            if mt_req.has_mt_company?
                mt_req.mt_company.workers.each do | wkr | 
                   if ( wkr.role.professional? )
                       arr << [ "#{wkr.role.name} (#{wkr.hr_name})", unique_obj_id(wkr) ];
                   end
                end 
            end 
        end
        
        if building.respond_to?(:has_owner) && building.has_owner?
           arr << [ "#{building.building_owner} (#{loc.term(Localization::BUILDING_OWNER)})",
                    unique_obj_id(building.building_owner) ];
        end
        
        # TODO add vaad.
        
        selected_id = "";
        selected_id = unique_obj_id(mt_req.assignee) unless mt_req.nil?
        
        return "<select id='#{tag_name.gsub("[","_").gsub("]","")}' name='#{tag_name}'>
                #{options_for_select(arr, selected_id)}
                </select>"; 
    end
    
    # renders a select of possible places user of a business can report mt_reqs on.
    def mt_request_place_menu( id, mt_request, user_or_business, building, other_place_id="other_place" )
        if ( user_or_business == nil )
            bu = nil
        elsif ( user_or_business.kind_of?(Business) )
            bu = user_or_business.building_units;
        elsif ( user_or_business.respond_to?(:business) )
            bu = user_or_business.business.building_units;
        else
            bu=nil
        end

        return render( :partial=>"/shared/places_menu", :locals=>{:select_id=>id, :building=>building, 
                                                                 :mt_request=>mt_request, :building_units=>bu,
                                                                 :other_place_id=>other_place_id } );
    end
    
    # replace the cr/lf/crlf to <br />
    def crlfs_to_brs( text )
        if ( text.nil? || text.strip.blank? )
            return "[אין]";
        else
            escaped = h(text.strip);
            escaped.gsub!(/\r\n/, "<br />");
            escaped.gsub!(/\r|\n/, "<br />");
            return escaped;
        end
    end
    
    # makes a legal id out of a name (obj[value]=>obj_value)
    def name_2_id( a_string ) 
        return a_string.gsub("[","_").gsub("]","");
    end

    # create a link to email the tenant, with the tenant name and all.
    # the do_flat parameter tells the functione whether to write the flat data or not.
    def email_tenant( tenant, do_flat=true )
        if tenant == nil 
            return "?"
        end 

        if ! tenant.email.blank?
            return "<a href='mailto:#{h(tenant.email)}'>#{pp_tenant(tenant, do_flat)}</a>";
        else
            return pp_tenant(tenant, do_flat);
        end
    end
    
    # <, =, >, != select
    def comparison_select(object, method, html_options={})
       arrs = ["<", "=", ">", "!="]
       select( object, method, arrs.collect{|x| [loc.comparison(x), x]}, html_options );
    end
        
    # abbreviates the text to the maximum of wordcount, and appends elipsis if needed.
    def abbreviate( text, wordcount )
        if text.nil? 
            return ""
        end
        comps = text.gsub(/(\s)+/, " ").split(" ");
        res = "";
        limit = wordcount;
        limit = comps.size if limit > comps.size;
        limit = 0 if limit < 2 

        for i in 0..(limit-2)
            res = res + comps[i] + " " if ! comps[i].nil?;
        end
        res += comps[limit-1]  if ! comps[limit-1].nil?;

        res += "..." if comps.size > wordcount;

        return res;
    end

    def open_in_new_window
        return image_tag("open_in_new_window.gif");
    end
    
    def task_status_image_tag( task, insert_id=false )
        id = "status_image_#{task.id}" if insert_id;

        if task.overdue?
            return image_tag("mt_task_status/overdue.gif", :id=>id );
        else
            return image_tag("mt_task_status/#{task.status}.gif", :id=>id );
        end
    end
        
    # gets an array of strings and prints them as a list with an error mark on the side
    def list_error_messages( error_list )
        render :partial=>"/shared/mt_request/request_error_report", :locals=>{:error_list=>error_list}
    end
    
    # returns the current user - copy of a method we have in application.rb
    def current_user
        if @current_user.nil?
            if ( ! session[ApplicationController::KEY_CURRENT_USER_ID].blank? )
                user_class = session[ApplicationController::KEY_CURRENT_USER_CLASS];
                return nil if user_class.blank?
                @current_user = user_class.instance_eval( "#{user_class}.find(#{session[ApplicationController::KEY_CURRENT_USER_ID]})" );
            end
        end
        return @current_user;
    end
    
    #####################
    # Sub forms helpers #
    #####################
    
    def subform_toggle_button( form_id, title="", icon="edit.png" ) 
        js_func = "nv=$(\"#{form_id}\").visible();\n" +
                  "$$(\".sub_form\").each( function(itm){ if ( itm.visible() ) { Effect.BlindUp(itm, {duration: 0.5}); } });\n" +
                  "if( !nv ){ Effect.BlindDown(\"#{form_id}\",{duration: 0.5})}";
                  #"if( !nv ){ $(\"#{form_id}\").show();}";
        return button_function_tag(title, js_func, icon, false);
    end
    
    def start_subform_tag( form_id, model_id, controller, action, multipart=false )
        return "<div class='sub_form' style='display:none' id='#{form_id}'>\n" +
			    start_form_tag( { :id=>model_id, 
			                      :controller=>controller, :action=>action,
			                      :origin=>HashMarshaler::marshal_hash(params) },
			                    { :multipart=>multipart }
			                   );
    end
    
    def end_subform_tag
        return "</form></div>";
    end
    
    
    #################
    # info messages #
    #################

    def has_messages( symbol )
        return ! ( session[:messages].nil? || session[:messages][symbol].nil? || session[:messages][symbol].length==0 );
    end
    
    def get_messages( symbol )
        return session[:messages][symbol];
    end

    def info?()
        return has_messages(:notice);
    end

    def errors?()
        return has_messages(:error);
    end

    def warnings?()
        return has_messages(:warning);
    end
    
    def confirmations?
        return has_messages(:confirmation);
    end
    
    def messages?
        return errors? || warnings? || info? || confirmations?
    end
    
    def get_confirmations()
        return get_messages(:confirmation);
    end
    
    def get_info()
        return get_messages(:notice);
    end

    def get_errors()
        return get_messages(:error);
    end

    def get_warnings()
        return get_messages(:warning);
    end
    
    def clear_messages()
        return if ( session[:messages].nil? )
        
        session[:messages][:notice] = [];
        session[:messages][:warning] = [];
        session[:messages][:error] = [];
        session[:messages][:confirmation] = [];
    end
 
    def pp_place( place ) 
        return render(:partial=>"/shared/place_one_line", :object=>place);
    end

    def pp_reporter( reporter ) 
        return render(:partial=>"/shared/reporter_one_line", :object=>reporter);
    end
   
    ################
    # PAGE  TITLES #
    ################
   
   # start the page title table
   def begin_page_title( title, show_help_button=false )
       if ( show_help_button )
           hb = button_function_tag("", 'Effect.toggle( "help", "slide", {duration:0.5}); return false', "help.png", false);
       else
           hb = ""
       end
       return "<table cellspacing='0' cellpadding='0' border='0' width='100%' class='page_title'><tr><td class='title'>#{title}&nbsp;#{hb}</td><td class='buttons'>";
   end
   
   # finish the page title table
   def end_page_title()
      return "</td></tr></table>";
   end
   
   def begin_help_section
       return "<div class=\"help\" id=\"help\" onclick=\"Effect.toggle( 'help', 'slide');\" style=\"display: none;\"><div>";
   end
   
   def end_help_section
       return "</div></div>";
   end
   
    ######
    # PP # TODO: deprecate. invoke directly the localized methods.
    ######
    def pp_tenant( tenant, do_flat=true )
    	loc.pp_tenant( tenant, do_flat );
    end

    def pp_date_time( date ) 
    	loc.pp_date_time( date ); 
    end

    def pp_date( date ) 
    	loc.pp_date( date );
    end

    def pp_file_size( num )
    	loc.pp_file_size( num );
    end

    def pp_price( amount ) 
    	loc.pp_price( amount ); 
    end

    def pp_number( num )
    	loc.pp_number( num );
    end

    def pp_car( number )
    	loc.pp_car( number );
    end

    def gpp_boolean( value )
      image_tag value ? 'accept.png' : 'no_mark.png'
    end
    
    def pp_boolean(value)
    	loc.pp_boolean(value);
    end

    def pp_flat( a_flat )
    	loc.pp_flat( a_flat );
    end

    def pp_contact_info( someone )
    	loc.pp_contact_info( someone );
    end

    def pp_assignee( assignee )
    	loc.pp_assignee( assignee );
    end

    def pp_task_status( state_int )
    	loc.pp_task_status( state_int );
    end

    def pp_service_type( mt_request_service_type )
    	loc.pp_service_type( mt_request_service_type );
    end

    def pp_urgency( urg )
    	loc.pp_urgency( urg );
    end

    
end
