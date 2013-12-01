class TenantPostsController < ApplicationController
    layout "vaad_admin"
    before_filter :authorize_vaad_admin
    before_filter :ensure_building_exists;
    
    def index
        list
        render :action => 'list'
    end

    # GETs should be safe (see http://www.w3.org/2001/tag/doc/whenToUseGet.html)
    verify :method => :post, :only => [ :destroy, :create, :update ],
         :redirect_to => { :action => :list }

    def list
        @tenant_post_pages, @tenant_posts = paginate :tenant_posts, :per_page => 15, :conditions=>["building_id=?", @building.id], :order=>"published_on DESC";
        @has_posts = (@tenant_posts.size>0)
    end

    def show
        @tenant_post = TenantPost.find(params[:id])
    end

    def new
        @tenant_post = TenantPost.new
        @tenant_post.display_on_site = true
    end

    def create
        
        if params[:tenant_post][:display_on_site] != nil
            params[:tenant_post][:display_on_site] = "true" 
        else
            params[:tenant_post][:display_on_site] = "false" 
        end
        @tenant_post = TenantPost.new(params[:tenant_post])
                
        # handle an uploaded file (if any)
        if ( params['afile'] != "" ) 
            @tenant_post.file_suffix = params['afile'].original_filename.split(".").last
        end
        
        @tenant_post.published_on = DateTime.now
        @tenant_post.link = fix_link(@tenant_post.link)
        @tenant_post.building_id = @building_id;
        
        if @tenant_post.save
            if ( params['afile'] != "" ) 
                File.open( @tenant_post.local_file_path, "wb" ) do |f| 
                    f.write( @params['afile'].read )
                end
            end
            add_info 'TENANT_POST_SAVE_SUCCESSFUL'
            redirect_to :action => 'list'
        else
            add_errors_of( @tenant_post );
            render :action => 'new'
        end
    end

    def edit
        @tenant_post = TenantPost.find(params[:id])
    end

    def update
        @tenant_post = TenantPost.find(params[:id])
        
        if params['remove_file'] != nil
            File.delete( @tenant_post.local_file_path )
        end
        
        # handle an uploaded file (if any)
        if params['afile'] != nil && params['afile'] != ""
            File.delete( @tenant_post.local_file_path ) if @tenant_post.has_file
            
            @tenant_post.file_suffix = params['afile'].original_filename.split(".").last
            File.open( @tenant_post.local_file_path, "wb" ) do |f| 
                f.write( @params['afile'].read )
            end
        end
        
        if params[:tenant_post][:display_on_site] != nil
            params[:tenant_post][:display_on_site] = "true" 
        else
            params[:tenant_post][:display_on_site] = "false" 
        end
        
        params[:tenant_post][:link] = fix_link(params[:tenant_post][:link])
        params[:tenant_post][:published_on] = DateTime.now();
        if @tenant_post.update_attributes(params[:tenant_post])
            add_info 'TenantPost updated.'
            redirect_to :action => 'list', :id => @tenant_post
        else
            add_errors_of( @tenant_post );
            render :action => 'edit'
        end
    end

    def destroy
        TenantPost.find(params[:id]).destroy
        redirect_to :action => 'list'
    end
end
