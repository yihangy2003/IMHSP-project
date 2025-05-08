export const API_BASE_URL = import.meta.env.VITE_API_URL || 'http://localhost:9000'

export const API_TIMEOUT = 5000

export enum ContentType {
  JSON = 'application/json;charset=UTF-8',
  FORM = 'application/x-www-form-urlencoded;charset=UTF-8',
  MULTIPART = 'multipart/form-data'
}

export enum ErrorCode {
  SUCCESS = 200,
  UNAUTHORIZED = 401,
  TOKEN_EXPIRED = 402,
  FORBIDDEN = 403,
  NOT_FOUND = 404,
  INTERNAL_ERROR = 500
}