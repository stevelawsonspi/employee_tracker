class Business < ApplicationRecord
  belongs_to :user
  has_many   :employees
  has_many   :emails, as: :emailable
end
