require 'rails_helper'

describe EmploymentPeriod, type: :model do
  subject { build(:employment_period) }

  describe 'Validations' do
    it { should validate_presence_of(:position) }
    it { should validate_numericality_of(:salary).only_integer.is_greater_than(0) }
    
    it "start date must be valid" do
      subject.start_date = nil
      expect(subject.valid?).to be false
      subject.start_date = 5
      expect(subject.valid?).to be false
      subject.start_date = Date.new(2019, 11, 17)
      expect(subject.valid?).to be true
    end
    
    it "end date must be valid (if specified)" do
      subject.end_date = nil
      expect(subject.valid?).to be true
      subject.end_date = 5
      expect(subject.valid?).to be false
      subject.end_date = Date.new(2019, 12, 18)
      expect(subject.valid?).to be true
    end
    
    context  "if specified, end date >= start date" do
      it "end date = start date" do
        subject.start_date = Date.new(2019, 12, 18)
        subject.end_date   = Date.new(2019, 12, 18)
        expect(subject.valid?).to be true
      end
      
      it "end date < start date" do
        subject.start_date = Date.new(2019, 12, 18)
        subject.end_date   = Date.new(2019, 12, 17)
        expect(subject.valid?).to be false
      end
      
      it "end date > start date" do
        subject.start_date = Date.new(2019, 12, 18)
        subject.end_date   = Date.new(2019, 12, 19)
        expect(subject.valid?).to be true
      end
    end
    
  end
end