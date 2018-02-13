# List of TODO encountered in the way

## TODO list

* Remove lib/rails5_ssl.rb
* Check bigint primary while migrating to rails 5.1
* secure_headers is a rack with some helpers to work on controller. Fix set_x_frame_options and the like
* comparison of Time.now and database value will likely fail as database does not store fractions of seconds (search in git history "fix fraction of seconds lost in DB")


## Articles to check

* [4.2 -> 5.0](http://edgeguides.rubyonrails.org/upgrading_ruby_on_rails.html#upgrading-from-rails-4-2-to-rails-5-0)
* [5.0 -> 5.1](http://edgeguides.rubyonrails.org/upgrading_ruby_on_rails.html#upgrading-from-rails-5-0-to-rails-5-1)
* [Upgrade to rails 5.0](https://medium.com/@tair/how-to-upgrade-to-rails-5-657b3bfd83)
* [Solution upgrading to rails 5.0](https://collectiveidea.com/blog/archives/2016/07/22/solutions-to-potential-upgrade-problems-in-rails-5)
