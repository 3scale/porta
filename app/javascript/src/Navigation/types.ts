export interface Item {
  id: string;
  title?: string;
  path?: string;
  target?: string;
  itemOutOfDateConfig?: boolean;
  subItems?: SubItem[];
}

export type Section = Omit<Item, 'subitems'> & {
  title: string;
  items?: Item[];
  outOfDateConfig?: boolean;
}

export type SubItem = Omit<Item, 'subitems'>
