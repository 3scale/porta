# frozen_string_literal: true

module CMS
  class SemanticFormBuilder < ::ThreeScale::SemanticFormBuilder
    def input_html_options
      options.delete(:autofocus) ? { autofocus: 'autofocus' } : super
    end

    def select_input(method, options = {})
      if @object.send(method).nil? && @object.new_record?
        options[:selected] ||= options.delete(:default)&.id
      end

      super
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
  end
end
