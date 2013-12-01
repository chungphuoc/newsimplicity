require 'find'
require "#{RAILS_ROOT}/lib/reload_tester"
class SuperUsersController < ApplicationController

    before_filter :authorize, :except=>[:login, :suggestion_list, :suggestion_destroy_external];

    def index
        list
        render :action => 'list'
    end

    # GETs should be safe (see http://www.w3.org/2001/tag/doc/whenToUseGet.html)
    verify :method => :post, :only => [ :destroy, :create, :update, 
        :mt_company_destroy, :mt_company_create, :mt_company_update,
        :flat_destroy, :flat_create, :flat_update,
        :pli_destroy, :pli_create, :pli_update,
        :suggestion_destroy, :suggestion_create, :suggestion_update,
        :cc_destroy, :cc_create, :cc_update,
        :building_destroy, :building_update, :building_create ],
        :redirect_to => { :action => :list }

    verify :method => :post, :only => [ :bo_destroy, :bo_create, :bo_update ],
            :redirect_to => { :action => :bo_list }

    def login
        if request.post? 
            su = SuperUser.authenticate(params[:username], params[:password]) 
            if su 
                session[:super_user] = su;               
                redirect_to(:action => "index");
            else 
                add_error "ERR_WRONG_USER_PASSWORD";
            end 
        end 
    end

    def logout
        session[:super_user] = nil;
        redirect_to(:controller=>"guest");
    end

    def list
        @super_user_pages, @super_users = paginate :super_users, :per_page => 10
    end

    def show
        @super_user = SuperUser.find(params[:id])
    end

    def new
        @super_user = SuperUser.new
    end

    def create
        @super_user = SuperUser.new(params[:super_user])
        if @super_user.save
            add_confirmation 'SuperUser was successfully created.'
            redirect_to :action => 'list'
        else
            render :action => 'new'
        end
    end

    def edit
        @super_user = SuperUser.find(params[:id])
    end

    def update
        @super_user = SuperUser.find(params[:id])
        if @super_user.update_attributes(params[:super_user])
            add_confirmation 'SuperUser was successfully updated.'
            redirect_to :action => 'show', :id => @super_user
        else
            render :action => 'edit'
        end
    end

    def destroy
        begin
            SuperUser.find(params[:id]).safe_delete;
        rescue RuntimeError => err
            add_error err.message;
        end
        redirect_to :action => 'list'
    end

    ## FLATS #############

    def flat_list
        @flat_pages, @flats = paginate :flats, :per_page => 25
    end

    def flat_show
        @flat = Flat.find(params[:id])
    end

    def flat_new
        @states = getFlatStates
        @flat = Flat.new
        @flat.number = Flat.count+1
        @flat.base_payment = 100.0
        @flat.area = session[:flatArea] if session[:flatArea]
        @flat.floor = session[:flatFloor] if session[:flatFloor]
        @flat.base_payment = session[:flatBasePayment] if session[:flatBasePayment]
    end

    def flat_create
        @flat = Flat.new(params[:flat])
        @states = getFlatStates    
        session[:flatArea]  = @flat.area
        session[:flatFloor] = @flat.floor
        session[:flatBasePayment] = @flat.base_payment

        if @flat.save
            add_confirmation "Flat was successfully created."
            redirect_to :action => 'flat_new'
        else
            render :action => 'flat_new'
        end
    end

    def flat_edit
        @states = getFlatStates
        @flat = Flat.find(params[:id])
    end

    def flat_update
        @flat = Flat.find(params[:id])
        if @flat.update_attributes(params[:flat])
            add_confirmation 'Flat was successfully updated.'
            redirect_to :action => 'flat_show', :id => @flat
        else 
            @states = getFlatStates
            render :action => 'flat_edit'
        end
    end

    def flat_destroy
        Flat.find(params[:id]).destroy
        redirect_to :action => 'flat_list'
    end

    #### PlaceLineItems

    def pli_list
        @place_list_item_pages, @place_list_items = paginate :place_list_items, :per_page => 10
    end

    def pli_show
        @place_list_item = PlaceListItem.find(params[:id])
    end

    def pli_new
        @place_list_item = PlaceListItem.new
    end

    def pli_create
        @place_list_item = PlaceListItem.new(params[:place_list_item])
        if @place_list_item.save
            add_confirmation 'PlaceListItem was successfully created.'
            redirect_to :action => 'pli_list'
        else
            render :action => 'pli_new'
        end
    end

    def pli_edit
        @place_list_item = PlaceListItem.find(params[:id])
    end

    def pli_update
        @place_list_item = PlaceListItem.find(params[:id])
        if @place_list_item.update_attributes(params[:place_list_item])
            add_confirmation 'PlaceListItem was successfully updated.'
            redirect_to :action => 'pli_show', :id => @place_list_item
        else
            render :action => 'pli_edit'
        end
    end

    def pli_destroy
        PlaceListItem.find(params[:id]).destroy
        redirect_to :action => 'pli_list'
    end

    ### SUGGESTIONS

    def internal_suggestion_list
        @suggestion_pages, @suggestions = paginate :suggestions, :per_page => 10
    end

    def suggestion_list
        @suggestions = Suggestion.find( :all, :order=>"created_on DESC" ); 
    end

    def suggestion_edit
        @suggestion = Suggestion.find(params[:id])
    end

    def suggestion_update
        @suggestion = Suggestion.find(params[:id])
        if @suggestion.update_attributes(params[:suggestion])
            add_confirmation 'Suggestion was successfully updated.'
            redirect_to :action => 'suggestion_show', :id => @suggestion
        else
            render :action => 'suggestion_edit'
        end
    end

    def suggestion_show
        @suggestion = Suggestion.find(params[:id])
    end

    def suggestion_destroy
        Suggestion.find(params[:id]).destroy
        redirect_to :action => 'suggestion_list'
    end

    def suggestion_destroy_external
        suggestion_destroy();
    end

    ##########
    # Condo Questions
    ##########

    def cc_list
        @condo_question_pages, @condo_questions = paginate :condo_questions, :per_page => 10
    end

    def cc_show
        @condo_question = CondoQuestion.find(params[:id])
    end

    def cc_new
        @condo_question = CondoQuestion.new;
        @condo_question.display_on_site = true;
    end

    def cc_create
        @condo_question = CondoQuestion.new(params[:condo_question])
        if @condo_question.save
            add_confirmation 'CondoQuestion was successfully created.'
            redirect_to :action => 'cc_list'
        else
            render :action => 'cc_new'
        end
    end

    def cc_edit
        @condo_question = CondoQuestion.find(params[:id])
    end

    def cc_update
        @condo_question = CondoQuestion.find(params[:id])
        if @condo_question.update_attributes(params[:condo_question])
            add_confirmation 'CondoQuestion was successfully updated.'
            redirect_to :action => 'cc_show', :id => @condo_question
        else
            render :action => 'cc_edit'
        end
    end

    def cc_destroy
        CondoQuestion.find(params[:id]).destroy
        redirect_to :action => 'cc_list'
    end

    #############
    # BUILDINGS #
    #############

    def building_list
        @building_pages, @buildings = paginate :buildings, :per_page => 10;
    end

    def building_show
        @building = Building.find(params[:id]);
    end

    def building_new
        @building = Building.new;
        @building.lowest_floor = "-2";
        @building.highest_floor = "15";
        @mt_companies = MtCompany.find_all();
        @mt_companies << KVObj.new(nil, "[none]");
        @username = "username";
        @password = "vaadnet";
        @owners = BuildingOwner.find(:all);
        @owners.sort!();
    end

    def building_create
        building_type = params[:building_type_tp_value];

        case building_type
        when "building"
            @building = Building.new(params[:building]);
        when "business_building"
            @building = BusinessBuilding.new(params[:building]);
        end

        stop = false;

        if params[:username].blank? || params[:password].blank?
            @building.errors.add_to_base("USERNAME_PASSWORD_CANNOT_BE_NULL");
            stop = true;
        end

        #begin
        if @building.save() && ! stop
            if ( @building.class.name == "Building" )
                #create flats
                flat_num = params[:flat_num].to_i();
                flats_per_floor = [flat_num / @building.highest_floor, 1].max();

                rooms_per_flat = params[:rooms_per_flat].to_i();
                area = params[:area].to_i();
                base_payment = params[:base_payment].to_i();

                params[:flat_num].to_i().times { |f_num|
                    f = Flat.new( :num_of_rooms=>rooms_per_flat,
                    :floor=>[(f_num / flats_per_floor)+1, @building.highest_floor].min(),
                    :area=>area,
                    :number=>f_num+1,
                    :base_payment=>base_payment,
                    :state=>"FLATSTATE_UNKNOWN");
                    f.building_id = @building.id;
                    f.save!;

                    # one default tenant per each flat
                    tnt = Tenant.new();
                    tnt.username = "#{f.number}";
                    tnt.password = "vaadnet";
                    tnt.flat = f;
                    tnt.first_name = "FLAT #{f.number}";
                    tnt.surname = "DEFAULT";
                    tnt.building = @building;
                    tnt.role = "TR_REGULAR";
                    tnt.fax = tnt.mobile = tnt.phone = tnt.email = tnt.site = tnt.about = "";
                    tnt.save!
                }

                #initial user for the building vaad management
                iniUser = User.new();
                iniUser.username = params[:username];
                iniUser.password = params[:password];
                iniUser.building_id = @building.id;
                iniUser.role = "UR_INITIAL";
                iniUser.save!;

            elsif (@building.class.name == "BusinessBuilding" )
                # no special needs here
            end

            redirect_to :action => 'building_list';
            add_confirmation "#{@building.class.name} was successfully created." << "<br/>#{params[:building_type_tp_value]}"
        else
            render :action => 'building_new';
        end
    end

    def building_edit
        @mt_companies = MtCompany.find_all();
        @mt_companies << KVObj.new(nil, "[none]");
        @building = Building.find(params[:id])
        @owners = BuildingOwner.find(:all);
        @owners.sort!();
        @non_unique_usernames = @building.get_non_unique_usernames;
    end

    def building_update
        @building = Building.find(params[:id])

        # if mt_company was changed, remove the manager
        if ( @building.mt_company_id != params[:building][:mt_company_id].to_i() ) 
            params[:building][:mt_building_manager_id]  = nil;
        end

        if @building.update_attributes(params[:building])
            add_confirmation 'Building was successfully updated.'
            redirect_to :action => 'building_show', :id => @building
        else
            render :action => 'building_edit';
        end
    end

    def building_destroy
        Building.find(params[:id]).destroy
        redirect_to :action => 'building_list'
    end


    #########################
    # MAINTENANCE COMPANIES #
    #########################
    def mt_company_list
        @mt_company_pages, @mt_companies = paginate :mt_companies, :per_page => 10
    end

    def mt_company_show
        @mt_company = MtCompany.find(params[:id])
    end

    def mt_company_new
        @mt_company = MtCompany.new();
        @mtc_worker = MtCompanyWorker.new();
    end

    def mt_company_create
        @mtc_worker = MtCompanyWorker.new(params[:mtc_worker]);
        @mt_company = MtCompany.new(params[:mt_company]);

        @mt_company.site = fix_link(@mt_company.site);

        if @mt_company.save!
            # create default worker and role
            mtc_role = MtCompanyWorkerRole.new();
            mtc_role.admin = true;
            mtc_role.mt_company = @mt_company;
            mtc_role.name = "מנהל";
            mtc_role.save!

            @mtc_worker.mt_company = @mt_company;
            @mtc_worker.mt_company_role = mtc_role;
            @mtc_worker.save!;

            add_confirmation 'MtCompany was successfully created.';
            redirect_to( :action => 'mt_company_list' );
        else
            render( :action => 'mt_company_new' );
        end
    end

    def mt_company_edit
        @mt_company = MtCompany.find(params[:id])
    end

    def mt_company_update
        @mt_company = MtCompany.find(params[:id])
        if @mt_company.update_attributes(params[:mt_company])
            add_confirmation 'MtCompany was successfully updated.'
            redirect_to :action => 'mt_company_list', :id => @mt_company
        else
            render :action => 'mt_company_edit'
        end
    end

    def mt_company_destroy
        cpny = MtCompany.find(params[:id]);
        cpny.update_attributes( :disable_checks=>true );
        cpny.destroy();

        redirect_to :action => 'mt_company_list';
    end


    ###################
    # BUILDING OWNERS #
    ###################

    def bo_list
        @building_owner_pages, @building_owners = paginate :building_owners, :per_page => 10
    end

    def bo_show
        @building_owner = BuildingOwner.find(params[:id])
    end

    def bo_new
        @building_owner = BuildingOwner.new
    end

    def bo_create
        @building_owner = BuildingOwner.new(params[:building_owner])
        if @building_owner.save
            add_confirmation 'BuildingOwner was successfully created.'
            redirect_to :action => 'bo_list'
        else
            render :action => 'bo_new'
        end
    end

    def bo_edit
        @building_owner = BuildingOwner.find(params[:id])
    end

    def bo_update
        @building_owner = BuildingOwner.find(params[:id])
        if @building_owner.update_attributes(params[:building_owner])
            add_confirmation 'BuildingOwner was successfully updated.'
            redirect_to :action => 'bo_show', :id => @building_owner
        else
            render :action => 'bo_edit'
        end
    end

    def bo_destroy
        BuildingOwner.find(params[:id]).destroy
        redirect_to :action => 'bo_list'
    end

    #####################
    # localized strings #
    #####################

    def localized_strings
        if request.post?
            ent_hash = params[:entry]
            ent_hash.each do | key, val |
                ent = LocalizedEntry.find( key );
                ent.value = val.strip;
                ent.save
            end
            reset_localization;
            add_confirmation( "LOCALIZATION_RESETED" );
            add_warning("NEED TO UPDATE FILES MANUALLY");
        end

        @entries = LocalizedEntry.find( :all, :order=>:value );
    end


    def sms_sender
        if request.post?
            begin
                res = SmsModule::deliver_sms( params[:text], params[:from_num],params[:to_num] )
                res = res.to_i
                if ( res==1 )
                    add_confirmation "SMS_SENT"
                else
                    if ( res = SmsModule::ERROR_WRONG_CELL_NUMBER )
                        add_error( "WRONG_CELL_NUMBER" );
                    else
                        add_error( "inforU Returned #{res}");
                    end
                end
            rescue Exception=>e
                add_error e.message
            end 
        end
    end
    
    ##################
    # Reload Classes #
    ##################
    def reload_classes
        if ( request.post? )
            @res = list_ruby_classes
            @res.each { |path| load path }
        end
        rt = ReloadTester.new
        @value = rt.get_value;
    end

    private
    def authorize
        if session[:super_user] == nil && SuperUser.count > 0
            redirect_to :action=>:login;
        end
    end
    
    def list_ruby_classes
        res = []
        folders = ["lib","app/####
        # TM_CURRENT_WORD #
        ####models"]
        excludes = [".svn"]
        
        folders.each do | fol |
            Find.find("#{RAILS_ROOT}/#{fol}") do |path|
                if FileTest.directory?(path)
                    if excludes.include?(File.basename(path))
                        Find.prune       # Don't look any further into this directory.
                    else
                        next
                    end
                else
                    if (path[path.length-3..path.length] == ".rb") && ( path[0..0]!="." )
                        res << path 
                    end
                end
            end
        end
        return res
    end
    
end
