class CMS::Layout < CMS::Template
  self.search_type = 'layout'
  attr_accessible :system_name, :draft, :title

  self.mass_assignment_sanitizer = :strict

  has_many :pages, :class_name => 'CMS::Page'
  validates :system_name, presence: true
  validate :yield_content_presence, :if => :is_main_layout?

  before_destroy :can_be_destroyed?

  def human_name
    title or I18n.t(system_name, :scope => [:cms, :layout], :default => system_name)
  end

  def content_type
    self[:content_type] || 'text/html'
  end

  def to_xml(options = {})
    xml = options[:builder] || Nokogiri::XML::Builder.new

    xml.layout do |x|
      unless new_record?
        xml.id id
        xml.created_at created_at.xmlschema
        xml.updated_at updated_at.xmlschema
      end

      x.system_name system_name
      x.content_type content_type
      x.handler handler
      x.liquid_enabled liquid_enabled
      x.title title

      unless options[:short]
        x.draft draft
        x.published published
      end
    end

    xml.to_xml
  end

  def can_be_destroyed?
    throw :abort unless pages.empty?
  end

  def search
    super.merge string: "#{system_name} #{title}",
                origin: is_main_layout? ? 'builtin' : 'own'
  end

  private

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
