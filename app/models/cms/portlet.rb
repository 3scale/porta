class CMS::Portlet < CMS::Partial
  self.search_type = 'portlet'

  attr_accessible :title, :portlet_type

  after_initialize :default_values
  validate :available_types
  serialize :options, Hash

  class_attribute :_attributes, :_inputs, :instance_writer => false, :instance_reader => false

  def self.attributes(*attrs)
    defined = self._attributes ||= Set.new
    inputs  = self._inputs ||= {}

    self._inputs = inputs.merge(attrs.extract_options!)

    attrs.flatten.each do |attr|
      attr = attr.to_sym
      defined << attr

      define_method(attr) { options[attr] } # reader
      alias_method "#{attr}_before_type_cast", attr
      define_method("#{attr}=") { |val| options[attr] = val } # writer
    end

    defined
  end

  def search
    super.merge string: "#{title} #{system_name} #{portlet_type}"
  end

  def self.available
    [ ExternalRssFeedPortlet, TableOfContentsPortlet, LatestForumPostsPortlet ]
  end

  class Base < CMS::Portlet
    def self.model_name
      klass = self
      name = self.superclass.model_name
      name.define_singleton_method(:human) { klass.human_name }
      name.define_singleton_method(:description) { klass.description }
      name
    end

    def self.human_name
      I18n.t(:name, :scope => [:cms, :portlet, name.underscore])
    end

    def self.description
      I18n.t(:description, :scope => [:cms, :portlet, name.underscore])
    end

    def draft
      self[:draft] || self[:published] || default_template
    end

    def human_name
      title or system_name
    end

    def liquid_enabled?
      true
    end

    def liquid_options
      {}
    end

    def cache(key, expires = 1.minute)
      Rails.cache.fetch("portlet:#{id}:#{key}", :expires_in => expires) do
        yield
      end
    end

    private

    def default_template
      self.class.respond_to?(:default_template) and self.class.default_template
    end
  end

  def inputs
    inputs = self.class._inputs
    Hash[ self.class.attributes.map{ |attr| [attr, { :as => inputs[attr] } ] } ]
  end

  def portlet_type
    options[:portlet_type]
  end

  def portlet_type= val
    options[:portlet_type] = val
  end

  def to_portlet
    klass = portlet_class or raise InvalidPortletError, "#{portlet_type.inspect} is invalid portlet type"

    other = becomes!(klass)
    other.cleanup_template_references
    other
  end

  def portlet_class
    self.class.available
        .find { |portlet| portlet.name == portlet_type }
  end

  class InvalidPortletError < StandardError; end

  private

  def default_values
    self.options ||= {}
  rescue ActiveModel::MissingAttributeError
    # this happens when portlet is not subclassed
  end

  def available_types
    unless self.class.available.include?(portlet_class)
      errors.add(:portlet_type, :invalid)
    end
  end

  protected

  def cleanup_template_references
    @errors = nil
  end

end
