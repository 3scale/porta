export interface EmailConfiguration {
  id: number;
  email: string;
  userName: string;
  updatedAt: string;
  links: {
    edit: string;
  };
}

export interface FormEmailConfiguration {
  id?: number; // If present it means updating. If not, creating.
  email: string | null;
  userName: string | null;
  password: string | null;
}

export interface FormErrors {
  // eslint-disable-next-line @typescript-eslint/naming-convention -- Comes from rails like that
  user_name?: string[];
  email?: string[];
  password?: string[];
}
