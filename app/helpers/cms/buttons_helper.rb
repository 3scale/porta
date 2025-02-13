# frozen_string_literal: true

module CMS
  module ButtonsHelper
    def cms_dropdown_button(title, url = nil, opts = {}, &)
      css_class = opts.delete(:important) ? 'important-button' : 'less-important-button'

      main_item = if url.nil?
                    title
                  else
                    link_to(title, url, opts.slice!(:id).merge(:class => css_class))
                  end

      list = tag.ul(capture(&), class: 'dropdown')

      caret = %(<a class="#{css_class} dropdown-toggle" href="#">
                  <i class="fa fa-caret-down"></i>
                </a>).html_safe # rubocop:disable Rails/OutputSafety

      tag.div(**opts.merge(class: 'button-group')) do
        main_item + list + caret
      end
    end
  end
end
