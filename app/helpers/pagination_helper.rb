module PaginationHelper

  DEFAULT_PER_PAGE = 20

  def url
    request.original_url
  end

  def current_page
    @current_page ||= params[:page].nil? ? 1 : params[:page].to_i
  end

  def is_first_page
    current_page === 1
  end

  def per_page
    @per_page ||= params[:per_page].nil? ? DEFAULT_PER_PAGE : params[:per_page].to_i
  end

  def per_page_button(per_page)
    children = content_tag(:p, "#{per_page} per page")
    children << content_tag(:div, class: 'pf-c-options-menu__menu-item-icon') do
      content_tag(:icon, nil, class: 'fas fa-check', aria_hidden: true)
    end if (per_page === self.per_page)

    content_tag(:button, children, class: 'pf-c-options-menu__menu-item', type: 'button', data: { per_page: per_page })
  end
end
