import { defineStore } from 'pinia'

export const useNavStore = defineStore('nav', {
  state: () => ({
    activeMenu: '/home'
  }),
  actions: {
    setActiveMenu(path: string) {
      this.activeMenu = path
    }
  },
  persist: true
}) 