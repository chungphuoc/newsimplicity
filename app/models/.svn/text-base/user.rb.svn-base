require "digest/sha1"
require "validation_mixin"

class User < ActiveRecord::Base
    include ValidationMixin;
    include NameSortabilityMixin;
    
    has_many :maintenance_requests, :as=>:reporter, :dependent=>:nullify;
    
    validates_presence_of :username,  
                          :user_type;
    belongs_to :building;
    belongs_to :business;
    
    attr_accessor :password_confirmation;
    
    ROLES = [ "UR_MAINTENANCE", "UR_CONTRACTOR", "UR_INITIAL", "UR_BIZ_USER", "UR_BIZ_MANAGER" ]
    
    def role=(t)
        if ROLES.include?(t)
            self[:user_type] = t
        else
            raise "Illegal user role: " + t
        end
    end
    
    def role
        self[:user_type]
    end
    
    def password 
        @password 
    end 

    def hr_name
        if first_name.nil?
            return username;
        else
            return first_name + " " + surname;
        end
    end

    def password=(pwd) 
        pwd.strip!
        return if pwd.length == 0
            
        @password = pwd 
        create_new_salt 
        self.hashed_password = User.encrypted_password(self.password, self.salt) 
    end 
    
    def username=(usr)
        write_attribute([:username], usr.strip);
    end
    
    def username
        read_attribute(:username);
    end
        
    def safe_delete 
        transaction do 
            destroy 
        end
    end
    
    # returns true iff the user is allowed to manage the site
    def can_manage_site?
        ['UR_INITIAL'].include?(role)
    end
    
    # user authentication for buildings
    def self.authenticate(username, password, building_id) 
        user = self.find_by_username_and_building_id(username, building_id); 
        return validate_password( user, password );
    end 
    
    # user authentication for businesses
    def self.biz_authenticate( username, password, biz_id ) 
        user = self.find_by_username_and_business_id(username, biz_id);
        return validate_password( user, password );
    end
    
    # makes sure that the password is the user's password.
    def self.validate_password( a_user_obj, password ) 

        return nil if a_user_obj == nil;
        
        expected_password = encrypted_password(password, a_user_obj.salt);
        if a_user_obj.hashed_password != expected_password 
            a_user_obj = nil;
        end
        
        return a_user_obj;
    end
    
    def before_validation
        self.building = self.business.building unless self.business.nil?
    end
    
    
    def validate
        if ( self.business.nil? || self.business.building.is_user_login_unique )
            field_name = "building_id";
            field_value = self.building_id;
        else
            field_name = "business_id";
            field_value = self.business_id;
        end
        
        if self.new_record?
            update_addition = ""
        else
            update_addition = "AND id!=#{self.id}"
        end
        
        cnt = User.count_by_sql( ["SELECT COUNT(*)
                                     FROM #{User.table_name}
                                     WHERE username=? 
                                      AND #{field_name}=#{field_value}
                                      #{update_addition}", self.username] );
        
        if ( cnt>0 )
            self.errors.add(:username, "USERNAME NOT UNIQUE");
        end
            
        if building_id != nil 
            if ! validate_building_uniqueness( :username ) 
                errors.add(:username, "NOT_UNIQUE_IN_BUILDING");
            end
        elsif business_id != nil
            if ! validate_business_uniqueness( :username ) 
                errors.add(:username, "NOT_UNIQUE_IN_BUSINESS`");
            end
        end

        if ( (! self.password.blank?) && (! self.password_confirmation.blank?) )
            unless self.password == self.password_confirmation
                errors.add( :password, "PASSWORDS DO NOT MATCH");
            end
        end

    end
    
    def before_save
        # set the building to match the business.
        self.building = self.business.building unless self.business.nil?
    end
    
    def after_destroy
        #make sure the business still has users
        if business != nil
            if business.users.size == 0
#               throw "CANT_DELETE_LAST_USER"; TODO enable, but make sure we don't throw when deleting the whole business.
            end
        end
    end
    
    ## < privacy! > #################################################
    private
    
    def self.encrypted_password(password, salt) 
        string_to_hash = password + "NaCl" + salt 
        Digest::SHA1.hexdigest(string_to_hash) 
    end
    
    def create_new_salt 
        self.salt = self.object_id.to_s + rand.to_s 
    end
    
    
end
