# == Schema Information
# Schema version: 18
#
# Table name: contact_people
#
#  id             :integer(11)   not null, primary key
#  first_name     :string(255)   
#  surname        :string(255)   
#  company        :string(255)   
#  phone          :string(255)   
#  fax            :string(255)   
#  mobile         :string(255)   
#  email          :string(255)   
#  site           :string(255)   
#  about          :text          
#  address        :string(255)   
#  cp_category_id :integer(11)   default(0), not null
#  position       :string(255)   
#

class ContactPerson < ActiveRecord::Base
    belongs_to :cp_category
    belongs_to :building;
end
