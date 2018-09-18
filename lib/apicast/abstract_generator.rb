# This is a base for other generators. It allows us to use Rails facilities to render views.
# That way we can abstract pieces of nginx configs into partials and helpers to reuse them.
# Also we can use it to require files from other files instead of pre populating everything.
# That way we can actually try to fix indentation problems with generated configs for example.
#
# The sublcasses are expected to:
# * set formats (can be on class level)
# * set view paths (using +ActionView::ViewPaths::ClassMethods+)
# * call abstract! if there is no need for rendering
#
# Then the subclasses can override method +assigns+ to assign variables into the view.
# Where they'll be available as instance variables.
#
# This is built on top of +ActionView::ViewPaths+ and +ActionView::Base+.
#

class Apicast::AbstractGenerator
  include AbstractController::Rendering
  class_attribute :formats
  self.formats = [].freeze

  # To satisfy the contract of AbstractController the parent class has to respond to .abstract?
  class << self
    attr_reader :abstract
    alias abstract? abstract

    def abstract!
      @abstract = true
    end

    def inherited(klass) # :nodoc:
      # Define the abstract ivar on subclasses so that we don't get
      # uninitialized ivar warnings
      unless klass.instance_variable_defined?(:@abstract)
        klass.instance_variable_set(:@abstract, false)
      end
      super
    end

    def controller_path
      __dir__
    end
  end

  delegate :controller_path, to: :class

  abstract!

  # @return [Hash] To be assigned as instance variables when rendering.
  def assigns
    {}
  end

  # @raise [NotImplementedError] Should be overridden in subclasses to emit a rendered template.
  def emit
    raise NotImplementedError, "This #{self.class} cannot respond to: #{__method__}"
  end

  delegate :render, to: :view

  protected

  def view
    ActionView::Base.new(lookup_context, assigns, nil, formats)
  end

  def details_for_lookup
    { formats: formats }
  end
end
