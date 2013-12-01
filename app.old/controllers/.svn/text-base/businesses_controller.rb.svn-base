# TODO remove this contoller!
class BusinessesController < ApplicationController
  def index
    list
    render :action => 'list'
  end

  # GETs should be safe (see http://www.w3.org/2001/tag/doc/whenToUseGet.html)
  verify :method => :post, :only => [ :biz_destroy, :biz_create, :biz_update ],
         :redirect_to => { :action => :list }

     def biz_list
         @business_pages, @businesses = paginate :businesses, :per_page => 20
     end

     def biz_show
         @business = Business.find(params[:id])
     end

     def biz_new
         @business = Business.new
     end

     def biz_create
         @business = Business.new(params[:business])
         if @business.save
             add_confirmation 'Business was successfully created.'
             redirect_to :action => 'biz_list'
         else
             render :action => 'biz_new'
         end
     end

     def biz_edit
         @business = Business.find(params[:id])
     end

     def biz_update
         @business = Business.find(params[:id])
         if @business.update_attributes(params[:business])
             add_confirmation 'Business was successfully updated.'
             redirect_to :action => 'biz_show', :id => @business
         else
             render :action => 'biz_edit'
         end
     end

     def biz_destroy
         Business.find(params[:id]).destroy
         redirect_to :action => 'biz_list'
     end
end
