<template>
  <div class="post-detail">
    <el-card class="post-card">
      <!-- 帖子头部 -->
      <div class="post-header">
        <div class="author-info">
          <el-avatar :size="40" :src="post.author.avatar" />
          <div class="author-text">
            <h3>{{ post.author.username }}</h3>
            <span class="post-time">{{ formatTime(post.createTime) }}</span>
          </div>
        </div>
      </div>

      <!-- 帖子内容 -->
      <div class="post-content">
        <h2 class="post-title">{{ post.title }}</h2>
        <p class="post-text">{{ post.content }}</p>
        
        <!-- 帖子图片 -->
        <div v-if="post.images?.length" class="post-images">
          <el-image
            v-for="(img, index) in post.images"
            :key="index"
            :src="img"
            :preview-src-list="post.images"
          />
        </div>
      </div>

      <!-- 帖子底部 -->
      <div class="post-footer">
        <div class="post-stats">
          <span class="stat-item">
            <el-icon><View /></el-icon>
            {{ post.viewCount }}
          </span>
          <span class="stat-item">
            <el-icon><ChatRound /></el-icon>
            {{ post.commentCount }}
          </span>
          <span class="stat-item">
            <el-icon><Star /></el-icon>
            {{ post.starCount }}
          </span>
        </div>
      </div>

      <!-- 评论区 -->
      <div class="comments-section">
        <h3>评论 ({{ post.commentCount }})</h3>
        <!-- 评论列表 -->
        <div class="comments-list">
          <!-- ... 评论组件 ... -->
        </div>
      </div>
    </el-card>
  </div>
</template>

<script setup lang="ts">
import { ref, onMounted } from 'vue'
import { useRoute } from 'vue-router'
import { formatTime } from '@/utils/format'

const route = useRoute()
const postId = route.params.id

// 模拟帖子数据
const post = ref({
  id: postId,
  title: '分享一些缓解焦虑的小技巧',
  content: '最近学习到了一些很有效的缓解焦虑的方法，希望能帮助到大家...',
  author: {
    username: '心理探索者',
    avatar: ''
  },
  createTime: new Date(),
  viewCount: 156,
  commentCount: 23,
  starCount: 45,
  images: []
})

onMounted(() => {
  // TODO: 获取帖子详情
})
</script>

<style scoped>
.post-detail {
  max-width: 800px;
  margin: 20px auto;
  padding: 0 20px;
}

.post-card {
  border-radius: 8px;
}

.post-header {
  display: flex;
  justify-content: space-between;
  align-items: center;
  margin-bottom: 20px;
}

.author-info {
  display: flex;
  align-items: center;
  gap: 12px;
}

.author-text h3 {
  margin: 0;
  font-size: 16px;
  color: #303133;
}

.post-time {
  font-size: 12px;
  color: #909399;
}

.post-content {
  margin-bottom: 24px;
}

.post-title {
  margin: 0 0 16px;
  font-size: 24px;
  color: #303133;
}

.post-text {
  font-size: 16px;
  line-height: 1.8;
  color: #606266;
  white-space: pre-wrap;
}

.post-images {
  display: grid;
  grid-template-columns: repeat(auto-fill, minmax(200px, 1fr));
  gap: 12px;
  margin-top: 16px;
}

.post-footer {
  border-top: 1px solid #ebeef5;
  padding-top: 16px;
  margin-top: 24px;
}

.post-stats {
  display: flex;
  gap: 24px;
}

.stat-item {
  display: flex;
  align-items: center;
  gap: 4px;
  color: #909399;
  font-size: 14px;
}

.comments-section {
  margin-top: 32px;
}

.comments-section h3 {
  margin: 0 0 20px;
  font-size: 18px;
  color: #303133;
}
</style> 