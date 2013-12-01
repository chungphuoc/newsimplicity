# Allows actions to set/get state objects.
# Users should invoke get_state, with optional key.
# if the the action was invoked with params[:clean_state]==true.to_s, 
# a new object will always be created and the old one will be discarded.
module ActionStateModule
    
    # a prefix to all state storage keys. Used to clear the stired states
    # when we need to selectovley clear the session
    @@STATE_PREFIX = "#{__FILE__}/"
    
   # gets the state, if there is one, or invokes a passed block if no such state exists.
   def get_state( name=nil )
       key = generate_key(name);
       if (session[key].nil? || params[:clean_state]==true.to_s)
           session[key] = yield
       end
       return session[key];
   end 
   
   private
   def generate_key( name )
       key = "#{params[:contoller]}/#{params[:action]}"
       key <<  "/#{name}" unless name.blank?
       usr = self.current_user();
       if usr.nil?
           user_key = "no/user"
       else
           user_key = "#{usr.class.name}/#{usr.id}"
       end
       key << "/#{user_key}"
       return key
   end
end