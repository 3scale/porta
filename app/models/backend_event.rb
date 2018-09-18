class BackendEvent < ApplicationRecord

  self.primary_key = :id

  serialize :data

  attr_accessible :id, :data

  validates :id, presence: true
  validates :data, length: { maximum: 65535 }
end
