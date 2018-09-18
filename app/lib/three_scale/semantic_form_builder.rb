module ThreeScale
  class SemanticFormBuilder < ::Formtastic::SemanticFormBuilder
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
      @object.column_for_attribute(method) if @object.respond_to?(:column_for_attribute) && @object.try(:has_attribute?, method)
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

    def domain_input(method, options)
      basic_input_helper(:text_field, :string, method, options) <<
        template.content_tag(:strong, ".3scale.net")
    end

    # Adds input followed by currency string and displays only two
    # decimals of the value.
    #
    # FIXME: if the price has more than 2 decimals than they are cut
    # on display - clicking save then damages the data!
    #
    def price_input(method, options)
      html_options = options.delete(:input_html) || {}
      html_options = default_string_options(method, :numeric).merge(html_options)

      currency = options[:currency] || @object.try!(:currency) || Account::DEFAULT_CURRENCY
      value = options[:value] || template.format_cost(@object.send(method))

      label(method, options_for_label(options)) <<
        send(:text_field, method, html_options.merge(:value => value)) <<
        ' ' + currency.to_s
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


    def commit_button(*args)
      opts = args.extract_options!
      button_html = (opts[:button_html] ||= {})

      if html_class = button_html[:class]
        html_class += ' important-button'
      else
        button_html[:class] = 'important-button'
      end

      args << opts
      super(*args)
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
    #   <%= form.buttons do %>
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

    def check_boxes_with_hints_input(method, options)
      collection   = find_collection_for_column(method, options)
      html_options = options.delete(:input_html) || {}

      input_name      = generate_association_input_name(method)
      hidden_fields   = options.delete(:hidden_fields)
      value_as_class  = options.delete(:value_as_class)
      unchecked_value = options.delete(:unchecked_value) || ''
      hint_method     = options.delete(:hint_method)
      html_options    = { :name => "#{@object_name}[#{input_name}][]" }.merge(html_options)
      input_ids       = []

      selected_values = find_selected_values_for_column(method, options)
      disabled_option_is_present = options.key?(:disabled)
      disabled_values = [*options[:disabled]] if disabled_option_is_present

      list_item_content = collection.map do |c|
        label = c.is_a?(Array) ? c.first : c
        value = c.is_a?(Array) ? c.last : c
        hint  = hint_method.call(value) if hint_method
        input_id = generate_html_id(input_name, value.to_s.gsub(/\s/, '_').gsub(/\W/, '').downcase)
        input_ids << input_id

        html_options[:checked] = selected_values.include?(value)
        html_options[:disabled] = disabled_values.include?(value) if disabled_option_is_present
        html_options[:id] = input_id

        li_content = template.content_tag(:label,
                                          Formtastic::Util.html_safe("#{create_check_boxes(input_name, html_options, value, unchecked_value, hidden_fields)} #{escape_html_entities(label)}"),
                                          :for => input_id
                                         )

        li_content << template.content_tag(:p, hint, class: 'inline-hints') if hint.present?
        li_options = value_as_class ? { :class => [method.to_s.singularize, value.to_s.downcase].join('_') } : {}
        li_options[:class] = "#{li_options[:class]} boolean"

        template.content_tag(:li, Formtastic::Util.html_safe(li_content), li_options)
      end

      fieldset_content = create_hidden_field_for_check_boxes(input_name, value_as_class) unless hidden_fields
      fieldset_content << template.content_tag(:ol, Formtastic::Util.html_safe(list_item_content.join))
      template.content_tag(:div, fieldset_content)
    end

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
