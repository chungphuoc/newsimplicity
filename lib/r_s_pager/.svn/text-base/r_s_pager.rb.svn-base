# Pager for SQL based data sets.
class RSPager
    DEFAULT_PAGE_SIZE = 15;
    
    # our data provider
    attr_accessor :pagee;
    
    # how many records are there. Cached value.
    attr_accessor :row_count;
            
    # name of the current pager. Allows us to have multiple pagers on a single page
    attr_accessor :name;
    
    def initialize( sql_row_provider )
        self.pagee = sql_row_provider;
        self.current_page = 1;
        self.page_size = DEFAULT_PAGE_SIZE;
        self.row_count = 0;
        self.name = "page";
        @page_count = nil;
    end
    
    def page_size
        return @page_size
    end
    
    def page_size=(value)
        @page_size = value
        @page_count = nil
    end
    
    def current_page
        return @current_page
    end
    
    def current_page=( a_page_num )
        @current_page = a_page_num.to_i
    end
    
    # return how many pages we have. might return a cached value. see update_page_count for the actual calculation and caching.
    def page_count
        if ( @page_count == nil)
            update_page_count();
        end
        return @page_count
    end
    
    # calcualte how many pages we have.
    def update_page_count
        self.row_count = pagee.get_count()
        @page_count = @row_count/@page_size
        @page_count += 1 if (@row_count%page_size > 0)
    end
    
    # get all the data
    def get_all
        get_rows();
    end
    
    # get the data in a certain page
    # also sets the current page
    def get_page( page_num=self.current_page )
        self.current_page = page_num;
        return self.pagee.get_rows( self.page_offset(page_num), self.page_size )
    end
    
    # get the data in the current page
    def get_current_page
        get_page( self.current_page );
    end
    
    def page_offset( page_num=nil )
        page_num = self.current_page if page_num.nil?
        return (page_num-1)*self.page_size
    end
    
end