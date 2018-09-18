require 'test_helper'

class AuditedWorkerTest < ActiveSupport::TestCase
  def test_perform
    assert_difference('Audited.audit_class.count') { AuditedWorker.new.perform(kind: 'some') }
  end
end
