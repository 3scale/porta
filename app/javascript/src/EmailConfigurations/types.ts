export type EmailConfiguration = {
  id: number,
  email: string,
  userName: string,
  updatedAt: string,
  links: {
    edit: string
  }
}

export type FormEmailConfiguration = {
  id?: number // Means it's updating not creating,
  email: string | null,
  userName: string | null,
  password: string | null
}

export type FormErrors = {
  // eslint-disable-next-line camelcase
  user_name?: string[],
  email?: string[],
  password?: string[]
}
