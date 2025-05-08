import request from '@/utils/request'
import type { ResponseData, PageParams, PageResult } from './types'

export interface DepartmentInfo {
  id: number
  name: string
  parentId: number
  order: number
  status: number
}

export function getDepartmentList(params: PageParams) {
  return request<ResponseData<PageResult<DepartmentInfo>>>({
    url: '/system/department/list',
    method: 'get',
    params
  })
}

export function addDepartment(data: Omit<DepartmentInfo, 'id'>) {
  return request<ResponseData>({
    url: '/system/department',
    method: 'post',
    data
  })
}