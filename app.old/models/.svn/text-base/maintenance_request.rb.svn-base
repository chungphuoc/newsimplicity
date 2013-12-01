require "sms_module";

class MaintenanceRequest < ActiveRecord::Base
    include LocalizedTimeMixin
    
    belongs_to :tenant;             #-+
    belongs_to :flat;               # +- TODO DEPRECIATE
    belongs_to :place_list_item;    #-+

    belongs_to :building;
    belongs_to :business;
    belongs_to :solving_worker, :class_name=>"MtCompanyWorker", :foreign_key=>"solving_worker_id";

    belongs_to :reporter, :polymorphic=>true;
    belongs_to :place,    :polymorphic=>true;
    belongs_to :assignee, :polymorphic=>true;
    
    has_many :history_items, :order=>"created_on DESC", :class_name=>"MaintenanceRequestHistoryItem";
    has_many :uploaded_files, :as=>:part_of, :order=>"upload_date DESC";
        
    belongs_to :mt_company;
    belongs_to :mt_company_task;
    
    @@URGENCIES = [ "[]",
                    "[!]",
                    "[!!]",
                    "[!!!]",
                    "[!!!!]" ];

    @@urgency_objs = nil;

    # TODO depricate
    @@OPEN = "OPEN";
    @@IN_PROGRESS = "IN_PROGRESS";
    @@SOLVED = "SOLVED";
    @@REJECTED = "REJECTED";
    @@STATES = [ @@OPEN, @@IN_PROGRESS, @@SOLVED, @@REJECTED ];

    @@state_objs = nil;

    # enum-like keys for STATES
    # TODO prefix with STATE_
    OPEN = 0;
    IN_PROGRESS = 1;
    SOLVED = 2;
    REJECTED = 3;
    DEBIT_PENDING = 4;
    DEBIT_DONE = 5;
    
    # enum-like keys for service type
    SERVICE_TYPE_FIX = 0;   # please fix the described problem
    SERVICE_TYPE_QOUTE = 1; # don't fix, just qoute me a price
    
    
    def self.state_ids
        return [OPEN, IN_PROGRESS, DEBIT_PENDING, DEBIT_DONE, REJECTED];
    end
    
    def self.service_types
        return [SERVICE_TYPE_FIX, SERVICE_TYPE_QOUTE];
    end
    
    # TODO depricate
    def self.states
        if @@state_objs.nil?
            @@state_objs = [];
            for i in (0..3)
                @@state_objs << KVObj.new( i, @@STATES[i] );
            end
        end

        return @@state_objs;
    end

    # make sure the state of the mt req is valid
    def validate
        if ( self.title.blank? )
           errors.add(:title,"TITLE CANNOT BE BLANK");
        end
    end

    def self.urgencies
        if @@urgency_objs.nil?
            @@urgency_objs = []
            for i in (0..4)
                @@urgency_objs << KVObj.new( i, @@URGENCIES[i] );
            end
        end

        return @@urgency_objs
    end

    # finds all the requests touched by the user (i.e. opened by or have been actioned on)
    # TODO deprecate
    def self.find_touched_by( acting_user, find_hash_param=nil ) 
        find_hash = {:order=>"updated_on DESC"};
        find_hash.merge!( find_hash_param ) unless find_hash_param.nil?

        sql_str = "SELECT *, (created_on=updated_on) as has_history
                   FROM #{MaintenanceRequest.table_name} mtr
                   WHERE EXISTS ( SELECT * FROM maintenance_request_history_items 
                                 WHERE maintenance_request_id = mtr.id 
                                   AND acting_user_id=? and acting_user_type=?)
                         OR (reporter_id=? AND reporter_type=?)
                   ORDER BY has_history ASC, #{find_hash[:order]} "
        sql_str << " OFFSET #{find_hash[:offset]}" unless find_hash[:offset].nil?
        sql_str << " LIMIT #{find_hash[:limit]}" unless find_hash[:limit].nil?        

        type_str  = acting_user.class.name

        return self.find_by_sql( [sql_str, acting_user.id, type_str, acting_user.id, type_str] );
    end
        
    # find all the reqeusts for a building.
    def self.find_for_building( building_id, unsolved_only=true );
        return self.find(:all, :conditions=>["building_id = ? " + 
            (unsolved_only ? "AND state IN (#{MaintenanceRequest::OPEN},#{MaintenanceRequest::IN_PROGRESS})" : ""), 
            building_id]);
    end

    def self.find_for_owner( owner, unresolved=true )
        if unresolved
            res_str = " AND state IN (#{MaintenanceRequest::OPEN},#{MaintenanceRequest::IN_PROGRESS})";
        else
            res_str = "";
        end

        return self.find_by_sql( [ "SELECT *
                                    FROM   maintenance_requests
                                    WHERE  building_id 
                                    IN ( SELECT id
                                         FROM   buildings
                                         WHERE  building_owner_id = ? ) #{res_str};",
                                    owner.id ] );
    end
        
    # if this is the first time our state is solved,
    # we automatically set the solved date
    def state=( a_state )
        begin
            a_state = a_state.to_i;
        rescue
            a_state = 0;
        end
        
        self[:state]=a_state;
        
        if ( ([ SOLVED, DEBIT_PENDING, DEBIT_DONE ].include? a_state) && (self.solved_on.nil?) ) 
            # request is NOW solved
            self[:solved_on] = Localization::localizer().now();
            if ( self.mt_company_task != nil )
               self.mt_company_task.status = MtCompanyTask::DONE
               self.mt_company_task.save
            end
        elsif ( [ OPEN, IN_PROGRESS ].include?(a_state) && (self.solved_on != nil) )
            # request is not really solved... amend solved date accordingly.
            self[:solved_on] = nil;
            if ( self.mt_company_task != nil )
               self.mt_company_task.status = a_state==OPEN ? MtCompanyTask::ACCEPTED : MtCompanyTask::IN_PROGRESS;
               self.mt_company_task.save
            end
        end
    end
    
    def state()
        return read_attribute(:state);
    end
    
    def solved?
        return ( [SOLVED, DEBIT_DONE, DEBIT_PENDING].include?read_attribute(:state) );
    end            
    
    def locked?
       return ( [DEBIT_PENDING].include? self.state ) 
    end
    
    def before_save
        # update the mt_company based on the building we beling to, if there is one.
        unless self.building.nil?
            self.mt_company = self.building.mt_company;
        end 
        
    end
    
    #check to see whether we need to send an SMS
    def after_save
        
    end

    # provides a human-readable string of the place
    def hr_place()
        begin
            if has_place_line_item?
                return place_list_item.place
            elsif has_flat?
                return flat.human_description
            elsif has_building_unit?
                return building_unit.name;
            else
                return "UNKNOWN";
            end
        rescue
            return "?"
        end
    end

    # return true if we can calculate the cost.
    def has_cost?()
        return ( ( (!hours_of_fix.nil?) && 
                     (!price_per_hour.nil?) ) ||
                 ( ! parts_cost_of_fix.nil? ) ||
                 ( ! fixed_price_of_fix.nil?) );
    end

    # return how much the fixing cost.
    def total_cost
        ttl=0;
        if (!self.hours_of_fix.nil?) && (!self.price_per_hour.nil?)
            ttl = self.hours_of_fix*self.price_per_hour;
        end
        ttl += self.parts_cost_of_fix if ! self.parts_cost_of_fix.nil?
        ttl += self.fixed_price_of_fix if ! self.fixed_price_of_fix.nil?

        return ttl
    end
    
    def qoute?
        return (self.service_type == SERVICE_TYPE_QOUTE);
    end
    
    def is_qoute=( arg ) 
        if arg 
            self.service_type = SERVICE_TYPE_QOUTE;
        else
            self.service_type = SERVICE_TYPE_FIX;
        end
    end
    
    def is_qoute
        return self.qoute?
    end
    
end

