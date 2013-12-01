class Building < ActiveRecord::Base
    
    # TODO deprcate and use building_units instead.
    has_many :flats, :dependent=>:destroy;
    has_many :announcements, :dependent=>:destroy;
    has_many :maintenance_requests, :dependent=>:destroy;
    has_many :tenant_posts, :dependent=>:destroy;
    has_many :tenants, :dependent=>:destroy, :order=>"surname";
    has_many :users, :dependent=>:destroy;
    has_many :contact_people, :dependent=>:destroy;
    has_many :cp_categories, :dependent=>:destroy;
    has_many :shared_documents, :dependent=>:destroy;
    
    belongs_to :default_public_unit_type, :class_name=>"UnitType", :foreign_key=>"default_public_unit_type_id";
 
    has_many :building_units, :foreign_key=>"building_id";
    has_many :unit_types;
    
    has_many :businesses, :foreign_key=>"building_id", :order=>"name";

    belongs_to :mt_building_manager, :class_name=>"MtCompanyWorker", :foreign_key=>"mt_building_manager_id";
    belongs_to :mt_company_contact, :class_name => "Tenant", :foreign_key=>"mt_company_contact_id";
    belongs_to :mt_company;
    belongs_to :building_owner;
    belongs_to :owner, :class_name=>"BuildingOwner", :foreign_key=>"building_owner_id";
    
    FAVORITE_LINKS_FILE_NAME = "favorite_links.txt"
    
    HOME_DIR = "building_files";
    MAP_PATH = "map";
    PRINT_MAP_PATH = "print_map";
        
    def local_path
        return "#{RAILS_ROOT}/public/#{HOME_DIR}/#{id.to_s}";
    end
    
    def web_path
        return ActionController::AbstractRequest.relative_url_root + "/#{HOME_DIR}/#{id.to_s}";
    end

    def base_folder_path
        return "#{HOME_DIR}/#{id}";
    end
    
    def <=>( other )
        return self.hr_address <=> other.hr_address;
    end
    
    # return all the public building units.
    def public_units
      return building_units.find(:all, :conditions=>["unit_types.is_public=?",true],
                                        :select=>"building_units.*, unit_types.is_public",
                                       :joins=>"INNER JOIN unit_types ON unit_types.id = unit_type_id").uniq;
    end
    
    def get_company_contact
        begin
            return Tenant.find( mt_company_contact_id );
        rescue
            return nil;
        end
    end
    
    def favorite_links_file
        begin
            path = "#{self.local_path}/#{FAVORITE_LINKS_FILE_NAME}"
            File.stat( path ) 
            return path
        rescue
            return "#{RAILS_ROOT}/config/#{FAVORITE_LINKS_FILE_NAME}"
        end
    end
    
    # returns a list of usernames and their count. If the list is empty,
    # there are no non-unique usernames.
    # list structure: [ {username=>?, count=>?}, {username=>?, count=>?}, ... ]
    def get_non_unique_usernames
        sqlstr =
            "SELECT #{User.table_name}.username, count(#{User.table_name}.username) as count
            FROM #{User.table_name} 
            WHERE building_id = #{self.id}
            GROUP BY #{User.table_name}.username
            HAVING count > 1"
        return connection.select_all( sqlstr );
    end
    
    # create the files needed for a new building,
    # and a default contact person group
    def after_create
        perm = 0745;
        Dir.mkdir( local_path, perm );
        Dir.mkdir( local_path + "/" + Announcement::SAVE_PATH, perm );
        Dir.mkdir( local_path + "/" + TenantPost::SAVE_PATH, perm );
        Dir.mkdir( local_path + "/" + SharedDocument::SAVE_PATH, perm );
        
        cpCat = CpCategory.new;
        cpCat.name = "כללי"; #TODO localize
        cpCat.building_id = self.id;
        cpCat.save!;
    end
    
    def after_destroy
       # TODO remove files
    end
    
    def validate
        # make sure the eng_* fields are grouply unique.
        cnd_str = "eng_city=? AND eng_street=? AND eng_number = ?";
        if ! new_record?
            cnd_str = "id != #{self.id} AND " + cnd_str;
        end
        cnt = Building.count( :conditions=>[cnd_str, eng_city, eng_street, eng_number] );
        if cnt != 0 
            errors.add(:base, "CITY/STREET/NUMBER NOT UNIQUE");
        end
    end
    
    def has_mt_manager?
        return ! mt_building_manager_id.nil?;
    end
    
    def mt_manager
        if has_mt_manager?
            return MtCompanyWorker.find( mt_building_manager_id );
        else
            return nil;
        end
    end
    
    def hr_address
        return street + " " + ( number!="0" ? number + ", " : "" ) + city;
    end
    
    # returns the /city/street/number path
    # TODO use the url object
    def vaadnet_path
        return "#{eng_city}/#{eng_street}/#{eng_number}";
    end
    
    def has_map?
        return false if map_extension.nil?
        return FileTest.exists?( local_map_path  );
    end
    
    def local_map_path
        return local_path + "/#{MAP_PATH}.#{map_extension}";
    end
    
    def map_address
        return web_path + "/" + MAP_PATH + "." + map_extension;
    end
    
    # returns true if the building has tenants that can manage it.
    def has_vaad?
        vaad_cnt = Tenant.count(:conditions=>["building_id=? AND (role='TR_VAAD' OR role='TR_BUDGET')", id]);
        return (vaad_cnt!=0);
    end
    
    def get_flats
        return Flat.find(:all, :conditions=>["building_id=?", self.id], :order=>"floor, number");
    end
    
    def get_cp_categories
        return CpCategory.find(:all, :conditions=>["building_id=?", self.id], :order=>"name");
    end
    
    def get_shared_documents
        return SharedDocument.find(:all, :conditions=>["building_id=?", self.id], :order=>"title, updated_on" );
    end

    def get_place_list_items
        return PlaceListItem.find(:all, :conditions=>["building_id=?", self.id], :order=>"place");
    end

    def get_maintenance_requests( unsolved_only )
        return MaintenanceRequest.find_for_building(self.id, unsolved_only);
    end

    # returns the N recent maintenance requests
    def recent_maintenance_requests( num )
        return MaintenanceRequest.find(:all, :conditions=>["building_id=? AND state IN (?,?)", self.id, 
                        MaintenanceRequest::OPEN, MaintenanceRequest::IN_PROGRESS], :order=>"created_on DESC", :limit=>"#{num}");
    end
    
    def public_maintenance_requests()
        return MaintenanceRequest.find_by_sql(
            [  "SELECT maintenance_requests.*
                FROM   ( place_list_items
                         INNER JOIN buildings
                         ON place_list_items.building_id = buildings.id
                            AND buildings.id = ? )
                       INNER JOIN maintenance_requests
                       ON place_list_items.id = maintenance_requests.place_id
                          AND maintenance_requests.place_type=?
                          AND maintenance_requests.state IN (?,?)
                ORDER BY created_on DESC",
                self.id,
                PlaceListItem.name,
                MaintenanceRequest::OPEN, MaintenanceRequest::IN_PROGRESS ] )
    end
    
    def get_announcements( displayed_only )
        if displayed_only
            cnds = ["building_id=? AND display_on_site=?", self.id, true];
        else
            cnds = ["building_id=?", self.id];
        end
        return Announcement.find(:all, :conditions=>cnds, :order=>"published_on DESC");
    end

    def get_tenant_posts( displayed_only )
        if displayed_only
            cnds = ["building_id=? AND display_on_site=?", self.id, true];
        else
            cnds = ["building_id=?", self.id];
        end
        return TenantPost.find(:all, :conditions=>cnds, :order=>"published_on DESC");
    end

    def get_tenants
        return Tenant.find(:all, :conditions=>["building_id=?", self.id], :order=>"published_on DESC");
    end
    
    # return a hashtable with pseudo interesting statistics
    def get_stats
        ret_hash = {};
        cnds = {:conditions=>["building_id = ?", self.id]};
        ret_hash[:tenant_count] = Tenant.count(cnds);
        ret_hash[:unsolved_mreq_count] = MaintenanceRequest.count(:conditions=>["building_id=? AND state IN (?,?)", self.id,
                                                                                    MaintenanceRequest::OPEN, MaintenanceRequest::IN_PROGRESS]);
        ret_hash[:flat_count] = Flat.count(cnds);
        ret_hash[:contact_person_count] = ContactPerson.count( cnds );
        ret_hash[:user_count] = User.count( cnds );
        
        cnds[:conditions][0] << " AND display_on_site=?";
        cnds[:conditions] << true;
        ret_hash[:tenant_post_count] = TenantPost.count(cnds);
        ret_hash[:announcement_count] = Announcement.count(cnds);
        
        return ret_hash;
    end
    
    # return the building whose city, street and adress are passed.
    # may return null
    def self.find_by_address( city, street, number )
        aBuilding = find(:first, :conditions => ["eng_city=? AND eng_street=? AND eng_number=?", city, street, number] );
        return aBuilding;
    end
    
end
