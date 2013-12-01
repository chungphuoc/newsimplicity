class BuildingOwner < ActiveRecord::Base
    include UsernamePasswordMixin;
    include NameSortabilityMixin;

    has_many :buildings;
    has_many :unit_types, :order=>"name";
    has_many :public_unit_types, :class_name=>"UnitType", :conditions=>"is_public = TRUE", :order=>"name";
    has_many :mt_company_tasks, :as=>:creator;
    has_many :businesses, :through=>:buildings;
    has_many :building_units, :through=>:buildings;
    
    validates_presence_of :username;
    validates_uniqueness_of :username;
    
    attr_accessor :password_confirmation;
    
    def self.authenticate( username, password )
        owner = self.find_by_username( username ); 
        if owner 
            expected_password = UsernamePasswordMixin::encrypted_password(password, owner.salt);
            if owner.hashed_password != expected_password 
                owner = nil;
            end 
        end 
        return owner;
    end
    
    def contracts( building_id=nil )
        if ( building_id != nil )
            building_id = building_id.id if building_id.class != Fixnum;
        end
        
        building_clause = (building_id != nil) ? "AND buildings.id = #{building_id.to_s}" : nil;
        UnitContract.find_by_sql(["SELECT distinct unit_contracts.*
                                    FROM ( ( ( buildings INNER JOIN building_owners
                                    	         ON buildings.building_owner_id = building_owners.id AND building_owners.id = ?
                                    	        ) 
                                    	        INNER JOIN building_units
                                    	        ON buildings.id = building_units.building_id 
                                    	        #{building_clause}
                                    	     )
                                    		 INNER JOIN building_units_unit_contracts
                                    		 ON building_units.id = building_units_unit_contracts.building_unit_id
                                     	  )
                                    	  INNER JOIN unit_contracts ON building_units_unit_contracts.unit_contract_id = unit_contracts.id;
                                        ",
                                        self.id ] );
    end
    
    def mt_companies
        mtc = buildings.collect{|b| b.mt_company }.compact.uniq.sort;
    end

    #--< protected >---------------------------
    protected
    def validate 
        if ( (! password.blank?) && (! password_confirmation.blank?) )
            unless self.password == self.password_confirmation
                errors.add( :password, "PASSWORDS MUST MATCH") 
            end
        end
    end
    
end
