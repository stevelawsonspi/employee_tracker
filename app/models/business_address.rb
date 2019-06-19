class BusinessAddress < ApplicationRecord
  belongs_to :business
  
  validates :street,    presence: true
  validates :suburb,    presence: true
  validates :state,     presence: true
  validates :post_code, presence: true
end
