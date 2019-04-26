class Services::BackendApiPresenter < BackendApiPresenter
  def product_slug
    nil || default_product_slug
  end
end
