namespace :release do
  desc 'git tag current tree'
  task :tag do

    tag = "v#{Time.now.strftime('%Y.%m.%d')}"

    # If there is a tag with the same name, append sequence number
    matching = `git tag -l #{tag}*`.split
    sequence = matching.inject(-1) do |memo, line|
      [memo, line[/^#{Regexp.quote(tag)}(?:\.(\d+))?$/, 1].to_i].max
    end

    tag += (sequence >= 0)? "-"+(sequence+1).to_s : ''

    puts "=> tagging with #{tag}"
    puts "=> hit X to abort"

    g= STDIN.gets
    g.chop!
    abort if g == "X" || g == "x"

    system "git tag #{tag}" || abort
    system "git push --tags" || abort
  end
end
