# == Records a single change in the state of a maintenance request.
class MaintenanceRequestHistoryItem < ActiveRecord::Base
    belongs_to :maintenance_request;
    belongs_to :acting_user, :polymorphic=>true;
    
    ##################
    # Types of changes. String cannot be longer than 16 chars!
    # TODO change to numbers.     1234567890123456
    TYPE_ADD_REMARK            = "remark";
    TYPE_ADD_COST_DATA         = "cost data add";
    TYPE_ASSIGNEE_CHANGE       = "assignee change";
    TYPE_STATE_CHANGE          = "state change";
    TYPE_TITLE_CHANGE          = "title change";
    TYPE_URGENCY_CHANGE        = "urgency change";
    TYPE_BODY_CHANGE           = "body change";
    TYPE_PLACE_CHANGE          = "place change";
    TYPE_BUILDING_CHANGE       = "building change";
    TYPE_SERVICE_TYPE_CHANGE   = "type change";
    TYPE_HOURS_OF_FIX_CHANGE   = "hrs change";
    TYPE_PRICE_PER_HOUR_CHANGE = "pph change";
    TYPE_PARTS_COST_CHANGE     = "pc change";
    TYPE_FIXED_PRICE_CHANGE    = "fx change";
    TYPE_ADD_FILES             = "add files";
    TYPE_READ_FILES            = "read files";
    TYPE_REMOVE_FILES          = "remove files";
    TYPE_BUDGET_CHANGE         = "budget change";
    
    # we save the created time in the relevant location, according to the localization.
    def before_create
       self.created_on = Localization.localizer.now(); 
    end
    
    def before_save
       # encode the acting user
       self.acting_user_data = "#{self.acting_user.hr_name}";
    end
    
    # returns an array with all the actions actor can perform over mt_req
    # if the request's state is DEBIT_DONE, only mt company admins and building
    # owners can change it, and the only thing they can do is state change.
    # otherwise, more complex logic follows.
    # /!\ Anyone can add remarks, always.
    def self.privileges_for( actor, mt_req )
        privs = [TYPE_ADD_REMARK]
        
        if (  mt_req.state == MaintenanceRequest::DEBIT_DONE )
            if ( ( (actor.kind_of? BuildingOwner ) && actor.buildings.include?(mt_req.building) ) ||
                 (actor.kind_of? MtCompanyWorker) && actor.mt_company.buildings.include?(mt_req.building) && actor.role.admin? )
                privs << TYPE_STATE_CHANGE; 
             end
        else
            # the request is still in progress
            # did the actor report mt_req?
            if ( mt_req.reporter == actor )
                privs << TYPE_TITLE_CHANGE;
                privs << TYPE_BODY_CHANGE;
                privs << TYPE_PLACE_CHANGE;
                privs << TYPE_SERVICE_TYPE_CHANGE;
                privs << TYPE_ASSIGNEE_CHANGE;
                privs << TYPE_URGENCY_CHANGE;
                privs << TYPE_BUILDING_CHANGE unless actor.kind_of? User;
                privs << TYPE_READ_FILES;
                privs << TYPE_ADD_FILES;
                privs << TYPE_REMOVE_FILES;
            end
        
            # did mt_req occured in a building owned by actor?
            if ( (actor.kind_of? BuildingOwner ) && actor.buildings.include?(mt_req.building) )
               privs << TYPE_ASSIGNEE_CHANGE;
               privs << TYPE_URGENCY_CHANGE;
               privs << TYPE_STATE_CHANGE;
               privs << TYPE_BUILDING_CHANGE;
               privs << TYPE_READ_FILES;
               privs << TYPE_ADD_FILES;
               privs << TYPE_REMOVE_FILES;
               privs << TYPE_BUDGET_CHANGE;
            end
        
            # did mt_req occured in a building actor takes care of?
            if ( (actor.kind_of? MtCompanyWorker) && actor.mt_company.buildings.include?(mt_req.building) )
                privs << TYPE_ASSIGNEE_CHANGE;
                privs << TYPE_URGENCY_CHANGE;
                privs << TYPE_HOURS_OF_FIX_CHANGE;
                privs << TYPE_PRICE_PER_HOUR_CHANGE;
                privs << TYPE_PARTS_COST_CHANGE;
                privs << TYPE_FIXED_PRICE_CHANGE;
                privs << TYPE_BUDGET_CHANGE;
                privs << TYPE_ADD_COST_DATA;
                privs << TYPE_READ_FILES;
                privs << TYPE_ADD_FILES;
                if ( actor.role.admin? )
                    privs << TYPE_STATE_CHANGE;
                end
            end
        
            # is the request assigned to the actor?
            if ( actor == mt_req.assignee )
               privs << TYPE_STATE_CHANGE; 
            end
        end
        return privs;
    end
    
end
