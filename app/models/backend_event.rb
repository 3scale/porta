class BackendEvent < ApplicationRecord

  serialize :data

  attr_accessible :id, :data

  validates :id, presence: true
  validates :data, length: { maximum: 65535 }
end
