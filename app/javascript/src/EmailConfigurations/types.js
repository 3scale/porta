// @flow

export type EmailConfiguration = {
  id: number,
  email: string,
  userName: string,
  links: {
    edit: string,
  }
}

export type FormEmailConfiguration = {
  email: string | null,
  userName: string | null,
  password: string | null
}

export type FormErrors = {
  user_name: string[],
  email: string[],
  password: string[]
}
