type Dictionary<T> = Record<number, T[] | undefined>

function paginateCollection<T> (items: T[], perPage: number): Dictionary<T> {
  const pageDictionary: Dictionary<T> = {}
  if (perPage > 0) {
    const pageCount = Math.ceil(items.length / perPage)
    for (let currentPage = 1; currentPage <= pageCount; currentPage++) {
      pageDictionary[currentPage] = items.slice((currentPage - 1) * perPage, currentPage * perPage)
    }
  }
  return pageDictionary
}

export { paginateCollection }
