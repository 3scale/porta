module ThreeScale
  class SemanticFormBuilder < ::Formtastic::FormBuilder
    include ThreeScale::SpamProtection::Integration::FormBuilder

    # Allow specify how to display errors for the input
    #
    # Ex:
    #   f.input :foo, inline_errors: :list
    #   f.input :bar, inline_errors: :sentence
    def inline_errors_for(method, options = {})
      original_inline_errors = inline_errors
      @options_inline_erros = options[:inline_errors]
      super
    ensure
      @options_inline_erros = original_inline_errors
    end

    def inline_errors
      @options_inline_erros || super
    end

    def text_field_with_errors( method, opts = {})
      errors =  @object.errors[method]
      if errors.present?
        opts = opts.merge(:class => 'error', 'data-errors' => errors, :title => errors)
      end

      text_field(method, opts)
    end

    # Get a column object for a specified attribute method - if possible.
    #
    def column_for(method) #:nodoc:
      # our old formtastic expects nil as in Rails 4, not a null object
      # https://github.com/rails/rails/pull/15878
      column = super
      ActiveRecord::ConnectionAdapters::NullColumn === column ? nil : column
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

    # Renders select for APPLICATION plans or SERVICE plans grouped by service.
    #
    #  form.input :plan, :as => :plan_selector, :collection => available_plans
    #
    # Options:
    #
    #   :default_plan - plan that is preselected when @object has no plan yet
    #
    # TODO: tests this selector
    #
    def plan_selector_input(method, options)
      options.reverse_merge! :group_association => :service, :group_label_method => :name, :group_by => :service
      html_options = options.delete(:input_html) || {}
      options = set_include_blank(options)

      input_name = generate_association_input_name(method)
      collection = find_raw_collection_for_column(method, options)
      selected = options[:selected] || @object.try!(method) || options[:default_plan]

      grouped_collection = {}
      #groups = collection.map &options[:group_by]
      group_association = options[:group_association] # || detect_group_association(method, options[:group_by]) # formtastic way

      group_label_method = options[:group_label_method] # || detect_label_method(groups) # formtastic way

      grouped_collection = collection.group_by { |item| item.send group_association }

      label, value = detect_label_and_value_method!(collection, options)

      select_options = grouped_collection.map do |group, collection|
        template.content_tag :optgroup, :label => group.send(group_label_method) do
          collection.map do |item|
            attrs = { :value => send_or_call(value, item) }
            attrs[:selected] = true if item == selected
            template.content_tag :option, send_or_call(label, item), attrs
          end.join.html_safe
        end
      end.join.html_safe

      self.label(method, options_for_label(options).merge(:input_name => input_name)) <<
        select(input_name, select_options, strip_formtastic_options(options), html_options)
    end

    def slider_input(method, options)
      html_options = options.delete(:input_html) || {}
      field_id = generate_html_id(method, "")
      html_options[:id] ||= field_id

      label_options = options_for_label(options)
      label_options[:for] ||= html_options[:id]

      value = options[:value] || @object.send(method)
      link_options = options.delete(:link_options) || {}
      link_options.reverse_merge!(:remote => true, :method => (value ? :delete : :post ), :'data-value' => value)

      url = options[:url] || '#'

      input = template.content_tag :ul, :class => 'slider' do
        if value
          template.content_tag(:li, '||') +
            template.content_tag(:li, 'ON', :class => "selected")
        else
          template.content_tag(:li, 'OFF', :class => "selected") +
            template.content_tag(:li, '||')
        end
      end

      label(method, label_options) + template.link_to(input, url, link_options)
    end

    def commit_button(label = nil, opts = {})
      button_html = (opts[:button_html] ||= {})
      pf4_button_classes = 'pf-c-button pf-m-primary '

      if button_html.key?(:class)
        button_html[:class].prepend(pf4_button_classes)
      else
        button_html[:class] = pf4_button_classes
      end

      label ||= 'Save' unless @object.respond_to?(:new_record?) && @object.new_record?

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

    # TODO: remove this? find_option was deprecated in formtastic 2.2.0.rc
    # As #find_collection_for_column but returns the collection without mapping the label and value
    #
    def find_raw_collection_for_column(column, options) #:nodoc:
      collection = if options[:collection]
                     options.delete(:collection)
                   elsif reflection = reflection_for(column)
                     options[:find_options] ||= {}
                     if conditions = reflection.options[:conditions]
                       if reflection.klass.respond_to?(:merge_conditions)
                         options[:find_options][:conditions] = reflection.klass.merge_conditions(conditions, options[:find_options][:conditions])
                         reflection.klass.all.where(options[:find_options])
                       else
                         reflection.klass.where(conditions).where(options[:find_options][:conditions])
                       end
                     else
                       reflection.klass.all.where(options[:find_options])
                     end
                   else
                     create_boolean_collection(options)
      end

      collection = collection.to_a if collection.is_a?(Hash)

      collection
    end
  end
end
