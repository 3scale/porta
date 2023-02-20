class CMS::Layout < CMS::Template
  self.search_type = 'layout'
  attr_accessible :draft, :title

  has_many :pages, :class_name => 'CMS::Page'
  validate :yield_content_presence, :if => :is_main_layout?

  before_destroy :avoid_destruction

  has_data_tag :layout

  def human_name
    title or I18n.t(system_name, :scope => [:cms, :layout], :default => system_name)
  end

  def content_type
    self[:content_type] || 'text/html'
  end

  def to_xml(options = {})
    xml = options[:builder] || Nokogiri::XML::Builder.new

    xml.__send__(self.class.data_tag) do |x|
      unless new_record?
        xml.id id
        xml.created_at created_at.xmlschema
        xml.updated_at updated_at.xmlschema
      end
      x.title title
      x.system_name system_name
      x.liquid_enabled liquid_enabled
      unless options[:short]
        x.draft { |node| node.cdata draft }
        x.published { |node| node.cdata published }
      end
    end

    xml.to_xml
  end

  def can_be_destroyed?
    pages.empty?
  end

  def search
    super.merge string: "#{system_name} #{title}",
                origin: is_main_layout? ? 'builtin' : 'own'
  end

  private

  def avoid_destruction
    throw :abort unless can_be_destroyed?
  end

  def set_rails_view_path
    self.rails_view_path = "layouts/#{system_name}"
  end

  def yield_content_presence
    if  draft && (not contains_content_tag?(draft))
      errors.add(:draft, :missing_content)
    end

    if published && (not contains_content_tag?(published))
      errors.add(:published, :missing_content)
    end
  end

  def contains_content_tag?(value)
    value && value =~ /\{%\s*content\s*%\}/
  end

  def is_main_layout?
    system_name == 'main_layout'
  end

  module ProviderAssociationExtension
    def default
      find_by_system_name('main_layout')
    end
  end

end
