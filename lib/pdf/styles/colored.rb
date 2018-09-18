class Pdf::Styles::Colored < Pdf::Styles::Base

  def tags
    super.merge(:domain   => { :color => "#999", :font_weight => :bold, :font_size => 14},
                :date     => {:font_size => 5.mm, :color => "999999", :font_weight => :bold},
                :subtitle => {:font_size => 4.mm, :font_weight => :bold, :color => "555"},
                :td       => {:font_size => 3.mm, :font_weight => :bold, :color => "222222"},
                :th       => {:font_weight => :bold, :font_size => 3.5.mm, :color => "ffffff"},
                :small    => {:font_size => 3.5.mm, :color => "555"},
                :red      => {:color => 'red'},
                :green    => {:color => 'green'})
  end


  def table_style
    super.merge( :header_text_color => 'ffffff',
                 :row_colors => ["d9e8f8", "e6f0fb"],
                 :border_color => 'ffffff',
                 :header_color => '7e7e7f' )
  end

end
