FactoryBot.define do
  factory :user do
    email                 { FFaker::Internet.email }
    admin                 { false }
    password              { 'password' }
    password_confirmation { 'password' }
    #confirmed_at          { Time.now }
    #first_name            { FFaker::Name.first_name }
    #last_name             { FFaker::Name.last_name }
    #mobile                { '0412345678' }
  end
end
