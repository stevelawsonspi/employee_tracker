class PhoneNumber < ApplicationRecord
  belongs_to :phone_numberable, polymorphic: true

  validates :number,  presence:  true
  validates :primary, inclusion: { in: [true, false] }
  validates :mobile,  inclusion: { in: [true, false] }
end
