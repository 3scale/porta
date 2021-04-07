# frozen_string_literal: true

module TableHelpers

  # Does the same thing as #tableish from cucumber-rails.
  #
  # +table+ is a table selector
  # +rows+ is rows selector
  # +cells+ is cells selector
  #
  # returns array with table content
  #
  def extract_table(table, rows, cells = nil)
    ThreeScale::Deprecation.warn "Detected old table. Move to PF4 and use #extract_pf4_table."
    find(*table).all(*rows).map do |row|
      if cells.respond_to?(:call)
        cells.call(row)
      elsif block_given?
        yield row
      else
        row.all(*cells).map { |cell| cell.text.strip }
      end
    end
  end

  def extract_pf4_table
    header = all('.pf-c-table thead th').map(&:text)

    body = all('.pf-c-table tbody tr').map do |row|
      row.all('td:not(.pf-c-table__action)').map(&:text)
    end

    [header] + body
  end

end

World(TableHelpers)
