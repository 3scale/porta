# frozen_string_literal: true

class Pdf::Styles::Colored < Pdf::Styles::Base

  def tags
    super.merge(domain: { color: "#999", font_weight: :bold, font_size: 14 },
                date: { font_size: 5.mm, color: "999999", font_weight: :bold },
                subtitle: { font_size: 4.mm, font_weight: :bold, color: "555" },
                table: {
                  header: { style: :bold, size: 3.5.mm, color: "ffffff" },
                  cell: { size: 3.mm, style: :bold, color: "222222" }
                },
                small: { font_size: 3.5.mm, color: "555" },
                red: { color: 'red' },
                green: { color: 'green' })
  end

  def table_style
    super.deep_merge(
      header_text_color: 'ffffff',
      row_colors: %w[d9e8f8 e6f0fb],
      cell_style: {
        border_color: 'ffffff',
        header_color: '7e7e7f'
      }
    )
  end

end
