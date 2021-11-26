# frozen_string_literal: true

class Pdf::Styles::BlackAndWhite < Pdf::Styles::Base

  def tags
    super.merge(
      { :domain => { :font_weight => :bold, :font_size => 14 },
        :period => { :font_size => 6.mm },
        :date => { :font_size => 5.mm, :font_weight => :bold },
        :subtitle => { :font_size => 4.mm, :font_weight => :bold },
        table: {
          header: { style: :bold, size: 3.mm, color: "ffffff" },
          cell: { size: 3.mm, style: :bold}
        },
        :small => { :font_size => 3.5.mm, :color => "555" },
        :red => { :color => 'black' },
        :green => { :color => 'b0b0b0' },
        :b => { :style => :bold }
      })
  end

  def table_style
    super.deep_merge(
      cell_style: { :border_color => 'a7a7a7' },
      :header_color => 'd6d6d6',
      # :row_colors => [ "d6d6d6d", "efefef" ],
      :row_colors => %w[ffffff ffffff])
  end
end
