# Page throught all the unit contracts of a building owner
class UnitContractsByOwnerPagee < UnitContractSqlPagee
    
    def initialize( building_owner )
        super();
        raise "Owner must be of class #{BuildingOwner.name}" unless building_owner.kind_of?(BuildingOwner)
        @owner = building_owner
    end
    
    def where_clause
        ["buildings.building_owner_id=?", @owner.id];
    end
end