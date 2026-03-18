class BackendEvent < ApplicationRecord

  serialize :data

  validates :id, presence: true
  validates :data, length: { maximum: 65535 }
end
