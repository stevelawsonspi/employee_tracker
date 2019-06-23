FactoryBot.define do
  factory :department do
    business { create(:business) }
    name { 'front' }
  end
end
