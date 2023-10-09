module BulkOperationsHelper
  def bulk_action(name, url, description)
    dt = content_tag(:dt, class: 'operation pf-c-description-list__term', 'data-url': url) do
           content_tag(:button, name, class: 'pf-c-button pf-m-secondary')
         end

    dd = content_tag(:dd, description, class: 'description pf-c-description-list__description')

    content_tag(:div, dt + dd, class: "pf-c-description-list__group")
  end

  def bulk_select_all
    check_box_tag 'selected[]', nil, nil, class: 'select-all', autocomplete: 'off'
  end

  def bulk_select_one(object)
    check_box_tag 'selected[]', object.id, nil, autocomplete: 'off'
  end
end
