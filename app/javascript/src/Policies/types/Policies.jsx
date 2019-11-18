// @flow

// eslint-disable-next-line flowtype/no-weak-types
export type Configuration = Object

// Represents the data stored for @proxy.policies_config
export type PolicyConfig = {
  name: string,
  configuration: Configuration,
  version: string,
  enabled: boolean,
}

// Represents each of the items contained in the registry object
// returned by rails (@registry_policies)
export type RawRegistryPolicy = {
  $schema: string,
  configuration: Configuration,
  description: [string],
  name: string,
  summary: string,
  version: string
}

// Represents the registry object returned by the server (@registry_policies)
export type RawRegistry = { [string]: RawRegistryPolicy[] }

// Represents policies of the Registry
export type RegistryPolicy = RawRegistryPolicy & {
  data?: Configuration,
  humanName: string
}

// Represents policies stored in the Chain, once copied from the Registry
export type ChainPolicy = RegistryPolicy & {
  uuid: string,
  enabled: boolean,
  removable: boolean
}
