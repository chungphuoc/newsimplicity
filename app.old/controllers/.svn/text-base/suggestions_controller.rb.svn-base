class SuggestionsController < ApplicationController

    # GETs should be safe (see http://www.w3.org/2001/tag/doc/whenToUseGet.html)
    verify :method => :post, :only => [ :destroy, :create, :update ],
    :redirect_to => { :action => :list }

    def new
        @suggestion = Suggestion.new;
        @suggestion.ctrl = params[:ctrl];
        @suggestion.actn = params[:actn];
    end

    def create
        @suggestion = Suggestion.new(params[:suggestion])
        @suggestion.created_on = DateTime.now
        @suggestion.body = "#{@suggestion.body.strip}\n#{current_user().hr_name()}" unless current_user.nil?
        if @suggestion.save
            redirect_to :action => 'thank_you'
        else
            add_errors_of( @suggestion );
            render :action => 'new'
        end
    end

    def thank_you
    end

end
