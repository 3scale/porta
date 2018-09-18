import * as migrate from 'services/migrate'

describe('Services migrate', () => {

  beforeEach(() => {
    document.cookie = 'cms-toggle-ids=; path=/; expires=Thu, 21 Sep 1979 00:00:01 UTC;'
    localStorage.clear()
    let basicStructure = `
      <div id='widget_1' class='u-legacy-cookie service-widget is-closed'>
        <article>
          <p id='title_1' class='title-toggle'>Title</p>
          <button class='button-to edit'>Edit</button>
          <div id='service_1' class='content-service'>Article</div>
        </article>
      </div>
      <div id='widget_2' class='u-legacy-cookie service-widget is-closed'>
        <article>
          <p id='title_2' class='title-toggle'>Title</p>
          <button class='button-to edit'>Edit</button>
          <div id='service_2' class='content-service'>Article</div>
        </article>
      </div>`

    fixture.set(basicStructure)
  })

  it('migrates data to local storage', () => {
    expect(undefined).toEqual(localStorage['toggle:widget_2'])
    migrate.migrateDataToLocalStorage(['widget_1', 'widget_3'])
    expect('{"is-closed":false}').toEqual(localStorage['toggle:widget_2'])
  })

  it('migrates data only once', () => {
    document.cookie = `cms-toggle-ids=${JSON.stringify(['widget_1', 'widget_3'])}`
    migrate.migrate()
    expect('{"is-closed":false}').toEqual(localStorage['toggle:widget_2'])
    expect(undefined).toEqual(localStorage['toggle:widget_1'])
    document.cookie = `cms-toggle-ids=${JSON.stringify(['widget_17'])}`
    migrate.migrate()
    expect('{"is-closed":false}').toEqual(localStorage['toggle:widget_2'])
    expect(undefined).toEqual(localStorage['toggle:widget_1'])
  })
})
