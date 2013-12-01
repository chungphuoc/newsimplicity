module VaadFlatHelper
        
    def make_name( flat, field )
        return "flat_" + flat.id.to_s() + "[#{field.to_s()}]";
    end

    def make_id( flat, field )
        return "flat_" + flat.id.to_s() + "_#{field.to_s()}";
    end


    # create a text field with the field value, name flat_id[fieldname] and id flat_id_fieldname
    def flat_text_field(flat, field)
        return "<input type='text' id='#{make_id(flat, field)}' name='#{make_name(flat, field)}' value='#{flat.send(field)}' size='5' />"
    end

    def flat_hidden_field(flat)
        return "<input type='hidden' id='#{make_id(flat, :id)}' name='#{make_name(flat, :id)}' value='#{flat.id}'/>"
    end

    
    def flat_state_select( flat )
        out_str = "<select id='#{make_id(flat, :state)}' name='#{make_name(flat, :state)}'>\n";
        for stt in Flat::STATES
            sel = ((stt == flat.state )? "selected='true'" : "" );
            out_str << "<option value='#{stt}' #{sel}>#{stt}</option>\n";
        end
        return out_str + "</select>";
    end
    
    def flat_floor_select( flat )
        
        base_floor_list = ["<select id='#{make_id(flat, :floor)}' name='#{make_name(flat,:floor)}'>\n"];
        for flr in (@building.lowest_floor..@building.highest_floor)
           base_floor_list << "<option value='#{flr}' #{flr==flat.floor ? "selected='true'" : ''}>#{flr!=0?flr:"קרקע"}</option>\n";
        end
        base_floor_list << "</select>";
        
        return base_floor_list.join;
        
    end

end
