require 'rails_helper'

describe Business, type: :model do
  describe 'Validations' do
    it { should validate_presence_of(:name) }

    it "likes valid data" do
      business = create(:business)
      expect(business.valid?).to be true
    end

    it "gives error if name not present" do
      business = create(:business)
      business.name = nil
      expect(business.valid?).to be false
      expect(business.errors.full_messages).to eq ["Name can't be blank"]
    end
  end
end