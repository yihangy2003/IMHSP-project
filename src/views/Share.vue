<template>
  <div class="share-container">
    <!-- 添加空状态显示 -->
    <el-empty
      v-if="!post"
      description="帖子不存在或已被删除"
      :image-size="200"
    >
      <template #extra>
        <el-button type="primary" @click="window.close()">
          关闭页面
        </el-button>
      </template>
    </el-empty>

    <!-- 帖子内容 -->
    <el-card v-else class="share-card">
      <!-- 帖子头部 -->
      <div class="post-header">
        <div class="author-info" @click="toggleAuthorInfo(post?.author)">
          <el-avatar :src="post?.author.avatar" :size="40" />
          <div class="author-meta">
            <span class="author-name">{{ post?.author.name }}</span>
            <span class="post-time">{{ post?.createTime }}</span>
          </div>
        </div>
      </div>

      <!-- 帖子内容 -->
      <div class="post-content">
        <div class="markdown-content" v-html="renderMarkdown(post?.content || '')"></div>
      </div>

      <!-- 帖子统计 -->
      <div class="post-stats">
        <span>
          <el-icon style="margin-right: 4px"><View /></el-icon>
          {{ post?.views }}
        </span>
        <span class="like-btn" @click="handleLike">
          <HeartOutlined v-if="!post?.isLiked" style="margin-right: 4px; font-size: 14px" />
          <HeartFilled v-else style="margin-right: 4px; font-size: 14px" class="liked" />
          {{ post?.likes }}
        </span>
        <span class="collect-btn" @click="handleCollect">
          <el-icon style="margin-right: 4px">
            <Star v-if="!post?.isCollected" />
            <StarFilled v-else class="collected"/>
          </el-icon>
          {{ post?.collects }}
        </span>
        <span class="comment-btn" @click="toggleComments">
          <el-icon style="margin-right: 4px"><ChatDotRound /></el-icon>
          {{ post?.comments?.length }}
        </span>
      </div>

      <!-- 评论区 -->
      <div v-show="showComments" class="comments-section">
        <div class="comments-list">
          <div v-for="comment in post?.comments" :key="comment.id" class="comment-item">
            <el-avatar :src="comment.author.avatar" :size="32" />
            <div class="comment-content">
              <div class="comment-header">
                <span class="comment-author">{{ comment.author.name }}</span>
                <span class="comment-time">{{ comment.createTime }}</span>
              </div>
              <div class="comment-text" :class="{ 'expanded': comment.isExpanded }">
                {{ comment.content }}
              </div>
              <div v-if="comment.content.length > 100" class="expand-btn" @click="toggleComment(comment)">
                {{ comment.isExpanded ? '收起' : '展开全文' }}
              </div>
            </div>
          </div>
        </div>

        <!-- 添加评论输入框 -->
        <div class="comment-input">
          <el-input
            type="textarea"
            v-model="newComment"
            placeholder="请输入评论..."
            rows="3"
            @keyup.enter="submitComment"
          />
          <el-button type="primary" @click="submitComment">提交</el-button>
        </div>
      </div>
    </el-card>

    <!-- 添加用户信息卡片 -->
    <div class="author-info-card" :class="{ 'show': showAuthorInfo }" v-if="selectedAuthor">
      <div class="card-header">
        <div class="close-btn" @click="toggleAuthorInfo()">
          <el-icon><Close /></el-icon>
        </div>
      </div>
      <div class="card-content">
        <div class="author-header">
          <el-avatar :src="selectedAuthor.avatar" :size="60" />
          <div class="author-name">{{ selectedAuthor.name }}</div>
        </div>
        <div class="author-bio">
          <div :class="{ 'bio-text': true, 'expanded': bioExpanded }">
            {{ selectedAuthor.bio }}
          </div>
          <div 
            v-if="selectedAuthor.bio?.length > 100" 
            class="expand-bio" 
            @click="bioExpanded = !bioExpanded"
          >
            {{ bioExpanded ? '收起' : '展开全文' }}
          </div>
        </div>
        <div class="author-stats">
          <div class="stat-item">
            <div class="stat-value">{{ selectedAuthor.posts }}</div>
            <div class="stat-label">帖子</div>
          </div>
          <div class="stat-item">
            <div class="stat-value">{{ selectedAuthor.followers }}</div>
            <div class="stat-label">粉丝</div>
          </div>
          <div class="stat-item">
            <div class="stat-value">{{ selectedAuthor.following }}</div>
            <div class="stat-label">关注</div>
          </div>
        </div>
        <div class="action-buttons">
          <el-button type="primary" plain>关注</el-button>
          <el-button 
            type="primary" 
            plain 
            @click="goToUserPage(selectedAuthor.id)"
          >
            <template #icon>
              <el-icon><User /></el-icon>
            </template>
            主页
          </el-button>
        </div>
      </div>
    </div>
  </div>
</template>

<script setup lang="ts">
import { ref, onMounted } from 'vue'
import { useRoute, useRouter } from 'vue-router'
import { marked } from 'marked'
import { View, Star, StarFilled, ChatDotRound, Close, User } from '@element-plus/icons-vue'
import { HeartOutlined, HeartFilled } from '@ant-design/icons-vue'
import { ElMessage } from 'element-plus'

const route = useRoute()
const router = useRouter()
const post = ref(null)
const showComments = ref(false)
const showAuthorInfo = ref(false)
const bioExpanded = ref(false)
const selectedAuthor = ref(null)
const newComment = ref('')

onMounted(() => {
  try {
    const storedPost = localStorage.getItem('currentPost')
    if (storedPost) {
      post.value = JSON.parse(storedPost)
      // 清除存储的数据，避免内存泄漏
      localStorage.removeItem('currentPost')
    }
  } catch (error) {
    console.error('Error loading post:', error)
  }
})

const renderMarkdown = (content: string) => {
  return marked(content)
}

const handleLike = () => {
  if (post.value) {
    post.value.isLiked = !post.value.isLiked
    post.value.likes += post.value.isLiked ? 1 : -1
  }
}

const handleCollect = () => {
  if (post.value) {
    post.value.isCollected = !post.value.isCollected
    post.value.collects += post.value.isCollected ? 1 : -1
  }
}

const toggleComments = () => {
  showComments.value = !showComments.value
}

const toggleComment = (comment: any) => {
  comment.isExpanded = !comment.isExpanded
}

const toggleAuthorInfo = (author?: any) => {
  if (author) {
    selectedAuthor.value = author
    showAuthorInfo.value = true
    bioExpanded.value = false
  } else {
    showAuthorInfo.value = false
  }
}

const goToUserPage = (userId: number) => {
  window.open(`/user/${userId}`, '_blank')
}

// 提交评论
const submitComment = () => {
  if (!newComment.value.trim()) {
    ElMessage.warning('评论内容不能为空')
    return
  }

  // 创建评论对象
  const comment = {
    id: Date.now(), // 临时ID，实际应该由后端生成
    content: newComment.value,
    author: {
      name: userStore.userInfo.username,
      avatar: userStore.userInfo.avatar
    },
    createTime: new Date().toLocaleString()
  }

  // TODO: 发送请求到后端保存评论
  post.value.comments.push(comment) // 更新本地评论列表
  newComment.value = '' // 清空输入框
}
</script>

<style scoped>
.share-container {
  padding: 20px;
  max-width: 800px;
  margin: 0 auto;
}

.share-card {
  border-radius: 8px;
}

.post-header {
  margin-bottom: 24px;
}

.author-info {
  display: flex;
  align-items: center;
  gap: 12px;
  cursor: pointer;
  transition: opacity 0.3s;
}

.author-info:hover {
  opacity: 0.8;
}

.author-meta {
  display: flex;
  flex-direction: column;
  gap: 4px;
}

.author-name {
  font-weight: 500;
  color: #303133;
}

.post-time {
  color: #909399;
  font-size: 12px;
}

.post-content {
  margin-bottom: 24px;
}

.markdown-content {
  font-size: 16px;
  line-height: 1.8;
  color: #303133;
}

/* 继承之前的 markdown 样式 */
.markdown-content :deep(h1) {
  font-size: 24px;
  margin: 24px 0 16px;
}

.markdown-content :deep(h2) {
  font-size: 20px;
  margin: 20px 0 14px;
}

.markdown-content :deep(p) {
  margin: 16px 0;
}

.markdown-content :deep(blockquote) {
  border-left: 4px solid #409EFF;
  padding: 12px 16px;
  margin: 16px 0;
  background: #f8f9fa;
  color: #606266;
}

.post-stats {
  display: flex;
  gap: 24px;
  margin-top: 16px;
  padding-top: 16px;
  border-top: 1px solid #ebeef5;
}

.post-stats span {
  display: flex;
  align-items: center;
  color: #606266;
  cursor: pointer;
  transition: color 0.3s;
}

.post-stats span:hover {
  color: #409EFF;
}

.post-stats .anticon {
  color: #909399;
  transition: all 0.3s;
}

.post-stats .liked {
  color: #F56C6C !important;  /* 红色 */
}

.post-stats .collected {
  color: #E6A23C !important;  /* 黄色 */
  transform: scale(1.2);
}

.post-stats .like-btn,
.post-stats .collect-btn {
  transition: all 0.3s;
}

.post-stats .like-btn:hover {
  color: #F56C6C;
  transform: scale(1.1);
}

.post-stats .like-btn:hover .anticon {
  color: #F56C6C;
}

.post-stats .collect-btn:hover {
  color: #E6A23C;
  transform: scale(1.1);
}

.comments-section {
  margin-top: 24px;
  padding-top: 16px;
  border-top: 1px solid #ebeef5;
}

.comment-item {
  display: flex;
  gap: 12px;
  margin-bottom: 16px;
}

.comment-content {
  flex: 1;
}

.comment-header {
  display: flex;
  justify-content: space-between;
  margin-bottom: 4px;
}

.comment-author {
  font-weight: 500;
  color: #303133;
}

.comment-time {
  color: #909399;
  font-size: 12px;
}

.comment-text {
  color: #606266;
  line-height: 1.6;
}

.expand-btn {
  color: #409EFF;
  font-size: 13px;
  cursor: pointer;
  margin-top: 4px;
}

/* 添加空状态样式 */
:deep(.el-empty) {
  padding: 60px 0;
}

:deep(.el-empty__description) {
  margin-top: 20px;
  font-size: 16px;
  color: #909399;
}

:deep(.el-empty__bottom) {
  margin-top: 20px;
}

/* 添加用户信息卡片样式 */
.author-info-card {
  position: fixed;
  top: 10px;
  right: -320px;
  width: 300px;
  background: white;
  border-radius: 8px;
  box-shadow: -2px 0 12px rgba(0, 0, 0, 0.1);
  transition: right 0.3s ease;
  z-index: 1000;
  max-height: calc(100vh - 120px);
  overflow-y: auto;
}

.author-info-card.show {
  right: 20px;
}

.card-header {
  padding: 12px;
  display: flex;
  justify-content: flex-end;
}

.close-btn {
  cursor: pointer;
  padding: 4px;
  border-radius: 4px;
  transition: background-color 0.3s;
}

.close-btn:hover {
  background-color: #f5f7fa;
}

.card-content {
  padding: 0 20px 20px;
}

.author-header {
  text-align: center;
  margin-bottom: 20px;
}

.author-header .author-name {
  margin-top: 12px;
  font-size: 18px;
  font-weight: 600;
}

.author-bio {
  margin: 16px 0;
  padding: 12px;
  background-color: #f5f7fa;
  border-radius: 4px;
  color: #606266;
  font-size: 14px;
  line-height: 1.6;
  word-break: break-word;
}

.bio-text {
  overflow: hidden;
  text-overflow: ellipsis;
  display: -webkit-box;
  -webkit-line-clamp: 3;
  -webkit-box-orient: vertical;
  transition: all 0.3s;
}

.bio-text.expanded {
  -webkit-line-clamp: unset;
}

.expand-bio {
  color: #409EFF;
  font-size: 13px;
  cursor: pointer;
  margin-top: 8px;
}

.author-stats {
  display: flex;
  justify-content: space-around;
  margin-top: 20px;
  padding: 16px 0;
  border-top: 1px solid #ebeef5;
}

.stat-item {
  text-align: center;
}

.stat-value {
  font-size: 18px;
  font-weight: 600;
  color: #303133;
}

.stat-label {
  font-size: 12px;
  color: #909399;
  margin-top: 4px;
}

.action-buttons {
  display: flex;
  gap: 12px;
  margin-top: 20px;
}

.action-buttons .el-button {
  flex: 1;
}

.comment-input {
  display: flex;
  align-items: flex-start; /* 确保按钮与文本框顶部齐平 */
  margin-top: 16px;
}

.comment-input .el-input {
  flex: 1;
  margin-right: 8px; /* 添加右侧间隔 */
}

.comment-input .el-button {
  margin-top: 0px; /* 添加顶部间隔，使按钮与文本框顶部齐平 */
  margin-left: 10px;
}
</style> 