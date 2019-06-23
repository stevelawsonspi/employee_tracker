FactoryBot.define do
  factory :employee do
    business   { create(:business) }
    first_name { FFaker::Name.first_name }
    last_name  { FFaker::Name.last_name }
  end
end
