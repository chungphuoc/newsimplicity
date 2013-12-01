# Maintenance Company. These guys are responsible for maintaining buildings (light bulbs, gardening, etc.)
class MtCompany < ActiveRecord::Base
    include FileHandleMixin
    
    validates_uniqueness_of :eng_name;
    has_many :buildings, :dependent=>:nullify;
    has_many :mt_company_workers, :dependent=>:destroy;
    has_many :mt_company_worker_roles, :dependent=>:destroy;
    has_many :mt_company_tasks;
    
    HOME_DIR = "mt_company_files";
    
    def self.save_path
        return HOME_DIR;
    end
    
    def mt_company
        return self
    end
    
    def file_suffix
        return image_extension
    end
    
    def local_path
        return "#{RAILS_ROOT}/public/#{HOME_DIR}/#{id.to_s}";
    end
    
    def after_create
        perm = 0745;
        Dir.mkdir( local_path, perm ); 
    end
    
    # return an array of all the roles in the company, sorted by name
    def roles
        return MtCompanyWorkerRole.find( :all, :conditions=>["mt_company_id=?", id], :order=>"name" );
    end
    
    # returns the workers that hold the role, or all, if the role is null
    def workers( a_role = nil )
        if ( a_role == nil )
            return mt_company_workers( :order=>"surname" );
        else
            # TODO change to object_id, pending lunar's version supporting this.
            return MtCompanyWorker.find(:all, :conditions=>["mt_company_id=? AND mt_company_role_id=?", self.id, a_role.id], :order=>"surname" );
        end
    end
    
    # returns all the workers that can manage a house
    def house_managers
        query_str = %{SELECT mt_company_workers.* 
                        FROM   mt_company_workers, mt_company_worker_roles
                        WHERE  mt_company_workers.mt_company_id = %s
                           AND mt_company_workers.mt_company_role_id = mt_company_worker_roles.id
                           AND mt_company_worker_roles.building_manager = true;}
        return MtCompanyWorker.find_by_sql( query_str % [self.id] );        
    end
    
    
    # returns the number of workers that can administer the site.
    # obviously, 0 is bad.
    def admin_count
        return MtCompanyWorkerRole.count_by_sql( "select count(*) from mt_company_workers, mt_company_worker_roles " +
                                                 "where mt_company_workers.mt_company_role_id = mt_company_worker_roles.id " +
                                                 "AND mt_company_worker_roles.admin = true " + 
                                                 "AND mt_company_workers.mt_company_id = #{id}" );
    end
    
    # returns the relevant mt_requests for the relevant worker. If no worker is passed,
    # all the requests are returned.
    def find_relvant_mt_requests( is_open=true, a_worker=nil ) 
        sql_str = "SELECT * FROM maintenance_requests";
        if (a_worker == nil) 
            sql_str << " WHERE building_id IN (SELECT id FROM buildings WHERE mt_company_id=#{id})";
        else
            sql_str << " WHERE building_id IN (SELECT id FROM buildings WHERE mt_building_manager_id=#{a_worker.id})";
        end
        
        if (is_open)
            sql_str << " AND state IN (#{MaintenanceRequest::OPEN}, #{MaintenanceRequest::IN_PROGRESS})";
        end
        
        return MaintenanceRequest.find_by_sql( sql_str );
    end
    
    # returns the tasks which were not accepted yet
    def new_tasks
        return MtCompanyTask.find( :all,
                                   :conditions=>"mt_company_id=#{self.id} AND status=#{MtCompanyTask::CREATED}" );
    end
    
    # return all the tasks that needs to be done.
    def pending_tasks
        return MtCompanyTask.find( :all,
                                   :conditions=>"mt_company_id=#{self.id} AND 
                                                NOT ( status=#{MtCompanyTask::DONE} OR status=#{MtCompanyTask::CANCELLED})" );        
    end
    
    def before_destroy
        update_attributes( :disable_checks=>true );
    end 
    
    def after_destroy
        # TODO remove mt_company's files
        
    end
    
    def <=>(other)
        return name<=>other.name
    end
    
end
