import type {Method} from 'utilities/ajax';

export * from 'Types/Api';
export * from 'Types/NavigationTypes';
export * from 'Types/FlashMessages';
export * from 'Types/Signup';

export type Record = {
  id: number,
  name: string
};

export type Action = {
  title: string,
  path: string,
  method: Method
};

export type Plan = Record & {
  contracts: number,
  state: string,
  actions: Action[],
  editPath: string,
  contractsPath: string
};

export type Product = Record & {
  systemName: string,
  path?: string,
  appPlans: Record[]
};

export type Backend = Record & {
  systemName: string,
  description?: string,
  privateEndpoint: string
};

export type Metric = Record & {
  systemName: string,
  path?: string,
  unit?: string,
  description?: string,
  mapped?: boolean,
  updatedAt: string
};

export type FieldDefinition = {
  hidden: boolean,
  required: boolean,
  label: string,
  name: string,
  id: string,
  choices?: string[],
  hint?: string,
  readOnly: boolean,
  type: 'extra' | 'internal' | 'builtin'
};
