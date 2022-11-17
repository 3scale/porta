/**
 * This extension replaces all 'expression' from the quickstart HTML with a link made from 'href' and 'text'.
 */

interface IMarkdownExtension {
  type: string;
  filter: (html: string) => string;
}

const replaceLinksExtension = (links: string[][]): IMarkdownExtension => ({
  type: 'output',
  filter: (html) => {
    const filteredHtml = links.reduce((_html, link) => {
      const [expression, href, text] = link
      return _html.replace(expression, `<a href="${href}">${text}</a>`)
    }, html)

    return filteredHtml
  }
})

export default replaceLinksExtension
