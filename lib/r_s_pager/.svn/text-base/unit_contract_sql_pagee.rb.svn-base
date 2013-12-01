class UnitContractSqlPagee < SQLPagee
    # ORDER BY keys for the pagers.
    ORDER_BY_KEYS = [ :BUILDING,
                      :BUSINESS,
                      :MODE,
                      :START_DATE,
                      :END_DATE
                    ]
    
    # mapping from order_by key to an array of columns.
    ORDER_BY = {
        :BUILDING   => ["#{Building.table_name}.city", "#{Building.table_name}.street", "#{Building.table_name}.number","#{Business.table_name}.name"],
        :BUSINESS   => ["#{Business.table_name}.name"],
        :MODE       => ["mode","#{Business.table_name}.name"],
        :START_DATE => ["start_date"], 
        :END_DATE   => ["end_date"]
    }
    
    def initialize()
        self.order_by = :BUILDING;
        self.data_class = UnitContract;
    end
    
    def order_by=( arg )
        if ( arg.kind_of?(String) )
            arg = arg.chomp.upcase.intern
        end
        throw "Illegal key" unless ORDER_BY.include?( arg )
        super( arg );
    end
    
    # return the order by clause needed for the order by
    def order_by_clause
        if ( ! descending? )
            return ORDER_BY[self.order_by()].join(",");
        else
            return ORDER_BY[self.order_by()].collect{|c| "#{c} DESC"}.join(",");
        end
    end
    
    # get the SQL FROM clause, including any joins needed for the order
    def from_clause
        "#{UnitContract.table_name} 
         INNER JOIN building_units_unit_contracts ON building_units_unit_contracts.unit_contract_id = #{UnitContract.table_name}.id
         INNER JOIN #{Business.table_name} ON #{UnitContract.table_name}.business_id = #{Business.table_name}.id
         INNER JOIN #{Building.table_name} ON #{Business.table_name}.building_id = #{Building.table_name}.id"
    end

    
    # return an array of ["SQL CONDITION", obj, obj ...]
    # as in ["building_id=? AND num=?", @building.id, 1948]
    def where_clause
        throw "unimplemented"
    end
    
    # return the SQL required for select (string/array)
    def select_sql
        where_arr = where_clause();
        ["SELECT DISTINCT #{UnitContract.table_name}.*
          FROM #{self.from_clause()}
          WHERE #{where_arr[0]}
          ORDER BY #{self.order_by_clause()}",
         *where_arr.slice(1..where_arr.length)
        ];
    end

    # return the SQL required for counting (string/array)
    def count_sql
        where_arr = where_clause();
        ["SELECT COUNT(DISTINCT #{UnitContract.table_name}.id)
         FROM #{self.from_clause()}
         WHERE #{where_arr[0]}",
         *where_arr.slice(1..where_arr.length)
        ]
    end
    
end
