// @flow

export type RawPolicy = {
  $schema?: string,
  id: number,
  name: string,
  version: string,
  description?: string,
  summary?: string,
  configuration: Object
}

export type RawRegistry = {
  [string]: Array<RawPolicy>
}

export type RegistryPolicy = & RawPolicy & {
  humanName: string,
  data?: Object
}

export type ChainPolicy = & RegistryPolicy & {
  enabled: boolean,
  removable?: boolean,
  uuid?: string
}

export type StoredChainPolicy = {
  name: string,
  version: string,
  configuration: Object,
  enabled: boolean
}

export type ShallowPolicy = {
  id: number,
  version: string,
  humanName: string,
  summary?: string
}
export type Schema = Object
export type Policy = {
  id: number,
  schema: Schema,
  directory: string
}
