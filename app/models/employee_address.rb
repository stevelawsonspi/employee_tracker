class EmployeeAddress < ApplicationRecord
  belongs_to :employee

  validates :street,    presence: true
  validates :suburb,    presence: true
  validates :state,     presence: true
  validates :post_code, presence: true
end
