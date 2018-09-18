class ChangeRequireCcOnSignupSwitchDefault < ActiveRecord::Migration
  def change
    change_column_default(:settings, :require_cc_on_signup_switch, 'denied')
    execute %{ UPDATE settings SET require_cc_on_signup_switch = 'hidden' }
  end
end
