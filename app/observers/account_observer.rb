# frozen_string_literal: true

class AccountObserver < ActiveRecord::Observer
  observe :account

  def after_commit(record)
    invalidate_master_id(record)
  end

  def after_update(record)
    invalidate_master_id(record)
  end

  def after_delete(record)
    invalidate_master_id(record)

    publish_account_deleted_event!(record)
  end

  def after_destroy(record)
    publish_account_deleted_event!(record)
  end

  def before_destroy(_record); end

  alias before_delete before_destroy

  private

  def invalidate_master_id(record)
    Rails.cache.delete('master_account_id') if record.master?
  end

  def publish_account_deleted_event!(account)
    event = Accounts::AccountDeletedEvent.create(account)
    Rails.application.config.event_store.publish_event(event)
  end
end
