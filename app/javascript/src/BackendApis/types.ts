interface ProductLink {
  name: 'Analytics' | 'Edit' | 'Mapping Rules' | 'Methods and Metrics' | 'Overview';
  path: string;
}

export interface Backend {
  id: number;
  name: string;
  systemName: string;
  privateEndpoint: string;
  updatedAt: string;
  links: ProductLink[];
  productsCount: number;
}
