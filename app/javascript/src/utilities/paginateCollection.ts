type Dictionary<T> = Record<number, T[]>

function paginateCollection<T> (items: T[], perPage: number): Dictionary<T> {
  const _pageDictionary: Dictionary<T> = {}
  if (perPage > 0) {
    const pageCount = Math.ceil(items.length / perPage)
    for (let currentPage = 1; currentPage <= pageCount; currentPage++) {
      _pageDictionary[currentPage] = items.slice((currentPage - 1) * perPage, currentPage * perPage)
    }
  }
  return _pageDictionary
}

export { paginateCollection }
