export type ArgumentsType<T extends (...args: any[]) => any> =
  T extends (...args: infer A) => any ? A : never;

export interface IDeveloperAccount {
  admin_name: string,
  apps_count: number
  created_at: string, // TODO: Find a specific date as string type
  id: number,
  org_name: string,
  state: string,
  plan?: string,
  updated_at: string,
}
