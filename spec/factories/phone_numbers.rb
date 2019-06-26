FactoryBot.define do
  factory :phone_number do
    phone_numberable { Employee.first   || association(:employee) }
    number  { FFaker::PhoneNumberAU.phone_number }
    mobile  { false }
    primary { false }
  end
end
