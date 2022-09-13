/**
 * This extension replaces all 'expression' from the quickstart HTML with a link made from 'href' and 'text'.
 */
const replaceLinksExtension = (links: Array<[string, string, string]>): {
  filter: (arg1: string) => string
} => ({
  type: 'output',
  filter: (html: string): string => {
    const filteredHtml = links.reduce((_html, link) => {
      const [expression, href, text] = link
      return _html.replace(expression, `<a href="${href}">${text}</a>`)
    }, html)

    return filteredHtml
  }
})

export default replaceLinksExtension
