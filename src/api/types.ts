export interface ResponseData<T = any> {
  code: number
  data: T
  message: string
}

export interface LoginParams {
  username: string
  password: string
}

export interface UserInfo {
  id: string
  username: string
  password: string
  email: string
  phone: string
  roles: 'explorer' | 'healer' | 'admin'
  avatar?: string
}

export interface PageParams {
  page: number
  pageSize: number
}

export interface PageResult<T> {
  list: T[]
  total: number
}