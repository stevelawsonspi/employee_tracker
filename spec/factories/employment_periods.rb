FactoryBot.define do
  factory :employment_period do
    department { Department.first || association(:department) }
    employee   { Employee.first   || association(:employee) }
    start_date { Date.new(2019, 01, 15) }
    end_date   { nil }
    position   { FFaker::Job.title}
    salary     { 65_000 }
  end
end