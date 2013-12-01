# A central class for uploaded files. Stored multiple data
# about the file, and the one that uploaded it.
# a special field, part_of, enables files to be part of a larger
# object that might need files. 
# this mechanism allows us to easily integrate files into other objects
# without duplicating code.
class UploadedFile < ActiveRecord::Base
    # the one that uploaded the file
    belongs_to :uploader, :polymorphic=>true;
    
    # the object this file complements (for contracts)
    # or belongs to (buildings etc)
    belongs_to :part_of,  :polymorphic=>true;
    
    # the place on the server files are stored.    
    FILE_STORE_PATH = "#{RAILS_ROOT}/uploaded_files/";
    
    # return the local path to the file
    def local_path
        return "#{FILE_STORE_PATH}#{id}";
    end
    
    # sets all the attributes a file field holds.
    # returns false if the file field is empty (size==0). Otherwise, returns true.
    def init_from_file_field( file_field )
        return false if (file_field.size == 0);
        self.mime_type = file_field.content_type.chomp;
        self.title = File.basename( file_field.original_filename );
        return true;
    end
    
    # saves the file in the file field into it's appropriate place
    # on the server.
    # /!\ NOTE: this can only be called *after* the record was saved.
    def save_file( file_field )
        throw "CAN'T SAVE FILE WITHOUT AN ID" if ( new_record? );
        File.open( self.local_path, "wb" ) do |f| 
            f.write( file_field.read );
        end
        self.size = File.stat( self.local_path ).size;
        self.save;
    end
    
    # Returns a stream of the file, to be sent to the client.
    def data
        f = File.open( self.local_path, File::RDONLY);
        the_data = f.read;
        f.close;
        return the_data;
    end
    
    # delete the actual file.
    def after_destroy
        remove_file();
    end
   
    ###########
    # privacy #
    ###########
    private
    def base_part_of( filename )
        return File.basename( filename ).gsub(/[^\w._-]/, '');
    end

    def remove_file
        File.delete(self.local_path) if File.exist?(self.local_path);
    end
end
