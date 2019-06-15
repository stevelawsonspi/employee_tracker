class Employee < ApplicationRecord
  belongs_to :business
  has_many   :phone_numbers,  as: :phone_numberable
  has_many   :emails,         as: :emailable
end
