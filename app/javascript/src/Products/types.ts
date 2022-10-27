interface ProductLink {
  name: 'ActiveDocs' | 'Analytics' | 'Applications' | 'Edit' | 'Integration' | 'Overview';
  path: string;
}

export interface Product {
  id: number;
  name: string;
  systemName: string;
  updatedAt: string;
  links: ProductLink[];
  appsCount: number;
  backendsCount: number;
  unreadAlertsCount: number;
}
