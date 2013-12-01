# Page throught all the unit contracts of a building
class UnitContractsByBuildingPagee < UnitContractSqlPagee
    
    def initialize( building )
        super();
        raise "building must be of class #{Building.name} (current class: #{building.class.name})" unless building.kind_of?(Building)
        @building = building
    end
    
    def where_clause
        ["buildings.id=?",@building.id]
    end
end