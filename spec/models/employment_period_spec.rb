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
    
    context "if specified, end date >= start date" do
      it "end date = start date" do
        subject.attributes = { start_date: Date.new(2019, 12, 18), end_date: Date.new(2019, 12, 18) }
        expect(subject.valid?).to be true
      end
      
      it "end date < start date" do
        subject.attributes = { start_date: Date.new(2019, 12, 18), end_date: Date.new(2019, 12, 17) }
        expect(subject.valid?).to be false
        expect(subject.errors.full_messages).to eq ['End date must be >= start date']
      end
      
      it "end date > start date" do
        subject.attributes = { start_date: Date.new(2019, 12, 18), end_date: Date.new(2019, 12, 19) }
        expect(subject.valid?).to be true
      end
    end

    context  "dates overlapping other employment periods (for same employee)" do
      before :each do
        create(:employment_period, start_date: Date.new(2019, 01, 10), end_date: Date.new(2019, 01, 20))
        create(:employment_period, start_date: Date.new(2019, 02, 10), end_date: Date.new(2019, 02, 20))
      end

      it "rejects if start date is within another employment period" do
        subject.start_date = Date.new(2019, 1, 18)
        expect(subject.valid?).to be false
        expect(subject.errors.full_messages[0]).to match(/Start date is within another employment period/)
      end
      
      it "accepts a start date outside of other employment periods" do        
        subject.start_date = Date.new(2019, 1,  8)
        expect(subject.valid?).to be true
  
        subject.start_date = Date.new(2019, 1, 25)
        expect(subject.valid?).to be true

        subject.start_date = Date.new(2019, 2, 28)
        expect(subject.valid?).to be true
      end

      it "rejects if start & end dates overlap another employment period" do
        subject.attributes = { start_date: Date.new(2019, 1,  1), end_date: Date.new(2019, 2, 18) }
        expect(subject.valid?).to be false
        expect(subject.errors.full_messages[0]).to match(/Start date conflicts with another employment period/)
        expect(subject.errors.full_messages[1]).to match(/End date conflicts with another employment period/)

        subject.attributes = { start_date: Date.new(2019, 1,  5), end_date: Date.new(2019, 1, 10) }
        expect(subject.valid?).to be false
        expect(subject.errors.full_messages[0]).to match(/Start date conflicts with another employment period/)
        expect(subject.errors.full_messages[1]).to match(/End date conflicts with another employment period/)

        subject.attributes = { start_date: Date.new(2019, 2, 20), end_date: Date.new(2019, 2, 21) }
        expect(subject.valid?).to be false
        expect(subject.errors.full_messages[0]).to match(/Start date is within another employment period/)
      end
      
      it "accepts start & end dates outside of other employment periods" do
        subject.attributes = { start_date: Date.new(2019, 1,  8), end_date: Date.new(2019, 1,  9) }     
        expect(subject.valid?).to be true

        subject.attributes = { start_date: Date.new(2019, 1, 25), end_date: Date.new(2019, 1, 29) }     
        expect(subject.valid?).to be true

        subject.attributes = { start_date: Date.new(2019, 2, 28), end_date: Date.new(2019, 3,  9) }     
        expect(subject.valid?).to be true
      end
    end
  end
end











