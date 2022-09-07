import * as React from 'react';

export type FieldGroupProps = {
  name: string,
  value: string,
  label: string,
  children?: React.ReactNode,
  legend?: string,
  checked?: string,
  hint?: string,
  placeholder?: string,
  defaultValue?: string,
  readOnly?: boolean,
  inputType?: string,
  isDefaultValue?: boolean,
  onChange?: (value: string, event: React.SyntheticEvent<HTMLButtonElement>) => void
};

export type FieldCatalogProps = {
  catalog: {
    [key: string]: string
  }
};

export type TypeItemProps = {
  type: FieldGroupProps & FieldCatalogProps,
  item: FieldGroupProps
};

export type LegendCollectionProps = {
  legend: string,
  collection: FieldGroupProps[]
};

export type SettingsProps = {
  isProxyCustomUrlActive: boolean,
  integrationMethod: FieldGroupProps & FieldCatalogProps,
  authenticationMethod: FieldGroupProps & FieldCatalogProps,
  proxyEndpoints: FieldGroupProps[],
  authenticationSettings: {
    appIdKeyPairSettings: FieldGroupProps[],
    apiKeySettings: FieldGroupProps,
    oidcSettings: {
      basicSettings: TypeItemProps,
      flowSettings: FieldGroupProps[],
      jwtSettings: TypeItemProps
    }
  },
  credentialsLocation: FieldGroupProps & FieldCatalogProps,
  security: FieldGroupProps[],
  gatewayResponse: LegendCollectionProps[]
};
