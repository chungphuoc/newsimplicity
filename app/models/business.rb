class Business < ActiveRecord::Base
    include Comparable;
    
    has_many :building_units;
    has_many :users, :dependent=>:destroy;
    has_many :unit_contracts, :dependent=>:destroy;
    has_many :maintenance_requests, :dependent=>:destroy;
    has_many :cars, :dependent=>:destroy;
    
    belongs_to :building;
        
    def <=>( other_biz )
        return self.name <=> other_biz.name;
    end
    
    # returns the building units currently in this building
    def building_units_sql
        sqlstr = "SELECT DISTINCT building_units.*
                  FROM ( unit_contracts 
                         INNER JOIN building_units_unit_contracts 
                         ON unit_contracts.id = building_units_unit_contracts.unit_contract_id )
                       INNER JOIN building_units
                       ON building_units_unit_contracts.building_unit_id = building_units.id
                  WHERE business_id = ?
                        AND (? BETWEEN start_date AND end_date )"
        return BuildingUnit.find_by_sql( [sqlstr, self.id, DateTime.now]);
    end
    
    def building_units
       
        n = DateTime.now;
        contracts = unit_contracts.collect{ |uc| ( uc.start_date < n) && ( uc.end_date==nil || uc.end_date > n) ? uc : nil }.compact;
        units = contracts.collect{|uc| uc.building_units }.flatten;
        
        return units;
        
    end
    
    def validate
        # make sure the name is not blank
        if ( self.name.blank? )
            errors.add(:name, "CAN'T BE BLANK");
        end
        # make sure the eng_name is unique in the building
        unless ( self.eng_name.blank? )
            begin
                if (/^[a-zA-Z0-9_]*$/ =~ self.eng_name) == nil
                    raise "INVALID ENGLISH NAME"
                end
                if ( self.new_record? ) 
                    update_addition = "";
                else
                    update_addition = "AND id != #{self.id}";
                end
            
                cnt = Business.count_by_sql( ["SELECT COUNT(*)
                                             FROM #{Business.table_name}
                                             WHERE eng_name = ? #{update_addition}", self.eng_name]) 
                if ( cnt > 0 ) 
                    raise "ENG NAME NOT UNIQUE"
                end
            rescue Exception => e
               self.errors.add(:eng_name, e.message); 
            end
        end
    end
    
end
