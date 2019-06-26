require 'rails_helper'

describe PhoneNumber, type: :model do
  subject { build(:phone_number) }
  
  describe 'Validations' do
    it { should belong_to(:phone_numberable) }
    it { should validate_inclusion_of(:mobile).in_array([true, false]) }
    it { should validate_inclusion_of(:primary).in_array([true, false]) }

    it "likes valid data" do
      expect(subject.valid?).to be true
    end
    
  end
end
