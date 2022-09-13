function paginateCollection<T> (items: T[], perPage: number): {
  [key: number]: T[]
} {
  const pageCount = Math.ceil(items.length / perPage)
  const _pageDictionary: Record<string, any> = {}
  for (let currentPage = 1; currentPage <= pageCount; currentPage++) {
    _pageDictionary[currentPage] = items.slice((currentPage - 1) * perPage, currentPage * perPage)
  }
  return _pageDictionary
}

export { paginateCollection }
