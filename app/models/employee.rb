class Employee < ApplicationRecord
  belongs_to :business
  has_many :phones, as :phoneable
end
