class UnitContract < ActiveRecord::Base
    
    has_many :uploaded_files, :as=>:part_of;
    belongs_to :business;
    has_and_belongs_to_many :building_units;
    belongs_to :building
    
    MODE_RENT = 0; # The relevant unit is sold. end_date should be nil
    MODE_SELL = 1; # the relevant unit is rented.
    
    def building
        unless ( building_units.nil? )
            return building_units[0].building;
        end
    end
    
    def end_date=(date)
        write_attribute(:end_date, date);
    end
    
    def end_date
        if self.mode == MODE_SELL
            return nil;
        else
            return read_attribute(:end_date);
        end
    end
    
    def add_unit( building_unit ) 
        unless building_units.include?(building_unit)
            building_units << building_unit;
        end
    end
end
