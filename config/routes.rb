ActionController::Routing::Routes.draw do |map|
    # The priority is based upon order of creation: first created -> highest priority.
    
    # Sample of regular route:
    # map.connect 'products/:id', :controller => 'catalog', :action => 'view'
    # Keep in mind you can assign values other than :controller and :action
    
    # Sample of named route:
    # map.purchase 'products/:id/purchase', :controller => 'catalog', :action => 'purchase'
    # This route can be invoked with purchase_url(:id => product.id)
    
    ########################################################################################
    # To turn off the system,
    # remove the # at the begining of the next lines to set the system to off mode.
    # map.connect 'super_users/:action', :controller=>"super_users"
    # map.connect '', :controller=>"dispatcher", :action=>"system_outage"
    # map.connect ':anything', :controller=>"dispatcher", :action=>"system_outage"
    # map.connect ':any/:thing', :controller=>"dispatcher", :action=>"system_outage"
    # map.connect ':any/:thi/:ng', :controller=>"dispatcher", :action=>"system_outage"
    ########################################################################################

    # You can have the root of your site routed by hooking up '' 
    # -- just remember to delete public/index.html.
    map.connect '', :controller => "general"
    
    # Allow downloading Web Service WSDL as a file with an extension
    # instead of a file named 'wsdl'
    map.connect ':controller/service.wsdl', :action => 'wsdl'
    
    map.direct_link 'dispatcher/direct_link/:link',
        :controller => "dispatcher",
        :action     => "direct_link"
    
    # the building dispatcher
    map.building "buildings/:eng_city/:eng_street/:eng_number", 
        :controller => "dispatcher", 
        :action => "create_building_session",
        :eng_city => /(\w|-)+/,
        :eng_street => /(\w|-)+/,
        :eng_number => /\w+/
     
    map.mt_company "mt_companies/:eng_name",
        :controller => "dispatcher",
        :action => "create_mt_company_session",
        :eng_name => /(\w|-)+/;
    
    map.business_building "businesses/:eng_city/:eng_street/:eng_number/:business_eng_name", 
        :controller => "dispatcher", 
        :action => "create_business_building_session",
        :eng_city => /(\w|-)+/,
        :eng_street => /(\w|-)+/,
        :eng_number => /\w+/,
        :business_eng_name => /[a-zA-Z0-9_]+/
    
    # Install the default route as the lowest priority.
    map.connect ':controller/:action/:id'
end
