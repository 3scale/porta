import { IPlan } from 'types/Plan'

export interface IApplication {
  name: string;
  state: string;
  account: string;
  plan: IPlan;
  created_at: number;
}
