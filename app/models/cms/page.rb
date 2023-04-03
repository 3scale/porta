class CMS::Page < CMS::BasePage

  RESERVED_FILENAMES  = %W{terms privacy refunds}
  RESERVED_EXTENSIONS = ['', '.html', '.htm']
  RESERVED_PATHS      = RESERVED_FILENAMES.flat_map{ |fn| RESERVED_EXTENSIONS.map{|ext| "#{fn}#{ext}"}}

  DEFAULT_CONTENT_TYPE = 'text/html'

  include NormalizePathAttribute
  acts_as_taggable
  include Tagging

  include Searchable

  belongs_to :section, class_name: 'CMS::Section', touch: true

  before_validation :set_system_name , on: %i[create update]
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

  private

  def set_default_values
    unless persisted?
      self.content_type ||= DEFAULT_CONTENT_TYPE
    end
  end

  def set_system_name
    self.system_name = title.parameterize if title.present? && system_name.blank?
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
