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
      return disabled_delete_button unless object_can_be_destroyed?

      template.link_to('Delete', template.url_for(action: :destroy),
                       'data-method': :delete,
                       class: 'delete pf-c-button pf-m-danger',
                       title: "Delete this #{@object.class.model_name.human.downcase}",
                       'data-confirm': "Do you really want to delete this #{@object.class.model_name.human.downcase}?")
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

    def actions(*args, &block)
      # HACK: CMS design is too far away from the rest of the app so skip SemanticFormBuilder implementation
      ::Formtastic::FormBuilder.instance_method(:actions).bind(self).call(*args, &block)
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
