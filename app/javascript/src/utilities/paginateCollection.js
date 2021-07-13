// @flow

function paginateCollection <T> (items: T[], perPage: number): {[number]: T[]} {
  const pageCount = Math.ceil(items.length / perPage)
  const _pageDictionary = {}
  for (let currentPage = 1; currentPage <= pageCount; currentPage++) {
    _pageDictionary[currentPage] = items.slice((currentPage - 1) * perPage, currentPage * perPage)
  }
  return _pageDictionary
}

export { paginateCollection }
