import type { Method } from 'utilities/ajax'

export * from 'Types/Api'
export * from 'Types/NavigationTypes'
export * from 'Types/FlashMessages'
export * from 'Types/Signup'

export interface IRecord {
  id: number | string;
  name: string;
}

export interface Action {
  title: string;
  path: string;
  method: Method;
}

export type Plan = IRecord & {
  contracts: number;
  state: string;
  actions: Action[];
  editPath: string;
  contractsPath: string;
}

export type Product = IRecord & {
  systemName: string;
  path?: string;
  appPlans: IRecord[];
}

export type Backend = IRecord & {
  systemName: string;
  description?: string;
  privateEndpoint: string;
  updatedAt: string;
}

export type Metric = IRecord & {
  systemName: string;
  path?: string;
  unit?: string;
  description?: string;
  mapped?: boolean;
  updatedAt: string;
}

export interface FieldDefinition {
  hidden: boolean;
  required: boolean;
  label: string;
  name: string;
  id: string;
  choices?: string[];
  hint?: string;
  readOnly: boolean;
  type: 'builtin' | 'extra' | 'internal';
}

export type ValidationErrors = Record<string, string[]> | undefined
