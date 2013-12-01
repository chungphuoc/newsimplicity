=begin rdoc
    Simple class that takes 2 values and lets users access them using _key_ and _value_ accessors.
=end
class KVObj
    attr_reader :key, :value
    
    def initialize( aKey, aValue )
        @key = aKey;
        @value = aValue;
    end
    
    def id
        @key
    end
    
    def name
        return @value;
    end
    
    def hr_name
        return self.name;
    end
    
    def hr_name_full
        return self.name;
    end
    
end