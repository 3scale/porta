class CMS::UpgradeContentWorker
  include Sidekiq::Worker

  sidekiq_options queue: :low

  class ExpandWorker
    include Sidekiq::Worker
    sidekiq_options queue: :low

    def perform(provider_id, kind)
      provider = Provider.find(provider_id)

      batch.jobs do
        provider.templates.select(:id).find_each do |template|
          CMS::UpgradeContentWorker.perform_async(template.id, kind)
        end
      end if valid_within_batch?
    end
  end

  def on_success(_, options)
    bid = options.fetch('bid') { return }
    batch = Sidekiq::Batch::Status.new(bid)
    batch.delete
  end

  def self.enqueue(provider_id, kind)
    provider = Provider.find(provider_id)
    batch = Sidekiq::Batch.new
    batch.on(:success, CMS::UpgradeContentWorker, bid: batch.bid)
    batch.description = "Upgrading CMS Content (#{kind}) of #{provider.org_name} (#{provider.id})"

    batch.jobs do
      ExpandWorker.perform_async(provider.id, kind)
    end
  end

  def perform(cms_template_id, kind)
    upgrade = method("upgrade_#{kind}")

    CMS::Template.transaction do
      template = CMS::Template.lock.find(cms_template_id)
      upgrade.call(template)
    end
  end

  def upgrade_include(template)
    published = replace_include_with(template.published || ''.freeze).presence
    draft = replace_include_with(template.draft || ''.freeze).presence

    template.draft = draft if template.draft != draft
    template.upgrade_content!(published, validate: false)
  end

  protected

  def replace_include_with(content)
    templates = %w(login/cas signup/cas shared/pagination)

    matches = content.gsub(/{%\s+include\s+#{Liquid::Include::Syntax}\s+%}/)

    return content if matches.count.zero?

    matches.each do |block|
      match = block.match(Liquid::Block::FullToken) or raise 'invalid liquid block'
      params = match[2]

      include = params.match(Liquid::Include::Syntax) or raise 'invalid include syntax'

      template = include[1]
      name = template.delete(%q('").freeze)

      case name
      when *templates
        "{% include #{template} with #{name.split('/').last} %}"
      else
        block
      end
    end
  end
end
