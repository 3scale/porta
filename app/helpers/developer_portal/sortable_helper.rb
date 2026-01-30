# frozen_string_literal: true

# :reek:TooManyStatements
# :reek:ManualDispatch
module DeveloperPortal::SortableHelper
  def sortable(column, title = nil, path = :url_for) # rubocop:disable Metrics/AbcSize
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

  ORDER_INDICATORS = {
    asc: '▲',
    up: '▲',
    desc: '▼',
    down: '▼'
  }.freeze

  private

  def title_with_order_indicator(title, direction)
    safe_join([title, ORDER_INDICATORS[direction&.to_sym]].compact, ' ')
  end
end
