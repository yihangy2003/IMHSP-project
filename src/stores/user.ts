import { defineStore } from 'pinia'
import type { UserInfo } from '@/types/user'
import { auth } from '@/api/auth'
import { getToken, removeToken, setToken } from '@/utils/auth'

interface UserState {
  userInfo: UserInfo | null
  token: string | null
}

export const useUserStore = defineStore('user', {
  state: (): UserState => ({
    userInfo: null,
    token: null
  }),

  actions: {
    setUserInfo(userInfo: UserInfo) {
      this.userInfo = userInfo
    },
    
    setToken(token: string) {
      this.token = token
      setToken(token)
    },
    
    async logout() {
      try {
        await auth.logout()
      } finally {
        this.userInfo = null
        this.token = null
        removeToken()
      }
    },

    // 清除所有状态
    $reset() {
      this.userInfo = null
      this.token = null
      removeToken()
    }
  },
  
  persist: true
})