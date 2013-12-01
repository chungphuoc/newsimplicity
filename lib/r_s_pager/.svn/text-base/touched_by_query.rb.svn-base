# This class finds all the maintenance requests that were touched by someone
# this means the were either:
# 1. opened by him
# 2. changed by him (i.e. there's a history item where the user has acted)
# 3. are currently assigned to him
class TouchedByQuery < MtRequestQuery
    
    def initialize( user )
        super()
        @acting_user = user;
        self.order_by = MtRequestQuery::KEY_UPDATED_ON;
        self.descending = true;
        self.history_order = MtRequestQuery::HISTORY_ORDER_LAST;
    end

    # return the SQL required for select (string/array)
    def select_sql
        sql_arr = core_sql
        sql_arr[0] = "SELECT * #{self.create_history_column_clause.gsub(MaintenanceRequest.table_name, "mtr")}
                     #{sql_arr[0]}
                     ORDER BY #{self.create_order_by_clause.gsub(MaintenanceRequest.table_name, "mtr")}"

        return sql_arr;
    end
    
    # return the SQL required for counting (string/array)
    def count_sql
        sql_arr = core_sql
        sql_arr[0] = "SELECT COUNT(*)
                     #{sql_arr[0]}"
        return sql_arr
    end
        
    # return the class of the expected objects.
    def data_class
        return MaintenanceRequest;
    end
    
    # return the specifying part only, no select/order
    def core_sql
        sql_str = "FROM #{MaintenanceRequest.table_name} mtr
                   WHERE EXISTS ( SELECT * FROM maintenance_request_history_items 
                                 WHERE maintenance_request_id = mtr.id 
                                   AND acting_user_id=? and acting_user_type=?)
                         OR (reporter_id=? AND reporter_type=?)
                         OR (assignee_id=? AND assignee_type=?)"

        type_str  = @acting_user.class.name

        return [sql_str, @acting_user.id, type_str, @acting_user.id, type_str,  @acting_user.id, type_str];
    end
end
