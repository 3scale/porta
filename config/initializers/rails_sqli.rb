# This is epic fail from rails side:
# https://groups.google.com/forum/#!topic/rubyonrails-security/8CVoclw-Xkk
# it does not recognize ActionController::Parameters as unsafe input
# and if it is a hash, treats it as column = value condition
# so find_by(table: ActionController::Parameters.new('column' => 'value'))
# becomes: table.column = 'value' instead of table = '{"column" => "value"}'

module RailsSQLiFix

  def sanitize_actioncontroller_parameters(attributes)
    # TODO: replace this with Hash#transform_values on Rails 4.2
    attrs = attributes.class.new

    attributes.each do |k,v|
      attrs[k] = case v
                 when ActionController::Parameters then v.to_s
                 else v
                 end
    end

    attrs
  end

  def sanitize_forbidden_attributes(attributes)
    case attributes
    when Hash
      sanitize_actioncontroller_parameters(attributes)
    else super
    end
  end
end

ActiveRecord::Relation.prepend(RailsSQLiFix)
