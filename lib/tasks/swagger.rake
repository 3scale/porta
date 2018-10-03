namespace :swagger do
  task invalids20: :environment do
    scope = ApiDocs::Service.where(swagger_version: '2.0')
    validate!(scope)
  end
  task invalids12: :environment do
    scope = ApiDocs::Service.where(swagger_version: '1.2').where('base_path != ?', 'https://echo-api.3scale.net')
    validate!(scope)
  end

  task destroy_orphans: :environment do
    ApiDocs::Service.joining { account.outer }.where.has { account.id == nil }.find_each(&DeleteObjectHierarchyWorker.method(:perform_later))
  end

  task stats_version: :environment do
    puts ApiDocs::Service.group('swagger_version').count
  end

  task resave: :environment do
    i = 0
    ApiDocs::Service.find_each do |ad|
      i += 1
      puts i if i % 100 == 0
      ad.save(validate: false)
    end
  end


  def validate!(scope)
    p "Spec ID, Account ID, Errors"

    invalids = 0
    scope.find_each do |swagger|
      next if swagger.specification.valid?
      invalids += 1
      p "#{swagger.id}, #{swagger.account.id}, #{swagger.specification.validate!.count}"
    end

    puts "Invalids #{invalids} from #{scope.count}"
  end

end
