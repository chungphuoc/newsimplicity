class UsersController < ApplicationController
    layout 'vaad_admin'
    before_filter :authorize_vaad_admin
    before_filter :ensure_building_exists

    def index
        list
        render :action => 'list'
    end

    # GETs should be safe (see http://www.w3.org/2001/tag/doc/whenToUseGet.html)
    verify :method => :post, :only => [ :destroy, :create, :update ],
    :redirect_to => { :action => :list }

    def list
        @user_pages, @users = paginate :users, :per_page => 15, :conditions=>["building_id=?", @building.id];
    end

    def show
        @user = User.find(params[:id])
    end

    def new
        @user = User.new
    end

    def create
        @user = User.new(params[:user])
        @user.building_id = @building.id;
        if @user.save
            add_info "USER CREATED";
            redirect_to :action => 'list';
        else
            add_errors_of @user;
            render :action => 'new';
        end
    end

    def edit
        @user = User.find(params[:id]);
    end

    def update
        @user = User.find(params[:id])
        if @user.update_attributes(params[:user])
            add_info 'USER UPDATED'
            redirect_to :action => 'list', :id => @user
        else
            add_errors_of @user;
            render :action => 'edit'
        end
    end

    def destroy
        User.find(params[:id]).destroy
        redirect_to :action => 'list'
    end
end
