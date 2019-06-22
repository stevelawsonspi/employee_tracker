class EmploymentPeriod < ApplicationRecord
  belongs_to :employee
  belongs_to :department
  
  validates :start_date, presence: true
  validates :position,   presence: true
  validates :salary,     presence: true, numericality: { greater_than: 0, only_integer: true }
  validate  :validate_start_date
  validate  :validate_end_date

  private

  def validate_start_date
    # check valid date
    # check does not overlap
    # errors[:start_date] << 'overlaps an existing Employment Period'
  end
  
  def validate_end_date
    # allow blank
    return if end_date.blank?
    # check valid date
    # greater than start date
    # check does not overlap
    # check range doesn't overlap
  end
end
