/**
 * highlight.js@7.5.0 doesn't have typings.
 * TODO: remove this once we update highlight
 */
declare module 'highlight.js' {
  function highlightBlock (block: HTMLElement): void
}
