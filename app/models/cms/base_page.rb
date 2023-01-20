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

  def hidden?
    published.nil?
  end

  def to_xml(options = {})
    xml = options[:builder] || Nokogiri::XML::Builder.new

    xml.__send__(options.fetch(:root, :page)) do |x|
      unless new_record?
        x.id id
        x.created_at created_at.xmlschema
        x.updated_at updated_at.xmlschema
      end

      x.title title
      section.to_xml(builder: x, root: 'section', short: true) unless options[:short]
      x.path(path) if respond_to?(:path)
      if options[:short]
        x.layout_name layout_name
      else
        layout&.to_xml(builder: x, short: true) || x.layout
      end
      x.system_name system_name
      x.content_type content_type
      x.liquid_enabled !liquid_enabled.nil?
      x.handler handler
      x.hidden hidden?

      unless options[:short]
        x.draft { |node| node.cdata draft }
        x.published { |node| node.cdata published }
      end
    end

    xml.to_xml
  end
end
