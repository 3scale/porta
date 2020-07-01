export type ArgumentsType<T extends (...args: any[]) => any> =
  T extends (...args: infer A) => any ? A : never;

export type State = 'approved' | 'live' | 'rejected' | 'pending' | 'suspended'
