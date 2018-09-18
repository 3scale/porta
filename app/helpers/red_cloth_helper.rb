require 'redcloth'

module RedClothHelper
  def mark_up(text)
    RedCloth.new(text).to_html.html_safe
  end
end
