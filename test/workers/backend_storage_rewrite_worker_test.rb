# frozen_string_literal: true

require 'test_helper'

class BackendStorageRewriteWorkerTest < ActiveSupport::TestCase
  test 'perform worker' do
    Backend::StorageRewrite::Processor.any_instance.expects(:rewrite).with(class_name: Cinstance, ids: [1,2,3,4,5])
    BackendStorageRewriteWorker.new.perform(Cinstance, [1,2,3,4,5])
  end
end
