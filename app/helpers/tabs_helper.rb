module TabsHelper

  def tab_link(title, to_dom_id, opts = {})
    clazz = opts[:selected] ? 'ui-tabs-selected' : ''

    content_tag :li, :class => clazz do
      link_to title, to_dom_id
    end
  end
end
