# This hack disables the i18n key deprecation warning, which we have currently
# no way of doing anything about until we move to rails3.
# TODO: Remove?
I18n::Backend::Base.module_eval do
  protected

  # Disables the i18n key deprecation warning
  def warn_syntax_deprecation!(*); end
end

# Avoid deprecation warning
I18n.enforce_available_locales = false
