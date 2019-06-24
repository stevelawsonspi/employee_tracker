class EmploymentPeriod < ApplicationRecord
  belongs_to :employee
  belongs_to :department

  validates_date :start_date
  validates_date :end_date, allow_nil: true
  validates :position, presence: true
  validates :salary,   presence: true, numericality: { greater_than: 0, only_integer: true }
  validate  :check_start_date_overlap
  validate  :end_date_greater_than_start_date
  validate  :check_date_range_overlap

  private

  def check_start_date_overlap    
    existing_employment_periods.each do |employment_period|
      if employment_period.id != id
        if start_date >= employment_period.start_date && start_date <= employment_period.end_date
          errors.add(:start_date, "is within another employment period (#{employment_period.position})")
          return
        end
      end
    end
  end

  def existing_employment_periods
    @existing_employment_periods ||= EmploymentPeriod.where(employee_id: employee_id)
  end

  def end_date_greater_than_start_date
    return if end_date.blank?
    return if errors.include?(:end_date) # don't do more checking if end_date already has an error

    unless end_date >= start_date
      errors.add(:end_date, 'must be >= start date')
      return
    end
  end

  def check_date_range_overlap
    return if end_date.blank?
    return if errors.include?(:end_date) || errors.include?(:start_date) # don't do more checking if a date already has an error

    existing_employment_periods.each do |employment_period|
      if employment_period.id != id
        if ((employment_period.start_date >= start_date && employment_period.start_date <= end_date)  ||
            (employment_period.end_date   >= start_date && employment_period.end_date   <= end_date)) ||
           ((start_date >= employment_period.start_date && start_date <= employment_period.end_date)  ||
            (end_date   >= employment_period.start_date && end_date   <= employment_period.end_date))
          errors.add(:start_date, "conflicts with another employment period (#{employment_period.position})")
          errors.add(:end_date,   "conflicts with another employment period (#{employment_period.position})")
          return
        end
      end
    end
  end
end
