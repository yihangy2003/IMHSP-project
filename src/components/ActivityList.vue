<template>
  <div class="activity-list">
    <!-- 添加隐私设置按钮 -->
    <div class="header-actions">
      <div class="filter-group">
        <el-radio-group v-model="activityType" size="large">
          <el-radio-button label="all">全部动态</el-radio-button>
          <el-radio-button label="posts">发布帖子</el-radio-button>
          <el-radio-button label="topics" v-if="isCounselor">发布专题</el-radio-button>
          <el-radio-button label="comments">评论</el-radio-button>
          <el-radio-button label="likes">点赞</el-radio-button>
          <el-radio-button label="stars">收藏</el-radio-button>
          <el-radio-button label="tests">心理测验</el-radio-button>
        </el-radio-group>
      </div>
      
      <!-- 只在当前用户或管理员访问时显示隐私设置 -->
      <el-tooltip
        v-if="isOwnProfile"
        content="设置动态是否对其他用户可见"
        placement="top"
      >
        <el-switch
          v-model="activitiesPublic"
          active-text="公开"
          inactive-text="私密"
          @change="handlePrivacyChange"
        />
      </el-tooltip>
    </div>

    <!-- 添加空状态显示 -->
    <div v-if="filteredActivities.length === 0" class="empty-state">
      <el-empty 
        :description="getEmptyText(activityType)" 
        :image-size="200"
      >
        <template #image>
          <el-icon :size="60" :color="getEmptyIconColor(activityType)">
            <component :is="getEmptyIcon(activityType)" />
          </el-icon>
        </template>
      </el-empty>
    </div>

    <!-- 活动时间线 -->
    <el-timeline v-else>
      <el-timeline-item
        v-for="activity in filteredActivities"
        :key="activity.id"
        :timestamp="formatTime(activity.timestamp)"
        :type="getActivityType(activity.type)"
      >
        <el-card class="activity-card">
          <template #header>
            <div class="activity-header">
              <span class="activity-type">{{ getActivityTypeText(activity.type) }}</span>
              <el-tag size="small" :type="getTagType(activity.type)">
                {{ activity.category }}
              </el-tag>
            </div>
          </template>
          
          <div class="activity-content">
            <!-- 发帖动态 -->
            <template v-if="activity.type === 'post'">
              <h4>发布了帖子：{{ activity.title }}</h4>
              <p class="content-preview">{{ activity.content }}</p>
              <div class="post-stats">
                <span><el-icon><View /></el-icon> {{ activity.views }}</span>
                <span><el-icon><ChatRound /></el-icon> {{ activity.comments }}</span>
                <span class="like-stat" @click="handleLike(activity)">
                  <heart-outlined v-if="!activity.isLiked" class="heart-icon" />
                  <heart-filled v-else class="heart-icon heart-filled" />
                  {{ activity.likes }}
                  <span class="stat-label"></span>
                </span>
                <span class="star-stat" @click="handleStar(activity)">
                  <el-icon>
                    <star-filled v-if="activity.isStarred" />
                    <star v-else />
                  </el-icon>
                  {{ activity.stars }}
                  <span class="stat-label"></span>
                </span>
              </div>
            </template>

            <!-- 评论动态 -->
            <template v-else-if="activity.type === 'comment'">
              <p>评论了 <el-link type="primary">{{ activity.postTitle }}</el-link>：</p>
              <p class="content-preview">{{ activity.content }}</p>
            </template>

            <!-- 点赞动态 -->
            <template v-else-if="activity.type === 'like'">
              <p>点赞了 <el-link type="primary">{{ activity.postTitle }}</el-link></p>
            </template>

            <!-- 测验动态 -->
            <template v-else-if="activity.type === 'test'">
              <h4>完成了测验：{{ activity.testName }}</h4>
              <div class="test-result">
                <span class="score">得分：{{ activity.score }}</span>
                <el-button type="primary" link @click="handleRetakeTest(activity.testId)">
                  重新测试
                </el-button>
              </div>
            </template>

            <!-- 专题动态 -->
            <template v-else-if="activity.type === 'topic'">
              <h4>发布了专题：{{ activity.title }}</h4>
              <p class="content-preview">{{ activity.description }}</p>
              <div class="topic-stats">
                <span><el-icon><View /></el-icon> {{ activity.views }}</span>
                <span><el-icon><ChatRound /></el-icon> {{ activity.comments }}</span>
                <span class="like-stat" @click="handleLike(activity)">
                  <heart-outlined v-if="!activity.isLiked" class="heart-icon" />
                  <heart-filled v-else class="heart-icon heart-filled" />
                  {{ activity.likes }}
                  <span class="stat-label"></span>
                </span>
                <span class="star-stat" @click="handleStar(activity)">
                  <el-icon>
                    <star-filled v-if="activity.isStarred" />
                    <star v-else />
                  </el-icon>
                  {{ activity.stars }}
                  <span class="stat-label"></span>
                </span>
              </div>
            </template>

            <!-- 收藏动态 -->
            <template v-else-if="activity.type === 'star'">
              <p>收藏了 
                <template v-if="activity.contentType === 'post'">
                  帖子 <el-link type="primary">{{ activity.title }}</el-link>
                </template>
                <template v-else-if="activity.contentType === 'topic'">
                  专题 <el-link type="primary">{{ activity.title }}</el-link>
                </template>
              </p>
              <p class="content-preview">{{ activity.description || activity.content }}</p>
            </template>
          </div>
        </el-card>
      </el-timeline-item>
    </el-timeline>

    <!-- 加载更多 -->
    <div class="load-more" v-if="hasMore">
      <el-button :loading="loading" @click="loadMore">加载更多</el-button>
    </div>
  </div>
</template>

<script setup lang="ts">
import { ref, computed } from 'vue'
import { useRouter, useRoute } from 'vue-router'
import { View, ChatRound, Star, StarFilled, Document, ChatDotSquare } from '@element-plus/icons-vue'
import { HeartOutlined, HeartFilled } from '@ant-design/icons-vue'
import dayjs from 'dayjs'
import relativeTime from 'dayjs/plugin/relativeTime'
import 'dayjs/locale/zh-cn'
import { useUserStore } from '@/stores/user'
import { ElMessage } from 'element-plus'

dayjs.extend(relativeTime)
dayjs.locale('zh-cn')

const router = useRouter()
const route = useRoute()
const activityType = ref('all')
const loading = ref(false)
const hasMore = ref(true)
const userStore = useUserStore()
const isCounselor = computed(() => userStore.userInfo?.roles === 'counselor')

// 判断是否是当前用户的主页
const isOwnProfile = computed(() => {
  return route.params.id === userStore.userInfo?.id
})

// 获取用户动态可见性设置
const activitiesPublic = ref(userStore.userInfo?.activitiesPublic ?? false)

// 处理隐私设置变更
const handlePrivacyChange = (value: boolean) => {
  if (userStore.userInfo) {
    userStore.userInfo.activitiesPublic = value
    ElMessage.success(`动态已设为${value ? '公开' : '私密'}`)
  }
}

// 修改活动数据接口
interface Activity {
  id: number
  type: 'post' | 'comment' | 'like' | 'test' | 'topic' | 'star'
  contentType?: 'post' | 'topic'  // 收藏内容的类型
  title?: string
  content?: string
  description?: string
  category: string
  views?: number
  comments?: number
  likes?: number
  stars?: number
  isLiked?: boolean
  isStarred?: boolean
  timestamp: string
  // ... 其他属性
}

// 修改模拟数据
const activities = ref<Activity[]>([
  {
    id: 1,
    type: 'post',
    title: '分享一下我的心路历程',
    content: '最近一直在思考人生的意义，经过深入的自我探索...',
    category: '心得分享',
    views: 156,
    comments: 23,
    likes: 45,
    stars: 12,
    isLiked: false,
    isStarred: false,
    timestamp: '2024-03-15 14:30:00'
  },
  {
    id: 2,
    type: 'test',
    testName: '焦虑自评量表',
    testId: 1,
    score: 75,
    category: '心理测验',
    timestamp: '2024-03-14 10:15:00'
  },
  {
    id: 3,
    type: 'comment',
    postTitle: '如何缓解考试焦虑？',
    content: '建议可以尝试深呼吸冥想，我觉得很有帮助...',
    category: '评论互动',
    timestamp: '2024-03-13 16:45:00'
  },
  {
    id: 4,
    type: 'like',
    postTitle: '走出抑郁的经验分享',
    category: '点赞互动',
    timestamp: '2024-03-12 09:20:00'
  },
  {
    id: 5,
    type: 'test',
    testName: '人格特质测试',
    testId: 3,
    score: 88,
    category: '心理测验',
    timestamp: '2024-03-11 15:30:00'
  },
  {
    id: 6,
    type: 'topic',
    title: '如何应对青少年心理压力',
    description: '本专题将深入探讨青少年在学习和生活中常见的心理压力问题...',
    category: '心理专题',
    views: 328,
    comments: 45,
    likes: 89,
    stars: 23,
    isLiked: false,
    isStarred: false,
    timestamp: '2024-03-10 11:20:00'
  },
  {
    id: 7,
    type: 'star',
    contentType: 'post',
    title: '如何培养积极心态',
    content: '这篇文章详细讲解了培养积极心态的具体方法...',
    category: '收藏互动',
    timestamp: '2024-03-09 16:40:00'
  },
  {
    id: 8,
    type: 'star',
    contentType: 'topic',
    title: '情绪管理技巧系列',
    description: '这个专题系统地介绍了各种情绪管理的实用技巧...',
    category: '收藏互动',
    timestamp: '2024-03-08 09:15:00'
  }
])

// 根据类型筛选活动
const filteredActivities = computed(() => {
  if (activityType.value === 'all') return activities.value
  return activities.value.filter(activity => {
    switch (activityType.value) {
      case 'posts':
        return activity.type === 'post'
      case 'comments':
        return activity.type === 'comment'
      case 'likes':
        return activity.type === 'like'
      case 'tests':
        return activity.type === 'test'
      case 'topics':
        return activity.type === 'topic'
      case 'stars':
        return activity.type === 'star'
      default:
        return true
    }
  })
})

// 格式化时间
const formatTime = (timestamp: string) => {
  return dayjs(timestamp).fromNow()
}

// 获取活动类型图标
const getActivityType = (type: string) => {
  switch (type) {
    case 'post':
      return 'primary'
    case 'comment':
      return 'success'
    case 'like':
      return 'warning'
    case 'test':
      return 'info'
    case 'topic':
      return 'danger'
    case 'star':
      return 'warning'
    default:
      return 'info'
  }
}

// 获取活动类型文本
const getActivityTypeText = (type: string) => {
  switch (type) {
    case 'post':
      return '发布帖子'
    case 'comment':
      return '发表评论'
    case 'like':
      return '点赞'
    case 'test':
      return '完成测验'
    case 'topic':
      return '发布专题'
    case 'star':
      return '收藏'
    default:
      return '其他活动'
  }
}

// 获取标签类型
const getTagType = (type: string) => {
  switch (type) {
    case 'post':
      return ''
    case 'comment':
      return 'success'
    case 'like':
      return 'warning'
    case 'test':
      return 'info'
    case 'topic':
      return 'danger'
    case 'star':
      return 'warning'
    default:
      return ''
  }
}

// 重新测试
const handleRetakeTest = (testId: number) => {
  router.push(`/test/${testId}?retake=true`)
}

// 加载更多
const loadMore = async () => {
  loading.value = true
  try {
    // TODO: 调用API加载更多数据
    await new Promise(resolve => setTimeout(resolve, 1000))
    // 模拟没有更多数据
    hasMore.value = false
  } finally {
    loading.value = false
  }
}

// 处理点赞/取消点赞
const handleLike = async (activity: Activity) => {
  try {
    if (activity.isLiked) {
      activity.likes!--
      activity.isLiked = false
      ElMessage.success('已取消点赞')
    } else {
      activity.likes!++
      activity.isLiked = true
      ElMessage.success('点赞成功')
    }
  } catch (error) {
    ElMessage.error('操作失败，请稍后重试')
  }
}

// 处理收藏/取消收藏
const handleStar = async (activity: Activity) => {
  try {
    if (activity.isStarred) {
      activity.stars!--
      activity.isStarred = false
      ElMessage.success('已取消收藏')
    } else {
      activity.stars!++
      activity.isStarred = true
      ElMessage.success('收藏成功')
    }
  } catch (error) {
    ElMessage.error('操作失败，请稍后重试')
  }
}

// 获取空状态文本
const getEmptyText = (type: string) => {
  switch (type) {
    case 'posts':
      return '暂无发帖动态'
    case 'comments':
      return '暂无评论动态'
    case 'likes':
      return '暂无点赞动态'
    case 'stars':
      return '暂无收藏动态'
    case 'tests':
      return '暂无测验记录'
    case 'topics':
      return '暂无专题动态'
    default:
      return '暂无任何动态'
  }
}

// 获取空状态图标
const getEmptyIcon = (type: string) => {
  switch (type) {
    case 'posts':
      return Document
    case 'comments':
      return ChatDotSquare
    case 'likes':
      return HeartFilled
    case 'stars':
      return Star
    case 'tests':
      return Document
    case 'topics':
      return Document
    default:
      return Document
  }
}

// 获取空状态图标颜色
const getEmptyIconColor = (type: string) => {
  switch (type) {
    case 'posts':
      return '#409EFF'  // 蓝色
    case 'comments':
      return '#67C23A'  // 绿色
    case 'likes':
      return '#ff4949'  // 红色
    case 'stars':
      return '#f7ba2a'  // 金色
    case 'tests':
      return '#909399'  // 灰色
    case 'topics':
      return '#F56C6C'  // 红色
    default:
      return '#909399'  // 灰色
  }
}
</script>

<style scoped>
.activity-list {
  padding: 20px;
}

.header-actions {
  display: flex;
  justify-content: space-between;
  align-items: center;
  margin-bottom: 24px;
}

.filter-group {
  margin-bottom: 0;
}

.activity-card {
  margin-bottom: 4px;
}

.activity-header {
  display: flex;
  justify-content: space-between;
  align-items: center;
}

.activity-type {
  font-weight: 500;
  color: #606266;
}

.activity-content {
  color: #303133;
}

.activity-content h4 {
  margin: 0 0 12px;
  font-size: 16px;
}

.content-preview {
  color: #606266;
  margin: 8px 0;
  line-height: 1.6;
  display: -webkit-box;
  -webkit-line-clamp: 2;
  -webkit-box-orient: vertical;
  overflow: hidden;
}

.post-stats {
  display: flex;
  gap: 16px;
  color: #909399;
  margin-top: 8px;
}

.post-stats span {
  display: flex;
  align-items: center;
  gap: 4px;
}

.test-result {
  display: flex;
  justify-content: space-between;
  align-items: center;
  margin-top: 8px;
}

.score {
  font-size: 16px;
  color: #409EFF;
  font-weight: 500;
}

.load-more {
  text-align: center;
  margin-top: 24px;
}

:deep(.el-timeline-item__node--primary) {
  background-color: #409EFF;
}

:deep(.el-timeline-item__node--success) {
  background-color: #67C23A;
}

:deep(.el-timeline-item__node--warning) {
  background-color: #E6A23C;
}

:deep(.el-timeline-item__node--info) {
  background-color: #909399;
}

:deep(.el-timeline-item__node--danger) {
  background-color: #F56C6C;
}

.topic-stats {
  display: flex;
  gap: 16px;
  color: #909399;
  margin-top: 8px;
}

.topic-stats span {
  display: flex;
  align-items: center;
  gap: 4px;
}

.stat-label {
  font-size: 12px;
  color: #909399;
  margin-left: 2px;
}

:deep(.el-switch) {
  margin-left: 16px;
}

:deep(.el-switch__label) {
  color: #606266;
}

:deep(.el-switch.is-checked .el-switch__label--right) {
  color: #409EFF;
}

/* 添加图标悬停效果 */
.el-icon {
  transition: transform 0.2s ease;
}

.el-icon:hover {
  transform: scale(1.1);
}

/* 点赞图标特殊样式 */
:deep(.el-icon.star-filled) {
  color: #f7ba2a;  /* 金色 */
}

/* 修改点赞和收藏统计样式 */
.like-stat,
.star-stat {
  cursor: pointer;
  user-select: none;
  transition: color 0.3s ease;
}

.like-stat:hover {
  color: #ff4949;  /* 红色 */
}

.star-stat:hover {
  color: #f7ba2a;  /* 金色 */
}

.like-stat:hover .el-icon,
.star-stat:hover .el-icon {
  transform: scale(1.2);
}

/* 图标样式 */
.el-icon {
  transition: all 0.3s ease;
}

:deep(.el-icon.like-filled) {
  color: #ff4949;
  animation: like-animation 0.3s ease;
}

:deep(.el-icon.star-filled) {
  color: #f7ba2a;
  animation: like-animation 0.3s ease;
}

/* 动画效果 */
@keyframes like-animation {
  0% {
    transform: scale(1);
  }
  50% {
    transform: scale(1.3);
  }
  100% {
    transform: scale(1);
  }
}

/* 统计标签样式 */
.stat-label {
  font-size: 12px;
  color: inherit;
  margin-left: 2px;
}

/* 修改爱心图标样式 */
.heart-icon {
  font-size: 16px;
  transition: all 0.3s ease;
}

.heart-filled {
  color: #ff4949;
  animation: like-animation 0.3s ease;
}

.like-stat:hover .heart-icon {
  transform: scale(1.2);
  color: #ff4949;
}

/* 修改收藏图标样式 */
.star-stat .el-icon {
  font-size: 16px;
  transition: all 0.3s ease;
}

.star-stat:hover .el-icon {
  transform: scale(1.2);
  color: #f7ba2a;
}

:deep(.star-stat .el-icon svg) {
  transition: all 0.3s ease;
}

:deep(.star-stat:hover .el-icon svg) {
  fill: #f7ba2a;
}

/* 已收藏状态 */
:deep(.star-stat .star-filled) {
  color: #f7ba2a;
  animation: like-animation 0.3s ease;
}

/* 添加空状态样式 */
.empty-state {
  display: flex;
  justify-content: center;
  align-items: center;
  min-height: 300px;
  background-color: #fff;
  border-radius: 8px;
}

:deep(.el-empty__description) {
  margin-top: 20px;
  font-size: 16px;
  color: #909399;
}

:deep(.el-empty__image) {
  display: flex;
  justify-content: center;
  align-items: center;
}
</style> 