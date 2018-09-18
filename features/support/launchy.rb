# we are on jenkins
if ENV['JOB_NAME']
  Launchy.stubs(:open)
end
