# frozen_string_literal: true

class Pdf::Styles::Colored < Pdf::Styles::Base

  private

  def styles
    super.deep_merge(
      subtitle: { color: "505050" },
      header: {
        background_color: '7e7e7f',
        text_color: 'ffffff',
      },
      table: {
        row_colors: %w[d9e8f8 e6f0fb],
        cell_style: {
          border_color: 'ffffff',
          size: 3.mm,
          text_color: "222222",
        },
      }
    )
  end
end
