require 'test_helper'

module Concerns
  class BackgroundDeletionTest < ActiveSupport::TestCase

    class DoubleObject
      include BackgroundDeletion
      self.background_deletion_method = :test_delete
    end

    def test_destroy_method_integration
      user = FactoryBot.create(:simple_user)
      double_object = DoubleObject.new
      double_object.expects(:test_delete).once
      double_object.background_deletion_method_call
    end

    test 'all associations of the config can be constantized' do
      Rails.application.eager_load!

      ApplicationRecord.descendants.each do |klass|
        next if klass.background_deletion.blank?

        klass.background_deletion.each do |association|
          # technically we just need a method that will return a query, not necessarily a defined association
          assert klass.reflect_on_association(association), "expected #{association} of the model #{klass} to exist"
        end
      end
    end
  end
end
