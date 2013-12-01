# base class for both vaad announcments and tenants advertisments.
# use the class methods to distinguish between them.
# 
class Post < ActiveRecord::Base
    POST_TYPE = [ :announcement, :addvertisment ]

    def self.get_all_announcements
        find_all_by_type(:announcement, :order => "published_on")
    end
    
    def self.get_all_advertizments
        find_all_by_type(:addvertisment, :order => "published_on")
    end
end
