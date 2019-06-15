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

### Employee (Aidan)

id
business_id
first_name
last_name
full_name()

rails g model employee business:references first_name last_name 

### EmploymentTerm (Aidan)
id
employee_id
start_date
end_date
department_id
position
salary

rails g model employmentperiod employee:references department:references start_date:date end_date:date position salary

### Department (Aidan)

id
business_id
name

rails g model department business:references name

### BusinessAddress (Aidan)
id
business_id
unit
street
suburb
state
post_code

primary?
mailing_address?

rails generate model businessaddress business:references unit street suburb state post_code


### EmployeeAddress (Aidan)
id
employee_id
unit
street
suburb
state
post_code

primary
mailing_address

rails g model employeeaddress employee:references unit street suburb state post_code primary:boolean mailing_address:boolean 

### Phone (Aidan polymorphic)
id
phoneable
number
mobile?
primary?

### Email. (Steve polymorphic)
id
emailable
email
primary?

rails g model Email email:string primary:boolean emailable:references{polymorphic}


