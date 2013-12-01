class SharedDocument < ActiveRecord::Base
    include FileHandleMixin, LocalizedTimeMixin
    
    belongs_to :building;
    
    SAVE_PATH = "/shared_docs/";
    
    def self.save_path
        return SAVE_PATH;
    end
    
    def local_path
        return building.local_path
    end
end
