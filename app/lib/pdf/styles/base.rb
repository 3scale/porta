# frozen_string_literal: true

module Pdf::Styles
  class Base
    delegate :fetch, to: :styles

    alias [] fetch

    private

    # @return [Hash] with default options for Prawn text, boxes, tables, font, etc.
    def styles
      return @style_hash if @style_hash

      @style_hash = {
        domain: { color: "909090", styles: [:bold], size: 14 },
        period: { size: 6.mm },
        date: { size: 5.mm, color: "999999", styles: [:bold] },
        subtitle: { size: 4.mm, style: :bold },
        header: {
          size: 3.5.mm,
          font_style: :bold,
        },
        table: {
          position: :left,
          width: Pdf::Printer::TABLE_FULL_WIDTH,
          cell_style: {
            padding: 1.2.mm,
            borders: %i[left right top bottom],
            border_width: 0.2.mm,
          },
          header: true,
        },
        small: { size: 3.5.mm, color: "505050" },
        red: { text_color: 'ff0000' },
        green: { text_color: '006400' },
        font: "Liberation Sans",
        font_family: {
          "Liberation Sans" => {
            normal: "#{liberation_dir}/LiberationSans-Regular.ttf",
            bold: "#{liberation_dir}/LiberationSans-Bold.ttf",
          }
        },
      }
      freeze_style_hash
    end

    def freeze_style_hash(struct = styles)
      struct.freeze.tap do
        if struct.respond_to? :each_value
          struct.each_value { |value| freeze_style_hash(value) }
        elsif struct.respond_to? :each
          struct.each { |value| freeze_style_hash(value) }
        end
      end
    end

    private

    def liberation_dir
      %w[
      /usr/share/fonts/liberation
      /usr/share/fonts/liberation-sans
      ].find do |path|
        File.directory? path
      end
    end
  end
end
