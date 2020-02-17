require 'test_helper'

module Concerns
  class BackgroundDeletionTest < ActiveSupport::TestCase

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

    test 'all associations of the config can be constantized' do
      Rails.application.eager_load!

      models = ActiveRecord::Base.descendants - [DoubleObject, DoubleActiveRecordObject, SecondDoubleActiveRecordObject]

      models.each do |klass|
        next unless klass.included_modules.include? BackgroundDeletion
        Array(klass.background_deletion).each do |config|
          reflection = BackgroundDeletion::Reflection.new(config)
          class_name = reflection.class_name
          assert reflection.try(:class_name).safe_constantize, "expected #{class_name.inspect} of the model #{klass} to be instantiated"
        end
      end
    end
  end
end
