# A module to Marshal/Unmarshal hashmaps.
# the keys must be symbols (:sample), and the values are either
# strings or maps. if the value is of a different type, it is represented as a string (to_s)
module HashMarshaler

    SPECIAL_CHARS = [":", "|", "$"]
    ESCAPE_CHAR = "\\";

    # {a:b|c:d|e:$f\:F\|g\:G$}
    def self.marshal_hash( a_hash )
        retval = a_hash.collect do |k,v| 
            if (v.kind_of?(Hash))
                v = "$#{marshal_hash(v)}$";
            end
            "#{k}:#{escape(v)}"
        end
        return "#{retval.join("|")}";
    end

    def self.unmarshal_hash( a_string )
        new_hash = {}
        cur_idx = 0
        while (cur_idx < a_string.length )
           entry_end_idx = get_unescaped("|", a_string, cur_idx );
           entry_end_idx = a_string.length if entry_end_idx == -1;
           entry_str =  a_string[cur_idx..entry_end_idx];
           key_end_idx = get_unescaped(":", a_string, cur_idx );
           key = a_string[cur_idx..key_end_idx-1].intern
           value = a_string[key_end_idx+1..entry_end_idx-1]
           value = unescape(value);
           if ( value[0..0] == "$" )
               value = unmarshal_hash( value[1..value.length-2])
          end
           new_hash[key] = value;

           cur_idx = entry_end_idx+1;
        end
        return new_hash;
    end 

    #############
    # protected #
    #############
    
    protected
    
    def self.escape( str )
        str="" if str.nil? #todo remove
        str = str.to_s unless str.kind_of?( String );
        str = str.gsub(ESCAPE_CHAR, "#{ESCAPE_CHAR}#{ESCAPE_CHAR}#{ESCAPE_CHAR}#{ESCAPE_CHAR}");
        SPECIAL_CHARS.each { |c| str = str.gsub(c, "#{ESCAPE_CHAR}#{c}") };
        return str;
    end

    def self.unescape( str )
        SPECIAL_CHARS.each { |c| str = str.gsub("#{ESCAPE_CHAR}#{c}", c) };
        return str.gsub("#{ESCAPE_CHAR}#{ESCAPE_CHAR}", ESCAPE_CHAR);
    end

    # return the index of the first un-escaped char in str
    def self.get_unescaped( char, str, start=0 ) 
        for i in (start..str.length)
           if ( str[i]==char[0] ) 
               return 0 if i==0
               return i unless str[i-1]==ESCAPE_CHAR[0]
           end
        end
        return -1
    end
end
