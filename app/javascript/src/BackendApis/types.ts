type ProductLink = {
  name: 'Edit' | 'Overview' | 'Analytics' | 'Methods and Metrics' | 'Mapping Rules',
  path: string
};

export type Backend = {
  id: number,
  name: string,
  systemName: string,
  privateEndpoint: string,
  updatedAt: string,
  links: Array<ProductLink>,
  productsCount: number
};
