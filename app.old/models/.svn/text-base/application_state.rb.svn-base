# Instances of this class capture the state of the application at a certain point in time,
# e.g. a certain user viewing a certain page. They allow us to capture, serialize and restore
# application states. This is useful for supplying direct links into the application.
class ApplicationState
    include UniqueIdModule;
    
    # the current user of the application
    attr_accessor :user;
    
    # the building (might be null)
    attr_accessor :building;
    
    # the maintenance company (might be null)
    attr_accessor :mt_company;
    
    # additional URL parameters (e.g. id)
    attr_accessor :url_params;
    
    attr_accessor :controller;
    attr_accessor :action
    
    def initialize()
        self.url_params={}
    end
    
    def to_s()
        to_hash().to_s();
    end
    
    # returns an encrypted string representing the object
    def marshal
        h = to_hash();
        h = HashMarshaler.marshal_hash( h );
        return Encryption.encrypt(h);
    end
    
    # returns a new object, from a marshaled string.
    # might throw some exceptions if the marshaled string is mangaled
    def self.unmarshal( marshaled_form )
        return from_hash( HashMarshaler.unmarshal_hash(Encryption.decrypt(marshaled_form)) );
    end
    
    def ==( other )
        return false unless other.kind_of?( ApplicationState );
        
        return false unless self.user       == other.user       
        return false unless self.mt_company == other.mt_company 
        return false unless self.url_params == other.url_params 
        return false unless self.building   == other.building   
        return false unless self.controller == other.controller 
        return false unless self.action     == other.action
        
        return true;
    end
    
    # return a hash table with all the data
    def to_hash
       rh = {};
       rh[KEY_USER]       = unique_obj_id(user) unless user.nil?
       rh[KEY_MT_COMPANY] = unique_obj_id(mt_company) unless mt_company.nil?
       rh[KEY_URL_PARAMS] = url_params unless url_params.blank?
       rh[KEY_BUILDING]   = unique_obj_id(building) unless building.nil?
       rh[KEY_CONTROLLER] = controller unless controller.nil?
       rh[KEY_ACTION]     = action unless action.nil?

       return rh;
    end
    
    # Create a new object, based on the passed hashtable
    def self.from_hash( ph )
        ro = ApplicationState.new;
        ro.user       = ro.obj_from_unique_id(ph[KEY_USER]) unless ph[KEY_USER].blank?;
        ro.mt_company = ro.obj_from_unique_id(ph[KEY_MT_COMPANY]) unless ph[KEY_MT_COMPANY].blank?;
        ro.url_params.update( ph[KEY_URL_PARAMS] ) unless ph[KEY_URL_PARAMS].blank?;
        ro.building   = ro.obj_from_unique_id(ph[KEY_BUILDING]) unless ph[KEY_BUILDING].blank?;
        ro.controller = ph[KEY_CONTROLLER] unless ph[KEY_CONTROLLER].blank?;
        ro.action     = ph[KEY_ACTION] unless ph[KEY_ACTION].blank?;

        return ro;
    end
    
    def redirect_to_hash
        hash = {};
        hash[:controller] = controller.to_s unless controller.nil?
        hash[:action] = action.to_s unless action.nil?
        hash.update( url_params ) unless url_params.blank?
        
        return hash;
    end
    
    protected 
    
    # keys for the marshaled form
    KEY_USER       = :U;
    KEY_MT_COMPANY = :M;
    KEY_URL_PARAMS = :P;
    KEY_BUILDING   = :B;
    KEY_CONTROLLER = :C;
    KEY_ACTION     = :A;
    
end