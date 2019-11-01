// @flow

// eslint-disable-next-line flowtype/no-weak-types
export type Configuration = Object

export type RawPolicy = {
  $schema?: string,
  id: number,
  name: string,
  version: string,
  description?: string,
  summary?: string,
  configuration: Configuration
}

export type RawRegistry = {
  [string]: Array<RawPolicy>
}

export type RegistryPolicy = & RawPolicy & {
  humanName: string,
  data?: Configuration
}

export type ChainPolicy = & RegistryPolicy & {
  enabled: boolean,
  removable?: boolean,
  uuid?: string
}

export type StoredChainPolicy = {
  name: string,
  version: string,
  configuration: Configuration,
  enabled: boolean
}

export type ShallowPolicy = {
  id: number,
  version: string,
  humanName: string,
  summary?: string
}
export type Schema = {
  name: string,
  version: string,
  summary: string,
  description: string,
  configuration: Configuration
}
export type Policy = {
  id: number,
  schema: Schema,
  directory: string
}
