# frozen_string_literal: true

module Pdf::Printer

  PAGE_WIDTH = 230.mm
  TABLE_HALF_WIDTH = 90.mm
  TABLE_FULL_WIDTH = 187.5.mm
  BREAK = 0.5.mm

  private

  # Creates 2-columns layout. Calls the block with :left or :right
  # parameter to render the columns content.
  #
  def two_columns(at = [0.mm, @pdf.cursor], options = {})
    first_y = 0
    second_y = 0

    box = @pdf.bounding_box(at, { :width => PAGE_WIDTH }.merge(options)) do
      @pdf.column_box [0.mm, @pdf.bounds.top], :width => TABLE_HALF_WIDTH, columns: 1 do
        yield(:left)
      end
      first_y = @pdf.y

      gap = TABLE_FULL_WIDTH - (2 * TABLE_HALF_WIDTH)
      @pdf.column_box [TABLE_HALF_WIDTH + gap, @pdf.bounds.top], :width => TABLE_HALF_WIDTH, columns: 1 do
        yield(:right)
      end
      second_y = @pdf.y
    end

    @pdf.move_down second_y - first_y if first_y < second_y && box.stretchy?
  end

  # Makes a horizontal line from left to right
  def print_line
    @pdf.stroke_horizontal_line @pdf.bounds.left, @pdf.bounds.right
  end

  def move_down(qty = 1)
    @pdf.move_down((BREAK.mm * qty))
  end

  def subtitle(text)
    @pdf.text text, **@style[:subtitle]
    move_down
  end

  def table_with_header(data, options = {}, &block)
    @pdf.table(data, @style[:table].deep_merge(options)) do |table|
      table.style(table.row(0), **@style[:header])

      if block
        block.arity < 1 ? table.instance_eval(&block) : block[table]
      end
    end
  end

  def table_with_column_header(data, options = {}, &block)
    @pdf.table(data, @style[:table].deep_merge(options).merge(header: false)) do |table|
      table.style(table.column(0), **@style[:header])

      if block
        block.arity < 1 ? table.instance_eval(&block) : block[table]
      end
    end
  end

  def set_default_font
    @pdf.font_families.update(@style[:font_family]) if @style[:font_family]
    @pdf.font(@style[:font]) if @style[:font]
  end
end
