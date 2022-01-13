# frozen_string_literal: true

# A liquid template lookup for 3scale buyer side partial rendering.
# That is, whenever you use the `{% include 'menu' %}`.
#
class CMS::DatabaseFileSystem < Liquid::BlankFileSystem
  EMPTY_STRING = ''

  attr_reader :provider, :history, :draft

  def initialize(provider, lookup_context, draft) # rubocop:disable Lint/MissingSuper no parent constructor
    @provider = provider
    @lookup_context = lookup_context
    @history = []
    @draft = draft
  end

  def read_template_file(template_path)
    raise ArgumentError, "Cannot find partial without name." unless template_path

    partial = find_partial(template_path)
    partial ? partial.content(draft) : partial_from_filesystem(template_path)
  end

  def find_portlet(path)
    record @provider.portlets.find_by(system_name: path)
  end

  def find_partial(path)
    record @provider.all_partials.find_by(system_name: path)
  end

  def partial_from_filesystem(path)
    renderer = LiquidPartialRenderer.new(@lookup_context)
    template = renderer.find_template(path)
    template.source
  rescue ActionView::MissingTemplate
    Rails.logger.error("MissingTemplate: #{path}")
    EMPTY_STRING
  end

  private

  class LiquidPartialRenderer < ActionView::PartialRenderer
    def initialize(*)
      super
      @details = { formats: [:html], handlers: [:liquid] }
    end

    def find_template(path)
      super(path, [])
    end
  end

  def record(template)
    @history << template if template
    template
  end

end
