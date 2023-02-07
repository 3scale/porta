export interface ServiceFormTemplate {
  service: {
    name: string;
    // eslint-disable-next-line @typescript-eslint/naming-convention -- Comes from rails like that
    system_name: string;
    description: string;
  };
  errors: {
    name?: string[];
    // eslint-disable-next-line @typescript-eslint/naming-convention -- Comes from rails like that
    system_name?: string[];
    description?: string[];
  };
}

export interface FormProps {
  id: string;
  formActionPath: string;
  hasHiddenServiceDiscoveryInput?: boolean;
  submitText: string;
  children?: React.ReactNode;
}
