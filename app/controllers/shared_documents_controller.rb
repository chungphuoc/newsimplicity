class SharedDocumentsController < ApplicationController
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
		@doc_pages, @docs = paginate :shared_documents, :per_page => 10, :conditions=>["building_id=?", @building.id]
	end

	def show
		@shared_document = SharedDocument.find(params[:id])
	end

	def new
		@shared_document = SharedDocument.new
	end

	def create
		@shared_document = SharedDocument.new(params[:shared_document])
		@shared_document.building_id = @building.id
        # handle an uploaded file (if any)
        if ( params['afile'] != "" ) 
            @shared_document.file_suffix = params['afile'].original_filename.split(".").last
        end
        
		if @shared_document.save
		    if ( params['afile'] != "" ) 
                File.open( @shared_document.local_file_path, "wb" ) do |f| 
                    f.write( @params['afile'].read );
                end
            end
            
			add_info 'SHARED_DOCUMENT_SAVED';
			redirect_to :action => 'list'
		else
		    add_errors_of( @shared_document )
			render :action => 'new'
		end
	end

	def edit
		@shared_document = SharedDocument.find(params[:id]);
	end

	def update
		@shared_document = SharedDocument.find(params[:id]);
		
		if params['remove_file'] != nil
            @shared_document.remove_file();
        end
        
        # handle the uploaded file
        if params['afile'] != nil && params['afile'] != ""
            @shared_document.remove_file();
            
            @shared_document.file_suffix = params['afile'].original_filename.split(".").last;
            File.open( @shared_document.local_file_path, "wb" ) do |f| 
                f.write( @params['afile'].read );
            end
            params[:shared_document][:file_suffix] = @shared_document.file_suffix;
        end
        
		if @shared_document.update_attributes(params[:shared_document])
			add_info 'UPDATE_SUCCESSFUL';
			redirect_to :action => 'list';
		else
		    add_errors_of( @shared_document );
			render :action => 'edit'
		end
	end

	def destroy
		SharedDocument.find(params[:id]).destroy
		redirect_to :action => 'list'
	end
	
	def get_shared_document
	    sdoc = SharedDocument.find(params[:id]);
	    #send_file(sdoc.local_file_path, :filename=>sdoc.title + "." + sdoc.file_suffix, :type=>"application/#{sdoc.file_suffix}" );
	    redirect_to( sdoc.web_file_path );
	end
	
end
