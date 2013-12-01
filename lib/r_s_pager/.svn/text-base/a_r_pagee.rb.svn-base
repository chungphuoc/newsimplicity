# a page provider for ActiveRecords.
class ARPagee < Pagee
    
    attr_accessor :conditions
    attr_accessor :order
    attr_accessor :include
    
    def initialize( a_data_class=nil, hash={} )
        self.data_class = a_data_class
        self.conditions = hash[:conditions] unless hash[:conditions].nil?
        self.order = hash[:order] unless hash[:order].nil?
        self.include = hash[:include] unless hash[:include].nil?
    end
    
    # how many records do we have
    def calculate_count
        if ( self.conditions() != nil )
            self.data_class().send( :count, :conditions=>self.conditions );
        else
            self.data_class().send( :count );
        end
    end
    
    # get all the records
    def get_all
        self.get_rows();
    end
    
    # get records for a single page
    def get_rows( offset=nil, limit=nil )
        hash = {}
        hash[:conditions] = self.conditions()  unless self.conditions().nil?
        hash[:order]      = self.order()       unless self.order().nil?
        hash[:include]    = self.include()     unless self.include().nil?
        hash[:limit]      = limit              unless limit.nil?
        hash[:offset]     = offset             unless offset.nil?
        
        self.data_class().send( :find, :all, hash );
        
    end
    
end