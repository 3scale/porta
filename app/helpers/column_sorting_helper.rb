module ColumnSortingHelper

  # table sorting
  # TODO: merge with sortable
  def sort_link(title, column, options = {})
    condition = options[:unless] if options.has_key?(:unless)
    sort_dir = params[:d] == 'up' ? 'down' : 'up'
    css_class = params[:d] if column.to_s == params[:c]
    link_to_unless condition, title_with_order_indicator(title, css_class), request.parameters.merge( {:c => column, :d => sort_dir} ), :class => css_class
  end

  # inspired by Railscast 240
  def sortable(column, title = nil, path = :url_for)
    title ||= column.titleize
    is_column = column.to_s == sort_column.to_s
    css_class = is_column ? "current #{sort_direction}" : nil

    current_direction = is_column ? sort_direction : nil
    new_direction = current_direction == 'asc' ? 'desc' : 'asc'

    sort_params = params.merge(sort: column, direction: new_direction, page: nil)
    url = public_send(path, sort_params.symbolize_keys)

    link_to title_with_order_indicator(title, current_direction),
            url,
            { :class => css_class }
  end

  def title_with_order_indicator title, direction
    [h(title), order_indicator_for(direction)].compact.join(' ').html_safe
  end

  private

  def order_indicator_for(order)
    case order.try!(:to_sym)
    when :asc, :up
      '&#9650;'
    when :desc, :down
      '&#9660;'
    end
  end
end
