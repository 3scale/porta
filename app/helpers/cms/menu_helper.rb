module CMS
  module MenuHelper

    def cms_new_button_dropdown(model)
      path = polymorphic_path([:provider, :admin, model], action: :new)
      render partial: "/provider/admin/cms/dropdown", locals: {
        id: "cms-new-content-button",
        type: :primary,
        toggle_button: {
          text: "New #{model.model_name.human}",
          attrs: { type: :button, onclick: "window.open('#{path}', '_self')" }
        },
        menu_items: [
          { text: "New Page", url: new_provider_admin_cms_page_path },
          { text: "New Layout", url: new_provider_admin_cms_layout_path },
          { text: "New Partial", url: new_provider_admin_cms_partial_path },
          { text: "New Section", url: new_provider_admin_cms_section_path },
          { text: "New File", url: new_provider_admin_cms_file_path },
          { text: "New Portlet", url: pick_provider_admin_cms_portlets_path }
        ]
      }
    end
  end
end
