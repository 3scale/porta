# frozen_string_literal: true

module Tagging
  extend ActiveSupport::Concern

  # see https://github.com/mbleigh/acts-as-taggable-on/issues/1064
  def as_json(options = {})
    except = Array.wrap(options[:except]) + [:tag_list]
    super options.merge({except: except})
  end
end
