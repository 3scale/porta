module ThreeScale
  class SemanticFormBuilder < ::Formtastic::FormBuilder
    include ThreeScale::BotProtection::Form

    delegate :tag, :site_account, :controller, to: :template

    # Allow specify how to display errors for the input
    #
    # Ex:
    #   f.input :foo, inline_errors: :list
    #   f.input :bar, inline_errors: :sentence
    def inline_errors_for(method, options = {})
      original_inline_errors = inline_errors
      @options_inline_errors = options[:inline_errors]
      super
    ensure
      @options_inline_errors = original_inline_errors
    end

    def inline_errors
      @options_inline_errors || super
    end

    def text_field_with_errors( method, opts = {})
      errors =  @object.errors[method]
      if errors.present?
        opts = opts.merge(:class => 'error', 'data-errors' => errors, :title => errors)
      end

      text_field(method, opts)
    end

    def toggled_inputs(title, opts = {}, &block)
      # to_str because title can be SafeBuffer and parameterize blows on it
      cookie_name = opts.delete(:cookie_name) || "#{title.to_str.parameterize}-toggle-cookie"
      cookie_path = opts.delete(:cookie_path) || '/'
      legend = opts.delete(:legend) || title.camelize

      opts = opts.reverse_merge('class' => 'inputs',
                                'data-behavior' => 'toggle-inputs',
                                'data-cookie-path' => cookie_path,
                                'data-cookie-name' => cookie_name)

      t = template
      legend_with_icon = t.icon('').html_safe + ' '.html_safe + legend

      t.content_tag :fieldset, opts do
        leg = t.content_tag(:legend, t.content_tag(:span, legend_with_icon))
        ol = t.content_tag(:ol, t.capture(&block))
        leg + ol
      end
    end

    def commit_button(label = nil, opts = {})
      button_html = (opts[:button_html] ||= {})
      pf4_button_classes = 'pf-c-button pf-m-primary '

      if button_html.key?(:class)
        button_html[:class].prepend(pf4_button_classes)
      else
        button_html[:class] = pf4_button_classes
      end

      action :submit, label: label, as: :button, **opts
    end

    def button(label, *args)
      options = args.extract_options!
      button_html = options.delete(:button_html) || {}

      button_html.reverse_merge! :type => :submit, :value => true

      template.content_tag :li, template.content_tag(:button, options[:label] || label, button_html)
    end


    # Adds cancel link to a form.
    #
    # Use this inside a buttons block:
    #
    #   <%= form.actions do %>
    #     <%= form.commit_button %>
    #     <%= form.cancel_link(some_url) %>
    #   <% end %>
    #
    def cancel_link(path_or_label, path = nil)
      label = path ? path_or_label : 'Cancel'
      path ||= path_or_label

      template.content_tag(:li, template.link_to(label, path), :class => 'link')
    end

    def system_name
      if @object.new_record?
        input :system_name, :hint => "Only ASCII letters, numbers, dashes and underscores are allowed."
      else
        input :system_name, :input_html => { :disabled => true }
      end
    end

    def actions(*args, &block)
      return super unless args.empty?

      tag.div(class: 'pf-c-form__group pf-m-action') do
        tag.div(class: 'pf-c-form__actions', &block)
      end
    end
  end
end
