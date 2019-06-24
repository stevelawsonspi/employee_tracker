FactoryBot.define do
  factory :business do
    user { User.create(email: FFaker::Internet.email, password: 'password', password_confirmation: 'password') || association(:user) }
    name { FFaker::Company.name }
    abn  { '123456789'}
  end
end
