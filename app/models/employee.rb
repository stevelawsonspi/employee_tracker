class Employee < ApplicationRecord
  belongs_to :business
  has_many   :emails,  as: :emailable
end
