List of TODO encountered in the way

* Remove lib/rails5_ssl.rb
* Check bigint primary while migrating to rails 5.1
* secure_headers is a rack with some helpers to work on controller. Fix set_x_frame_options and the like
* comparison of Time.now and database value will likely fail as database does not store fractions of seconds (search in git history "fix fraction of seconds lost in DB")
