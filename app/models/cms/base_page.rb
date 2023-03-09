class CMS::BasePage < CMS::Template
  self.search_type = 'page'
  self.search_origin = 'own'

  belongs_to :layout, :class_name => 'CMS::Layout'
  belongs_to :section, :class_name => 'CMS::Section'

  validates :section, presence: true
  validate :section_same_provider

  def layout_name
    layout.try!(:system_name)
  end

  def parent_sections
    sections = []
    section = self.section
    while not section.root?
      sections << section
      section = section.parent
    end
    sections.reverse
  end

  protected

  def section_same_provider
    return if section&.provider == provider

    errors.add(:section_id, "must belong to the same provider")
  end
end
