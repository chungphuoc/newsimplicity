class ContactMailer < ActionMailer::Base

    def contact(sender, subject, body, sent_at = Time.now) 
        @subject = subject; 
        @body[:body] = body;
        @body[:sender] = sender;
        @recipients = 'ofir@vaadnet.com';
        @from = 'vaadnet2@vaadnet.com';
        @sent_on = sent_at;
        @headers = {};
    end 
    
    def sms( text, mobile )
        recepient = "#{mobile}@inforu.co.il";
        @subject = recepient + ": " + text; 
        @recipients = recepient; #"mich.barsinai@gmail.com";
        @from = 'system@vaadnet.com';
        @sent_on = Time.now;
        @headers = {};  
    end
    
end
