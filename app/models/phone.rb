class Phone < ApplicationRecord
  belongs_to :phonable, polymorphic: true
end
