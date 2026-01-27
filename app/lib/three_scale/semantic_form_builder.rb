module ThreeScale
  class SemanticFormBuilder < ::Formtastic::FormBuilder
    include ThreeScale::BotProtection::Form
    include ApplicationHelper
    include ActionView::Helpers::TagHelper

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

    def error_messages
      error_messages_for(@object_name, object: @object)
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

    def recaptcha_action
      controller.controller_path
    end

    private

    # :reek:DuplicateMethodCall, :reek:FeatureEnvy, :reek:TooManyStatements
    def error_messages_for(*params) # rubocop:disable Metrics/AbcSize, Metrics/CyclomaticComplexity, Metrics/MethodLength, Metrics/PerceivedComplexity
      ignore_me = ['Account is invalid', 'Bought cinstances is invalid']
      options = params.extract_options!.symbolize_keys

      objects = if (object = options.delete(:object))
                  [object].flatten
                else
                  params.filter_map {|object_name| instance_variable_get("@#{object_name}") }
                end

      count  = objects.inject(0) {|sum, object| sum + object.errors.count }
      if count.zero?
        ''
      else
        html = {}
        %i[id class].each do |key|
          if options.include?(key)
            value = options[key]
            html[key] = value if value.present?
          else
            html[key] = 'errorExplanation'
          end
        end
        options[:object_name] ||= params.first

        I18n.with_options :locale => options[:locale], scope: %i[activerecord errors template] do |locale|
          header_message = if options.include?(:header_message)
                             options[:header_message]
                           else
                             object_name = options[:object_name].to_s.tr('_', ' ')
                             object_name = I18n.t(object_name, default: object_name, scope: %i[activerecord models], count: 1)
                             locale.t :header, count: count, model: object_name
                           end
          message = options.include?(:message) ? options[:message] : locale.t(:body)
          error_messages = collect_error_messages(objects, ignore_me).join

          # rubocop:disable Rails/OutputSafety
          contents = ''
          contents << content_tag(options[:header_tag] || :h2, header_message.html_safe) if header_message.present?
          contents << content_tag(:p, message.html_safe) if message.present?
          contents << content_tag(:ul, error_messages.html_safe)
          content_tag(:div, contents.html_safe, html)
          # rubocop:enable Rails/OutputSafety
        end
      end
    end

    def collect_error_messages(objects, ignore_list)
      all_messages = objects.flat_map { |object| object.errors.full_messages }
      filtered_messages = all_messages.reject { |msg| ignore_list.include?(msg) }
      filtered_messages.map { |msg| content_tag(:li, msg) }
    end
  end
end
