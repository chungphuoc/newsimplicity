class PlaceListItem < ActiveRecord::Base
    include Comparable;
    
    has_many :maintenance_requests, :as=>:place;
    belongs_to :building;
    
    def hr_name
        return place;
    end
    
    def <=>( other )
        return self.place <=> other.place;
    end
    
    def to_s
        return "PlaceListItem##{self.id}: place=>'#{self.place}' building=>'#{self.building.hr_address}'";
    end
end
