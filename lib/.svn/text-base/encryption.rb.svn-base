require 'openssl'
require 'digest'
require 'digest/sha1'

# Simple encrypt/decrypt functionality, adapted for the web
module Encryption
    
    DEF_PASSWORD = "RimOnKawa";
    DEF_IV = "IV IV rup!krup!"
    
    def self.encrypt( value, password=DEF_PASSWORD, iv=DEF_IV )
        c = OpenSSL::Cipher::Cipher.new("aes-256-cbc")
        c.encrypt;
        c.key = Digest::SHA1.hexdigest(password);
        c.iv  = Digest::SHA1.hexdigest(iv);
        e = c.update( value );
        e << c.final;
        return e;
    end
    
    def self.decrypt( value, password=DEF_PASSWORD, iv=DEF_IV )
        c = OpenSSL::Cipher::Cipher.new("aes-256-cbc");
        c.decrypt;
        c.key = Digest::SHA1.hexdigest(password);
        c.iv  = Digest::SHA1.hexdigest(iv);
        d = c.update(value);
        d << c.final
        return d;
    end
end