require 'test_helper'

module Concerns
  class BackgroundDeletionTest < ActiveSupport::TestCase

    test 'all associations of the config can be constantized' do
      Rails.application.eager_load!

      ApplicationRecord.descendants.each do |klass|
        next if klass.background_deletion.blank?

        klass.background_deletion.each do |association|
          reflection = klass.reflect_on_association(association)
          assert reflection, "expected #{association} of the model #{klass} to exist"
          assert_includes %i[delete delete_all destroy destroy_all], reflection.options[:dependent]
        end
      end
    end
  end
end
