=begin rdoc
Models a single flat.     
=end
class Flat < ActiveRecord::Base
    #         Displayed         stored in db 
    STATES = [ "FLATSTATE_SOLD", "FLATSTATE_CONTRACTOR", "FLATSTATE_UNKNOWN" ]
    
    belongs_to :building;
    has_many :tenants;
    validates_inclusion_of :state, :in => STATES.map {|value| value} 
    validates_numericality_of :number, :floor, :area, :base_payment;
    
    def human_description
        "FLAT #{number} FLOOR #{floor}"
    end
    
    
    def before_validtaion
        if state.nil? 
            state = FLATSTATE_UNKNOWN;
        end
    end
    
    
    ## < protection > ###################################
    protected 

    def validate 
        errors.add(:area, "should be at least 1") if area.nil? || area < 1;
        errors.add(:building, "must not be nil") if  building == nil;
        
        if Flat.count(:conditions=>["building_id = ? AND number = ? AND id != ?", building_id, self.number, self.id]) > 0
            errors.add(:number,"already taken for this building");
        end
    end
        
        
end
