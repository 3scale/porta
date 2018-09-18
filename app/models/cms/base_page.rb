class CMS::BasePage < CMS::Template
  self.search_type = 'page'
  self.search_origin = 'own'

  attr_accessible :layout

  belongs_to :layout, :class_name => 'CMS::Layout'
  belongs_to :section, :class_name => 'CMS::Section'

  validates :section, presence: true

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

end
