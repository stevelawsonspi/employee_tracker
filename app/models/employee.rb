class Employee < ApplicationRecord
  belongs_to :business
  has_many   :phones,  as: :phoneable
  has_many   :emails,  as: :emailable
end
