require 'test_helper'

class Concerns::BackgroundDeletionTest < ActiveSupport::TestCase

  class DoubleObject
    include BackgroundDeletion
    self.background_deletion = [:services, [:users, { action: :delete }]]
  end

  class DoubleActiveRecordObject < ApplicationRecord
    self.table_name = 'access_tokens'

    include BackgroundDeletion
    self.background_deletion = [[:owner, { action: :destroy, has_many: false }]]

    belongs_to :owner, class_name: 'User', dependent: :destroy
  end

  def test_destroy_integration
    user = FactoryBot.create(:simple_user)
    double_object = DoubleActiveRecordObject.create!(owner: user, value: 'abc123', name: 'super-token', permission: 'rw')
    DeleteObjectHierarchyWorker.expects(:perform_later).with(user, anything, 'destroy').once
    DeleteObjectHierarchyWorker.expects(:perform_later).with(user, anything, 'delete').never
    DeleteObjectHierarchyWorker.perform_now(double_object)
  end

  class SecondDoubleActiveRecordObject < DoubleActiveRecordObject
    self.background_deletion = [[:owner, { action: :delete, has_many: false }]]
  end

  def test_delete_integration
    user = FactoryBot.create(:simple_user)
    double_object = SecondDoubleActiveRecordObject.create!(owner: user, value: 'abc123', name: 'super-token', permission: 'rw')
    DeleteObjectHierarchyWorker.expects(:perform_later).with(user, anything, 'delete').once
    DeleteObjectHierarchyWorker.expects(:perform_later).with(user, anything, 'destroy').never
    DeleteObjectHierarchyWorker.perform_now(double_object)
  end
end
