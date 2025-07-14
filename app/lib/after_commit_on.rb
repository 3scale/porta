module AfterCommitOn
  def after_commit(object)

    include_action = ->(action) { object.send(:transaction_include_any_action?, [action]) }

    case
    when respond_to?(:after_commit_on_create) && include_action.call(:create)
      after_commit_on_create(object)
    when respond_to?(:after_commit_on_update) && include_action.call(:update)
      after_commit_on_update(object)
    when respond_to?(:after_commit_on_destroy) && include_action.call(:destroy)
      after_commit_on_destroy(object)
    end
  end
end
