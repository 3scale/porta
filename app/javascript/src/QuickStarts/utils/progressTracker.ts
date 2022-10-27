/**
 * This is a collection of wrappers around localStorage to ease getting information about Quickstarts state
 */

function getActiveQuickstart (): string | null {
  const data = localStorage.getItem('quickstartId')
  // eslint-disable-next-line @typescript-eslint/no-unsafe-return
  return (data?.length && JSON.parse(data)) || null
  // return data?.length ? JSON.parse(data) as string : null
}

export { getActiveQuickstart }
