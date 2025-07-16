# frozen_string_literal: true

class NotificationPreferencesRepresenter < ThreeScale::Representer
  include ThreeScale::JSONRepresenter

  property :preferences, as: :notification_preferences, getter: ->(*) { preferences.sort.to_h }
end
