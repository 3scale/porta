# frozen_string_literal: true

class Admin::Api::CMS::TemplateService
  include Callable

  class TemplateServiceError < StandardError; end
  class UnknownTemplateTypeError < TemplateServiceError; end
  class UnknownSectionError < TemplateServiceError; end
  class UnknownLayoutError < TemplateServiceError; end



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
      attach_section(template)
      attach_layout(template)
      template.save

      template
    end

    private

    def attach_section(template)
      return unless type == :page

      section = find_section
      if section.present?
        template.section = section
      elsif section_received?
        raise UnknownSectionError, "Unknown section: '#{section_id || section_name}'"
      else
        template.section = current_account.sections.root
      end
    end

    def attach_layout(template)
      return unless type == :page

      layout = find_layout
      if layout.present?
        template.layout = layout
      elsif layout_received?
        raise UnknownLayoutError, "Unknown layout: '#{layout_id || layout_name}'"
      end
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
      attach_section
      attach_layout
      template.update(params)

      template
    end

    private

    def attach_section
      return unless resource_class == CMS::Page

      section = find_section
      if section.present?
        template.section = section
      elsif section_received?
        raise UnknownSectionError, "Unknown section: '#{section_id || section_name}'"
      end
    end

    def attach_layout
      return unless resource_class == CMS::Page

      layout = find_layout
      if layout.present?
        template.layout = layout
      elsif layout_received_empty?
        # We received the parameter, but empty. So the user explicitly wants to remove the layout
        template.layout = nil
      elsif layout_received?
        raise UnknownLayoutError, "Unknown layout: '#{layout_id || layout_name}'"
      end
    end
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

  def section_received?
    !section_id.nil? || !section_name.nil?
  end

  def layout_received?
    !layout_id.nil? || !layout_name.nil?
  end

  def layout_received_empty?
    layout_received? && (layout_id.try(:empty?) || !!layout_name.try(:empty?))
  end
end
