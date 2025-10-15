# frozen_string_literal: true

class Fields::PatternflyFormBuilder < Fields::FormBuilder
  delegate :tag, to: :template

  # Overrides the one used in Fields::FormBuilder#user_defined_form
  def output_html(field, options = {})
    typed_input_field = input_field(field, options)
    builder_options = typed_input_field.builder_options

    default_type = default_input_type(field.name.to_sym, builder_options)
    type = default_type == :select ? :patternfly_select : :patternfly_input
    builder_options[:as] = type

    builder_options[:input_html] = {
      required: field.required
    }

    typed_input_field.input(self, builder_options)
  end

  def commit_button(title, opts = {})
    raise ArgumentError, 'button_html prop will be ignored, use standard html attributes' if opts.key?(:button_html)

    tag.button(title, type: :submit, class: 'pf-c-button pf-m-primary', **opts)
  end

  def delete_button(title, href, opts = {})
    opts.reverse_merge!(method: :delete, class: 'pf-c-button pf-m-danger')
    template.link_to(title, href, **opts)
  end

  def collection_select(*opts)
    super(*opts.first(4), {}, { class: 'pf-c-form-control' })
  end

  def inputs(*args, &block)
    options = args.extract_options!

    class_names = ['pf-c-form__section'] << options.delete(:class)
    tag.section(class: class_names, role: 'group', **options.slice(:id)) do
      title = if (title = args.first)
                tag.div(title, class: 'pf-c-form__section-title')
              else
                ''.html_safe
              end

      title + template.capture { yield block } # FIXME: Is this making the first render super slow?
    end
  end
end
