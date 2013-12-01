class MiniLoc
   def initialize
       puts "initing"
       @msgs = {}
       self.read_messages
   end
   
   def read_messages
       i = 0;
       IO.foreach("hebrew.properties") do | line |
           comps = line.split("=")
           @msgs[comps[0]] = comps[1].strip()
           i = i + 1
       end
       puts " read #{i} messages"
   end
   
   def translate( msg )
        if ( @msgs[msg].nil? )
            return "!#{msg}!"
        else
            return @msgs[msg]
        end
   end
end


m = MiniLoc.new
puts m.translate("one");
puts m.translate("untitled file name");
puts m.translate("second title");
