FactoryBot.define do
  factory :email do
    emailable { Employee.first   || association(:employee) }
    email     { FFaker::Internet.email }
    primary   { false }
  end
end
