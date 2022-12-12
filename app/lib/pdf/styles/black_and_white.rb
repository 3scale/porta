# frozen_string_literal: true

class Pdf::Styles::BlackAndWhite < Pdf::Styles::Base

  private

  def styles
    super.deep_merge(
      header: {
        # size: 3.8.mm,
        font_style: :normal,
        background_color: 'd6d6d6',
        # color: '000000',
      },
      table: {
        cell_style: { :border_color => 'a7a7a7' },
        # :row_colors => [ "d6d6d6d", "efefef" ],
        row_colors: %w[ffffff ffffff],
      },
      :red => { text_color: '000000' },
      :green => { text_color: 'b0b0b0' }
    )
  end
end
