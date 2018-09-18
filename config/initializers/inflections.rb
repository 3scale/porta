# Be sure to restart your server when you modify this file.

# Add new inflection rules using the following format
# (all these examples are active by default):
# ActiveSupport::Inflector.inflections do |inflect|
#   inflect.plural /^(ox)$/i, '\1en'
#   inflect.singular /^(ox)en/i, '\1'
#   inflect.irregular 'person', 'people'
#   inflect.uncountable %w( fish sheep )
# end
ActiveSupport::Inflector.inflections do |inflect|
  inflect.uncountable << 'trash'
  inflect.uncountable << 'ogone'
  inflect.uncountable << 'braintree_blue'
  inflect.uncountable << 'authorize_net'
  inflect.uncountable << 'stripe'
  inflect.uncountable << 'sudo'
  inflect.uncountable << 'github'
  inflect.uncountable << 'adyen12'
  # ThinkingSphinx fails to preload CMS models because it thinks they are Cms
  # see ThinkingSphinx::Context#load_models for mode details, it uses 'cms/model'.camelize
  inflect.acronym 'CMS' # , enable this and rename every Cms to CMS
  inflect.acronym 'OAuth'
  inflect.acronym 'GitHub'
  inflect.acronym 'SSO'
  inflect.acronym 'OIDC' # OpenID Connect
end


# Backport from Rails 4.2 to properly underscore ThreeScale::OAuth into three_scale/oauth instead of three_scale/o_auth
ActiveSupport::Inflector.singleton_class.prepend(Module.new do
  def underscore(camel_cased_word)
    return camel_cased_word unless camel_cased_word.to_s =~ /[A-Z-]|::/
    word = camel_cased_word.to_s.gsub(/::/, '/')
    word.gsub!(/(?:(?<=([A-Za-z\d]))|\b)(#{inflections.acronym_regex})(?=\b|[^a-z])/) { "#{$1 && '_'}#{$2.downcase}" }
    word.gsub!(/([A-Z\d]+)([A-Z][a-z])/,'\1_\2')
    word.gsub!(/([a-z\d])([A-Z])/,'\1_\2')
    word.tr!("-", "_")
    word.downcase!
    word
  end
end)
