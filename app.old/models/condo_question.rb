class CondoQuestion < ActiveRecord::Base

def self.find_all_displayed
    find_all_by_display_on_site(true, :order=>"id");
end

end
