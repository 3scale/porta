module UserWidgetHelper

  def provider_top_menu_link(key, link, opts = {})
    attrs = { :class => 'active' } if active_menu?(:topmenu, key)
    title = opts[:title] || key.to_s.humanize

    content_tag :li, attrs do
      opts[:id] ||= "top-menu-link-#{key}"
      link_to(title, link, opts)
    end
  end

end
