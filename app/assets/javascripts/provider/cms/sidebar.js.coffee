## We are defining :like(stuff) selector. Usage:
##
## $('li a:like(potato)')
##
## matches all links that have a word 'potato' somwhere in the
## data-search attribute.
##
## ---------------------------------------------------------------------------------
##
## NOTE: (http:##www.malsup.com/jquery/expr/):
## jQuery provides some very powerful selection expressions using colon (:) syntax.
## Things like :first, :odd, and :even let you write code like: $('#content a:first')
## to get the first anchor within #content, or $('tr:odd') to get the odd
## numbered rows of a table. What's even cooler is that you can extend this
## behavior to add your own convenience selectors by extending the jQuery.expr[':']
## object. This page adds these two expressions:
##

jQuery.expr[':'].like = (el, i, selector) ->
  return true if !selector[3]
  content = ($(el).data('search') || '').toLowerCase()
  text_to_search = selector[3].toLowerCase()
  return content.indexOf(text_to_search) >= 0

## Sidebar class
class Sidebar
  FOLDER_ICONS = ['fa-folder-o', 'fa-folder-open-o']
  ICON_SETS = [FOLDER_ICONS]
  HIGHLIGHT_CLASS = 'current'
  TOGGLE_SELECTOR = '[data-behavior~=toggle]'
  TOGGLE_ALL_BUTTON_SELECTOR = '#cms-sidebar-collapse-all'

  constructor: (@selector) ->

    @fire_ajax()

    @template = new SidebarTemplates()
    @filter = new SidebarFilter(this)

    @hook(document)

    $ =>
      @element = $(@selector)

      @element
        .on 'click', TOGGLE_ALL_BUTTON_SELECTOR, (event) =>
          sections = @top_level_sections()
          all_packed = @all_items_packed()

          if all_packed
            sections.filter('.packed').each (_, element) => ThreeScale.Toggle.get(element).unpack()
          else
            sections.filter(':not(.packed)').each (_, element) => ThreeScale.Toggle.get(element).pack()

          @update_expand_collapse_button(!all_packed)

        .on 'click', TOGGLE_SELECTOR, (event) =>
          target = $(event.target)
          return unless target.is('.fa')
          ul = target.siblings('ul')
          return unless ul.length
          ThreeScale.Toggle.get(ul).toggle 300, (el) =>
            @update_expand_collapse_button()
          return false

        .on 'toggle:pack toggle:unpack', (event) ->
          icon = $(event.target).parent().children('.fa')
          for icon_set in ICON_SETS
            class_names = _(icon_set).map((class_name) -> "." + class_name).join(', ')
            icon.filter(class_names).toggleClass(icon_set.join(' '))

  top_level_sections: () ->
    root_section = $('#cms-sidebar-content ul .cms-section ul:first', @element)
    root_section.children(TOGGLE_SELECTOR).children('ul')

  all_items_packed: () ->
    top_level_sections = @top_level_sections()
    packed_sections = top_level_sections.filter('.packed')

    return packed_sections.length == top_level_sections.length

  expand_collapse_all_button: () ->
    @element.find(TOGGLE_ALL_BUTTON_SELECTOR)

  update_expand_collapse_button: (all_packed = @all_items_packed()) ->
    @expand_collapse_all_button().
      html(Sidebar.icon(if all_packed then 'plus-square-o' else 'minus-square-o'))

  fire_ajax: ->
    @ajax.abort() if @ajax
    @ajax = $.ajax('/p/admin/cms/templates/sidebar.json')
      .success (json) => @update(json)
      .error (xhr, status, error) ->
        console.error("#{xhr.status} #{error}")
        console.error(xhr.responseText)

  hook: (element) ->
    selector = @selector
    element = $(element)
    element.tipsy(live: "#{selector} li > a", gravity: $.fn.tipsy.autoWE)
    element
      .on 'cms-sidebar:update', (event) =>
        ThreeScale.Toggle.loadAndMarkPacked()
        @filter.filter()
        @tooltips()

        @update_expand_collapse_button()

        @items('[data-behavior~=drag]').draggable
          handle: ":not(.cms-section > i:first-child)"
          helper: (event) ->
            el = $(this)
            list = $('<ul>', class: 'cms-sidebar-listing').appendTo(selector)
            el.clone().width(el.width()).prependTo(list).addClass('dragged')[0]
          revert: 'invalid'

      .on 'pjax:end cms-sidebar:update', (event) =>
        @highlight(window.location.pathname)

      .on 'pjax:end', (event) ->
        $(event.target).trigger('cms-template:init')

      .on 'click', '#cms-sidebar .cms-sidebar-listing a', (event) =>
        $.pjax.click(event, '#tab-content')
      .on 'mouseenter mouseleave', '.cms-sidebar-listing li > a', (event) ->
        $(this).parent().toggleClass('ui-state-hover')


  highlight: (path) ->
    @element.find("a.#{HIGHLIGHT_CLASS}").removeClass(HIGHLIGHT_CLASS)
    @element.find("a[href='#{path}']").addClass(HIGHLIGHT_CLASS)

  content: ->
    @element.find('#cms-sidebar-content')

  layouts: ->
    @element.find('#cms-sidebar-layouts')

  partials: ->
    @element.find('#cms-sidebar-partials')

  portlets: ->
    @element.find('#cms-sidebar-portlets')

  listings: ->
    @element.find('.cms-sidebar-listing')

  items: (filter) ->
    items = @listings().find('li')
    if filter? then items.filter(filter) else items

  update: (json) ->
    @groups = @group(json)
    @json = json

    content = @render_content(json.root.section)
    layouts = @render_layouts(@json.layouts)
    partials = @render_partials(@json.partials)
    portlets = @render_portlets(@json.portlets)

    $ =>

      @content().html(content)
      @layouts().html(layouts)
      @partials().html(partials)
      @portlets().html(portlets)

      @element.trigger('cms-sidebar:update')

  tooltips: ->
    @items('[title]').tipsy(gravity: $.fn.tipsy.autoWE);

  group: (json) ->
    section_id = (p) -> p.section_id
    parent_id = (s) -> s.parent_id

    {
      sections: _(json.sections).groupBy(parent_id),
      pages: _(json.pages).groupBy(section_id),
      files: _(json.files).groupBy(section_id),
      builtins: _(json.builtins).groupBy(section_id)
    }

  render_layouts: (layouts) =>
    data = {
      layouts: @json.layouts
    }

    @template.layouts(data)

  render_portlets: (portlets) =>
    data =
      portlets: @json.portlets

    @template.portlets(data)

  render_partials: (partials) =>
    data =
      partials: @json.partials

    @template.partials(data)


  render_content: (section) =>
    section_id = section.id

    data = {
      section: section,

      sections: @groups.sections[section_id],
      pages: @groups.pages[section_id],
      files: @groups.files[section_id],
      builtins: @groups.builtins[section_id],

      render: @.render_content
    }

    all = _.union(data.sections || [], data.pages || [], data.files || [], data.builtins || [])
    section.empty = _(all).isEmpty()

    if section.parent_id || section.rendered
      @template.content(data)
    else
      section.rendered = true
      @template.root(data)

  @html = (element) ->
    element.clone().wrap('<div>').parent().html()

  @link_to = (text, path, title = text) ->
    title = " " if title is null
    title = title.join(' ') unless typeof(title) == 'string'
    Sidebar.html($('<a>', text: text, href: path, title: title))

  @icon = (icon, text) ->
    text = if text? then " " + text else ''
    Sidebar.html($('<i>', class: "fa fa-#{icon} fa-fw")) + text

  @icon_link_to = (icon, text, path, title = text) ->
    icon = Sidebar.icon(icon)
    link = Sidebar.link_to(text, path, title)

    Sidebar.html($(link).prepend(icon + ' '))

  @search = (item) ->
    """ data-search="#{item.search.string}" data-type="#{item.search.type}" data-origin="#{item.search.origin}" """

class SidebarToolbar
  ACTIVE = 'active'

  constructor: (@filter) ->
    $(document).on 'click', '[data-filter-type]', @process_type
    $(document).on 'click', '[data-filter-origin]', @process_origin

    $ =>
      types = @filter.status.types
      types = ['all'] if !types || types?.length == 0

      for type in types
        $("[data-filter-type=#{type}]").addClass(ACTIVE)

      if origin = @filter.status.origin || 'own'
        $("[data-filter-origin=#{origin}]").addClass(ACTIVE)

  process_type: (event) =>
    element = $(event.currentTarget)
    type = element.data('filter-type')
    items = element.siblings()
    all = items.filter('[data-filter-type=all]')

    if @filter.type(type)
      element.toggleClass(ACTIVE)
      all.removeClass(ACTIVE)
    else
      items.removeClass(ACTIVE)

      if element.data('filter-type') == 'all'
        element.addClass(ACTIVE)
      else
        element.removeClass(ACTIVE)
        all.addClass(ACTIVE)


  process_origin: (event) =>
    element = $(event.currentTarget)
    origin = element.data('filter-origin')
    @filter.origin(origin)
    element.addClass('active').siblings().removeClass('active')

class SidebarFilter
  CMS_FILTER_COOKIE_NAME = 'cms-filter-string'
  INPUT = '#cms-filter input'
  ALL = 'all'

  @serialized_status: ->
    $.cookie(CMS_FILTER_COOKIE_NAME, path: '/') || '{}'

  @load: ->
    @status ||= JSON.parse(@serialized_status())

  @save: (status) ->
    @status = status
    json = JSON.stringify(status)
    $.cookie(CMS_FILTER_COOKIE_NAME, json, {expires: 30, path: '/'})

  constructor: (@sidebar) ->
    @status = SidebarFilter.load()
    @toolbar = new SidebarToolbar(this)

    $(document).on 'keyup change search click', INPUT, (event) =>
      text = event.currentTarget.value
      @search(text)

    if query = @status.query
      $ => $(INPUT).val(query)


  save: ->
    SidebarFilter.save(@status)

  filter: ->
    items = @sidebar.items('[data-behavior~="search"]')
    items.removeClass('matched not-matched')

    matched = items

    if query = @status.query
      matched = matched.filter(":like(#{query})")

    types = for type in @status.types || []
      matched.filter("[data-type~=#{type}]").toArray()
    if types.length > 0
      matched = $(_(matched.toArray()).intersection(_.union types...))

    if origin = @status.origin
      matched = matched.filter("[data-origin~=#{origin}]")

    matched.show().addClass('matched')

    not_matched = _(items.toArray()).difference(matched.toArray())
    $(not_matched).hide().addClass('not-matched')

    items.filter('.cms-section:has(.matched)').show()

    listings = @sidebar.listings().removeClass('empty')
    listings.filter(':not(:has(.matched))').addClass('empty')

  type: (type) ->
    types = @status.types ||= []
    index = types.indexOf(type)

    if type == ALL
      types = []
    else if index >= 0
      types.splice(index, 1)
    else
      types.push(type)

    @status.types = types

    @filter()
    @save()

    types.length > 0

  origin: (origin) ->
    origin = null if origin == ALL

    @status.origin = origin

    @filter()
    @save()

  search: (string) ->
    if string == ""
      delete @status.query
    else
      @status.query = string

    @filter()
    @save()

class SidebarTemplates
  @root = """
          <style>
            html {
              // So that the the scrollbar does not
              // turn on/off while filtering.
              overflow: -moz-scrollbars-vertical;
              overflow-y: scroll;
            }
          </style>

          <ul>
            <li class="cms-section" data-behavior="toggle search">
              <span id="cms-sidebar-collapse-all" class="collapse-button"><i class="folder-open-o fa-fw"></i></span>
              <%= link_to(section.title, section.edit_path) %>
              <%= render(section) %>
            </li>
            <li class="no-results">No Content Found</li>
          </ul>
          """
  @content = """
          <ul id="cms-sidebar-section-<%= section.id %>">
            <% _.each(pages, function(page) { %>
              <li class="cms-page" data-id="<%= page.id %>" data-behavior="drag search" data-param="cms_page" <%= search(page) %>>
                <%= icon_link_to('file-o', page.title, page.edit_path, [ page.path, '(' + page.title + ')' ]) %>
              </li>
            <% }); %>

            <% _.each(files, function(file) { %>
              <li class="cms-file" data-id="<%= file.id %>" data-behavior="drag search" data-param="cms_file" <%= search(file) %>>
                <%= icon_link_to('paperclip', file.attachment_file_name, file.edit_path) %>
              </li>
            <% }); %>

            <% _.each(builtins, function(builtin) { %>
              <li class="cms-builtin" data-id="<%= builtin.id %>" data-behavior="drag search" data-param="cms_builtin" <%= search(builtin) %>>
                <%= icon_link_to('cog', builtin.title, builtin.edit_path) %>
              </li>
            <% }); %>

            <% _.each(sections, function(section){ %>
              <li class="cms-section"  data-id="<%= section.id %>" data-behavior="toggle drag search" data-param="cms_section" <%= search(section) %>>
                <%= icon('folder-open-o fa-fw') %>
                <%= link_to(section.title, section.edit_path) %>
                <%= render(section) %>
              </li>
            <% });  %>
          </ul>
             """
  @layouts = """
             <h3>Layouts</h3>
             <ul>
              <% _.each(layouts, function(layout) { %>
                <li <%= search(layout) %> data-behavior="search">
                  <%= icon_link_to('code', layout.title, layout.edit_path) %>
                 </li>
              <% }); %>
              <% if(_.isEmpty(layouts)) { %><li data-behavior="search">No Layouts</li><% }; %>
              <li class="no-results">No Layouts Found</li>
             </ul>
             """

  @portlets = """
              <h3>Portlets</h3>
              <ul>
                <% _.each(portlets, function(portlet) { %>
                  <li <%= search(portlet) %>>
                    <%= icon_link_to('rocket', portlet.title, portlet.edit_path) %>
                  </li>
                <% }); %>
                <% if(_.isEmpty(portlets)) { %><li data-behavior="search">No Portlets</li><% }; %>
                <li class="no-results">No Portlets Found</li>
              </ul>

              """
  @partials = """
              <h3>Partials</h3>
              <ul>
                <% _.each(partials, function(partial) { %>
                  <li <%= search(partial) %> data-behavior="search">
                    <%= icon_link_to('puzzle-piece', partial.system_name, partial.edit_path) %>
                  </li>
                <% }); %>
                <% if(_.isEmpty(partials)) { %><li data-behavior="search">No Partials</li><% }; %>
                <li class="no-results">No Partials Found</li>
              </ul>
              """

  @helpers: (template) ->

    helpers =
      link_to: Sidebar.link_to,
      icon: Sidebar.icon,
      icon_link_to: Sidebar.icon_link_to
      search: Sidebar.search

    (data) ->
      $.extend(data, helpers)
      template(data)

  @template: (source) ->
    @helpers _.template(source)

  content: @template(@content)
  root: @template(@root)
  layouts: @template(@layouts)
  portlets: @template(@portlets)
  partials: @template(@partials)


## Exporting variables
window.ThreeScale.Sidebar = Sidebar
