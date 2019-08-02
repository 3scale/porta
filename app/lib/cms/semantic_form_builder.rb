module CMS
  class SemanticFormBuilder < ::ThreeScale::SemanticFormBuilder

    def input(method, options = {})
      if options.delete(:autofocus)
        super( method, :input_html => { :autofocus => 'autofocus' })
      else
        super( method, options)
      end
    end

    def section_input(method, options = {})
      sections = template.current_account.sections

      options.reverse_merge! :collection => template.cms_section_select(sections.root),
                             :include_blank => false

      select_input(method, options).tap do |html|
        if options[:paths]
          paths = Hash[sections.partial_paths]
          html << template.javascript_tag("$.partial_paths(#{paths.to_json});")
        end
      end
    end

    def handler_input(method, options = {})
      handlers = CMS::Handler.available.map{ |h| [h.to_s.humanize, h] }
      options.reverse_merge! :collection => handlers,
                             :include_blank => true
      select_input(method, options)
    end

    def select_input(method, options = {})
      if @object.send(method).nil? && @object.new_record?
        options[:selected] ||= options.delete(:default).try!(:id)
      end

      super
    end

    def codemirror_input(method, options = {})
      html_options = options.delete(:input_html) || {}
      if value = options.delete(:value)
        html_options[:value] = value
      end

      html_options[:class] = 'mousetrap'

      codemirror_options = options.delete(:options) || {}

      label(method, options_for_label(options)) <<
        text_area(method, html_options) <<
        template.render('/provider/admin/cms/codemirror',
                        :html_id => "cms_template_#{method}",
                        :options => codemirror_options,
                        :content_type => self.object.content_type,
                        :liquid_enabled => self.object.liquid_enabled)
    end


    def delete_button(*args)
      icon = template.content_tag(:i, '', :class => 'fa fa-trash')
      button = template.link_to(icon << ' Delete', template.url_for(:action => :destroy),
                       :'data-method' => :delete,
                       :class => 'delete dangerous-button',
                       :title => "Delete this #{@object.class.model_name.human.downcase}",
                       :'data-confirm' => "Do you really want to delete this #{@object.class.model_name.human.downcase}?")

      template.content_tag(:li, button, :id => 'cms-template-delete-button')
    end

    def disabled_delete_button(*args)
      icon = template.content_tag(:i, '', :class => 'fa fa-trash')
      button = template.link_to(icon << ' Delete', '',
                       :class => 'delete less-important-button disabled-button',
                       :title => "You can not delete this #{@object.class.model_name.human.downcase} because it's being used")

      template.content_tag(:li, button, :id => 'cms-template-delete-button')
    end

    def commit_button(*args)
      options = args.extract_options!
      button_html = options[:button_html] ||= {}

      unless @object.new_record?
        button_html.reverse_merge! :title => 'Save the draft'
        options[:label] ||= "Save"
      end

      button_html[:class] ||= 'important-button'

      args << options # ruby 1.8

      super(*args)
    end

    def publish_button(*args)
      options = args.extract_options!
      button_html = options.delete(:button_html) || {}

      button_html.reverse_merge! :title => 'Save and publish the current draft.',
                                 :type => :submit,
                                 :name => :publish,
                                 :value => true,
                                 :class => 'less-important-button'

      template.content_tag(:button, 'Publish', button_html)
    end

    def hide_button(*args)
      options = args.extract_options!
      button_html = options.delete(:button_html) || {}

      button_html.reverse_merge! :class => 'hide',
                                 :title => 'Unpublishes the page. User would receive a 404 when trying to access its path. ',
                                 :type => :submit,
                                 :name => :hide,
                                 :value => true

      template.content_tag(:button, 'Hide', button_html)
    end

    def save_as_version_button(*args)
      options = args.extract_options!

      # TODO: Save Page as version
      text = options.delete(:label) || args.shift || "Save as Version"

      button_html = options.delete(:button_html) || {}
      button_html.merge! :class => 'save_as_version',
                         :title => 'Saves current draft in a version history without publishing it.',
                         :type => :submit, :name => :version, :value => true

      button = template.content_tag(:button, text, button_html)
      template.content_tag(:li, button, :class => :save_as_version)
    end
  end
end
