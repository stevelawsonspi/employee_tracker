class PhoneNumber < ApplicationRecord
  belongs_to :phone_numberable, polymorphic: true
end
