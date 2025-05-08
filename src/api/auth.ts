import { http } from '@/utils/request'
import type { LoginRequest, RegisterRequest } from '@/types/auth'
import { getToken } from '@/utils/auth'

export const auth = {
    // 登录
    login(data: LoginRequest) {
        return http.post('/auth/login', data)
    },

    // 注册
    register(data: RegisterRequest) {
        return http.post('/auth/register', data)
    },

    // 刷新token
    refreshToken(token: string) {
        return http.post('/auth/refresh', { token })
    },

    // 重置密码
    resetPassword(data: {
        username: string,
        verifyType: 'email' | 'phone',
        verifyValue: string,
        newPassword: string,
        confirmPassword: string
    }) {
        return http.post('/auth/resetPassword', data)
    },

    // 登出
    logout() {
        const token = getToken()
        if (token) {
            return http.post('/auth/logout', { token })
        }
        return Promise.resolve()
    }
} 