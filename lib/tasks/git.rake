namespace :git do

  desc "Tag current Git HEAD with a deployment tag of the selected stage"
  task :tag do
    tags = `git tag -l`
    tags = tags.lines.map(&:chomp)

    product = ENV['PRODUCT'] || 'enterprise'
    date = ENV['DATE'] || Date.today.strftime('%Y-%m-%d')
    name = "#{product}-#{date}"

    # TODO: maybe it is better to use -f
    collisions = tags.select do |tag|
      tag =~ /^#{Regexp.quote(name)}/
    end

    unless collisions.empty?
      index = collisions.inject(0) do |memo, tag|
        number = tag[/\d+\-\d+\-\d+\-(\d+)$/, 1].to_i
        [memo, number].max
      end

      name += if index > 0
        "-#{index + 1}"
              else
        "-2"
              end
    end

    `git tag #{name}`
    `git push --tags origin #{name}` unless ENV['NOPUSH']
  end
end
