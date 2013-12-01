# a request returning all the mt_requests relevant for a user.
# this means:
# ( 1. mt reqs the user, or the user's business opened
#  - or -
#  2. mt reqs that are in areas that currenlty belong to the users's business
# )
# - and -
# 3. whose state is OPEN/IN_PROGRESS (by default, could be changed )
class UserRelatedMtReqsQuery < MtRequestQuery
    def initialize( user )
        super()
        @user = user;
        self.order_by = MtRequestQuery::KEY_CREATED_ON;
        self.descending = true;
        add_state( MaintenanceRequest::OPEN )
        add_state( MaintenanceRequest::IN_PROGRESS )
        
    end

    # return the SQL required for select (string/array)
    def select_sql
        sql_arr = core_sql
        sql_arr[0] = "SELECT DISTINCT #{MaintenanceRequest.table_name}.*, #{Building.table_name}.city, #{Building.table_name}.street, #{Building.table_name}.number
        #{sql_arr[0]}
        ORDER BY #{self.create_order_by_clause}"

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
    # TODO respect the dates here. Also, looking at the reporter id and the business id might be redundant.
    def core_sql
        sql_str = 
        "FROM #{MaintenanceRequest.table_name} INNER JOIN #{Building.table_name} ON #{MaintenanceRequest.table_name}.building_id = #{Building.table_name}.id
        WHERE ( ( place_id IN (
                SELECT DISTINCT buuc.building_unit_id
                FROM ( -- get the list of building_units a business 'owns'
                (businesses INNER JOIN unit_contracts ON businesses.id = unit_contracts.business_id)
                INNER JOIN building_units_unit_contracts buuc ON buuc.unit_contract_id = unit_contracts.id )
                WHERE businesses.id = ?
            )
            AND place_type='BuildingUnit' ) 
            OR business_id = ?
            OR (reporter_id=? AND reporter_type=?))";
        
        sql_str << " AND #{create_state_clause}" unless self.state_ids.blank?
        
        type_str  = @user.class.name

        return [sql_str, @user.business_id, @user.business_id, @user.id, @user.class.name];
    end 
end