# This is epic fail from rails side:
# https://groups.google.com/forum/#!topic/rubyonrails-security/8CVoclw-Xkk
# it does not recognize ActionController::Parameters as unsafe input
# and if it is a hash, treats it as column = value condition
# so find_by(table: ActionController::Parameters.new('column' => 'value'))
# becomes: table.column = 'value' instead of table = '{"column" => "value"}'

module RailsSQLiFix

  # It comes from a controller so we should escape all nested hashes
  def sanitize_actioncontroller_parameters(attributes)
    result = attributes.respond_to?(:to_unsafe_h) ? attributes.to_unsafe_h : attributes
    result.transform_values do |value|
      case value
        when ActionController::Parameters, Hash
          value.to_s
        else
          value
      end
    end
  end

  def sanitize_forbidden_attributes(attributes)
    return super unless action_controller_parameters_in?(attributes)
    super sanitize_actioncontroller_parameters(attributes)
  end

  # This checks only if the `attributes` or any of its value is an ActionCotroller::Parameters
  def action_controller_parameters_in?(attributes)
    return false unless [Hash, ActionController::Parameters].include?(attributes.class)
    ActionController::Parameters === attributes || attributes.any?{|_k,v| ActionController::Parameters === v }
  end
end

ActiveRecord::Relation.prepend(RailsSQLiFix)
