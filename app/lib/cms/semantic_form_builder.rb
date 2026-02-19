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

    def delete_button
      tag.div(class: 'pf-c-action-list__item') do
        return disabled_delete_button unless object_can_be_destroyed?

        template.link_to('Delete', template.url_for(action: :destroy),
                         'data-method': :delete,
                         class: 'delete pf-c-button pf-m-danger',
                         title: "Delete this #{@object.class.model_name.human.downcase}",
                         'data-confirm': "Do you really want to delete this #{@object.class.model_name.human.downcase}?")
      end
    end

    def hide_button(*args)
      options = args.extract_options!
      button_html = options.delete(:button_html) || {}

      button_html.reverse_merge! :class => 'hide',
                                 :title => 'Unpublishes the page. User would receive a 404 when trying to access its path. ',
                                 :type => :submit,
                                 :name => :hide,
                                 :value => true

      template.tag.button('Hide', button_html)
    end

    def actions(&)
      tag.div(class: 'pf-c-action-list pf-l-level pf-u-mt-md', &)
    end

    private

    def object_can_be_destroyed?
      object.try(:can_be_destroyed?) != false
    end

    def disabled_delete_button
      template.link_to('Delete', '', class: 'delete pf-c-button pf-m-danger pf-m-disabled')
    end
  end
end
