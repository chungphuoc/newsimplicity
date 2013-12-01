# models a single business building.
# TODO merge with Building
class BusinessBuilding < Building

    # TODO deprecate
    def private_maintenance_requests( business )
        mt_reqs = [];
        cnds = "state IN (#{MaintenanceRequest::OPEN}, #{MaintenanceRequest::IN_PROGRESS})";
        for bu in business.building_units
            mt_reqs.concat( bu.maintenance_requests.find(:all, :conditions=>cnds) );
        end
        
        return mt_reqs;
    end

end
