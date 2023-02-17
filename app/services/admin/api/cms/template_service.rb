# frozen_string_literal: true

class Admin::Api::CMS::TemplateService
  include Callable

  class UnknownTemplateTypeError < StandardError; end

  def initialize(current_account, params)
    @params = params
    @current_account = current_account
    @section_id = params.delete('section_id')
    @section_name = params.delete('section_name')
    @layout_id = params.delete('layout_id')
    @layout_name = params.delete('layout_name')
  end

  attr_reader :current_account, :params, :section_id, :section_name, :layout_id, :layout_name

  class Create < Admin::Api::CMS::TemplateService

    def initialize(current_account, params)
      super current_account, params
      @type = params.delete('type')&.to_sym
    end

    attr_reader :type

    def call
      collection = { page: current_account.pages,
                      partial: current_account.partials,
                      layout: current_account.layouts }[type]

      raise UnknownTemplateTypeError, "Unknown template type '#{type}'" unless type && collection

      template = collection.new(params)
      attach_section_layout(template)
      template.save

      template
    end

    private

    def attach_section_layout(template)
      return unless type == :page

      template.section ||= find_section || current_account.sections.root
      template.layout ||= find_layout
    end
  end

  class Update < Admin::Api::CMS::TemplateService
    def initialize(current_account, params, template)
      super current_account, params
      @template = template
      @resource_class = template.class
    end

    attr_reader :template, :resource_class

    def call
      attach_section_layout
      template.update(params)

      template
    end

    private

    def attach_section_layout
      return unless resource_class == CMS::Page

      section = find_section
      template.section = section if section.present?
      layout = find_layout
      if layout.present?
        template.layout = layout
      elsif layout_received_empty?
        # We received the parameter, but empty. So the user explicitly want's to remove the layout
        template.layout = nil
      end
    end
  end

  def layout_received_empty?
    !!layout_id.try(:empty?) || !!layout_name.try(:empty?)
  end

  protected

  def find_section
    scope = current_account.sections

    return scope.find_by(id: section_id) if section_id.present?

    scope.find_by(system_name: section_name) if section_name.present?
  end

  def find_layout
    scope = current_account.layouts

    return scope.find_by(id: layout_id) if layout_id.present?

    scope.find_by(system_name: layout_name) if layout_name.present?
  end
end
