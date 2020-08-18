# frozen_string_literal: true

module DecoratorAdditions

  # This smells of :reek:NilCheck
  def current_account
    @_decorated_current_account ||= super&.decorate
  end

  # This smells of :reek:NilCheck
  def current_user
    @_decorated_current_user ||= super&.decorate
  end

  def current_ability
    @current_ability ||= ::Ability.new(controller.send(:current_user))
  end
end
