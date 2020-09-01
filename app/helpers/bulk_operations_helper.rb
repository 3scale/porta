module BulkOperationsHelper
  def bulk_action name, url
    content_tag(:button, name, class: 'pf-c-button pf-m-primary', data: { url: url })
  end

  def bulk_select_all
    check_box_tag 'selected[]', nil, nil, :class => 'select-all', aria_label: 'Select all rows'
  end

  def bulk_select_one object
    check_box_tag 'selected[]', object.id
  end
end
