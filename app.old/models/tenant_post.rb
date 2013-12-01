class TenantPost < ActiveRecord::Base
    belongs_to :tenant;
    belongs_to :building;
    
    SAVE_PATH = "/tenant_posts/";
    
    # returns true iff the post has a file associated with it
   def has_file
       if id == nil 
           false
       else
           FileTest.exists?( local_file_path )
       end
   end

   # returns the file path of the file associated with this post
   def web_file_path 
       afilePath = building.web_path + SAVE_PATH + id.to_s
       if file_suffix != "" && file_suffix != nil
          afilePath = afilePath + "." + file_suffix 
       end

       afilePath
   end

   # sets the link of the message. Makes sure it has protocol decleration            
   def _link=( aLink )
       comps = aLink.split("://")
       if comps.size == 1 
           # no protocol decleration, assume it's http
           aLink = "http://" + aLink
       end
       
       @link = aLink
       
   end
   
   def _link
       @link
   end
   
   
   # returns the path of the file associated with this post    
   def local_file_path
       afilePath = building.local_path + SAVE_PATH + id.to_s

       if file_suffix != "" && file_suffix != nil
           afilePath = afilePath + "." + file_suffix
       end

       afilePath 
   end
   
   # lists all messages that should be displayed, ordered by publish date
   def self.find_all_displayed 
       anns = find(:all, :conditions=>"display_on_site=true", :order=>"published_on DESC")
   end

   def after_destroy
      File.delete(local_file_path) if File.exist?(local_file_path)
   end
end
