# allows objects to sort themselvs according to their hr_name.
# default implementatioin of hr_name is provided. It assumes existance of
# - first_name
# - surname
# - username
module NameSortabilityMixin
   
   def <=>( hr_name_object )
       return self.hr_name<=>hr_name_object.hr_name;
   end
   
   def hr_name( with_id=false )
       ret_str = "";

       if self.first_name.nil?
           ret_str = self.username;
       else
           ret_str = self.first_name + " " + self.surname;
       end
       
       ret_str << " (#{self.id})" if with_id;
       return ret_str;
   end
   
   def hr_name_with_id()
       return hr_name( true );
   end

end