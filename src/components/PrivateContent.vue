<template>
  <div class="private-content">
    <el-icon class="lock-icon"><Lock /></el-icon>
    <h3>私密内容</h3>
    <p>{{ message }}</p>
  </div>
</template>

<script setup lang="ts">
import { Lock } from '@element-plus/icons-vue'

defineProps<{
  message: string
}>()
</script>

<style scoped>
.private-content {
  display: flex;
  flex-direction: column;
  align-items: center;
  justify-content: center;
  padding: 40px;
  text-align: center;
  background-color: #f5f7fa;
  border-radius: 8px;
  min-height: 200px;
}

.lock-icon {
  font-size: 48px;
  color: #909399;
  margin-bottom: 16px;
}

h3 {
  margin: 0 0 8px;
  font-size: 18px;
  color: #606266;
}

p {
  margin: 0;
  color: #909399;
  font-size: 14px;
}
</style> 