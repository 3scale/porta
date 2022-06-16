module ActiveJobUniquenessTestHelper
  protected

  module_function

  def active_job_uniqueness_test_mode!
    ActiveJob::Uniqueness.test_mode!
  end

  def active_job_uniqueness_enable!
    ActiveJob::Uniqueness.instance_variable_set :@lock_manager, nil
  end
end
