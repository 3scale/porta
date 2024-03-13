# rubocop:disable Metrics/AbcSize, Metrics/CyclomaticComplexity, Metrics/MethodLength
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
    hash_methods = %I[to_unsafe_h to_hash]
    to_hash_method = hash_methods.find { |method| sort_params.respond_to?(method) }
    sort_params = sort_params.public_send(to_hash_method)

    url = public_send(path, sort_params.symbolize_keys)

    link_to title_with_order_indicator(title, current_direction),
            url,
            { :class => css_class }
  end

  # This smells of :reek:DataClump but it is what it is
  def th_sortable(column, title = nil, path = :url_for, opts: {})
    title ||= column.titleize

    is_current_column = column.to_s == sort_column.to_s

    th_class = "pf-c-table__sort#{is_current_column ? ' pf-m-selected' : ''} #{opts[:class]}"
    icon_class = 'fas fa-arrows-alt-v'

    if is_current_column
      icon_class = case sort_direction
                   when 'asc' then 'fas fa-long-arrow-alt-up'
                   when 'desc' then 'fas fa-long-arrow-alt-down'
                   end
    end

    new_direction = sort_direction == 'asc' ? 'desc' : 'asc'

    sort_params = params.merge(sort: column, direction: new_direction, page: nil)
    hash_methods = %I[to_unsafe_h to_hash]
    to_hash_method = hash_methods.find { |method| sort_params.respond_to?(method) }
    sort_params = sort_params.public_send(to_hash_method)

    url = public_send(path, sort_params.symbolize_keys)

    content_tag :th, role: "columnheader", scope: "col", class: th_class do
      content_tag :a, class: 'pf-c-table__button', href: url do
        content_tag :div, class: 'pf-c-table__button-content' do
          content = content_tag(:span, title, class: 'pf-c-table__text')
          content << content_tag(:span, class: 'pf-c-table__sort-indicator') do
            content_tag(:i, nil, class: icon_class)
          end
          content
        end
      end
    end
  end

  def title_with_order_indicator title, direction
    [h(title), order_indicator_for(direction)].compact.join(' ').html_safe
  end

  private

  def sort_column
    params[:sort]
  end

  def sort_direction
    params[:direction]
  end

  def order_indicator_for(order)
    case order.try!(:to_sym)
    when :asc, :up
      '&#9650;'
    when :desc, :down
      '&#9660;'
    end
  end
end

# rubocop:enable Metrics/AbcSize, Metrics/CyclomaticComplexity, Metrics/MethodLength
