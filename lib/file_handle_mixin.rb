module FileHandleMixin

    # returns true iff the object has a file associated with it
    def has_file?
        if id == nil 
            return false;
        else
            return FileTest.exists?( local_file_path );
        end
    end
        
    # returns the file path of the file associated with this object
    def web_file_path 
        # TODO check the building validity
        afilePath = building.web_path + self.class.save_path + id.to_s
        if file_suffix != "" && file_suffix != nil
           afilePath = afilePath + "." + file_suffix;
        end

        return afilePath;
    end

    # returns the path of the file associated with this object    
    def local_file_path
        afilePath = self.local_path + self.class.save_path + id.to_s;

        if ! file_suffix.blank?
            afilePath = afilePath + "." + file_suffix;
        end

        return afilePath;
    end

    def after_destroy
        remove_file();
    end
   
    def remove_file
        File.delete(local_file_path) if File.exist?(local_file_path);
    end
end