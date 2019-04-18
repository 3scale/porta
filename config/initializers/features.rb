# frozen_string_literal: true

Features::AccountDeletionConfig.configure(Rails.configuration.three_scale.features.account_deletion)
Features::SegmentDeletionConfig.configure(Rails.configuration.three_scale.features.segment_deletion)
