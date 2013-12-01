# handles username / password handling in various models.
# assumes attributes:
#  - hashed_password
#  - salt
# adds attributes:
#  - password 
require 'digest/sha1'
require 'digest'
module UsernamePasswordMixin
        
    attr_reader :password;
    def password 
        return @password;
    end 

    def password=( pwd )
        pwd.strip!
        return if pwd.length == 0;
            
        @password = pwd;
        create_new_salt();
        
        self.hashed_password = UsernamePasswordMixin.encrypted_password( self.password, self.salt );
    end 
    
    def username=( usr )
       self[:username] = usr.strip;
    end
    
    def username
        return self[:username];
    end
     
    def create_new_salt 
        self.salt = self.object_id.to_s + rand.to_s;
    end

    def UsernamePasswordMixin.encrypted_password( password, salt )
        string_to_hash = password + "NaCl" + salt;
        return Digest::SHA1.hexdigest(string_to_hash);
    end

end