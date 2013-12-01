module RSPaginationHelper
    # shows 1 2 3 4 pages
    def rs_page_links( rspager, param_hash={} )
        return "" if ( rspager.page_count<2 );

        internal_pages = page_range(rspager.current_page.to_i, rspager.page_count);

        html = [];
        
        last_page_num=0;
        internal_pages.each do | page_num |
            classes = ""
            classes << " rs_page_first" if page_num.to_i == 1
            classes << " rs_page_last" if page_num.to_i == rspager.page_count
            classes << " rs_page_link_current" if page_num.to_i == rspager.current_page.to_i
            param_hash.update( {rspager.name=>page_num} );

            html << "&laquo;&laquo;" if (page_num-last_page_num)>1
            html << link_to( page_num, param_hash,{:class=>classes})
            
            last_page_num = page_num;
        end

        return "<div class='rs_page_links'>#{html.reverse().join("&nbsp;")}</div>"
    end

    # shows << < > >>
    def rs_player_controls( rspager, param_hash={} )
        if ( rspager.page_count > 1 )
            return rs_player_backward_conrols( rspager, param_hash ) + "&nbsp;" + rs_player_forward_conrols( rspager, param_hash );
        else
            return ""
        end
    end

    # shows > >>
    def rs_player_forward_conrols( rspager, param_hash={} )
        if ( rspager.current_page != rspager.page_count )
            param_hash.update({rspager.name=>rspager.current_page+1})
            html = link_to( "&gt;", param_hash, {:class=>"rs_page_button"})
            param_hash.update({rspager.name=>rspager.page_count})
            html << "&nbsp;"
            html << link_to( "&raquo;", param_hash, {:class=>"rs_page_button"})
        else
            html = "<span class='rs_page_button_disabled'>&gt;</span>"
            html << "&nbsp;<span class='rs_page_button_disabled'>&raquo;</span>"
        end

        return html;
    end

    # shows << <
    def rs_player_backward_conrols( rspager, param_hash={} )
        if ( rspager.current_page > 1 )
            param_hash.update({rspager.name=>1})
            html = link_to( "&laquo;", param_hash, {:class=>"rs_page_button"})
            param_hash.update({rspager.name=>rspager.current_page-1})
            html << "&nbsp;"
            html << link_to( "&lt;", param_hash, {:class=>"rs_page_button"})
        else
            html = "<span class='rs_page_button_disabled'>&laquo;</span>"
            html << "&nbsp;<span class='rs_page_button_disabled'>&lt;</span>"
        end

        return html;
    end
    
    # returns an array with integers to be used as page numbers.
    # idx - index of the current page
    # len - amount of pages
    # around - how many pages to show near the start, index and end. defaults to 2
    def page_range( idx, len, around=2 )
        out_arr = []
        e = (around>len) ? len : around
        (1..e).each{|x| out_arr << x unless out_arr.include?(x) }

        s = (idx-around>1) ? idx-around : 1
        (s..idx).each{|x| out_arr << x unless out_arr.include?(x) }

        e = (idx+around>len) ? len : idx+around
        (idx..e).each{|x| out_arr << x unless out_arr.include?(x) }

        s = (len-around+1>1) ? len-around+1 : 1
        (s..len).each{|x| out_arr << x unless out_arr.include?(x) }

        return out_arr
    end

end