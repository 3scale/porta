class DropStateDefaults < ActiveRecord::Migration
  # Both User and its :state machine have defined a different default for "state". Use only one or the other for defining defaults to avoid unexpected behaviors.
  # Both Plan and its :state machine have defined a different default for "state". Use only one or the other for defining defaults to avoid unexpected behaviors.
  # Both Account and its :state machine have defined a different default for "state". Use only one or the other for defining defaults to avoid unexpected behaviors.
  # Both Contract and its :state machine have defined a different default for "state". Use only one or the other for defining defaults to avoid unexpected behaviors.
  # Both Message and its :state machine have defined a different default for "state". Use only one or the other for defining defaults to avoid unexpected behaviors.
  # Both Service and its :state machine have defined a different default for "state". Use only one or the other for defining defaults to avoid unexpected behaviors.
  # Both Alert and its :state machine have defined a different default for "state". Use only one or the other for defining defaults to avoid unexpected behaviors.
  # Both MessageRecipient and its :state machine have defined a different default for "state". Use only one or the other for defining defaults to avoid unexpected behaviors.

  def up
    change_column_default :users, :state, nil
    change_column_default :plans, :state, nil
    change_column_default :accounts, :state, nil
    change_column_default :cinstances, :state, nil
    change_column_default :messages, :state, nil
    change_column_default :services, :state, nil
    change_column_default :alerts, :state, nil
    change_column_default :message_recipients, :state, nil
  end

  def down
    change_column_default :users, :state, 'passive'
    change_column_default :plans, :state, ''
    change_column_default :accounts, :state, 'pending'
    change_column_default :cinstances, :state, ''
    change_column_default :messages, :state, ''
    change_column_default :services, :state, ''
    change_column_default :alerts, :state, 'new'
    change_column_default :message_recipients, :state, ''
  end
end
