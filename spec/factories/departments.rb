FactoryBot.define do
  factory :department do
    business { Business.first || association(:business) }
    name { FFaker::Company.name } # can't find a better faker for this!
  end
end
