import axios from 'axios'
import type { AxiosInstance, AxiosRequestConfig, AxiosResponse, InternalAxiosRequestConfig } from 'axios'
import { ElMessage } from 'element-plus'
import { getToken, setToken, clearAuth } from '@/utils/auth'
import router from '@/router'
import eventBus from '@/utils/eventBus'

// 创建axios实例
const service: AxiosInstance = axios.create({
  baseURL: import.meta.env.VITE_API_URL,  // 确保 baseURL 正确
  timeout: 5000,
  headers: {
    'Content-Type': 'application/json'
  },
  withCredentials: true  // 允许携带认证信息
})

// 请求拦截器
service.interceptors.request.use(
  (config) => {
    const token = getToken()
    if (token) {
      config.headers['Authorization'] = `Bearer ${token}`  // 确保 token 正确添加
    }
    return config
  },
  (error) => {
    return Promise.reject(error)
  }
)

// 响应拦截器
service.interceptors.response.use(
  (response: AxiosResponse) => {
    const { code, message, data } = response.data
    
    if(code == 200){
        ElMessage.success(message)
    }else{
        ElMessage.error(message)
    }

    return response.data
  },
  (error) => {
    if (error.response) {
      switch (error.response.status) {
        case 401:
          ElMessage.error('请先登录');
          router.push('/login');
          break;
        case 403:
          ElMessage.error('没有权限访问');
          break;
        default:
          ElMessage.error(error.message || '网络错误');
      }
    } else {
      ElMessage.error(error.message || '网络错误');
    }
    return Promise.reject(error)
  }
)

// 封装HTTP方法
export const http = {
  get<T = any>(url: string, params?: any): Promise<T> {
    return service.get(url, { params })
  },

  post<T = any>(url: string, data?: any): Promise<T> {
    return service.post(url, data)
  },

  put<T = any>(url: string, data?: any): Promise<T> {
    return service.put(url, data)
  },

  delete<T = any>(url: string): Promise<T> {
    return service.delete(url)
  }
}

// 导出实例和工具方法
export default {
  service,
  http
}