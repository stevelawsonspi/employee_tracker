class Employee < ApplicationRecord
  belongs_to :business
  has_many   :employment_periods, dependent: :destroy
  has_many   :phone_numbers, as: :phone_numberable, dependent: :destroy
  has_many   :emails,        as: :emailable,        dependent: :destroy
  
  validates :first_name, presence: true
  validates :last_name,  presence: true
end
