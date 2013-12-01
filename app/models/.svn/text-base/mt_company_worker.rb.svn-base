class MtCompanyWorker < ActiveRecord::Base
    include UsernamePasswordMixin;
    include NameSortabilityMixin;
    
    belongs_to  :mt_company;
    has_one     :mt_company_role;
    has_many    :buildings, :foreign_key=>"mt_building_manager_id", :dependent=>:nullify;
    has_many    :maintenance_requests, :foreign_key=>"solving_worker_id", :dependent=>:nullify;
    has_many    :assigned_requests, :as=>:assignee, :class_name=>"MaintenanceRequest", :dependent=>:nullify;
    has_many    :mt_company_tasks, :as=>:creator;
    
    validates_presence_of :username;
    validates_presence_of :hashed_password;
    
    attr_accessor :password_confirmation;
        
    def mt_company_role=( value )
        
        if value.class == MtCompanyWorkerRole
            write_attribute(:mt_company_role_id, value.id );
            
        elsif value.class == Fixnum
            write_attribute(:mt_company_role_id, value );
            
        elsif value.class == String
            write_attribute(:mt_company_role_id, value.to_i() );

        else
            raise "Can't assign company role to none company role obejct #{value.class.name}";
        end
    end
    
    def hr_name
        if first_name.nil?
            return username;
        else
            return first_name + " " + surname;
        end
    end
 
    def mt_company_role
        id = read_attribute(:mt_company_role_id);
        return MtCompanyWorkerRole.find( id );
    end
    
    def role
        return self.mt_company_role;
    end
    
    def buildings 
        return Building.find(:all, :conditions=>["mt_building_manager_id=?", id], :order=>"city, street, number" );
    end
    
    def count_buildings
        return Building.count(:conditions=>["mt_building_manager_id=?", id]);
    end
        
    def self.authenticate( aUsername, aPassword, mt_cpny_id ) 
        wkr = self.find_by_username_and_mt_company_id(aUsername, mt_cpny_id); 
        if wkr 
            expected_password = UsernamePasswordMixin::encrypted_password(aPassword, wkr.salt);
            if wkr.hashed_password != expected_password 
                wkr = nil;
            end 
        end 
        return wkr;
    end

    def after_destroy 
        return if mt_company.disable_checks();
        if mt_company.admin_count() == 0
            raise "Can't delete last admin";
        end 
    end 
    
    def after_update
        return if mt_company.disable_checks();
        if mt_company.admin_count() == 0
            errors.add_to_base "must have at least one admin";
            raise "must have at least one admin";
        end 
    end
    
    #--< protected >---------------------------
    protected
    def validate 
        # vlaidate that the passwords match
        if ( (! password.blank?) && (! password_confirmation.blank?) )
            unless self.password == self.password_confirmation
                errors.add( :password, "PASSWORDS MUST MATCH") 
            end
        end
        
        # validate the the usernaem in unique in the mt_compnay
        if self.new_record?
            update_addition = ""
        else
            update_addition = "AND id!=#{self.id}"
        end
        
        cnt = MtCompanyWorker.count_by_sql( ["SELECT COUNT(*)
                                     FROM #{MtCompanyWorker.table_name}
                                     WHERE username=? 
                                      AND mt_company_id=?
                                      #{update_addition}", self.username, self.mt_company_id] );
        
        if ( cnt>0 )
            self.errors.add(:username, "USERNAME NOT UNIQUE");
        end
    end
    
end
