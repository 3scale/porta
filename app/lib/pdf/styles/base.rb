# frozen_string_literal: true

module Pdf::Styles
  class Base
    def tags
      { domain: { color: "#999", font_weight: :bold, font_size: 14 },
        period: { font_size: 6.mm },
        date: { font_size: 5.mm, color: "999999", font_weight: :bold },
        subtitle: { font_size: 4.mm, font_weight: :bold, color: "555" },
        table: {
          header: { style: :bold, size: 3.5.mm, color: "ffffff" },
          cell: { size: 3.mm, style: :bold, color: "222222" }
        },
        small: { font_size: 3.5.mm, color: "555" },
        red: { color: 'red' },
        green: { color: 'green' },
        b: { style: :bold }
      }
    end

    def table_style
      {
        position: :left,
        width: 187.5.mm,
        cell_style: {
          padding: 1.2.mm,
          borders: [:left, :right, :top, :bottom],
          border_width: 0.2.mm
        }
      }
    end

    def font
      Rails.root.join('app', 'lib', 'pdf', 'fonts', 'arial.ttf').to_s
    end
  end
end
