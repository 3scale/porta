require 'prawn/format'

class Pdf::Styles::BlackAndWhite < Pdf::Styles::Base

  def tags
    super.merge(
    { :domain   => { :font_weight => :bold, :font_size => 14},
      :period   => { :font_size => 6.mm},
      :date     => { :font_size => 5.mm, :font_weight => :bold},
      :subtitle => { :font_size => 4.mm, :font_weight => :bold },
      :td       => { :font_size => 3.mm, :font_weight => :bold },
      :th       => { :font_weight => :bold, :font_size => 3.5.mm, :color => "ffffff"},
      :small    => { :font_size => 3.5.mm, :color => "555"},
      :red      => { :color => 'black'},
      :green    => { :color => 'b0b0b0'},
      :b        => { :style => :bold }
    })
  end

  def table_style
    super.merge(:border_color => 'a7a7a7',
                :header_color => 'd6d6d6',
                # :row_colors => [ "d6d6d6d", "efefef" ],
                :row_colors => [ "ffffff", "ffffff" ])
  end
end
