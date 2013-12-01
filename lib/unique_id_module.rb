# module to create a unique id for AR objects
module UniqueIdModule
    
    def unique_obj_id( obj ) 
        return "" if obj.nil?
        return "#{obj.class.name}|#{obj.id}"
    end
    
    def obj_from_unique_id( uid )
        return nil if uid.blank?
        
        comps = uid.split("|");
        cls_name = comps[0];
        if (cls_name =~ /^[A-Z][A-Za-z]+$/) == nil
            raise "ILLEGAL CLASS NAME IN UID #{uid}"
        end
        
        cls = cls_name.instance_eval( "#{cls_name}.find(#{comps[1]})" );
        return cls;
    end
    
    
    
end