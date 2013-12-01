class BuildingUnitsController < ApplicationController
  def index
    list
    render :action => 'list'
  end

  # GETs should be safe (see http://www.w3.org/2001/tag/doc/whenToUseGet.html)
  verify :method => :post, :only => [ :bu_destroy, :bu_create, :bu_update ],
         :redirect_to => { :action => :list }

  def list
    @building_unit_pages, @building_units = paginate :building_units, :per_page => 10
  end

  def show
    @building_unit = BuildingUnit.find(params[:id])
  end

  def new
    @building_unit = BuildingUnit.new
  end

  def create
    @building_unit = BuildingUnit.new(params[:building_unit])
    if @building_unit.save
      add_confirmation 'BuildingUnit was successfully created.'
      redirect_to :action => 'bu_list'
    else
      render :action => 'bu_new'
    end
  end

  def edit
    @building_unit = BuildingUnit.find(params[:id])
  end

  def update
    @building_unit = BuildingUnit.find(params[:id])
    if @building_unit.update_attributes(params[:building_unit])
      add_confirmation 'BuildingUnit was successfully updated.'
      redirect_to :action => 'bu_show', :id => @building_unit
    else
      render :action => 'bu_edit'
    end
  end

  def destroy
    BuildingUnit.find(params[:id]).destroy
    redirect_to :action => 'bu_list'
  end
end
