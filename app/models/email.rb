class Email < ApplicationRecord
  belongs_to :emailable, polymorphic: true
end
