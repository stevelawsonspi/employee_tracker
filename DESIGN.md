# Employee Tracker Design


## Features

Store
- employee name, address, phone, email
- employment start and stop dates
- position
- department
- salary
- employer name, address, phone, email

## Models

### User
id
email

### Business
id
user_id
name
abn

rails generate model Business user:references name:string abn:string

### Employee
id
business_id
first_name
last_name

### EmploymentTerm
id
employee_id
start_date
end_date
department_id
position
salary

### Department
id
name

### BusinessAddress
id
business_id
unit
street
suburb
state
post_code
primary?
mailing_address?

### EmployeeAddress
id
employee_id
unit
street
suburb
state
post_code
primary?
mailing_address?

### Phone
id
phoneable
number
mobile?
primary?

### Email
id
emailable
email
primary?