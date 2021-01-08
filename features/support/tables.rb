# frozen_string_literal: true

World(Module.new do
  def table_row_with_cells?(*cells)
    assert_selector :xpath, selector_for_table_row_with_cells(*cells)
  end

  def selector_for_table_row_with_cells(*cells)
    tds = cells.map{|cell| XPath.generate { |x| x.child(:td)[x.string.contains(cell)] } }.reduce(:+)
    XPath.generate { |x| x.anywhere[ tds ] }.to_s
  end
end)
