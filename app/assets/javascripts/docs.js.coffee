# use `coffee --watch --compile public/javascripts/docs.coffee` to compile this

class DocsWidget
  @host = "//support.3scale.net"
  @url = @host + "/search.json"
  @per_page = 10

  constructor: (element) ->
    $ =>
      @widget = $(element)
      @widget.find('[data-role=search]')
              .on('submit', (event) => @search(event.target)).end()
              .find('[data-role=close]').on('click', => @close())
      @results = @widget.find('[data-role=results]')

  el: (name, attrs = {}) ->
    $("<#{name}/>", attrs)

  activate: ->
    @widget.addClass('active')
    @results.slideDown()

  deactivate: ->
    @widget.removeClass('active')
    @results.slideUp()

  search: (form) ->
    query = $(form.q).val()

    $.ajax
      url: DocsWidget.url,
      dataType: 'jsonp',
      data: { q: query, per_page: DocsWidget.per_page },
      success: (data) =>
        @show(data)

    return false

  result: (attrs) ->
    return unless attrs?

    result = []
    result.push @el('li').append(
      @el(
        'a',
        href: DocsWidget.host + attrs.path, html: attrs.title, target: '_blank'
      )
    )
    result

  show: (data) ->
    @empty()

    if data.length > 0
      for item in data
        @results.append @result(item.page)

    else
      @results.append @el('li', text: 'No results', class: 'no-results')

    @activate()

  empty: ->
    @results.find('*').remove()

  reset: ->
    input = @widget.find('input')
    input.val('')
    input.focus()

  close: ->
    @deactivate()
    @empty()
    @reset()

docs = new DocsWidget('#docs-widget')
