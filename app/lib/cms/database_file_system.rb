# frozen_string_literal: true

# A liquid template lookup for 3scale buyer side partial rendering.
# That is, whenever you use the `{% include 'menu' %}`.
#
class CMS::DatabaseFileSystem < Liquid::BlankFileSystem
  EMPTY_STRING = ''

  attr_reader :provider, :history, :draft

  def initialize(provider, lookup_context, options = {})
    @provider = provider
    @lookup_context = lookup_context
    @draft = options.fetch(:draft, false)
    @history = []
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
    def initialize(lookup_context, options = {})
      super(lookup_context, options)
      @details = { formats: [:html], handlers: [:liquid] }
    end

    def find_template(path, locals = [])
      super(path, locals)
    end
  end

  def record(template)
    @history << template if template
    template
  end

end
