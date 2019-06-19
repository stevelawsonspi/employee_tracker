class Department < ApplicationRecord
  belongs_to :business
  has_many   :employment_periods
  
  validates :name, presence: true, uniqueness: true

end
