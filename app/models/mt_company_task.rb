class MtCompanyTask < ActiveRecord::Base
    include Comparable, LocalizedTimeMixin
    
    belongs_to :mt_company;
    belongs_to :building_owner;
    belongs_to :building;
    
    belongs_to :creator, :polymorphic=>true;
    
    has_one    :maintenance_request;
    
    # states a request can be in
    CREATED     = 0; # created by the owner
    ACCEPTED    = 1; # seen by the mt_company
    IN_PROGRESS = 2; # someone's on the roof putting the flag
    DONE        = 3; # done!
    CANCELLED   = 4; # no need to do this (now you say?)
    
    def <=>(other)
        return -1 if until_date == nil;
        return until_date<=>other.until_date;
    end
    
    def no_from_date=(value)
        from_date = nil
    end
    
    def overdue?
        return false if status==CANCELLED;
        if self.status == DONE
            return completed_on.to_date() > until_date;
        else
            return Localization::localizer().now().to_date() > until_date;
        end
    end
    
    def status=( a_status )
        begin
            a_status = a_status.to_i;
        rescue
            a_status = 0;
        end
        
        if ( self[:status] != a_status )
            self[:status] = a_status;
            if ( DONE == a_status ) 
                self[:completed_on] = Localization::localizer().now();
            else
                self[:completed_on] = nil;
            end
        end
    end
    
    def status
        return self[:status];
    end
    
end
