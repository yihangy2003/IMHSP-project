import request from '@/utils/request'
import type { LoginParams, UserInfo, ResponseData } from './types'

export function login(data: LoginParams) {
  return request<ResponseData<{ token: string }>>({
    url: '/auth/login',
    method: 'post',
    data
  })
}

export function getUserInfo() {
  return request<ResponseData<UserInfo>>({
    url: '/user/info',
    method: 'get'
  })
}

export function logout() {
  return request<ResponseData>({
    url: '/auth/logout',
    method: 'post'
  })
}

export function updatePassword(data: { oldPassword: string; newPassword: string }) {
  return request<ResponseData>({
    url: '/user/password',
    method: 'put',
    data
  })
}