import * as React from 'react';

export type ServiceFormTemplate = {
  service: {
    name: string,
    system_name: string,
    description: string
  },
  errors: {
    name?: string[],
    system_name?: string[],
    description?: string[]
  }
};

export type FormProps = {
  id: string,
  formActionPath: string,
  hasHiddenServiceDiscoveryInput?: boolean,
  submitText: string,
  children?: React.ReactNode
};
