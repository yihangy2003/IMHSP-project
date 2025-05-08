<template>
  <div class="topic-detail">
    <div class="topic-header">
      <el-image :src="topic?.cover" fit="cover" class="topic-cover" />
      <div class="topic-info">
        <h1>{{ topic?.title }}</h1>
        <div class="topic-meta">
          <span class="author">作者：{{ topic?.author }}</span>
          <span class="stats">
            <el-icon><View /></el-icon>{{ topic?.views }}
            <el-icon><Heart /></el-icon>{{ topic?.likes }}
          </span>
          <el-tag :type="topic?.type === 'free' ? 'success' : 'warning'" size="small">
            {{ topic?.type === 'free' ? '免费' : `￥${topic?.price}` }}
          </el-tag>
        </div>
      </div>
    </div>
    
    <!-- 专题内容区域 -->
    <div class="topic-content">
      <!-- 这里可以添加专题的具体内容 -->
    </div>
  </div>
</template>

<script setup lang="ts">
import { ref, onMounted } from 'vue'
import { useRoute } from 'vue-router'
import { View, Heart } from '@element-plus/icons-vue'
import type { Topic } from '@/types/topic' // 我们稍后会创建这个类型文件

const route = useRoute()
const topic = ref<Topic>()

onMounted(() => {
  // 这里可以根据路由参数获取专题详情
  const topicId = route.params.id
  // TODO: 调用API获取专题详情
})
</script>

<style scoped>
.topic-detail {
  padding: 20px;
}

.topic-header {
  display: flex;
  gap: 24px;
  margin-bottom: 24px;
}

.topic-cover {
  width: 300px;
  height: 200px;
  border-radius: 8px;
}

.topic-info {
  flex: 1;
}

.topic-info h1 {
  margin: 0 0 16px;
  font-size: 24px;
  color: #303133;
}

.topic-meta {
  display: flex;
  align-items: center;
  gap: 24px;
  color: #909399;
  font-size: 14px;
}

.stats {
  display: flex;
  align-items: center;
  gap: 16px;
}

.stats .el-icon {
  margin-right: 4px;
}

.topic-content {
  margin-top: 24px;
  padding: 24px;
  background: #fff;
  border-radius: 8px;
  min-height: 400px;
}
</style> 