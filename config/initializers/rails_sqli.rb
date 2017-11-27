# This is epic fail from rails side:
# https://groups.google.com/forum/#!topic/rubyonrails-security/8CVoclw-Xkk
# it does not recognize ActionController::Parameters as unsafe input
# and if it is a hash, treats it as column = value condition
# so find_by(table: ActionController::Parameters.new('column' => 'value'))
# becomes: table.column = 'value' instead of table = '{"column" => "value"}'

module RailsSQLiFix

  def sanitize_actioncontroller_parameters(attributes)
    attributes.transform_values do |value|
      case value
        when ActionController::Parameters
          value.to_s
        else
          value
      end
    end
  end

  def sanitize_forbidden_attributes(attributes)
    case attributes
      when ActionController::Parameters
        super sanitize_actioncontroller_parameters(attributes)
      else super
    end
  end
end

ActiveRecord::Relation.prepend(RailsSQLiFix)
