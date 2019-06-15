class Business < ApplicationRecord
  belongs_to :user
  has_many :employees
  has_many :phones, as :phoneable
end
