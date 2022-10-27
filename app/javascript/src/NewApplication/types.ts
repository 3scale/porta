export interface Plan {
  id: number;
  name: string;
}

export interface Product {
  id: number;
  name: string;
  systemName: string;
  updatedAt: string;
  appPlans: Plan[];
  servicePlans: Plan[];
  defaultAppPlan: Plan | null;
  defaultServicePlan: Plan | null;
}

export interface ContractedProduct {
  id: number;
  name: string;
  withPlan: Plan;
}

export interface Buyer {
  id: number;
  name: string;
  admin: string;
  createdAt: string;
  contractedProducts: ContractedProduct[];
  createApplicationPath: string;
  multipleAppsAllowed?: boolean;
}
