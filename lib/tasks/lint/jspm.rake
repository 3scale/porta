namespace :lint do
  RED = "\033[91m"
  BOLD = "\033[1m"
  CLEAR = "\033[0m"

  task :jspm do
    system('which', 'eslint', err: :out, out: '/dev/null') or abort 'Could not find eslint'
    lint = system 'eslint --color --ext .es6 --ext .js assets'
    lint or abort "#{RED + BOLD}Some files are not matching our code style. Please check https://github.com/feross/standard/blob/master/RULES.md#{CLEAR}"
  end
end
