# frozen_string_literal: true

class ProxyConfigAffectingChange < ApplicationRecord
  belongs_to :proxy, touch: true
end
