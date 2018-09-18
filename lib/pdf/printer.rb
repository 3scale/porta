module Pdf::Printer

  PAGE_WIDTH = 230.mm
  TABLE_HALF_WIDTH = 90.mm
  TABLE_FULL_WIDTH = 187.5.mm
  BREAK = 0.5.mm

  private

  # Creates 2-columns layout. Calls the block with :left or :right
  # parameter to render the columns content.
  #
  def two_columns(at = [0.mm, @pdf.cursor], options = {}, &block)
    @pdf.bounding_box(at, { :width => PAGE_WIDTH }.merge(options)) do
      @pdf.column_box [0.mm, @pdf.bounds.top], :width => TABLE_HALF_WIDTH  do
        yield(:left)
      end

      @pdf.column_box [97.mm, @pdf.bounds.top], :width => TABLE_HALF_WIDTH do
        yield(:right)
      end
    end
  end

  # Makes a horizontal line from left to right
  def print_line
    @pdf.stroke_horizontal_line @pdf.bounds.left, @pdf.bounds.right
  end

  def move_down(qty = 1)
    @pdf.move_down((BREAK.mm * qty))
  end

  def subtitle(text)
    @pdf.text "<subtitle>#{text}</subtitle>"
    move_down
  end

end
