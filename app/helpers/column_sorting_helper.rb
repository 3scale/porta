# frozen_string_literal: true

module ColumnSortingHelper

  # This smells of :reek:DataClump, :reek:LongParameterList, :reek:TooManyStatements, :reek:ManualDispatch
  def th_sortable(column, title = nil, path = :url_for, opts: {}) # rubocop:disable Metrics/AbcSize, Metrics/CyclomaticComplexity, Metrics/MethodLength
    title ||= column.titleize

    is_current_column = column.to_s == sort_column.to_s

    th_class = "pf-c-table__sort#{' pf-m-selected' if is_current_column} #{opts[:class]}"
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

  private

  def sort_column
    params[:sort]
  end

  def sort_direction
    params[:direction]
  end
end
