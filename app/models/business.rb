class Business < ApplicationRecord
  belongs_to :user
  has_many   :departments,   dependent: :destroy
  has_many   :employees,     dependent: :destroy
  has_many   :phone_numbers, as: :phone_numberable, dependent: :destroy
  has_many   :emails,        as: :emailable,        dependent: :destroy
  
  validates :name, presence: true

end
