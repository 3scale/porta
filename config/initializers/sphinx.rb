SPHINX_DELTA_INTERVAL = 90.minutes

ThinkingSphinx::Callbacks.suspend!

# Prevents concurrent threads (e.g. sidekiq, puma) to deadlock while racing to obtain access to the mutex block at https://github.com/pat/thinking-sphinx/blob/v3.4.2/lib/thinking_sphinx/configuration.rb#L78
# This is a ThinkingSphinx's known bug, fixed in v4.3.0+ - see: https://github.com/pat/thinking-sphinx/commit/814beb0aa3d9dd1227c0f41d630888a738f7c0d6
# See also https://github.com/pat/thinking-sphinx/issues/1051 and https://github.com/pat/thinking-sphinx/issues/1132
ThinkingSphinx::Configuration.instance.preload_indices if Rails.env.development?
