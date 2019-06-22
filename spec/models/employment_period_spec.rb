require 'rails_helper'

describe EmploymentPeriod, type: :model do
  describe 'Validations' do
    it { should validate_presence_of(:start_date) }
    it { should validate_presence_of(:position) }
    it { should validate_presence_of(:salary) }
    it { should validate_numericality_of(:salary).is_greater_than(0) }
    
    
  end
end