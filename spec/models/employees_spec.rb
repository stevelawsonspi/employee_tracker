require 'rails_helper'

describe Employee, type: :model do
  subject { create(:employee) }

  describe 'Validations' do
    it { should belong_to(:business) }
    it { should validate_presence_of(:first_name) }
    it { should validate_presence_of(:last_name) }

    it "likes valid data" do
      expect(subject.valid?).to be true
    end

    # immitating "should" tests, just because :)

    it "gives error if not linked to business" do
      subject.business = nil
      expect(subject.valid?).to be false
      expect(subject.errors.full_messages).to eq ["Business must exist"]
    end

    it "gives error if first name not present" do
      subject.first_name = nil
      expect(subject.valid?).to be false
      expect(subject.errors.full_messages).to eq ["First name can't be blank"]
    end

    it "gives error if last name not present" do
      subject.last_name = nil
      expect(subject.valid?).to be false
      expect(subject.errors.full_messages).to eq ["Last name can't be blank"]
    end
  end
end