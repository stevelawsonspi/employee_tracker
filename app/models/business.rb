class Business < ApplicationRecord
  belongs_to :user
  has_many   :departments
  has_many   :employees
  has_many   :phone_numbers, as: :phone_numberable
  has_many   :emails,        as: :emailable
end
