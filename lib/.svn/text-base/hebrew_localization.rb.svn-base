class HebrewLocalization < Localization
    include Singleton
    
    # TODO move to a property file and create a UI to control this.
    SUMMER_CLOCK = false;
    
    def language_name
        return "hebrew"
    end
    
    def language_localized_name
        return "עברית"
    end
    
    def reset
        @@instance = nil;
    end
    
    # localize the time
    def now
        if ( @timezone.nil? )
            @timezone = TimeZone.new("Jerusalem");
        end
        
        if ( SUMMER_CLOCK ) 
            # summer clock
            return 1.hour.since(@timezone.now);
        else
            # winter clock
            return @timezone.now
        end
    end
    
    def pp_task_status( state_int )
        case state_int 
        when MtCompanyTask::CREATED
            return "נוצר"
        when MtCompanyTask::ACCEPTED
            return "התקבל"
        when MtCompanyTask::IN_PROGRESS
            return "בטיפול"
        when MtCompanyTask::DONE
            return "בוצע"
        when MtCompanyTask::CANCELLED 
            return "בוטל"
        end
    end
    
    # localize the state of maintenance requests.
    def mt_state( state ) 
        case state
        when MaintenanceRequest::OPEN
            return "פתוח";
        when MaintenanceRequest::IN_PROGRESS
            return "בטיפול";
        when MaintenanceRequest::SOLVED
            return "תוקן";
        when MaintenanceRequest::REJECTED
            return "נדחה";
        when MaintenanceRequest::DEBIT_PENDING
            return "תוקן וממתין לחיוב";
        when MaintenanceRequest::DEBIT_DONE
            return "חוייב";
        else
            return "(#{state})";
            #throw "unknown mt req state: #{state}";
        end
    end
    
    # return the name for untitled files
    def untitled_file_name()
        return "ללא שם"
    end
    
    # return the localized currency symbol.
    def currency()
        return " ש\"ח"
    end

    # return a description of a comparison operator
    def comparison( opr )
        case opr
        when "<"
            return "קטן מ-";    
        when "="
            return "שווה";
        when "!="
            return "שונה";
        when ">"
            return "גדול מ-";
        else
            throw "unknown comparison: #{opr}";
        end            
    end

    # translate an error string from the possible errors of the MtRequestQuery class
    def request_error( err_str )
        case err_str
        when "MAINTENANCE COMPANY NOT SPECIFIED"
            return "יש לבחור חברת אחזקה";
        else
            return translate( "QUERY_ERROR_#{err_str}" );
        end
    end

    # translate sort keys of MtRequestQueries to hebrew
    def mt_req_sort_key( key )
        case key
        when MtRequestQuery::KEY_BUILDING
            return "בניין"
        when MtRequestQuery::KEY_MT_COMPANY
            return "חברת אחזקה"
        when MtRequestQuery::KEY_STATE
            return "מצב"
        when MtRequestQuery::KEY_CREATED_ON
            return "תאריך דיווח"
        when MtRequestQuery::KEY_TITLE
            return "תיאור"
        when MtRequestQuery::KEY_URGENCY
            return "דחיפות"
        when MtRequestQuery::KEY_SOLVED_ON
            return "תאריך תיקון"
        when MtRequestQuery::KEY_SERVICE_TYPE
            return "סוג שירות"
        when MtRequestQuery::KEY_UPDATED_ON
            return "עדכון אחרון"
        else
            RAILS_DEFAULT_LOGGER.error( "mt_req_sort_key( #{key} )");
            return key.to_s;
        end
    end 

    # translate service types
    def mt_req_service_type( service_type_key )
        case service_type_key
        when MaintenanceRequest::SERVICE_TYPE_FIX
            return "תיקון";
        when MaintenanceRequest::SERVICE_TYPE_QOUTE
            return "בקשה להצעת מחיר";
        else
            RAILS_DEFAULT_LOGGER.error( "mt_req_service_type( #{service_type_key} )" ); 
            return service_type_key.to_s;
        end 
    end

    # constant terms translation
    def term( key )
        case key
        when Localization::BUILDING_MANAGER
            return "אב בית";
        when Localization::BUILDING_OWNER
            return "בעל הבניין";
        when Localization::MT_COMPANY
            return "חברת האחזקה";
        when Localization::UNASSIGNED
            return "[אין]";
        end 
    end
    
    # describe, in hebrew, what was the change that was and is described in item.
    def describe_history_item( item )
        case item.action_type
        when MaintenanceRequestHistoryItem::TYPE_ADD_REMARK:
            # nothing to do
            return "";
        when MaintenanceRequestHistoryItem::TYPE_ASSIGNEE_CHANGE:
            return "העברת אחריות ל-#{item.new_state_data}";
        when MaintenanceRequestHistoryItem::TYPE_STATE_CHANGE: 
            return "שינוי מצב ל-#{mt_state(item.new_state_data.to_i)}";
        when MaintenanceRequestHistoryItem::TYPE_TITLE_CHANGE:
            return "שינוי כותרת מ-'#{h(item.old_state_data)}' ל-'#{h(item.new_state_data)}'";
        when MaintenanceRequestHistoryItem::TYPE_URGENCY_CHANGE:
            return "שינוי דחיפות ל-"  + pp_urgency(item.new_state_data.to_i);
        when MaintenanceRequestHistoryItem::TYPE_PLACE_CHANGE:
            return "שינוי מיקום מ-" + item.old_state_data + " ל-" + item.new_state_data;
        when MaintenanceRequestHistoryItem::TYPE_BODY_CHANGE:
            return "שינוי תאור";
        when MaintenanceRequestHistoryItem::TYPE_SERVICE_TYPE_CHANGE:    
            return "שינוי סוג שירות מ-" + mt_req_service_type(item.old_state_data.to_i) + " ל-"  + mt_req_service_type(item.new_state_data.to_i) + ".";
        when MaintenanceRequestHistoryItem::TYPE_ADD_COST_DATA:
            ret_str = [];
            ret_str <<  "הוספו נתוני עלות:<br/><ul>";
            item.new_state_data.split("|").each do | pair |
               vals = pair.split("=");
                case vals[0]
                when "hrs":
                    ret_str << "<li>#{vals[1]} שעות</li>" unless vals[1].blank?
                when "pph":
                    ret_str << "<li>מחיר לשעה: #{vals[1]} #{self.currency()}</li>" unless vals[1].blank?
                when "pc":
                    ret_str << "<li>מחיר חלקים: #{vals[1]} #{self.currency()}</li>" unless vals[1].blank?
                when "fp":
                    ret_str << "<li>מחיר קבוע: #{vals[1]} #{self.currency()}</li>" unless vals[1].blank?
                end
            end
            ret_str << "</ul>";
            return ret_str.join();
        when MaintenanceRequestHistoryItem::TYPE_HOURS_OF_FIX_CHANGE:
            return "מספר שעות העבודה שונה מ-" + safe_str(item.old_state_data) + " " + " ל-" + item.new_state_data + ".";
        when MaintenanceRequestHistoryItem::TYPE_PRICE_PER_HOUR_CHANGE:
            return "מחיר לשעה שונה מ-" + safe_str(item.old_state_data) + " " + self.currency() + " ל-" + item.new_state_data + " " + self.currency();        
        when MaintenanceRequestHistoryItem::TYPE_PARTS_COST_CHANGE:  
            return "מחיר החלקים שונה מ-" + safe_str(item.old_state_data) + " " + self.currency() + " ל-" + item.new_state_data + " " + self.currency();
        when MaintenanceRequestHistoryItem::TYPE_FIXED_PRICE_CHANGE:
            return "המחיר הקבוע שונה מ-" + safe_str(item.old_state_data) + " " + self.currency() + " ל-" + item.new_state_data + " " + self.currency();
        when MaintenanceRequestHistoryItem::TYPE_BUILDING_CHANGE:
            return "הבניין שונה מ-#{safe_str(item.old_state_data)} ל-#{safe_str(item.new_state_data)}";
        when MaintenanceRequestHistoryItem::TYPE_ADD_FILES:
            return "צירוף קבצים: #{item.new_state_data}";
        when MaintenanceRequestHistoryItem::TYPE_REMOVE_FILES:
            return "מחיקת קבצים: #{item.new_state_data}";
        when MaintenanceRequestHistoryItem::TYPE_BUDGET_CHANGE:
            return "הוספת תקציב: #{item.new_state_data}" if item.old_state_data.nil?
            return "שינוי תקציב מ-#{item.old_state_data} ל-#{item.new_state_data}";
        end
    end
    
    # return human readable form of the value
    def pp_boolean(value)
        if value
            return "כן";
        else
            return "לא";
        end
    end
    
    def pp_flat( a_flat )
        return "דירה #{a_flat.number} קומה #{a_flat.floor}";
    end
    
end