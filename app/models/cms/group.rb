class CMS::Group < ApplicationRecord
  attr_accessible :provider, :sections, :name, :accounts

  # This is BuyerGroup
  self.table_name = :cms_groups

  belongs_to :tenant
  belongs_to :provider, :class_name => "Account"

  validates :name, :provider, presence: true, length: { maximum: 255 }
  validates :name, uniqueness: { scope: [:provider_id] }

  has_many :group_sections, :class_name => 'CMS::GroupSection'
  has_many :sections, :class_name => 'CMS::Section', :through => :group_sections

  has_many :permissions, :class_name => 'CMS::Permission'
  has_many :accounts, :through => :permissions

  def label
    section_titles = sections.map(&:title)
    label = name.dup

    if section_titles.present?
      label << " (#{section_titles.to_sentence})"
    end

    ERB::Util.html_escape(label)
  end
end
