module Pdf::Styles
  class Base

    def tags
      { :domain   => { :color => "#999", :font_weight => :bold, :font_size => 14},
        :period   => {:font_size => 6.mm},
        :date     => {:font_size => 5.mm, :color => "999999", :font_weight => :bold},
        :subtitle => {:font_size => 4.mm, :font_weight => :bold, :color => "555"},
        :td       => {:font_size => 3.mm, :font_weight => :bold, :color => "222222"},
        :th       => {:font_weight => :bold, :font_size => 3.5.mm, :color => "ffffff"},
        :small    => {:font_size => 3.5.mm, :color => "555"},
        :red      => {:color => 'red'},
        :green    => {:color => 'green'},
        :b        => { :style => :bold }
      }
    end

    def table_style
      { :position           => :left,
        :width              => 187.5.mm,
        :vertical_padding   => 1.2.mm,
        :horizontal_padding => 1.2.mm,
        :border_style => :grid,
        :border_width => 0.2.mm }
    end

    def font
      "#{Rails.root}/app/lib/pdf/fonts/arial.ttf"
    end

  end
end
