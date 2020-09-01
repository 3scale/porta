module ColumnSortingHelper

  def pf4_sortable(column, title, opts = {})
    is_selected_column = column.to_s === sort_column.to_s
    new_direction = sort_direction === 'asc' ? 'desc' : 'asc'

    sort_params = params.merge(sort: column, direction: new_direction, page: nil)
    hash_methods = %I[to_unsafe_h to_hash]
    to_hash_method = hash_methods.find { |method| sort_params.respond_to?(method) }
    sort_params = sort_params.public_send(to_hash_method)

    path = opts[:url] || :url_for
    url = public_send(path, sort_params.symbolize_keys)

    button_content = content_tag(:span, title, class: 'pf-c-table__text')
    button_content << content_tag(:span, class: 'pf-c-table__sort-indicator') do
      sort_icon_for sort_direction
    end

    classes = ['pf-c-table__sort', is_selected_column ? 'pf-m-selected' : nil]
    classes << opts[:class]
    content_tag(:th, class: classes,
                     role: 'columnheader',
                     aria_sort: sort_direction,
                     scope: 'col') do
      # FIXME: should be button
      content_tag(:a, class: 'pf-c-table__button', href: url) do
        content_tag(:div, button_content, class: 'pf-c-table__button-content')
      end
    end
  end

  private

  def sort_icon_for(order)
    content_tag(:i, nil, class: ['fas', "fa-long-arrow-alt-#{order === 'asc' ? 'up' : 'down'}"])
  end
end
