# frozen_string_literal: true

module SearchHelpers
  def find_items(label)
    all("td[data-label='#{label}']").map(&:text)
  end

  def clear_search
    clear_button = find('button[aria-label="Reset"]')
    clear_button.click
  end
end

World(SearchHelpers)
