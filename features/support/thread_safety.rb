# frozen_string_literal: true

# Cleanup after each scenario the Thread.current[:cms_user]
# It leads to stale object in memory though they were removed from the Database.
# And it is really hard to debug

After do
  User.current = nil
end
