class CMS::Page < CMS::BasePage

  RESERVED_FILENAMES  = %W{terms privacy refunds}
  RESERVED_EXTENSIONS = ['', '.html', '.htm']
  RESERVED_PATHS      = RESERVED_FILENAMES.flat_map{ |fn| RESERVED_EXTENSIONS.map{|ext| "#{fn}#{ext}"}}

  DEFAULT_CONTENT_TYPE = 'text/html'

  include NormalizePathAttribute
  acts_as_taggable

  attr_accessible :title, :section, :path, :content_type, :tag_list, :system_name

  belongs_to :section, class_name: 'CMS::Section', touch: true

  before_validation :strip_trailing_slashes
  verify_path_format :path

  validates :title, presence:   true
  validates :path,  presence:   true,
                    format:     { with: /\A\/.*\z/, message: :slash },
                    uniqueness: { scope: [:provider_id] },
                    exclusion:  { in: RESERVED_PATHS }

  validates_associated  :section

  before_save :mark_for_searchability
  after_initialize :set_default_values

  def self.path(chunks, format = nil)
    path = Array(chunks).compact.join('/')
    path.prepend(root_path) unless path.start_with?(root_path)

    if chunks.present? && format
      path += '.' + format
    end

    path
  end

  def self.root_path
    '/'
  end

  def default_path
  end

  def search
    super.merge(string: "#{self.title} #{self.path}")
  end

  delegate :public?, :protected?, :to => :section, :allow_nil => true

  def hidden?
    published.nil?
  end

  def visible?
    not hidden?
  end

  def accessible_by?(buyer)
    visible? && section.accessible_by?(buyer)
  end

  def is_searchable?
    case
    when ! mime_type.html?
       false

    when liquid_enabled?
      template = Liquid::Template.parse(published)
      nodelist = template.instance_variable_get("@root").instance_variable_get("@nodelist")

      nodelist.none?{ |i| i.is_a?(Liquid::Tag) and not i.is_a?(Liquid::Include) }

    else
      true

    end
  end

  # Returns parsed Mime::Type or default ('text/html')
  def mime_type
    super || Mime::Type.lookup(DEFAULT_CONTENT_TYPE)
  end

  def to_xml(options = {})
    xml = options[:builder] || Nokogiri::XML::Builder.new

    xml.page do |x|
      unless new_record?
        x.id id
        x.created_at created_at.xmlschema
        x.updated_at updated_at.xmlschema
      end

      x.title title
      x.system_name system_name
      x.path(path) if respond_to?(:path)
      x.hidden hidden?
      x.layout layout_name
      x.content_type content_type
      x.handler handler
      x.liquid_enabled liquid_enabled

      unless options[:short]
        x.draft draft
        x.published published
      end
    end

    xml.to_xml
  end

  private

  def set_default_values
    unless persisted?
      self.content_type ||= DEFAULT_CONTENT_TYPE
    end
  end

  def strip_trailing_slashes
    return unless self.path
    self.path.gsub!(/^(.*[^\/])\/*$/, '\1')
    self.path.gsub!(/^\/+/,"/")
  end

  def mark_for_searchability
    self.searchable = is_searchable?

    return
  end

end
