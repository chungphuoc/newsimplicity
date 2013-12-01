# instances of this class are able to produce pageable data sets
# this basically a view of an underlaying data set (either SQL or AR)
class Pagee
    
    # the class of the expected objects.
    attr_accessor :data_class
    
    # how many records do we have
    def get_count
        if ( @count.nil? )
            @count = self.calculate_count
        end
        return @count
    end
    
    def calculate_count
        throw "unimplemented"
    end
    
    # get all the records
    def get_all
        throw "unimplemented"
    end
    
    # get records for a single page
    def get_rows( offset, limit )
        throw "unimplemented"
    end
    
end