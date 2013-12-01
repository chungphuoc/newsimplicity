class VaadFlatController < ApplicationController
    layout 'vaad_admin'
    before_filter :authorize_vaad_admin
    before_filter :ensure_building_exists;

    def list
        @flat_pages, @flats = paginate :flats, :per_page => 25, :conditions=>["building_id=?", @building.id], :order=>"floor";
    end
    
    def edit_building_structure
        @flats = @building.get_flats;
    end
    
    def update_building_structure
        report = "";
        params.each_key {|key|
            if /flat_(\d)+$/.match(key) != nil
                flat_id = key.split("_")[1];
                flt = Flat.find_by_id(flat_id);
                unless flt.update_attributes(params[key])
                    report << "Flat #{params[key][:id]} was not saved!!\n";
                end
            end
        }

        add_info report;
        redirect_to(:action=>:list);
        
    end
    
    def edit
        @states = getFlatStates
        @flat = Flat.find(params[:id])
        @tenants = @flat.tenants
    end
    
    def show
        @flat = Flat.find(params[:id])
        @tenants = @flat.tenants        
    end
    
    
    def update
        @flat = Flat.find(params[:id])
        if @flat.update_attributes(params[:flat])
            add_info 'FLAT_SAVE_SUCCESSFUL'
            redirect_to :action => 'list'
       else
           @states = getFlatStates
           @tenants = @flat.tenants
           add_errors_of( @flat )
           render :action => 'edit'
       end
    end
end
