class UnitType < ActiveRecord::Base
    belongs_to :building_owner;
    has_many   :building_units, :dependent=>false; # an exception is thrown if any exist anyway.
    has_many   :buildings, :foreign_key=>:default_public_unit_type_id, :dependent=>false;
    
    def public?
        return self.is_public
    end
    
    # if we are not public, make sure we are not the default public unit type of any building
    def validate
        if ( (! self.public?) && self.buildings.size>0)
            self.errors.add_to_base("CANNOT SET PUBLIC TO FALSE - UNIT TYPE IS DEFAULT FOR A BUILDING");
        end
    end
    
    def before_destroy
        # we make sure that:
        # - there are no building units of this type, and
        # - there are no buildings whose default public unit type is ours.
        throw "BUILDING UNITS OF THIS TYPE EXISTS" unless self.building_units.empty?
        throw "DEFAULT PUBLIC TYPE FOR BUILDING"   unless self.buildings.empty?
    end
    
    
end
