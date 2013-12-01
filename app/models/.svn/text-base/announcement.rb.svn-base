class Announcement < ActiveRecord::Base
    belongs_to :building;
    validates_presence_of :title, :on => :create, :message => "ERR_TITLE_MISSING"
    
    attr_reader :display
    
    SAVE_PATH = "/announcements/"

    # returns true iff the announcement has a file associated with it
    def has_file
        if id == nil 
            false
        else
            FileTest.exists?( local_file_path )
        end
    end
        
    # returns the file path of the file associated with this announcement
    def web_file_path 
        afilePath = building.web_path + SAVE_PATH + id.to_s
        if file_suffix != "" && file_suffix != nil
           afilePath = afilePath + "." + file_suffix 
        end

        afilePath
    end

    # returns the path of the file associated with this announcement    
    def local_file_path
        afilePath = building.local_path + SAVE_PATH + id.to_s

        if file_suffix != "" && file_suffix != nil
            afilePath = afilePath + "." + file_suffix
        end

        afilePath 
    end

    def after_destroy
       File.delete(local_file_path) if File.exist?(local_file_path)
    end

    
    def self.find_all_displayed 
        anns = find(:all, :conditions=>"display_on_site=true", :order=>"published_on DESC")
    end

    
end
