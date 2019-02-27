// flow-typed signature: aec7625772e55d1a614a208b09294bdd
// flow-typed version: 5150417741/enzyme_v3.x.x/flow_>=v0.53.x

declare module "enzyme" {
  declare type PredicateFunction<T: Wrapper> = (
    wrapper: T,
    index: number
  ) => boolean;
  declare type NodeOrNodes = React$Node | Array<React$Node>;
  declare type EnzymeSelector = string | Class<React$Component<*, *>> | {};

  // CheerioWrapper is a type alias for an actual cheerio instance
  // TODO: Reference correct type from cheerio's type declarations
  declare type CheerioWrapper = any;

  declare class Wrapper {
    find(selector: EnzymeSelector): Wrapper,
    findWhere(predicate: PredicateFunction<this>): Wrapper,
    filter(selector: EnzymeSelector): Wrapper,
    filterWhere(predicate: PredicateFunction<this>): Wrapper,
    hostNodes(): Wrapper,
    contains(nodeOrNodes: NodeOrNodes): boolean,
    containsMatchingElement(node: React$Node): boolean,
    containsAllMatchingElements(nodes: NodeOrNodes): boolean,
    containsAnyMatchingElements(nodes: NodeOrNodes): boolean,
    dive(option?: { context?: Object }): Wrapper,
    exists(selector?: EnzymeSelector): boolean,
    isEmptyRender(): boolean,
    matchesElement(node: React$Node): boolean,
    hasClass(className: string): boolean,
    is(selector: EnzymeSelector): boolean,
    isEmpty(): boolean,
    not(selector: EnzymeSelector): Wrapper,
    children(selector?: EnzymeSelector): Wrapper,
    childAt(index: number): Wrapper,
    parents(selector?: EnzymeSelector): Wrapper,
    parent(): Wrapper,
    closest(selector: EnzymeSelector): Wrapper,
    render(): CheerioWrapper,
    renderProp(propName: string): (...args: Array<any>) => Wrapper,
    unmount(): Wrapper,
    text(): string,
    html(): string,
    get(index: number): React$Node,
    getDOMNode(): HTMLElement | HTMLInputElement,
    at(index: number): Wrapper,
    first(): Wrapper,
    last(): Wrapper,
    state(key?: string): any,
    context(key?: string): any,
    props(): Object,
    prop(key: string): any,
    key(): string,
    simulate(event: string, ...args: Array<any>): Wrapper,
    slice(begin?: number, end?: number): Wrapper,
    setState(state: {}, callback?: () => void): Wrapper,
    setProps(props: {}, callback?: () => void): Wrapper,
    setContext(context: Object): Wrapper,
    instance(): React$Component<*, *>,
    update(): Wrapper,
    debug(options?: Object): string,
    type(): string | Function | null,
    name(): string,
    forEach(fn: (node: Wrapper, index: number) => mixed): Wrapper,
    map<T>(fn: (node: Wrapper, index: number) => T): Array<T>,
    reduce<T>(
      fn: (value: T, node: Wrapper, index: number) => T,
      initialValue?: T
    ): Array<T>,
    reduceRight<T>(
      fn: (value: T, node: Wrapper, index: number) => T,
      initialValue?: T
    ): Array<T>,
    some(selector: EnzymeSelector): boolean,
    someWhere(predicate: PredicateFunction<this>): boolean,
    every(selector: EnzymeSelector): boolean,
    everyWhere(predicate: PredicateFunction<this>): boolean,
    length: number
  }

  declare class ReactWrapper extends Wrapper {
    constructor(nodes: NodeOrNodes, root: any, options?: ?Object): ReactWrapper,
    mount(): ReactWrapper,
    ref(refName: string): ReactWrapper,
    detach(): void
  }

  declare class ShallowWrapper extends Wrapper {
    constructor(
      nodes: NodeOrNodes,
      root: any,
      options?: ?Object
    ): ShallowWrapper,
    equals(node: React$Node): boolean,
    shallow(options?: { context?: Object }): ShallowWrapper,
    getElement(): React$Node,
    getElements(): Array<React$Node>
  }

  declare function shallow(
    node: React$Node,
    options?: { context?: Object, disableLifecycleMethods?: boolean }
  ): ShallowWrapper;
  declare function mount(
    node: React$Node,
    options?: {
      context?: Object,
      attachTo?: HTMLElement,
      childContextTypes?: Object
    }
  ): ReactWrapper;
  declare function render(
    node: React$Node,
    options?: { context?: Object }
  ): CheerioWrapper;

  declare module.exports: {
    configure(options: {
      Adapter?: any,
      disableLifecycleMethods?: boolean
    }): void,
    render: typeof render,
    mount: typeof mount,
    shallow: typeof shallow,
    ShallowWrapper: typeof ShallowWrapper,
    ReactWrapper: typeof ReactWrapper
  };
}
