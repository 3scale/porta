module AfterCommitOn
  def after_commit(contract)

    include_action = ->(action) { contract.send(:transaction_include_any_action?, [action]) }

    case
    when respond_to?(:after_commit_on_create) && include_action.call(:create)
      after_commit_on_create(contract)
    when respond_to?(:after_commit_on_update) && include_action.call(:update)
      after_commit_on_update(contract)
    when respond_to?(:after_commit_on_destroy) && include_action.call(:destroy)
      after_commit_on_destroy(contract)
    end
  end
end
