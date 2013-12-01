require 'net/http'
require 'uri'

# module for sending SMS messages.
module SmsModule

    # the url for inforU's interface
    POST_URL = "http://www.inforu.co.il/InforuFrontEnd/webInterface/SendMessageByNumber.aspx"
    USERNAME = "vaadnet"
    PASSWORD = "bachar"

    ERROR_WRONG_CELL_NUMBER = -4

    # posts the text to the mobile number, and returns a number.
    # we usually hope for 1, which means "one message delivered".
    # positive numbers are the number of delivered messages.
    # -1: wrong username/passowrd
    # -4: wrong cell number
    def self.deliver_sms( message_text, from_mobile, to_mobile )
        # validate text
        if (message_text.length > 160 )
            throw "Text too long";
        end
        
        throw "Illegal from number" unless( validate_phone_num(from_mobile) );
        throw "Illegal to number" unless( validate_phone_num(to_mobile) );
        
        # send using inforyou.
        param_hash = { 
            :CellNumber => to_mobile,
            :SenderCellNumber => from_mobile,
            :MessageString => message_text,
            :UserName => USERNAME,
            :Password => PASSWORD }

            res = Net::HTTP.post_form(URI.parse(POST_URL), param_hash);

            return res.body.to_i
        end 

        #validate phone number
        def self.validate_phone_num( phone_num )
            phone_num = phone_num.strip;
            phone_num = phone_num.gsub(/-| /,"");
            if (phone_num.index(/[^0-9]/) != nil )
                return false
            else
                return true;
            end
        end 
    end