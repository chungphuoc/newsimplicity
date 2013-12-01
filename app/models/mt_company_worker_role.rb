class MtCompanyWorkerRole < ActiveRecord::Base
    belongs_to  :mt_company;
    has_many    :mt_company_workers;
    
    validates_presence_of :name
    
    # can manage a building
    def building_manager?
        return building_manager unless building_manager.nil?;
        return false;
    end
    
    # can manage site
    def admin?
        return admin unless admin.nil?;
        return false;
    end
    
    # has a professional quality (can solve mt requests)
    def professional?
        return professional unless professional.nil?;
        return false;
    end
    
    # might get sms as because of an mt request?
    def smsable?
        return (professional? || building_manager?);
    end

    def after_destroy 
        return if mt_company.disable_checks();
        
        if mt_company.admin_count() == 0
            raise "Can't delete last admin" 
        end 
    end 
    
    def after_update
        return if mt_company.disable_checks();
        
        if mt_company.admin_count() == 0
            raise "must have at least one admin" 
        end 
    end
    
    def workers
        return MtCompanyWorker.find(:all, :conditions=>["mt_company_role_id=?", id], :order=>"surname");
    end
    
    def count_workers
        return MtCompanyWorker.count(:conditions=>["mt_company_role_id=?", id]);
    end
end
