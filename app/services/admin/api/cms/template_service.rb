# frozen_string_literal: true

class Admin::Api::CMS::TemplateService
  include Callable

  class UnknownTemplateTypeError < StandardError; end

  def initialize(current_account, params)
    @params = params
    @current_account = current_account
    @type = params.delete('type')
    @section_id = params.delete('section_id')
    @section_name = params.delete('section_name')
    @layout_id = params.delete('layout_id')
    @layout_name = params.delete('layout_name')
  end

  attr_reader :current_account, :params, :type, :section_id, :section_name, :layout_id, :layout_name

  class Create < Admin::Api::CMS::TemplateService
    def call
      collection = { page: current_account.pages,
                      partial: current_account.partials,
                      layout: current_account.layouts }[type.to_sym]

      raise UnknownTemplateTypeError, "Unknown template type '#{type}'" unless type && collection

      template = collection.new(params)
      template.section ||= find_section if template.respond_to?(:section)
      template.layout ||= find_layout if template.respond_to?(:layout)
      template.save

      template
    end
  end

  class Update < Admin::Api::CMS::TemplateService
    def initialize(template, current_account, params)
      super current_account, params
      @template = template
    end

    attr_reader :template

    def call
      if template.respond_to?(:section)
        section = find_section
        template.section = section if section.present?
      end
      if template.respond_to?(:layout)
        layout = find_layout
        template.layout = layout if layout.present?
      end
      template.update(params)

      template
    end
  end

  protected

  def find_section
    scope = current_account.sections

    return scope.find_by(id: section_id) if section_id.present?

    return scope.find_by(system_name: section_name) if section_name.present?

    scope.root
  end

  def find_layout
    scope = current_account.layouts

    return scope.find_by(id: layout_id) if layout_id.present?

    scope.find_by(system_name: layout_name) if layout_name.present?
  end
end
