class CMS::Permission < ApplicationRecord
  attr_accessible :group, :account

  self.table_name = :cms_permissions

  validates :name, length: { maximum: 255 }

  belongs_to :group, :class_name => 'CMS::Group', inverse_of: :permissions
  belongs_to :account, inverse_of: :permissions

end
