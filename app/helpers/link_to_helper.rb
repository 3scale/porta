module LinkToHelper
  # Conditionally joins a set of CSS class names into a single string
  # http://www.carlosramireziii.com/a-cleaner-way-to-set-multiple-conditional-css-classes-for-link-to.html
  # 
  # @param css_map [Hash] a mapping of CSS class names to boolean values
  # @return [String] a combined string of CSS classes where the value was true
  def class_string(css_map)
    classes = []

    css_map.each do |css, bool|
      classes << css if bool
    end
    
    classes.join(" ")
  end
end