// eslint-disable-next-line flowtype/no-weak-types
export type Configuration = any;

// Represents the data stored for @proxy.policies_config
export type PolicyConfig = {
  name: string,
  configuration: Configuration,
  version: string,
  enabled: boolean
};

// Represents policies of the Registry
export type RegistryPolicy = {
  $schema: string,
  configuration: Configuration,
  description: [string],
  name: string,
  summary: string,
  version: string,
  data?: Configuration,
  humanName: string
};

// Represents policies stored in the Chain, once copied from the Registry
export type ChainPolicy = RegistryPolicy & {
  uuid: string,
  enabled: boolean,
  removable: boolean
};
