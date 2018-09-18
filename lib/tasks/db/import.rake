namespace :db do
  desc "Import DB from s3"
  task import: :environment do
    bucket = Shellwords.escape(ENV.fetch('bucket', 'operations.backups-eu'))
    backup = Shellwords.escape(ENV.fetch('backup', 'system_obfuscated'))
    path = ENV.fetch('DB_FILE_PATH', nil) # optionally specified for s3/local files

    s3cmd = if ENV['AWS_SECRET_ACCESS_KEY'] && ENV['AWS_ACCESS_KEY_ID']
              [
                's3cmd', '--region', 'us-east-1',
                '--secret_key', Shellwords.escape(ENV.fetch('AWS_SECRET_ACCESS_KEY')),
                '--access_key', Shellwords.escape(ENV.fetch('AWS_ACCESS_KEY_ID'))
              ].join(' ')
            else
              's3cmd'
            end

    connection_config = ActiveRecord::Base.connection_config

    host = connection_config[:host]
    database = connection_config[:database]
    port = connection_config[:port] || '3306'
    socket = connection_config[:socket]
    user = connection_config[:username] || 'root'
    password = connection_config[:password]

    mysql_options = []

    if socket
      mysql_options << '--socket' << Shellwords.escape(socket)
    else
      mysql_options << '--host' << Shellwords.escape(host) << '--port' << Shellwords.escape(port)
    end

    mysql_options << '--user' << Shellwords.escape(user)
    mysql_options << '--password' << Shellwords.escape(password) if password

    mysql_options = mysql_options.join(' ')

    # FIXME: We do not need to create this user right?
    mysql = %(mysql #{mysql_options} -e "create user 'systemdb'@'%'; grant ALL on *.* to 'systemdb'@'%';")
    system(mysql)


    # if path wasn't specified, use today's backup path
    path ||= begin
               today = `#{s3cmd} ls s3://#{bucket}/#{backup}/ | tail -n 1 | awk '{ print $2 }'`.chomp
               cmd = "#{s3cmd} ls #{Shellwords.escape today} | tail -n 1 | awk '{ print $4 }'"
               `#{cmd}`.chomp
             end
    escaped_path = Shellwords.escape(path)

    size, get = if path.start_with?('s3://')
                  [`#{s3cmd} ls #{escaped_path} | awk '{ print $3 }'`.chomp,
                   "#{s3cmd} get #{escaped_path} --quiet -"]
                elsif File.readable?(path)
                  [File.size(path),
                   "cat #{escaped_path}"]
                else
                  raise "unknown or unreadable DB_FILE_PATH: #{path}"
                end

    gunzip = 'gunzip --decompress --stdout' if path.end_with? '.gz'
    import = "mysql #{mysql_options} #{database}"
    pv = "pv --size #{size} --eta --rate --progress --timer" if system('which', 'pv', out: '/dev/null')
    command = [get, pv, gunzip, import].compact.join(' | ')

    puts command
    exec command
  end
end
