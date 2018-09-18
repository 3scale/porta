module FeaturesHelper
  def feature_name(feature)
    maybe_hidden_attribute(feature, :name)
  end

  def feature_description(feature)
    maybe_hidden_attribute(feature, :description)
  end

  private

  def maybe_hidden_attribute(feature, name)
    value = h(feature.send(name))
    value = content_tag('span', value, :class => 'hidden') if feature.hidden?
    value
  end
end
