require 'r_s_pager/sql_pagee'
# an object that encapsulates a query for maintenance requests.
class MtRequestQuery < SQLPagee

    # keys by which one can sort the query
    KEY_BUILDING     = 0;
    KEY_MT_COMPANY   = 1;
    KEY_STATE        = 2;
    KEY_CREATED_ON   = 3;
    KEY_URGENCY      = 4;
    KEY_TITLE        = 5;
    KEY_SOLVED_ON    = 6;
    KEY_SERVICE_TYPE = 7;
    KEY_UPDATED_ON   = 8;
    KEY_ACCEPTED     = 9;
    KEY_ASSIGNEE     = 10;
    KEY_BODY         = 11;
    KEY_BUDGET       = 12;
    KEY_BUDGET_NAME  = 13;
    KEY_BUSINESS     = 14;
    KEY_FIXED_PRICE_OF_FIX = 15;
    KEY_HOURS_OF_FIX = 16;
    KEY_MT_COMPANY_TASK   = 17;
    KEY_PARTS_COST_OF_FIX = 18;
    KEY_PLACE           = 19;
    KEY_PLACE_FREE_TEXT = 20;
    KEY_PRICE_PER_HOUR  = 21;
    KEY_QOUTE_TEXT      = 22;
    KEY_QUOTED_PRICE    = 23;
    KEY_REMARKS        = 24;
    KEY_REPORTER       = 25;
    KEY_SOLVING_WORKER = 26;
    
    # TODO move to the report generator (mt_req_report_build) logic. Should not be here.
    SORT_KEYS = [ KEY_BUILDING, KEY_MT_COMPANY, KEY_STATE, 
                       KEY_CREATED_ON, KEY_URGENCY, KEY_TITLE,
                       KEY_SOLVED_ON, KEY_SERVICE_TYPE ];
    
    # how to handle history while sorting
    HISTORY_ORDER_IGNORE = 0;
    HISTORY_ORDER_FIRST  = 1;
    HISTORY_ORDER_LAST   = 2;
    HISTORY_ORDERS = [ HISTORY_ORDER_IGNORE, HISTORY_ORDER_FIRST, HISTORY_ORDER_LAST ]
    
    attr_accessor :from_date, :until_date
    attr_accessor :updated_since
    attr_accessor :time_until_fixed
    attr_accessor :time_until_fixed_opr
    attr_accessor :state_ids
    attr_accessor :building_ids
    attr_accessor :mt_company_ids
    attr_accessor :assignees
    attr_accessor :limit
    attr_accessor :offset
    attr_accessor :warnings
    attr_accessor :service_types
    attr_accessor :fixed_from_date, :fixed_until_date
    attr_accessor :reporters
    
    # This maintenance request is used to get the columns names in the order_by query
    @@MT_REQ_TEMPLATE = MaintenanceRequest.new
    
    ########################################################################################### Order of the records
    #sets the sort_by key
    # TODO deprecate. use order_by.
    def update_sort_by(args)
        self.update_order_by( args )
    end
    
    def sort_by=(args)
        self.order_by= args
    end

    def sort_by 
        self.order_by
    end

    def order_by=( key )
        key = key.to_i;
        throw "illegal order_by key #{key}" unless (0..26)===key
        @order_by = key.to_i;
    end
    
    def order_by
        return @order_by
    end

    # sets the sort_by key, toggles the descending when key == sort_by
    def update_order_by( key )
        key = key.to_i;
        if @order_by == key
            @descending = ! @descending;
        else
            @descending = false;
            self.order_by = key;
        end
    end
    
    def is_descending
        return self.descending?
    end
    
    def descending=(value)
        @descending = (value == true)
    end
    
    def descending?
        return @descending
    end
    
    ########################################################################################### Order of the history
    
    def history_order=( history_order_key )
        throw "invalid history order value #{history_order_key}" unless HISTORY_ORDERS.include?( history_order_key );
        @history_order = history_order_key
    end
    
    def history_order
        return @history_order_key
    end
    
    def update_history_order()
        self.history_order == HISTORY_ORDER_LAST if ( self.history_order == HISTORY_ORDER_FIRST )
        self.history_order == HISTORY_ORDER_FIRST if ( self.history_order == HISTORY_ORDER_LAST )
    end
        
    ########################################################################################### Select manipulation

    def error_list
        return @error_list;
    end
        
    def add_state( stt )
        stt = stt.to_i
        @state_ids.push( stt ) unless @state_ids.include?( stt );
    end
    
    def clear_states()
        @state_ids = []
    end
    
    def add_building( stt )
        stt = stt.to_i if stt.kind_of? String
        stt = stt.id if stt.kind_of? Building
        @building_ids.push( stt ) unless @building_ids.include?( stt );
    end
    
    def add_mt_company( mtc )
        mtc = mtc.to_i if mtc.kind_of? String
        mtc = mtc.id if mtc.kind_of? MtCompany
        @mt_company_ids.push( mtc ) unless @mt_company_ids.include?(mtc);
    end
    
    def add_assignee( asn )
        @assignees.push( asn ) unless @assignees.include?(asn);
    end
    
    def add_service_type( stp )
        @service_types.push( stp.to_i ) unless @service_types.include?(stp);
    end
    
    def add_reporter( rp ) 
        @reporters.push( rp ) unless @reporters.include?( rp )
    end
    
    def clear_reporters()
        @reporters = []
    end
    
    def assignees_specified?
        return (@assignees.size != 0);
    end
        
    def initialize()
        @error_list     = [];
        @mt_company_ids = [];
        @building_ids   = [];
        @state_ids      = [];
        @assignees      = [];
        @warnings       = [];
        @service_types  = [];
        @reporters      = [];
        self.history_order = HISTORY_ORDER_IGNORE
    end
    
    # true iff there is more than one building in the request.
    # NOTE: this only involves the _query_, not the results.
    def many_buildings?()
        return @building_ids.size != 1
    end
    
    # true iff there is more than one mt_company in the request.
    # NOTE: this only involves the _query_, not the results.
    def many_mt_companies?()
        return @mt_company_ids.size != 1
    end
    
    # true iff the query might return requests for more than one assignee.
    def many_assignees?()
        return @assignees.size != 1;
    end
    
    # true iff only one service type was specified.
    def many_service_types?() 
        return @service_types.size != 1;
    end
    
    # parse the query from a hash
    def parse( data_hash )
        
        unless data_hash[:use_from_date].nil?
            unless ( data_hash[:from_date].blank? )
                @from_date  = data_hash[:from_date]
            else
                add_warning "NO FROM DATE SPECIFIED"
            end
        end
        
        unless data_hash[:use_until_date].nil?
            unless data_hash[:until_date].blank?
                @until_date = data_hash[:until_date] 
            else
                add_warning "NO UNTIL DATE SPECIFIED"
            end
        end
        
        if ( (! @from_date.nil?) && (! @until_date.nil?) )
            if ( @from_date > @until_date )
                add_warning "FROM_DATE LATER THAN UNTIL_DATE";
                tmp = @from_date;
                @from_date = @until_date;
                @until_date = tmp;
            end
        end
        
        @time_until_fixed = data_hash[:time_until_fixed] unless data_hash[:use_time_until_fixed].nil?
        @time_until_fixed_opr = data_hash[:time_until_fixed_opr];
        
        unless data_hash[:states].nil?
            if ensure_not_empty(data_hash, :states)
                for stt in data_hash[:states]
                    add_state( stt.first );
                end
            end
        end
        
        unless data_hash[:service_types].nil?
            if ensure_not_empty(data_hash, :service_types)
                for stp in data_hash[:service_types]
                    add_service_type( stp.first );
                end
            end
        end
        
        unless data_hash[:buildings].nil?
            if ensure_not_empty(data_hash, :buildings)
                for bld in data_hash[:buildings]
                    add_building( bld.first.to_i );
                end
            end
        end
        
        unless data_hash[:mt_companies].nil?
            if ensure_not_empty(data_hash, :mt_companies)
                for mtc in data_hash[:mt_companies]
                    add_mt_company( mtc.first.to_i );
                end
            end
        end
        
        unless data_hash[:use_assignee].nil?
            unless data_hash[:assignee].nil?
                for asn in data_hash[:assignee] 
                    add_assignee( MtCompanyWorker.find(asn.first.to_i) );
                end
            else
               add_warning "USE ASSIGNEE SPECIFIED, BUT NO ASSIGNEE SPECIFIED"; 
            end
        end
        
        @order_by = data_hash[:sort_by].to_i;
        @descending = !(data_hash[:is_descending].blank?);
    end
    
    # return true iff the query can be submitted
    # if false, one can query the errors in the error_list() array
    def valid?
        @error_list = [];
        # make sure the dates are fine
        if ( !from_date.nil? && !until_date.nil? )
            if ( from_date > until_date ) 
                temp = from_date;
                from_date = until_date;
                until_date = temp;
            end
        end
        
        if ( !fixed_from_date.nil? && !fixed_until_date.nil? )
            if ( fixed_from_date > fixed_until_date ) 
                temp = fixed_from_date;
                fixed_from_date = fixed_until_date;
                fixed_until_date = temp;
            end
        end
        
        # make sure the the operator and fix time are valid, if needed
        if ( !(@time_until_fixed.blank?) && !(@time_until_fixed_opr.blank?) )
            @error_list.push("TIME_UNTIL_FIXED NOT NUMERIC") if time_until_fixed.strip.match(/^[0-9]+$/).nil?
            unless ( ["<",">","=","!="].include?(@time_until_fixed_opr) )
                @error_list << "TIME_UNTIL_FIXED_OPERATOR_INVALID";
            end        
        end
        
        unless ( @order_by.blank? )
            unless SORT_KEYS.include?(@order_by)
                @error_list.push("INVALID SORT KEY");
            end
        end
        
        return ( @error_list.size==0 );
    end
    
    # return the hash needed to select the appropriate mt_reqs using find, paginate, etc..
    def conditions_hash()
        if ! valid?
            throw "invalid state"
        end
        
        ret_val = { :conditions=>self.where_clause(), :joins=>self.join_clause, :select=>self.select_clause, :order=>self.create_order_by_clause };

        ##########
        # limits
        ret_val[:limit]  = @limit  unless @limit.nil?
        ret_val[:offset] = @offset unless @offset.nil?
        
        return ret_val;
    end
    
    # return the WHERE clause. This is an array, [text, value, value, .... ]
    # TODO use x IN (a,b,c,d) syntax, when moving to MySQL5
    def where_clause
        cnd_arr = [] # used for text conditions
        obj_arr = [] # used for objects
        tmp = []
        
        # buildings
        if ( building_ids.size > 0 )
            building_ids.each{|x| tmp << "building_id=?"; obj_arr << x; }
            cnd_arr << tmp.join( " OR " );
        end
        
        # mt_companies
        if ( mt_company_ids.size > 0 )
            tmp = [];
            mt_company_ids.each{|x| tmp << "#{MaintenanceRequest.table_name}.mt_company_id=?"; obj_arr << x; }
            cnd_arr << tmp.join( " OR " );
        end
        
        # assignees
        if ( assignees.size > 0 )
            tmp = [];
            assignees.each{ |a| tmp << "(assignee_id=? AND assignee_type=?)"; obj_arr << a.id; obj_arr << a.class.name }
            cnd_arr << tmp.join( " OR " );
        end
        
        # reporters
        if ( reporters.size > 0 )
            tmp = [];
            reporters.each{ |rpr| tmp << "(reporter_id=? AND reporter_type=?)"; obj_arr << rpr.id; obj_arr << rpr.class.name }
            cnd_arr << tmp.join(" OR ");
        end
        
        # states
        if state_ids.size > 0
            tmp = [];
            state_ids.each{|x| tmp << "state=?"; obj_arr << x; }
            cnd_arr << tmp.join( " OR " );
        end
        
        # times
        unless ( from_date.nil? )
            cnd_arr << "created_on >= ?"
            obj_arr << from_date
        end
        
        unless ( until_date.nil? )
            cnd_arr << "created_on <= ?"
            # TODO use proper date objects!
            obj_arr << "#{until_date} 23:59"
        end
        
        unless ( updated_since.nil? )
            cnd_arr << "updated_on >= ?"
            obj_arr << updated_since
        end
        
        if ( !(@time_until_fixed.blank?) && !(@time_until_fixed_opr.blank?) )
            cnd_arr << "((state=?) OR (state=?)) AND DATEDIFF(solved_on, created_on) #{time_until_fixed_opr} #{time_until_fixed}";
            obj_arr << MaintenanceRequest::SOLVED;
            obj_arr << MaintenanceRequest::REJECTED;
        end
        
        if ( !fixed_from_date.nil? )
            cnd_arr << "solved_on >= ?";
            obj_arr << fixed_from_date;
        end
        
        if ( !fixed_until_date.nil? )
            cnd_arr << "solved_on <= ?";
            obj_arr << fixed_until_date;
        end
        
        
        # service types
        if ( self.service_types.size > 0 )
            tmp = [];
            self.service_types.each { |stp| tmp << "service_type=#{stp}"; }
            cnd_arr << tmp.join( " OR " );
        end
        
        cond_value = ["(" + cnd_arr.join(") AND (") + ")" ,obj_arr].flatten;
        
        return cond_value;
    end
    
    # return the join clause. This is the "table" we are selecting from
    # basically the FROM ..... clause, up to and not including the WHERE part.
    def join_clause()
       return "inner join #{Building.table_name} on #{MaintenanceRequest.table_name}.building_id=#{Building.table_name}.id
                        inner join #{MtCompany.table_name} on #{Building.table_name}.mt_company_id=#{MtCompany.table_name}.id";
        
    end
    
    # the SELECT .... clause, up to and not including the FROM part.
    def select_clause()
       return "#{MaintenanceRequest.table_name}.*, \"#{MaintenanceRequest.name}\" as class, " +
              "#{Building.table_name}.city, #{Building.table_name}.street, #{Building.table_name}.number, " +
              "#{MtCompany.table_name}.name"; 
    end
    
    # run the query and return results
    def execute
        MaintenanceRequest.find(:all, self.conditions_hash );
    end
    
    # pagee's select implementation
    def select_sql()
        where_arr = self.where_clause
        ret_arr =  ["SELECT #{select_clause()} 
        FROM #{MaintenanceRequest.table_name} #{join_clause()}
        WHERE #{where_arr[0]}", where_arr[1..1000] ].flatten;
        order_by_clause = self.create_order_by_clause
        ret_arr[0] << " ORDER BY #{order_by_clause}" unless order_by_clause.blank?
        return ret_arr;
    end
    
    # pagee's count implementation
    def count_sql()
        where_arr = self.where_clause
        return ["SELECT count(*) 
        FROM #{MaintenanceRequest.table_name} #{join_clause()}
        WHERE #{where_arr[0]}", where_arr[1..1000] ].flatten;
    end
    
    def data_class()
        return MaintenanceRequest
    end
    
    # get a query that would return all the pending mt reqs
    # for_me can be a building, an mt_company, an mt_company_worker or a building_owner
    def self.create_pending_query( for_me )
        qer = MtRequestQuery.new;
        qer.add_state( MaintenanceRequest::OPEN );
        qer.add_state( MaintenanceRequest::IN_PROGRESS );
        qer.sort_by = KEY_CREATED_ON;
        
        if for_me.kind_of? MtCompany
            qer.add_mt_company( for_me )
            for_me.buildings.each { |b| qer.add_building(b.id) }
            
        elsif for_me.kind_of? Building
            qer.add_building( for_me );
            qer.add_mt_company( for_me.mt_company_id );

        elsif for_me.kind_of? BuildingOwner
            for_me.buildings.each do |b|
                qer.add_building(b.id);
                qer.add_mt_company( b.mt_company_id );
            end
        elsif for_me.kind_of? MtCompanyWorker
            qer.add_mt_company( for_me.mt_company );
            qer.add_assignee( for_me ) unless for_me.role.admin?;
        end
        
        return qer;     
    end
   
   # see that the hash pointed by hash[:symbol] is not empty, and if so, issue a warning
   def ensure_not_empty( hash, symbol )
      inspected = hash[symbol];
      raise "cannot inspect nil hashtable" if inspected.nil?
      if ( inspected.size == 0 )
          add_warning "NO #{symbol.to_s.upcase} SPECIFIED";
          return false;
      end    
      return true;
   end 
   
   def add_warning( warn )
       @warnings << warn unless warn.blank?
   end

   ##############
   # protection #
   ##############
   protected
   # create the ORDER BY clause (without the actual ORDER BY)
   def create_order_by_clause

       order_value = "";

       if ( self.history_order == HISTORY_ORDER_FIRST )
           order_value << "has_history DESC"
       elsif ( self.history_order == HISTORY_ORDER_LAST )
           order_value << "has_history ASC"
       end
       
       unless ( @order_by.blank? )
           order_value << ", " unless order_value.blank?;
           
           case @order_by
           when KEY_CREATED_ON:
               order_value << "#{MaintenanceRequest.table_name}.created_on";
           when KEY_STATE:
               order_value << "#{MaintenanceRequest.table_name}.state";
           when KEY_MT_COMPANY:
               order_value << "#{MtCompany.table_name}.name"
           when KEY_BUILDING:
               order_value << "#{Building.table_name}.city, #{Building.table_name}.street, #{Building.table_name}.number"
           when KEY_URGENCY:
               order_value << "#{MaintenanceRequest.table_name}.urgency";
           when KEY_TITLE:
               order_value << "#{MaintenanceRequest.table_name}.title";
           when KEY_SOLVED_ON:
               order_value << "#{MaintenanceRequest.table_name}.solved_on";
           when KEY_SERVICE_TYPE:
               order_value << "#{MaintenanceRequest.table_name}.service_type";
           when KEY_UPDATED_ON:
               order_value << "#{MaintenanceRequest.table_name}.updated_on";
           when KEY_ACCEPTED
           	   order_value <<  @@MT_REQ_TEMPLATE.column_for_attribute(:state).name;
           when KEY_ASSIGNEE
           	   order_value <<  "#{MaintenanceRequest.table_name}.assignee_id";
           when KEY_BODY
           	   order_value <<  @@MT_REQ_TEMPLATE.column_for_attribute(:body).name;
           when KEY_BUDGET_NAME
           	   order_value <<  @@MT_REQ_TEMPLATE.column_for_attribute(:budget_name).name;
           when KEY_BUSINESS
           	   order_value <<  @@MT_REQ_TEMPLATE.column_for_attribute(:business_id).name; # TODO support actual sorting
           when KEY_FIXED_PRICE_OF_FIX
           	   order_value <<  @@MT_REQ_TEMPLATE.column_for_attribute(:fixed_price_of_fix).name;
           when KEY_HOURS_OF_FIX
           	   order_value <<  @@MT_REQ_TEMPLATE.column_for_attribute(:hours_of_fix).name;
           when KEY_MT_COMPANY_TASK
           	   order_value <<  @@MT_REQ_TEMPLATE.column_for_attribute(:mt_company_task_id).name;# TODO support actual sorting
           when KEY_PARTS_COST_OF_FIX
           	   order_value <<  @@MT_REQ_TEMPLATE.column_for_attribute(:parts_cost_of_fix).name;
           when KEY_PLACE
           	   order_value <<  @@MT_REQ_TEMPLATE.column_for_attribute(:place_type).name;# TODO support actual sorting
          	   order_value <<  ", ";
          	   order_value <<  @@MT_REQ_TEMPLATE.column_for_attribute(:place_id).name;# TODO support actual sorting
           when KEY_PLACE_FREE_TEXT
           	   order_value <<  @@MT_REQ_TEMPLATE.column_for_attribute(:place_free_text).name;
           when KEY_PRICE_PER_HOUR
           	   order_value <<  @@MT_REQ_TEMPLATE.column_for_attribute(:price_per_hour).name;
           when KEY_QOUTE_TEXT
           	   order_value <<  @@MT_REQ_TEMPLATE.column_for_attribute(:quote_text).name;
           when KEY_QUOTED_PRICE
           	   order_value <<  @@MT_REQ_TEMPLATE.column_for_attribute(:quoted_price).name;
           when KEY_REMARKS
           	   order_value <<  @@MT_REQ_TEMPLATE.column_for_attribute(:remarks).name;
           when KEY_REPORTER
           	   order_value <<  @@MT_REQ_TEMPLATE.column_for_attribute(:reporter_type).name;# TODO support actual sorting
          	   order_value <<  ", ";
          	   order_value <<  @@MT_REQ_TEMPLATE.column_for_attribute(:reporter_id).name;# TODO support actual sorting
           when KEY_SOLVING_WORKER
          	   order_value <<  @@MT_REQ_TEMPLATE.column_for_attribute(:solving_worker_id).name;# TODO support actual sorting
           end

           order_value << " DESC" if descending?
       end
        return order_value;
   end
   
   def create_history_column_clause
       return ", (#{MaintenanceRequest.table_name}.created_on=#{MaintenanceRequest.table_name}.updated_on) as has_history"
   end
   
   # builds a state specifing string ( "State=1 OR state=50..." ) )
   # TODO use x IN (a,b,c,d) syntax, when moving to MySQL5
   def create_state_clause
       if state_ids.size > 0
           tmp = [];
           obj_arr = [];
           state_ids.each{|x| tmp << "state=#{x}";}
           return "(" + tmp.join( " OR " ) + ")";
       end
       return nil;
   end
   
end