module Provider::Admin::CMS::TemplatesHelper

   def cms_section_select(section, result = [], level = 0)
     prefix = if section.root?
                '. '
              else
                '|' + ('&mdash;' * level) + ' '
              end

     result << [ prefix.html_safe + h(section.title), section.id ]

     section.children.each do |child|
       cms_section_select(child, result, level+1)
     end

     result
   end


  def edit_builtin_page_url(system_name)
    page = current_account.builtin_pages.find_by_system_name(system_name)

    if page
      edit_provider_admin_cms_builtin_page_path(page)
    else
      admin_upgrade_notice_path(:branding)
    end
  end

  def edit_main_layout_url
    layout = current_account.layouts.find_by_system_name('main_layout')
    edit_provider_admin_cms_layout_path(layout)
  end

  def liquid_snippet(name)
    content_tag :li, Liquid::ThreeScaleSnippets[name]
  end

end
