require 'rails_helper'

describe Email, type: :model do
  subject { build(:email) }

  describe 'Validations' do
    it { should belong_to(:emailable) }
    it { should validate_inclusion_of(:primary).in_array([true, false]) }

    it "likes valid data" do
      expect(subject.valid?).to be true
    end
    
  end
end
