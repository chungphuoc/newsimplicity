class ContactPeopleController < ApplicationController
    before_filter :authorize_vaad_admin 
    before_filter :ensure_building_exists;
    layout 'vaad_admin'

    def index
        list
        render :action => 'list'
    end

    # GETs should be safe (see http://www.w3.org/2001/tag/doc/whenToUseGet.html)
    verify :method => :post, :only => [ :destroy, :create, :update ],
    :redirect_to => { :action => :list }

    def list
        @contact_person_pages, @contact_people = paginate :contact_people, :per_page => 15, :conditions=>["building_id=?", @building.id];
    end

    def show
        @contact_person = ContactPerson.find(params[:id])
    end

    def new
        @js_files = ["contact_person_form.js"]
        @categories = @building.get_cp_categories();
        @contact_person = ContactPerson.new;
    end

    def create
        @contact_person = ContactPerson.new(params[:contact_person])
        @contact_person.building_id = @building.id;
        # check to see if we need a new category
        if params["add_category"] == "1"
            cpCat = CpCategory.new
            cpCat.name = params["new_category_name"]
            cpCat.building_id = @building.id;
            unless cpCat.save
                add_error "ERR_CANT_SAVE_CATEGORY"
            end
            @contact_person.cp_category = cpCat
        end

        if @contact_person.save
            add_info 'CONTACT_PERSON_ADDED'
            redirect_to :action => 'list'
        else
            add_errors_of( @contact_person );
            render :action => 'new'
        end
    end

    def edit
        @js_files = ["contact_person_form.js"]
        @categories = @building.cp_categories;
        @contact_person = ContactPerson.find(params[:id])
    end

    def update
        @contact_person = ContactPerson.find(params[:id])
        # check to see if we need a new category
        if params["add_category"] == "1"
            cpCat = CpCategory.new
            cpCat.name = params["new_category_name"]
            cpCat.building_id = @building.id;
            unless cpCat.save
                add_error "ERR_CANT_SAVE_CATEGORY"
            end
            @contact_person.cp_category = cpCat
        end

        if @contact_person.update_attributes(params[:contact_person])
            add_confirmation 'ContactPerson was successfully updated.'
            redirect_to :action => 'list', :id => @contact_person
        else
            add_errors_of( @contact_person );
            render :action => 'edit'
        end
    end

    def destroy
        ContactPerson.find(params[:id]).destroy
        redirect_to :action => 'list'
    end

    private



end
