class CMS::Redirect < ApplicationRecord
  self.table_name = :cms_redirects

  belongs_to :provider, :class_name => 'Account'

  validates :source, :target, :provider, presence: true
  validates :source, uniqueness: { scope: [:provider_id] }, length: { maximum: 255 }
  validates :target, length: { maximum: 255 }

  attr_accessible :source, :target

  include NormalizePathAttribute
  verify_path_format :source, :target
end
