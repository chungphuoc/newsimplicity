class AnnouncementsController < ApplicationController
    layout 'vaad_admin';
    before_filter :authorize_vaad_admin;
    before_filter :ensure_building_exists;
    
    def index
        list
        render :action => 'list'
    end
    
    # GETs should be safe (see http://www.w3.org/2001/tag/doc/whenToUseGet.html)
    verify :method => :post, :only => [ :destroy, :create, :update ],
           :redirect_to => { :action => :list }
    
    def list
        @announcements_pages, @announcements = paginate :announcements, :per_page => 15, :conditions=>["building_id=?", @building.id], :order=>"published_on DESC";
        @has_anns = (@announcements.size > 0 )
    end
    
    def show
        @announcement = Announcement.find(params[:id])
    end
    
    def new
        @announcement = Announcement.new
        @announcement.display_on_site = true
    end
    
    def create
        if params[:announcement][:display_on_site] != nil
            params[:announcement][:display_on_site] = "true" 
        else
            params[:announcement][:display_on_site] = "false" 
        end
             
        @ann = Announcement.new(params[:announcement])
        @ann.link = fix_link( @ann.link )
        @ann.published_on = DateTime.now
        @ann.building_id = @building.id
        # handle an uploaded file (if any)
        if ( params['afile'] != "" ) 
            @ann.file_suffix = params['afile'].original_filename.split(".").last
        end
        
        if @ann.save
            if ( params['afile'] != "" ) 
                File.open( @ann.local_file_path, "wb" ) do |f| 
                    f.write( @params['afile'].read )
                end
            end
            add_confirmation 'ANN_SAVE_SUCCESSFUL'
            redirect_to :action => 'list'
        else
          render :action => 'new'
        end
    end
    
    def edit
        @announcement = Announcement.find(params[:id])
    end
    
    def update
        @announcement = Announcement.find(params[:id])
        
        if params['remove_file'] != nil
            File.delete( @announcement.local_file_path )
        end
        
        # handle an uploaded file (if any)
        if params['afile'] != nil && params['afile'] != ""
            File.delete( @announcement.local_file_path ) if @announcement.has_file
            
            @announcement.file_suffix = params['afile'].original_filename.split(".").last
            File.open( @announcement.local_file_path, "wb" ) do |f| 
                f.write( @params['afile'].read )
            end
        end
        
        if params[:announcement][:display_on_site] != nil
            params[:announcement][:display_on_site] = "true" 
        else
            params[:announcement][:display_on_site] = "false" 
        end
        params[:announcement][:link] = fix_link(params[:announcement][:link])
        params[:announcement][:published_on] = DateTime.now
        if @announcement.update_attributes(params[:announcement])
          add_confirmation 'ANN_UPDATE_SUCCESSFUL'
          redirect_to :action => 'list'
        else
          add_errors_of( @announcement );
          render :action => 'edit'
        end
    end
    
    def destroy
        Announcement.find(params[:id]).destroy
        redirect_to :action => 'list'
    end
end
