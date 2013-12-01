class GuestController < ApplicationController
    layout "guest", :except=>["print_map"]
    before_filter :ensure_building_exists

    def index
        if ( @building.class == BusinessBuilding )
            redirect_to :controller=>"business_building", :id=>@building;
            return;
        end
        
        @anns = @building.get_announcements( true );
        @ann_count = @anns.size>8 ? 8 : @anns.size
        @psts = @building.get_tenant_posts( true );
        @pst_count = @psts.size>12 ? 12 : @psts.size
    end

    def directions
        #nothing to do - just show the page.
    end

    def print_map

    end

    def announcements
        @css_files = ["tables"]
        @anns = @building.get_announcements( true );
    end

    def show_single_announcement
        @ann = Announcement.find( params[:id] )
    end

    def tenant_posts
        @css_files = ["tables"]
        @psts = @building.get_tenant_posts( true );
    end

    def show_single_post
        @pst = TenantPost.find( params[:id] )
    end

    def login_tenant
        # make sure tenants from other buildings can't log into @building.
        if @tenant != nil
            if @building.id == @tenant.building_id
                redirect_to :controller=>"tenant";
                return false;
            else
                clear_session_tenant;
            end
        end
    end

    def login_vaad
        # make sure tenants from other buildings can't log in to @building.
        if @tenant != nil
            if @building.id == @tenant.building_id
                redirect_to :controller=>"vaad_admin";
                return false;
            else
                clear_session_tenant;
            end
        end
    end

    def login_other
        if ! request.post?
            # first time, nothing to do (for now)
        else
            #submitted, validate and redirect
            usr = User.authenticate( params[:username].strip, params[:password].strip, @building.id );
            if usr != nil
                if usr.role == "UR_INITIAL"
                    start_session( usr );
                    set_current_user( usr );
                    session[:msg_nituk] = "התנתק";
                    redirect_to(:controller => "vaad_admin", :action=>"index");
                end
            else
                add_error "AUTHENTICATION_FAILED";
            end
        end
    end

    def legal_faq
        @css_files ||="qa";
        @questions = CondoQuestion.find_all_displayed();
    end

    def test

    end

end
