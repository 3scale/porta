require 'test_helper'

class SearchPresentersTest < ActiveSupport::TestCase
  include ActiveJob::TestHelper

  test 'index presenter as json' do

    provider = FactoryBot.create(:simple_account)
    provider.sections << FactoryBot.create(:root_cms_section, :provider => provider)

    ThinkingSphinx::Test.rt_run do
      perform_enqueued_jobs only: SphinxIndexationWorker do
        page = FactoryBot.create(:cms_page, :published => 'my text whatever', :provider => provider).reload
        request = stub('request')
        params = {:q => '*text*'}


        presenter = SearchPresenters::IndexPresenter.new(params, request, page.reload.tenant_id)
        search_results = presenter.as_json

        assert hash = search_results.first, "missing search result"
        assert_equal page.title, hash[:title]
      end
    end
  end

  test 'search_token' do
    presenter = SearchPresenters::SearchAbstractPresenter.new({ q: 'foo/bar' }, mock('request'), mock('tenant_id'))

    assert_equal 'foo\/bar', presenter.search_token
  end

  test 'pagination' do
    provider = FactoryBot.create(:simple_account)
    provider.sections << section = FactoryBot.create(:root_cms_section, :provider => provider)

    ThinkingSphinx::Test.rt_run do
      perform_enqueued_jobs only: SphinxIndexationWorker do

        10.times do
          FactoryBot.create(:cms_page, published: 'my text whatever', provider: provider, section: section)
        end

        request = stub('request')
        params = {:q => '*text*', per_page: 1, page: 2}

        presenter = SearchPresenters::IndexPresenter.new(params, request, provider.id)
        search = presenter.search

        assert_equal 10, search.total_entries
        assert_equal 10, search.total_pages
        assert_equal 10, presenter.total_found
        assert_equal 1,  search.per_page
        assert_equal 2,  search.current_page
      end
    end
  end

  test 'per_page' do
    presenter = SearchPresenters::SearchAbstractPresenter.new({per_page: 1}, nil ,nil)
    assert_equal 1, presenter.per_page

    presenter = SearchPresenters::SearchAbstractPresenter.new({per_page: nil}, nil, nil)
    assert_equal 7, presenter.per_page

    presenter = SearchPresenters::SearchAbstractPresenter.new({per_page: 10}, nil, nil)
    assert_equal 10, presenter.per_page

    presenter = SearchPresenters::SearchAbstractPresenter.new({per_page: ''}, nil, nil)
    assert_equal 7, presenter.per_page

    presenter = SearchPresenters::SearchAbstractPresenter.new({per_page: '6'}, nil, nil)
    assert_equal 6, presenter.per_page

    presenter = SearchPresenters::SearchAbstractPresenter.new({per_page: '90'}, nil, nil)
    assert_equal 20, presenter.per_page

    presenter = SearchPresenters::SearchAbstractPresenter.new({per_page: 90}, nil, nil)
    assert_equal 20, presenter.per_page

    presenter = SearchPresenters::SearchAbstractPresenter.new({per_page: { '$acunetix' => '1'}}, nil, nil)
    assert_equal 7, presenter.per_page
    assert_equal 1, presenter.page
  end

  test 'page' do
    sp = SearchPresenters::SearchAbstractPresenter.new({page: 1000000, per_page: 10}, nil, nil)
    assert_equal 100, sp.page
    assert_equal 10, sp.per_page
    assert sp.page * sp.per_page <= SearchPresenters::SearchAbstractPresenter::MAX_MATCHES

    sp = SearchPresenters::SearchAbstractPresenter.new({page: 1000000, per_page: 9}, nil, nil)
    assert_equal 111, sp.page
    assert_equal 9, sp.per_page
    assert sp.page * sp.per_page <= SearchPresenters::SearchAbstractPresenter::MAX_MATCHES
  end
end
