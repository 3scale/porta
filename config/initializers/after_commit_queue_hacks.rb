# frozen_string_literal: true

AfterCommitSubscriber::AfterCommitCallback.class_eval do
  def before_committed!
    # noop
  end
end
