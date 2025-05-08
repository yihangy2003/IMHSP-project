import type { PersistedStateOptions } from 'pinia-plugin-persistedstate'

/**
 * @description pinia 持久化参数配置
 * @param {String} key 存储到持久化的 name
 * @param {Array} paths 需要持久化的 state name
 * @param {Number} expires 过期时间，单位：天，默认7天
 * @return persist
 * */
const piniaPersistConfig = (key: string, paths?: string[], expires: number = 7) => {
  const persist: PersistedStateOptions = {
    enabled: true,
    strategies: [
      {
        key,
        storage: localStorage,
        paths,
        // 过期时间，转换为毫秒
        beforeRestore: ({ storage }) => {
          const storageData = storage.getItem(key)
          if (storageData) {
            const { timestamp } = JSON.parse(storageData)
            const now = Date.now()
            if (timestamp && now - timestamp > expires * 24 * 60 * 60 * 1000) {
              // 数据过期，清除存储
              storage.removeItem(key)
              return false
            }
          }
        },
        beforeSerialize: (data) => {
          // 存储时添加时间戳
          return {
            ...data,
            timestamp: Date.now()
          }
        }
      }
    ]
  }
  return persist
}

export default piniaPersistConfig 