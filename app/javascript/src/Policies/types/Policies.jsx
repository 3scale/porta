// @flow

export type RawPolicy = {
  $schema: string,
  name: string,
  version: string,
  description: string,
  summary: string,
  configuration: Object
}

export type RawRegistry = {
  [string]: Array<RawPolicy>
}

export type RegistryPolicy = & RawPolicy & {
  humanName: string,
  schema: Object
}

export type ChainPolicy = & RegistryPolicy & {
  enabled: boolean,
  removable: boolean,
  uuid: string
}

export type StoredChainPolicy = {
  name: string,
  version: string,
  configuration: Object,
  enabled: boolean
}
