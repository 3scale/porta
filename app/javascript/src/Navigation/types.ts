export interface Item {
  id: string;
  title: string;
  path?: string;
  target?: string;
  itemOutOfDateConfig?: boolean;
}

export type Section = Item & {
  items?: Item[];
  outOfDateConfig?: boolean;
}
