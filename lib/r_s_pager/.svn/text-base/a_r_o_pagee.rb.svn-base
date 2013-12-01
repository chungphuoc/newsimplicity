# class to page collections accessed from active record objects
class AROPagee < Pagee

    attr_accessor :conditions
    attr_accessor :order
    attr_accessor :include

    # name of collection being paged
    attr_accessor :collection

    # Create a new pagee.
    # an_object = the activerecord object whose collection is to be paged
    # a_collection = the collection to be paged
    # hash = may contain :conditions, :order, and :include.
    def initialize( an_object, a_collection, hash={})
        self.data_class = an_object
        self.collection = a_collection
        self.conditions = hash[:conditions] unless hash[:conditions].nil?
        self.order = hash[:order] unless hash[:order].nil?
        self.include = hash[:include] unless hash[:include].nil?
    end

    # how many records do we have
    def calculate_count
        if ( self.conditions() != nil )
            self.data_class().send(self.collection).send( :count, self.conditions );
        else
            self.data_class().send(self.collection).send( :count );
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

        self.data_class().send(self.collection).send( :find, :all, hash );

    end
end