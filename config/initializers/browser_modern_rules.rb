# frozen_string_literal: true

Browser.modern_rules.clear
Browser.modern_rules << ->(b) { b.webkit? }
Browser.modern_rules << ->(b) { b.firefox? && b.version.to_i >= 18 }
Browser.modern_rules << ->(b) { b.ie? && b.version.to_i >= 9 && !b.compatibility_view? }
Browser.modern_rules << ->(b) { b.edge? && !b.compatibility_view? }
Browser.modern_rules << ->(b) { b.opera? && b.version.to_i >= 12 }
Browser.modern_rules << ->(b) { b.firefox? && b.device.tablet? && b.platform.android? && b.version.to_i >= 14 }
