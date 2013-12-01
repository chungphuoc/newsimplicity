class BuildingUnit < ActiveRecord::Base
    include Comparable;

    belongs_to  :building, :foreign_key=>"building_id";
    belongs_to  :unit_type;
    has_many    :maintenance_requests, :as=>:place;
    has_and_belongs_to_many :unit_contracts, :order=>"end_date";
    
    # return the business residing in the unit.
    def current_businesses
        current_date = Localization::localizer.now().to_date();
        businesses = [];
        unit_contracts.each do | uc |
            if ( (current_date >= uc.start_date) && 
                 ((uc.end_date.nil?) || (uc.end_date  > uc.start_date))     )
                 businesses << uc.business;
            end
        end
        
        return businesses;
    end
    
    def hr_name
        return name;
    end 
    
    def <=>( other_uc )
        return self.name <=> other_uc.name
    end
    
    def to_s
       return "/BuildingUnit ##{self.id} name=>#{self.name} building=>#{self.building.hr_address}/";
    end
end
