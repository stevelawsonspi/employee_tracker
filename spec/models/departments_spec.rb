require 'rails_helper'

describe Department, type: :model do
  subject { build(:department) }
  
  describe 'Validations' do
    it { should belong_to(:business) }
    it { should validate_presence_of(:name) }
    it { should validate_uniqueness_of(:name) }

    it "likes valid data" dos
      expect(subject.valid?).to be true
    end
  end
end
