class TenantsController < ApplicationController
    layout 'vaad_admin'
    before_filter :authorize_vaad_admin;
    before_filter :ensure_building_exists;
    
	# GETs should be safe (see http://www.w3.org/2001/tag/doc/whenToUseGet.html)
	verify :method => :post, :only => [ :destroy, :create, :update ],
		     :redirect_to => { :action => :list }
	
	def index
		list
		render :action => 'list'
	end

	def list
		@tenant_pages, @tenants = paginate :tenants, :per_page => 15, :conditions=>["building_id=?", @building.id];
		
	end

	def show
		@tenant = Tenant.find(params[:id])
	end

	def new
		@tenant = Tenant.new
		@tenant.role = "TR_REGULAR"
		@tenant.is_male = true
		
		if params[:flat_id] != nil # special state: we came from and go to the flats controller
		    @flat_mode = true
		    @tenant.flat_id = params[:flat_id]
		else
		    @flat_mode = false
		end
	end

	def create
		@tenant = Tenant.new(params[:tenant]);
		@tenant.building_id = @building.id;
		if @tenant.save
            add_confirmation 'Tenant was successfully created.';
            if params['flat_mode'] == "true";
                redirect_to :action => 'edit', :controller => 'vaad_flat', :id=>@tenant.flat_id;
            else
                redirect_to :action => 'list';
            end
		else
		  render :action => 'new';
		end
	end

	def edit
		@tenant = Tenant.find(params[:id]);
	end

	def update
		@tenant = Tenant.find(params[:id])

		if @tenant.update_attributes(params[:tenant])
		  add_confirmation 'Tenant was successfully updated.'
		  redirect_to :action => 'show', :id => @tenant
		else
		  render :action => 'edit'
		end
	end

	def destroy
		Tenant.find(params[:id]).destroy
		if params["flat_id"] != nil 
		    redirect_to :controller=>"vaad_flat", :action=>"edit", :id=>params["flat_id"]
		else
		    redirect_to :action => 'list'
		end
	end
end
