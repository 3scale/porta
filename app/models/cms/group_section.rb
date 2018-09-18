class CMS::GroupSection < ApplicationRecord
  self.table_name = :cms_group_sections

  attr_accessible :section, :group
  belongs_to :group, :class_name => 'CMS::Group'
  belongs_to :section, :class_name => 'CMS::Section'
  belongs_to :tenant
end
