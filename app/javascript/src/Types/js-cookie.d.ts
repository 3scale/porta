declare module 'js-cookie' {
  function get (key: string): string | undefined
  function set (key: string, value: string, opts: unknown): undefined
}
