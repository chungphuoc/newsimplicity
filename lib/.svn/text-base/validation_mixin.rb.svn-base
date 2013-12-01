module ValidationMixin
    # validates that there is a single entity by this name in the building.
    def validate_building_uniqueness( column_name )
        cond_str = "#{column_name.to_s} = ? AND building_id = ?";
        if ! new_record?
            cond_str = "id != #{self.id} AND " + cond_str;
        end
        
        count = self.class.count(:conditions=>[cond_str, self.send(column_name), self.building_id]);
        return (count == 0);
    end
    
    # validates that there is a single entity by this name in the building.
    def validate_business_uniqueness( column_name )
        cond_str = "#{column_name.to_s} = ? AND business_id = ?";
        if ! self.new_record?
            cond_str = "id != #{self.id} AND " + cond_str;
        end
        
        count = self.class.count(:conditions=>[cond_str, self.send(column_name), self.business_id]);
        return (count == 0);
    end
end