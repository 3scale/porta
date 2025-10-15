type PaginatedCollection<T = unknown> = Record<number, T[] | undefined>

/**
 * TODO: replace paginateCollection
 */
class ModalTableCollection<T = unknown> {
  // eslint-disable-next-line @typescript-eslint/naming-convention
  private readonly PER_PAGE = 5
  private paginatedCollection: PaginatedCollection<T>

  public constructor (items: T[]) {
    this.paginatedCollection = this.paginate(items)
  }

  public get (pageNumber: number): T[] | undefined {
    return this.paginatedCollection[pageNumber]
  }

  public set (pageNumber: number, items: T[]): T[] | undefined {
    return this.paginatedCollection[pageNumber] = items
  }

  public isPageEmpty (pageNumber: number): boolean {
    const items = this.get(pageNumber)

    return items === undefined || items.length === 0
  }

  public clear (): void {
    this.paginatedCollection = {}
  }

  private paginate (items: T[]): PaginatedCollection<T> {
    const pageDictionary: PaginatedCollection<T> = {}
    const pageCount = Math.ceil(items.length / this.PER_PAGE)

    for (let currentPage = 1; currentPage <= pageCount; currentPage++) {
      const startIndex = (currentPage - 1) * this.PER_PAGE
      const endIndex = currentPage * this.PER_PAGE
      pageDictionary[currentPage] = items.slice(startIndex, endIndex)
    }

    return pageDictionary
  }
}

export { ModalTableCollection }
