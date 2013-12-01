# instances of this class are able to produce pageable data sets
# using SQL queries
class SQLPagee < Pagee
    
    # optional parameter for ordering the result set.
    attr_accessor :order_by
    
    def initialize()
        @descending = false;
    end
    
    # return the SQL required for select (string/array)
    def select_sql
       throw "unimplemented"
    end

    # return the SQL required for counting (string/array)
    def count_sql
        throw "unimplemented"
    end
    
    def calculate_count
        self.data_class().send( :count_by_sql, self.count_sql )
    end

    # get all the records
    def get_all
        get_rows(nil,nil)
    end

    # get records for a single page
    # actual SQL execution
    def get_rows( offset=nil, limit=nil )
        sql = self.select_sql

        sql_str = ( sql.kind_of? Array ) ? sql[0] : sql;

        sql_str << " LIMIT #{limit}"   unless limit.nil?
        sql_str << " OFFSET #{offset}" unless offset.nil?

        return self.data_class().send( :find_by_sql, sql )
    end
    
    def descending=( arg )
        @descending = ["true", true, "DESC", 1, "1", "YES"].include?(arg);
    end
    
    def descending?
        return @descending;
    end
    
    def toggle_descending()
        self.descending = !self.descending?();
    end
    
end