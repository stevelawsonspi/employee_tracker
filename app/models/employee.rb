class Employee < ApplicationRecord
  belongs_to :business
  has_many   :employment_periods
  has_many   :phone_numbers,    as: :phone_numberable
  has_many   :emails,           as: :emailable
  
  validates :first_name, presence: true
  validates :last_name,  presence: true
end
