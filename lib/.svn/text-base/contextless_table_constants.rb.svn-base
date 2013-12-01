# constants used in the contextless table.
# here beacuse we can't define constants in a view.
module ContextlessTableConstants
    # valid symbols for the table
    VALID_COLUMNS = [ :accepted, :assignee, 
    :body, :budget, :budget_name, :building, :business,
    :created_on,
    :fixed_price_of_fix,
    :hours_of_fix,
    :mt_company, :mt_company_task,
    :parts_cost_of_fix, :place, :place_free_text, :price_per_hour, :total_cost,
    :qoute_text, :quoted_price,
    :remarks, :reporter,
    :service_type, :solved_on, :solving_worker, :state,
    :title, :updated_on, :urgency
    ]

    # the default columns set
    DEFAULT_COLUMNS = [:building, :title, :urgency, :state, :service_type, :created_on]
    
    def get_default_columns
        return DEFAULT_COLUMNS.clone
    end
end