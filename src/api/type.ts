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
    id: number
    username: string
    avatar?: string
    roles: string[]
    permissions: string[]
  }
  
  export interface PageParams {
    page: number
    pageSize: number
  }
  
  export interface PageResult<T> {
    list: T[]
    total: number
  }