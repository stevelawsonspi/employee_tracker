require 'rails_helper'

describe Department, type: :model do
  subject { build(:department) }
  
  describe 'Validations' do
    it { should belong_to(:business) }
    it { should validate_presence_of(:name) }
    it { should validate_uniqueness_of(:name) }

    it "likes valid data" do
      Department.all.each do |d|
        warn "#{d.id}, #{d.business_id}, #{d.name}"
      end
      
      subject.valid?
      warn "#{subject.errors.full_messages}"
      expect(subject.valid?).to be true
    end
  end
end
