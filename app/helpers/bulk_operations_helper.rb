module BulkOperationsHelper
  def bulk_action name, url, description
    content_tag(:dt, name, :class => :operation, :'data-url' => url) <<
    content_tag(:dd, description, :class => :description)
  end

  def bulk_select_all
    check_box_tag 'selected[]', nil, nil, :class => 'select-all'
  end

  def bulk_select_one object
    check_box_tag 'selected[]', object.id
  end
end
