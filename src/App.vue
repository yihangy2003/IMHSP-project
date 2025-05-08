<template>
  <el-container>
      <router-view></router-view>
  </el-container>
</template>

<script setup lang="ts">
import { onMounted } from 'vue'
import { useRouter } from 'vue-router'
import eventBus from '@/utils/eventBus'

const router = useRouter()

onMounted(() => {
  // 监听未授权事件
  eventBus.on('unauthorized', (code) => {
    // 跳转到登录页
    router.push('/login')
  })

  // 监听禁止访问事件
  eventBus.on('forbidden', (code) => {
    // 跳转到无权限页面
    router.push('/403')
  })

  // 监听错误事件
  eventBus.on('error', (code) => {
    // 根据不同的错误码处理
    switch (code) {
      case 500:
        router.push('/500')
        break
      // 其他错误码处理...
    }
  })
})
</script>

<style>
#app {
  font-family: Avenir, Helvetica, Arial, sans-serif;
  -webkit-font-smoothing: antialiased;
  -moz-osx-font-smoothing: grayscale;
}
</style>