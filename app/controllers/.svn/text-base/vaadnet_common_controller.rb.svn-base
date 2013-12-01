class VaadnetCommonController < ApplicationController

    def about_us
    end

    def legal_faq
        @css_files ||="qa";
        @questions = CondoQuestion.find_all_displayed();
        
    end
end
