class EmploymentPeriod < ApplicationRecord
  belongs_to :employee
  belongs_to :department
  
  validates_date :start_date
  validates_date :end_date, allow_nil: true
  validates :position,   presence: true
  validates :salary,     presence: true, numericality: { greater_than: 0, only_integer: true }
  validate  :validate_start_date
  validate  :validate_end_date

  private

  def validate_start_date
    # check does not overlap
    # errors[:start_date] << 'overlaps an existing Employment Period'
  end
  
  def validate_end_date
    return if end_date.blank? 
    return if errors.include?(:end_date) # don't do more checking if end_date already has an error
    
    unless end_date >= start_date
      errors.add(:end_date, 'must be >= start date')
      return
    end
    # check does not overlap
    # check range doesn't overlap
  end
end
