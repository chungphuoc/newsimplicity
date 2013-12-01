# allowed to control the behind-the-site data
require "digest/sha1"

class SuperUser < ActiveRecord::Base
    validates_presence_of :username;
    validates_uniqueness_of :username;
    
    def password 
        @password 
    end 

    def password=(pwd) 

        return if pwd.strip.length == 0
            
        @password = pwd 
        create_new_salt 
        self.hashed_password = SuperUser.encrypted_password(self.password, self.salt) 
    end 
    
    def self.authenticate(username, password) 
        user = self.find_by_username(username) 
        if user 
            expected_password = encrypted_password(password, user.salt) 
            if user.hashed_password != expected_password 
                user = nil 
            end 
        end 
        user 
    end 
    
    def safe_delete 
        transaction do 
            destroy;
            if SuperUser.count == 0 
                raise "ERR_CANT_DELETE_LAST_SUPER_USER";
            end
        end
    end
    
    ##< PRIVACY >################################################
    private
    def self.encrypted_password(password, salt) 
        string_to_hash = password + "NaCl" + salt # 'wibble' makes it harder to guess 
        Digest::SHA1.hexdigest(string_to_hash) 
    end
    
    def create_new_salt 
        self.salt = self.object_id.to_s + rand.to_s 
    end
    
end
