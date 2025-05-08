<template>
  <el-scrollbar v-if="currentTopic" class="topic-detail" height="calc(100vh - 20px)">
    <div class="topic-container">
      <div class="topic-header">
        <el-image :src="currentTopic.cover" fit="cover" class="topic-cover" />
        <div class="topic-info">
          <div class="header-top">
            <h1>{{ currentTopic.title }}</h1>
            <el-button 
              type="primary" 
              plain 
              @click="goToTopicList"
              class="back-button"
            >
              <el-icon><ArrowLeft /></el-icon>
              返回专题列表
            </el-button>
          </div>
          <div class="topic-meta">
            <span class="author">作者：{{ currentTopic.author }}</span>
            <span class="stats">
              <el-icon><View /></el-icon>{{ currentTopic.views }}
              <span class="like-button" @click="handleLike">
                <HeartOutlined v-if="!isLiked" class="like-icon" />
                <HeartFilled v-else class="like-icon liked" />
                {{ currentTopic.likes }}
              </span>
              <span class="collect-button" @click="handleCollect">
                <el-icon :class="{ 'collected': isCollected }">
                  <Star v-if="!isCollected" />
                  <StarFilled v-else />
                </el-icon>
                {{ currentTopic.collects }}
              </span>
            </span>
            <el-tag :type="currentTopic.type === 'free' ? 'success' : 'warning'" size="small">
              {{ currentTopic.type === 'free' ? '免费' : `￥${currentTopic.price}` }}
            </el-tag>
          </div>
          <div class="topic-intro">
            <p class="intro-text">{{ currentTopic.introduction || '这是一段专题简介，作者将在这里介绍专题的主要内容、目标人群和预期收获。通过这个专题，您将了解到相关领域的核心知识，掌握实用技能，获得专业指导。' }}</p>
          </div>
        </div>
      </div>
      
      <div class="topic-content">
        <div id="vditor-preview" class="vditor-preview"></div>
        
        <!-- 付费内容遮罩 -->
        <div v-if="currentTopic.type === 'paid'" class="content-mask"></div>
      </div>
      
      <!-- 付费提示卡片移到外层 -->
      <div v-if="currentTopic.type === 'paid'" class="purchase-card">
        <el-icon class="lock-icon"><Lock /></el-icon>
        <h3>付费内容</h3>
        <p>解锁完整内容需要支付 ¥{{ currentTopic.price }}</p>
        <el-button type="primary" size="large" @click="handlePurchase">
          立即解锁
        </el-button>
      </div>
    </div>
  </el-scrollbar>
  <div v-else class="no-topic">
    <el-empty 
      description="未找到专题内容" 
      :image-size="200"
    >
      <template #extra>
        <el-button type="primary" @click="goToTopicList">
          返回专题列表
        </el-button>
      </template>
    </el-empty>
  </div>
</template>

<script setup lang="ts">
import { ref, onMounted } from 'vue'
import { useRouter, useRoute } from 'vue-router'
import { View, Star, ArrowLeft } from '@element-plus/icons-vue'
import { StarFilled } from '@element-plus/icons-vue'
import { HeartOutlined, HeartFilled } from '@ant-design/icons-vue'
import { ElMessage } from 'element-plus'
import { useNavStore } from '@/stores/navStore'
import type { Topic } from '@/types/topic'
import 'vditor/dist/index.css'

const router = useRouter()
const route = useRoute()
const navStore = useNavStore()
const currentTopic = ref<Topic>()
const isLiked = ref(false)
const isCollected = ref(false)

// 从 localStorage 获取点赞状态
const getLikedStatus = (topicId: number) => {
  const likedTopics = JSON.parse(localStorage.getItem('likedTopics') || '[]')
  return likedTopics.includes(topicId)
}

// 从 localStorage 获取收藏状态
const getCollectedStatus = (topicId: number) => {
  const collectedTopics = JSON.parse(localStorage.getItem('collectedTopics') || '[]')
  return collectedTopics.includes(topicId)
}

// 保存点赞状态
const saveLikedStatus = (topicId: number, liked: boolean) => {
  const likedTopics = JSON.parse(localStorage.getItem('likedTopics') || '[]')
  if (liked) {
    if (!likedTopics.includes(topicId)) {
      likedTopics.push(topicId)
    }
  } else {
    const index = likedTopics.indexOf(topicId)
    if (index > -1) {
      likedTopics.splice(index, 1)
    }
  }
  localStorage.setItem('likedTopics', JSON.stringify(likedTopics))
}

// 保存收藏状态
const saveCollectedStatus = (topicId: number, collected: boolean) => {
  const collectedTopics = JSON.parse(localStorage.getItem('collectedTopics') || '[]')
  if (collected) {
    if (!collectedTopics.includes(topicId)) {
      collectedTopics.push(topicId)
    }
  } else {
    const index = collectedTopics.indexOf(topicId)
    if (index > -1) {
      collectedTopics.splice(index, 1)
    }
  }
  localStorage.setItem('collectedTopics', JSON.stringify(collectedTopics))
}

// 处理点赞
const handleLike = () => {
  if (!currentTopic.value) return
  
  isLiked.value = !isLiked.value
  currentTopic.value.likes += isLiked.value ? 1 : -1
  
  saveLikedStatus(currentTopic.value.id, isLiked.value)
  updateTopicData()
}

// 处理收藏
const handleCollect = () => {
  if (!currentTopic.value) return
  
  isCollected.value = !isCollected.value
  currentTopic.value.collects += isCollected.value ? 1 : -1
  
  saveCollectedStatus(currentTopic.value.id, isCollected.value)
  updateTopicData()
}

// 更新专题数据
const updateTopicData = () => {
  if (!currentTopic.value) return
  
  const topicPool = JSON.parse(localStorage.getItem('topicPool') || '[]')
  const updatedPool = topicPool.map((topic: Topic) => {
    if (topic.id === currentTopic.value?.id) {
      return { 
        ...topic, 
        likes: currentTopic.value.likes,
        collects: currentTopic.value.collects
      }
    }
    return topic
  })
  localStorage.setItem('topicPool', JSON.stringify(updatedPool))
  localStorage.setItem('currentTopic', JSON.stringify(currentTopic.value))
}

// 获取部分内容的 Markdown
const getPartialContent = (topic: Topic) => `
## 主要内容

### 1. 心理健康的重要性
- 心理健康对生活质量的影响
- 如何识别心理健康问题

### 2. 常见心理问题的应对
- 压力管理技巧
- 情绪调节方法

> 解锁完整内容以查看更多专业建议和实践方法...
`

// 获取完整内容的 Markdown
const getFullContent = (topic: Topic) => `
## 主要内容

### 1. 心理健康的重要性
- 心理健康对生活质量的影响
- 如何识别心理健康问题
- 日常心理健康维护方法

### 2. 常见心理问题的应对
- 压力管理技巧
- 情绪调节方法
- 人际关系处理

### 3. 专业建议
- 寻求帮助的时机
- 心理咨询的作用
- 自助与互助方法

## 实践练习
1. 日常观察记录
2. 放松训练方法
3. 认知重构练习

## 参考资源
- 推荐书籍
- 在线课程
- 专业机构
`

// 处理购买
const handlePurchase = () => {
  ElMessage({
    type: 'info',
    message: '购买功能开发中...'
  })
}

// 初始化 Vditor 预览器
const initVditor = async (topic: Topic) => {
  const { default: Vditor } = await import('vditor')
  const previewElement = document.getElementById('vditor-preview')
  if (previewElement) {
    const content = topic.type === 'paid' ? getPartialContent(topic) : getFullContent(topic)
    Vditor.preview(previewElement, content, {
      theme: 'light',
      markdown: {
        toc: true,
        sanitize: true,
        listStyle: true
      }
    })
  }
}

onMounted(async () => {
  const topicId = Number(route.params.id)
  // 优先从 localStorage 获取专题数据
  const topicData = localStorage.getItem('currentTopic')
  if (topicData) {
    const topic = JSON.parse(topicData)
    if (topic.id === topicId) {
      currentTopic.value = topic
      isLiked.value = getLikedStatus(topicId)
      isCollected.value = getCollectedStatus(topicId)
      await initVditor(topic)
      return
    }
  }
  
  // 如果没有当前专题数据或 ID 不匹配，从专题池中查找
  const topicPool = localStorage.getItem('topicPool')
  if (topicPool) {
    const topics = JSON.parse(topicPool)
    const topic = topics.find((t: Topic) => t.id === topicId)
    if (topic) {
      currentTopic.value = topic
      isLiked.value = getLikedStatus(topicId)
      isCollected.value = getCollectedStatus(topicId)
      await initVditor(topic)
      return
    }
  }
  
  // 如果仍然没有找到专题数据，返回专题列表
  router.push('/recommendation')
})

const goToTopicList = () => {
  navStore.setActiveMenu('/topic')
  router.push('/topic')
}
</script>

<style scoped>
.topic-detail {
  background-color: #f5f7fa;
}

.topic-container {
  padding: 20px;
}

.topic-header {
  display: flex;
  gap: 24px;
  margin-bottom: 24px;
  background: white;
  padding: 20px;
  border-radius: 8px;
  box-shadow: 0 2px 12px rgba(0, 0, 0, 0.05);
  border: 1px solid #ebeef5;
}

.topic-cover {
  width: 300px;
  height: 200px;
  border-radius: 8px;
  object-fit: cover;
}

.topic-info {
  flex: 1;
}

.header-top {
  display: flex;
  justify-content: space-between;
  align-items: center;
  margin-bottom: 16px;
}

.header-top h1 {
  margin: 0;
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
  position: relative;
  margin-top: 24px;
  padding: 32px;
  background: white;
  border-radius: 8px;
  min-height: 400px;
  box-shadow: 0 2px 12px rgba(0, 0, 0, 0.05);
  border: 1px solid #ebeef5;
}

.vditor-preview {
  font-size: 15px;
  line-height: 1.6;
}

:deep(.vditor-reset) {
  padding: 0;
}

:deep(.vditor-reset h1) {
  font-size: 24px;
  border-bottom: 1px solid #ebeef5;
  padding-bottom: 16px;
  margin-bottom: 24px;
}

:deep(.vditor-reset h2) {
  font-size: 20px;
  margin-top: 32px;
}

:deep(.vditor-reset h3) {
  font-size: 18px;
  margin-top: 24px;
}

:deep(.vditor-reset ul),
:deep(.vditor-reset ol) {
  padding-left: 24px;
}

:deep(.vditor-reset li) {
  margin: 8px 0;
}

.no-topic {
  display: flex;
  justify-content: center;
  align-items: center;
  min-height: calc(100vh - 20px);
  background-color: #f5f7fa;
  padding: 20px;
}

.topic-intro {
  margin-top: 20px;
  padding-top: 16px;
  border-top: 1px solid #ebeef5;
}

.intro-text {
  font-size: 14px;
  color: #606266;
  line-height: 1.6;
  margin: 0;
}

.back-button {
  flex-shrink: 0;
  margin-left: 16px;
  font-size: 15px;
  padding: 10px 20px;
  height: auto;
}

.back-button .el-icon {
  margin-right: 6px;
  font-size: 16px;
}

.like-button,
.collect-button {
  cursor: pointer;
  display: flex;
  align-items: center;
  gap: 4px;
  transition: all 0.3s;
}

.like-button:hover {
  color: #F56C6C;
}

.collect-button:hover {
  color: #E6A23C;
}

.like-icon {
  font-size: 14px;
  margin-right: 4px;
  transition: all 0.3s;
}

.like-icon.liked {
  color: #F56C6C;
  transform: scale(1.1);
}

.stats .el-icon {
  font-size: 16px;
  transition: all 0.3s;
}

.like-button:hover .el-icon {
  transform: scale(1.2);
}

.like-button .el-icon {
  transition: all 0.3s;
}

.content-mask {
  position: absolute;
  top: 35%;
  left: 0;
  right: 0;
  bottom: 0;
  background: linear-gradient(transparent, white 20%);
  border-radius: 0 0 8px 8px;
  pointer-events: none;
}

.purchase-card {
  position: fixed;
  top: 45%;
  left: 57%;
  transform: translate(-50%, -50%);
  text-align: center;
  padding: 32px 48px;
  background: white;
  border-radius: 8px;
  box-shadow: 0 4px 24px rgba(0, 0, 0, 0.1);
  border: 1px solid #ebeef5;
  z-index: 10;
  width: 320px;
}

.lock-icon {
  font-size: 32px;
  color: #E6A23C;
  margin-bottom: 16px;
}

.purchase-card h3 {
  margin: 0 0 8px;
  font-size: 20px;
  color: #303133;
}

.purchase-card p {
  margin: 0 0 24px;
  color: #606266;
}

.collect-button .collected {
  color: #E6A23C;
  transform: scale(1.1);
}
</style> 