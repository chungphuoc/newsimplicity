class Localization
   
   # constant terms for translation use
   # TODO make integers
   BUILDING_MANAGER = "BUILDING_MANAGER";
   BUILDING_OWNER   = "BUILDING_OWNER";
   MT_COMPANY       = "MT_COMPANY";
   UNASSIGNED       = "UNASSIGNED";
   
   def initialize
       self.load_messages
   end
   
   # main method of the class. Gets a MESSAGE_LIKE_THIS, finds the hebrew version.
   # If the message is not in the dictionary, we add it to the "please translate me" list.
   def translate( string )
       if @messages[string].nil? && !string.blank?
           # no such value, mark as needed
           loc_ent = LocalizedEntry.new();
           loc_ent.id = string;
           loc_ent.save;
           @messages[string] = string;
       end
       return (@messages[string].blank?) ? string : @messages[string];
   end
   
   def file_name
       return "#{RAILS_ROOT}/config/i18n/#{self.language_name}.properties"
   end
   
   # fills the cache from the appropriate .properties file
   def load_messages()
       @messages = {}
       IO.foreach(self.file_name) do | line |
          comps = line.split("=")
          @messages[comps[0].strip()] = comps[1].strip()
      end
   end
   
   def self.localizer()
       if @localizer.nil? 
           @localizer = HebrewLocalization::instance();
       end
       return @localizer;
   end

   def html_escape(s)
      return s.to_s.gsub(/&/n, '&').gsub(/\"/n, '"').gsub(/>/n, '>').gsub(/</n, '<');
   end
   
   alias h html_escape
   
   # pretty-print the tenant name and flat.
   def pp_tenant( tenant, do_flat=true )
       if tenant == nil 
           return "?";
       else
           str = h(tenant.first_name) + " " + h(tenant.surname);
           str += " (" + tenant.flat.human_description + ")" if do_flat;
           return  str
       end
   end

   # pretty-print the date and time
   def pp_date_time( date ) 
       return "-" if date.nil?
       if date.kind_of? String
           date = Date.parse(date)
       end
       return date.strftime("%H:%M %d/%m/%y");
   end

   # pretty-print the date
   def pp_date( date, y2k_compatible = false ) 
       return "-" if date.nil?
       if date.kind_of? String
           date = Date.parse(date)
       end
       fmt = y2k_compatible ? "%d/%m/%Y" : "%d/%m/%y";
       return date.strftime( fmt );
   end

   # pretty-print a file size. 
   # num is the size of the file in bytes.
   def pp_file_size( num )
       num = num.to_i;
       return pp_number( num / 1024 ) + " kb";
   end

   # pretty-print price
   def pp_price( amount ) 
       return pp_number(amount)+ " " + self.currency();
   end

   ## takes a number, returns a string with commas.
   def pp_number( num )
       return "-" if num.nil?
       parts = sprintf("%f", num).split(".");
       parts[0] = parts[0].to_s.gsub(/(\d)(?=(\d\d\d)+(?!\d))/, "\\1,");
       if ( parts[1].nil? )
           parts[1] = "00";
       else
           parts[1] = (parts[1] + "0")[0..1]
       end
       return parts.join(".")
   end

   # pretty-print car number to xx-yy...yyyy-zz
   def pp_car( number )
       if ( number.length < 6 )
           return number;
       end
       last_idx = number.length;        
       res = number[0..1] + "-" + number[2..last_idx-3] + "-" + number[(last_idx-2)..(last_idx-1)];
       return res;
   end

   # prints the the first to exist of someone's mobile/phone/email/contact_info.
   def pp_contact_info( someone )
       [:mobile, :phone, :email, :contact_info].each do | msg |
           if ( someone.respond_to? msg )
               return h(someone.send(msg)) unless someone.send(msg).blank?;
           end
       end

       return ""; # nothing to say about this someone.
   end

   def pp_assignee( assignee )
       return Localization.localizer.term( Localization::UNASSIGNED ) if assignee.nil?
       assignee = assignee.assignee if assignee.kind_of? MaintenanceRequest
       if ( assignee.kind_of? MtCompanyWorker)
           return "#{assignee.hr_name} (#{assignee.role.name})";
       elsif ( assignee.kind_of? MtCompany )
           return assignee.name;
       else
           RAILS_DEFAULT_LOGGER.debug "pp_assignee called with #{assignee.class.name}"
           return h(assignee.to_s)
       end
   end

   # pretty-print the service type. can get either mt_Req or its type.
   def pp_service_type( mt_request_service_type )
       if mt_request_service_type.kind_of? MaintenanceRequest
           mt_request_service_type = mt_request_service_type.service_type
       end
       return icon_service_type(mt_request_service_type) + loc.mt_req_service_type( mt_request_service_type);
   end

   # do the icon of an urgency (can also deal with mt_req)
   def pp_urgency( urg )
       if ( urg.kind_of? MaintenanceRequest )
           urg = urg.urgency;
       end
       return "<img src='#{ActionController::AbstractRequest.relative_url_root}/images/urgency/#{urg.to_s}.gif' alt='' />";
   end
   
   # return the data or a statement that the value is empty (e.g. [empty])
   # TODO localize [empty]
   def safe_str( str )
       return str.blank? ? "[ריק]" : h(str.strip);
   end
   

end
