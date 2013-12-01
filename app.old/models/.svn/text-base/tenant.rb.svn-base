require "digest/sha1"
require "validation_mixin"
# Models a single tenant in the building.
# belongs to a flat, and also acts as user for the site (i.e. conatains a username and a password)
# author: Michael Bar-Sinai

class Tenant < ActiveRecord::Base
    include ValidationMixin;
    include NameSortabilityMixin;

    has_many :tenant_posts;
    has_many :maintenance_requests, :as=>:reporter;
    has_many :cars;
    belongs_to :building;
    belongs_to :flat;
    validates_presence_of :first_name;
    validates_presence_of :username;    

    attr_accessor :password_confirmation;

    # roles a tenant may assume during his life in the building
    ROLES = ['TR_REGULAR', 'TR_VAAD', 'TR_BUDGET']

    # returns true iff the user is allowed to manage the site
    def can_manage_site?
        ['TR_VAAD', 'TR_BUDGET'].include?(role)
    end

    def hr_name(full=false)

        if first_name.nil?
            ret_str = username;
        else
            ret_str = first_name + " " + surname;
        end
        if ( full )
            ret_str << " (" << self.flat.human_description << ")";
        end

        return ret_str;
    end

    def hr_name_full
        return hr_name( true );
    end

    # updates the password of the tenant. If the parameter passed is blank, no updating occurs, and the call is ignored.
    def password
        return @password
    end

    def password=(pwd)
        pwd.strip!;
        return if pwd.length == 0;

        @password = pwd;
        create_new_salt();
        self.hashed_password = Tenant.encrypted_password(self.password, self.salt) 
    end

    def username=(usr)
        write_attribute([:username], usr.strip);
    end

    def username
        read_attribute(:username);
    end

    # username/password authentication
    def self.authenticate(username, password, building_id) 
        tnnt = Tenant.find_by_username_and_building_id(username, building_id); 
        if tnnt
            expected_password = encrypted_password(password, tnnt.salt) 
            if tnnt.hashed_password != expected_password 
                tnnt = nil;
            end 
        end 
        tnnt 
    end 

    ## < protection > ###################################
    protected 

    def validate 
        if ( (! password.blank?) && (! password_confirmation.blank?) )
            unless self.password == self.password_confirmation
                errors.add( :password, "PASSWORDS MUST MATCH") 
            end
        end
        errors.add(:password, "ERROR_BAD_PASSWORD")     if (:password == nil ) && (hashed_password.nil);
        errors.add(:username, "NOT_UNIQUE_IN_BUILDING") if ! validate_building_uniqueness( :username );
    end

    ## < privacy! > #################################################
    private

    def self.encrypted_password(password, salt)
        if password.blank?
            return "";
        end
        string_to_hash = password + "sodium_chloride" + salt;

        Digest::SHA1.hexdigest(string_to_hash) 

    end

    def create_new_salt 
        self.salt = self.object_id.to_s + rand.to_s 
    end

end
