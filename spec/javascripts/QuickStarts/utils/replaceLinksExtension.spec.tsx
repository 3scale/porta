import replaceLinksExtension from 'QuickStarts/utils/replaceLinksExtension'

const links = [
  ['[create-mapping-rule]', '/the/url', 'this page'],
  ['[click-me-link]', '/click/me', 'Click me!']
]

it('should work', () => {
  const html = `
    <h1>Create Mapping rules</h1>
    <p>
      You can add a new mapping rule at [create-mapping-rule].
    </p>

    <footer>[click-me-link]</footer>
  `
  const newHTML: string = replaceLinksExtension(links).filter(html)

  expect(newHTML).toMatch(`
    <h1>Create Mapping rules</h1>
    <p>
      You can add a new mapping rule at <a href="/the/url">this page</a>.
    </p>

    <footer><a href="/click/me">Click me!</a></footer>
  `)
})
