module CMS
  module MenuHelper

    def cms_new_button_dropdown(model)
      path = polymorphic_path([:provider, :admin, model], action: :new)
      render("provider/admin/cms/new_button", new_button_path: path, name: model.model_name.human)
    end
  end
end
