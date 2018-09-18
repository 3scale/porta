module CMS
  module FormHelper

    def cms_form_for(template, options = {}, &block)
      base_name = template.class.base_class.model_name.to_s.parameterize('_').to_sym

      options[:builder] ||= CMS::SemanticFormBuilder
      options[:url] ||= polymorphic_path([:provider, :admin, template])
      options[:as] ||= base_name

      semantic_form_for(template, options, &block)
    end

    def cms_remote_form_for(template, options = {}, &block)
      cms_form_for(template, options.reverse_merge(:html => { :"data-remote" => 'true' }), &block)
    end

    def cms_fields_for(template, options = {}, &block)
      base_name = template.class.base_class.model_name.to_s.parameterize('_').to_sym

      options[:builder] ||= CMS::SemanticFormBuilder
      options[:as] ||= base_name

      monkey_patched_semantic_fields_for(template, options, &block)
    end

    private

    # Method `fields_for` changed the number of parameters in Rails3 and therefor is not
    # compatible with our version of Formtastic. Remove this when we upgrade
    # Formtastic.
    #
    def monkey_patched_semantic_fields_for(record_or_name_or_array, *args, &proc)
      options = args.extract_options!

      # options[:builder] ||= @@builder
      options[:html] ||= {}

      options[:builder].custom_namespace = options[:namespace].to_s

      singularizer = defined?(ActiveModel::Naming.singular) ? ActiveModel::Naming.method(:singular) : ActionController::RecordIdentifier.method(:singular_class_name)

      class_names = options[:html][:class] ? options[:html][:class].split(" ") : []
      class_names << 'formtastic'
      class_names << case record_or_name_or_array
                     when String, Symbol then record_or_name_or_array.to_s                                  # :post => "post"
                     when Array then options[:as] || singularizer.call(record_or_name_or_array.last.class)  # [@post, @comment] # => "comment"
                     else options[:as] || singularizer.call(record_or_name_or_array.class)                  # @post => "post"
                     end
      options[:html][:class] = class_names.join(" ")

      with_custom_field_error_proc do
        # HACK: - nil added to the list
        fields_for(record_or_name_or_array, nil, *(args << options), &proc)
      end
    end

  end
end
