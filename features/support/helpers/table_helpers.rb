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

end

World(TableHelpers)
