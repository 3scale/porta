class Numeric
  # Allows to serialize simple numbers to XML. Just suppy the :root options to give it
  # custom name.
  #
  # == Options
  #
  # root:: name of the tag
  # skip_instruct:: skips the XML header
  #
  # == Example
  #
  # # Returns "<answer>42</answer>"
  # 42.to_xml(:root => 'answer')
  #
  def to_xml(options = {})
    builder = options[:builder] || ThreeScale::XML::Builder.new
    builder.__send__(:method_missing, options[:root] || 'number', self.to_s)
    builder.to_xml
  end
end
