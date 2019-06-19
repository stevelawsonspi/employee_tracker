class Email < ApplicationRecord
  belongs_to :emailable, polymorphic: true
  
  validates :email,   format: /\A([^@\s]+)@((?:[-a-z0-9]+\.)+[a-z]{2,})\Z/i
  validates :primary, inclusion: { in: [true, false] }
end
