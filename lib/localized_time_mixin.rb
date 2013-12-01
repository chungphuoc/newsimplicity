# allows active records to save the dates on the localized time zone
module LocalizedTimeMixin
    def before_create
        write_attribute( :created_on, Localization::localizer.now() );
        write_attribute( :updated_on, Localization::localizer.now() );
    end
    
    def before_update
        write_attribute( :updated_on, Localization::localizer.now() );
    end
    
end