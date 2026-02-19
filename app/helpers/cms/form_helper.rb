# frozen_string_literal: true

module CMS
  module FormHelper

    def cms_form_for(template, options = {}, &)
      options[:builder] ||= CMS::SemanticFormBuilder
      options[:url] ||= polymorphic_path([:provider, :admin, template])
      options[:as] ||= base_name(template)

      content_for :javascripts, javascript_packs_with_chunks_tag('cms_form', 'pf_spacing')

      semantic_form_for(template, options, &)
    end

    def cms_remote_form_for(template, options = {}, &block)
      cms_form_for(template, options.reverse_merge({ remote: true }), &block)
    end

    def cms_fields_for(template, options = {}, &block)
      options[:builder] ||= CMS::SemanticFormBuilder

      semantic_fields_for(base_name(template), template, options, &block)
    end

    # Returns the base name of the template, e.g. will return `cms_template` for CMS::Page, CMS::Partial etc.
    def base_name(template)
      template.class.base_class.model_name.to_s.parameterize(separator: '_').to_sym
    end
  end
end
