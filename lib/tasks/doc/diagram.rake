namespace :doc do
  namespace :diagram do

    desc "Generates class diagram of Models in SVG (requires patched Railroad gem)"
    task :models do
      excludes = %w{ app/models/account/billing.rb }
      sh "railroad -M -i -e #{excludes.join(' ')} | dot -Tsvg | sed 's/font-size:14.00/font-size:11.00/g' > doc/models.svg"
    end

    # task :controllers do
    #    sh "railroad -i -l -C | neato -Tsvg | sed 's/font-size:14.00/font-size:11.00/g' > doc/controllers.svg"
    # end

    # task :assm do
    #   sh "railroad -i -l -C | neato -Tsvg | sed 's/font-size:14.00/font-size:11.00/g' > doc/controllers.svg"
    # end
  end

  task :diagrams => %w(diagram:models diagram:controllers diagram:assm)
end
