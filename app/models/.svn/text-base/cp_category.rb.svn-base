# == Schema Information
# Schema version: 18
#
# Table name: cp_categories
#
#  id   :integer(11)   not null, primary key
#  name :string(255)   
#

class CpCategory < ActiveRecord::Base
    belongs_to :building;
    has_many :contact_persons;
end
