class Car < ActiveRecord::Base
    belongs_to :tenant;
    belongs_to :business;
    
    def number=( arg )
        val = Car.sterilize_number(arg); 
        write_attribute(:number, val ); 
        val;
    end
    
    def number() 
        return read_attribute(:number);
    end
    
    def self.find_by_number( car_num )
        arr =  find_by_sql( ["SELECT * FROM cars WHERE number=? LIMIT 0,1",Car.sterilize_number(car_num)] );
        return arr[0]
    end
    
    # get an arbiterary string, return the digits only.
    def self.sterilize_number( number_string ) 
        return number_string.gsub(/[^0-9]/,'');
    end
end
