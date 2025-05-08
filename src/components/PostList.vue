<template>
  <div class="post-list">
    <el-card v-for="post in posts" :key="post.id" class="post-card">
      <!-- 帖子头部 -->
      <div class="post-header">
        <div class="author-info">
          <el-avatar :size="40" :src="post.author.avatar" />
          <div class="author-text">
            <h3>{{ post.author.username }}</h3>
            <span class="post-time">{{ formatTime(post.createTime) }}</span>
          </div>
        </div>
        
        <!-- 添加查看详情按钮 -->
        <el-button 
          type="primary" 
          link 
          @click="viewDetail(post.id)"
        >
          查看详情
        </el-button>
      </div>

      <!-- 帖子内容，限制显示长度 -->
      <div class="post-content">
        <h2 class="post-title">{{ post.title }}</h2>
        <p class="post-text">{{ truncateText(post.content) }}</p>
        
        <!-- 如果内容被截断，显示展开提示 -->
        <span v-if="post.content.length > 100" class="expand-hint">
          点击查看详情查看完整内容...
        </span>
      </div>

      <!-- ... 其他内容保持不变 ... -->
    </el-card>
  </div>
</template>

<script setup lang="ts">
import { useRouter } from 'vue-router'

const router = useRouter()

// 截断文本
const truncateText = (text: string, limit = 100) => {
  if (text.length <= limit) return text
  return text.slice(0, limit) + '...'
}

// 查看详情
const viewDetail = (postId: string | number) => {
  router.push(`/post/${postId}`)
}
</script>

<style scoped>
/* ... 其他样式保持不变 ... */

.expand-hint {
  color: #909399;
  font-size: 14px;
  margin-top: 8px;
  display: block;
}

.post-text {
  margin: 12px 0;
  line-height: 1.6;
  color: #606266;
}
</style> 