class AddRequireCcOnSignupToSwitches < ActiveRecord::Migration
  def change
    add_column :settings, :require_cc_on_signup_switch, :string, default: 'hidden', null: false
  end
end
