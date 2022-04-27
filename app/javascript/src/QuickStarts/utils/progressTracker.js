// @flow

/**
 * This is a collection of wrappers around localStorage to ease getting information about Quickstarts state
 */

function getActiveQuickstart (): null | string {
  // $FlowIgnore[incompatible-type] getItem returns string null
  const data: null | string = localStorage.getItem('quickstartId')
  return (data && data.length && JSON.parse(data)) || null
}

export { getActiveQuickstart }
