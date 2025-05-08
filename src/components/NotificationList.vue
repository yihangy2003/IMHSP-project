<template>
  <div class="notification-list">
    <!-- 修改头部区域 -->
    <div class="header-actions">
      <div class="filter-section">
        <el-radio-group v-model="notificationType" size="large">
          <el-radio-button label="all">
            全部通知
            <el-badge 
              v-if="isOwnProfile && unreadCount > 0" 
              :value="unreadCount" 
              class="unread-badge" 
            />
          </el-radio-button>
          <el-radio-button label="comments">
            评论
            <el-badge 
              v-if="isOwnProfile && getTypeUnreadCount('comment')" 
              :value="getTypeUnreadCount('comment')" 
              class="unread-badge" 
            />
          </el-radio-button>
          <el-radio-button label="likes">
            点赞
            <el-badge 
              v-if="isOwnProfile && getTypeUnreadCount('like')" 
              :value="getTypeUnreadCount('like')" 
              class="unread-badge" 
            />
          </el-radio-button>
          <el-radio-button label="stars">
            收藏
            <el-badge 
              v-if="isOwnProfile && getTypeUnreadCount('star')" 
              :value="getTypeUnreadCount('star')" 
              class="unread-badge" 
            />
          </el-radio-button>
          <el-radio-button label="follows">
            关注
            <el-badge 
              v-if="isOwnProfile && getTypeUnreadCount('follow')" 
              :value="getTypeUnreadCount('follow')" 
              class="unread-badge" 
            />
          </el-radio-button>
        </el-radio-group>
      </div>

      <div class="action-buttons">
        <el-button
          v-if="isOwnProfile && hasUnread"
          type="primary"
          :icon="Check"
          @click="handleMarkAllRead"
        >
          全部已读
        </el-button>

        <!-- 只在当前用户访问自己的主页时显示隐私设置 -->
        <el-tooltip
          v-if="isOwnProfile"
          content="设置通知列表是否对其他用户可见"
          placement="top"
        >
          <el-switch
            :model-value="notificationsPublic"
            @update:model-value="handlePrivacyChange"
            active-text="公开"
            inactive-text="私密"
          />
        </el-tooltip>
      </div>
    </div>

    <!-- 判断是否可以查看内容 -->
    <template v-if="canViewContent">
      <!-- 添加空状态显示 -->
      <div v-if="filteredNotifications.length === 0" class="empty-state">
        <el-empty 
          :description="getEmptyText(notificationType)" 
          :image-size="200"
        >
          <template #image>
            <el-icon :size="60" :color="getEmptyIconColor(notificationType)">
              <component :is="getEmptyIcon(notificationType)" />
            </el-icon>
          </template>
        </el-empty>
      </div>

      <!-- 通知时间线 -->
      <el-timeline v-else>
        <el-timeline-item
          v-for="notification in filteredNotifications"
          :key="notification.id"
          :type="getTimelineItemType(notification)"
          :timestamp="formatTime(notification.timestamp)"
          :hollow="isOwnProfile && !notification.isRead"
        >
          <el-card 
            class="notification-card"
            :class="{ 'unread': isOwnProfile && !notification.isRead }"
          >
            <template #header>
              <div class="notification-header">
                <span class="notification-type">{{ getNotificationTypeText(notification.type) }}</span>
                <el-tag size="small" :type="getTagType(notification.type)">
                  {{ notification.category }}
                </el-tag>
                <div v-if="isOwnProfile && !notification.isRead" class="unread-dot"></div>
              </div>
            </template>
            
            <div class="notification-content">
              <!-- 评论通知 -->
              <template v-if="notification.type === 'comment'">
                <div class="user-info">
                  <el-avatar :size="32" :src="notification.userAvatar" />
                  <el-link type="primary">{{ notification.username }}</el-link>
                </div>
                <p>评论了你的{{ notification.contentType === 'post' ? '帖子' : '专题' }} 
                  <el-link type="primary">{{ notification.title }}</el-link>
                </p>
                <p class="comment-content">{{ notification.content }}</p>
              </template>

              <!-- 点赞通知 -->
              <template v-else-if="notification.type === 'like'">
                <div class="user-info">
                  <el-avatar :size="32" :src="notification.userAvatar" />
                  <el-link type="primary">{{ notification.username }}</el-link>
                </div>
                <p>点赞了你的{{ notification.contentType === 'post' ? '帖子' : '专题' }}
                  <el-link type="primary">{{ notification.title }}</el-link>
                </p>
              </template>

              <!-- 收藏通知 -->
              <template v-else-if="notification.type === 'star'">
                <div class="user-info">
                  <el-avatar :size="32" :src="notification.userAvatar" />
                  <el-link type="primary">{{ notification.username }}</el-link>
                </div>
                <p>收藏了你的{{ notification.contentType === 'post' ? '帖子' : '专题' }}
                  <el-link type="primary">{{ notification.title }}</el-link>
                </p>
              </template>

              <!-- 关注通知 -->
              <template v-else-if="notification.type === 'follow'">
                <div class="user-info">
                  <el-avatar :size="32" :src="notification.userAvatar" />
                  <el-link type="primary">{{ notification.username }}</el-link>
                </div>
                <p>关注了你</p>
                <div class="follow-actions" v-if="!notification.isFollowing">
                  <el-button type="primary" size="small" @click="handleFollow(notification)">
                    回关
                  </el-button>
                </div>
              </template>
            </div>
          </el-card>
        </el-timeline-item>
      </el-timeline>

      <!-- 加载更多 -->
      <div class="load-more" v-if="hasMore">
        <el-button :loading="loading" @click="loadMore">加载更多</el-button>
      </div>
    </template>
    <template v-else>
      <private-content message="该用户的通知列表已设为私密" />
    </template>
  </div>
</template>

<script setup lang="ts">
import { ref, computed, watch, onMounted } from 'vue'
import dayjs from 'dayjs'
import relativeTime from 'dayjs/plugin/relativeTime'
import 'dayjs/locale/zh-cn'
import { ElMessage } from 'element-plus'
import { ChatDotSquare, Star, UserFilled, Check } from '@element-plus/icons-vue'
import { HeartOutlined, HeartFilled } from '@ant-design/icons-vue'
import { useUserStore } from '@/stores/user'
import { eventBus } from '@/utils/eventBus'
import { useRoute } from 'vue-router'
import PrivateContent from './PrivateContent.vue'

dayjs.extend(relativeTime)
dayjs.locale('zh-cn')

interface Notification {
  id: number
  type: 'comment' | 'like' | 'star' | 'follow'
  contentType?: 'post' | 'topic'
  username: string
  userAvatar: string
  title?: string
  content?: string
  category: string
  isFollowing?: boolean
  isRead: boolean
  timestamp: string
}

const notificationType = ref('all')
const loading = ref(false)
const hasMore = ref(true)

const userStore = useUserStore()
const route = useRoute()

// 判断是否是当前用户的主页
const isOwnProfile = computed(() => {
  return route.params.id === userStore.userInfo?.id
})

// 获取用户信息
const userInfo = computed(() => {
  return userStore.userInfo
})

// 获取用户通知可见性设置
const notificationsPublic = ref(userStore.userInfo?.notificationsPublic ?? false)

// 模拟通知数据
const notifications = ref<Notification[]>([
  {
    id: 1,
    type: 'comment',
    contentType: 'post',
    username: '心理咨询师小王',
    userAvatar: '',
    title: '如何缓解焦虑',
    content: '这篇文章写得很好，我也来分享一下我的经验...',
    category: '评论互动',
    isRead: false,
    timestamp: '2024-03-15 14:30:00'
  },
  {
    id: 2,
    type: 'like',
    contentType: 'topic',
    username: '阳光探索者',
    userAvatar: '',
    title: '情绪管理技巧系列',
    category: '点赞互动',
    isRead: false,
    timestamp: '2024-03-14 10:15:00'
  },
  {
    id: 3,
    type: 'star',
    contentType: 'post',
    username: '心理学研究生小李',
    userAvatar: '',
    title: '走出抑郁的经验分享',
    category: '收藏互动',
    isRead: false,
    timestamp: '2024-03-13 16:45:00'
  },
  {
    id: 4,
    type: 'follow',
    username: '快乐成长',
    userAvatar: '',
    category: '关注互动',
    isFollowing: false,
    isRead: false,
    timestamp: '2024-03-12 09:20:00'
  },
  // 添加更多评论通知
  {
    id: 5,
    type: 'comment',
    contentType: 'topic',
    username: '心灵探索者',
    userAvatar: '',
    title: '压力管理专题',
    content: '这个专题对我帮助很大，希望能有更多这样的内容...',
    category: '评论互动',
    isRead: false,
    timestamp: '2024-03-11 16:30:00'
  },
  // 添加更多点赞通知
  {
    id: 6,
    type: 'like',
    contentType: 'post',
    username: '阳光心态',
    userAvatar: '',
    title: '如何培养积极心态',
    category: '点赞互动',
    isRead: false,
    timestamp: '2024-03-10 11:20:00'
  }
])

// 修改筛选通知逻辑
const filteredNotifications = computed(() => {
  if (notificationType.value === 'all') return notifications.value
  
  // 将单数形式转换为复数形式进行匹配
  const typeMap: Record<string, string> = {
    'comments': 'comment',
    'likes': 'like',
    'stars': 'star',
    'follows': 'follow'
  }
  
  return notifications.value.filter(notification => 
    notification.type === typeMap[notificationType.value]
  )
})

// 格式化时间
const formatTime = (timestamp: string) => {
  return dayjs(timestamp).fromNow()
}

// 获取通知类型样式
const getNotificationType = (type: string) => {
  switch (type) {
    case 'comment':
      return 'success'
    case 'like':
      return 'info'
    case 'star':
      return 'warning'
    case 'follow':
      return 'primary'
    default:
      return 'info'
  }
}

// 获取通知类型文本
const getNotificationTypeText = (type: string) => {
  switch (type) {
    case 'comment':
      return '收到评论'
    case 'like':
      return '收到点赞'
    case 'star':
      return '收到收藏'
    case 'follow':
      return '新增关注'
    default:
      return '其他通知'
  }
}

// 获取标签类型
const getTagType = (type: string) => {
  switch (type) {
    case 'comment':
      return 'success'
    case 'like':
      return 'info'
    case 'star':
      return 'warning'
    case 'follow':
      return 'primary'
    default:
      return ''
  }
}

// 处理关注
const handleFollow = async (notification: Notification) => {
  try {
    notification.isFollowing = true
    ElMessage.success(`已关注 ${notification.username}`)
  } catch (error) {
    ElMessage.error('操作失败，请稍后重试')
  }
}

// 加载更多
const loadMore = async () => {
  loading.value = true
  try {
    await new Promise(resolve => setTimeout(resolve, 1000))
    hasMore.value = false
  } finally {
    loading.value = false
  }
}

// 获取空状态文本
const getEmptyText = (type: string) => {
  switch (type) {
    case 'comments':
      return '暂无评论通知'
    case 'likes':
      return '暂无点赞通知'
    case 'stars':
      return '暂无收藏通知'
    case 'follows':
      return '暂无关注通知'
    default:
      return '暂无任何通知'
  }
}

// 获取空状态图标
const getEmptyIcon = (type: string) => {
  switch (type) {
    case 'comments':
      return ChatDotSquare
    case 'likes':
      return HeartFilled
    case 'stars':
      return Star
    case 'follows':
      return UserFilled
    default:
      return ChatDotSquare
  }
}

// 获取空状态图标颜色
const getEmptyIconColor = (type: string) => {
  switch (type) {
    case 'comments':
      return '#67C23A'  // 绿色
    case 'likes':
      return '#ff4949'  // 红色
    case 'stars':
      return '#f7ba2a'  // 金色
    case 'follows':
      return '#409EFF'  // 蓝色
    default:
      return '#909399'  // 灰色
  }
}

// 计算未读通知总数
const unreadCount = computed(() => {
  return notifications.value.filter(notification => !notification.isRead).length
})

// 监听未读数变化并触发事件
watch(() => unreadCount.value, (newCount) => {
  emit('update:unread-count', newCount)
})

// 定义事件
const emit = defineEmits(['update:unread-count'])

// 组件挂载时触发一次更新
onMounted(() => {
  emit('update:unread-count', unreadCount.value)
})

// 获取特定类型的未读通知数
const getTypeUnreadCount = (type: string) => {
  return notifications.value.filter(
    notification => notification.type === type && !notification.isRead
  ).length
}

// 计算是否有未读通知
const hasUnread = computed(() => {
  return notifications.value.some(notification => !notification.isRead)
})

// 修改处理全部已读函数
const handleMarkAllRead = () => {
  notifications.value.forEach(notification => {
    notification.isRead = true
  })
  ElMessage.success('已将所有通知标记为已读')
  // 触发全部已读事件
  eventBus.emit('notifications-read')
}

// 修改处理隐私设置变更函数
const handlePrivacyChange = (value: boolean) => {
  if (userStore.userInfo) {
    userStore.updateUserInfo({
      ...userStore.userInfo,
      notificationsPublic: value
    })
    ElMessage.success(`通知列表已设为${value ? '公开' : '私密'}`)
  }
}

// 修改获取时间线项类型的函数
const getTimelineItemType = (notification: Notification) => {
  // 根据通知类型返回对应的样式
  switch (notification.type) {
    case 'comment':
      return 'success'  // 绿色
    case 'like':
      return 'danger'   // 红色
    case 'star':
      return 'warning'  // 黄色
    case 'follow':
      return 'primary'  // 蓝色
    default:
      return 'info'     // 灰色
  }
}

// 判断是否可以查看内容
const canViewContent = computed(() => {
  const targetUser = userStore.getUserById(route.params.id as string)
  return isOwnProfile.value || 
         userStore.userInfo?.roles === 'admin' || 
         targetUser?.notificationsPublic
})

// 导出未读通知数，供父组件使用
defineExpose({
  unreadCount
})
</script>

<style scoped>
.notification-list {
  padding: 20px;
}

.header-actions {
  display: flex;
  justify-content: space-between;
  align-items: center;
  margin-bottom: 24px;
}

.filter-section {
  margin-bottom: 0;
}

.notification-card {
  margin-bottom: 4px;
}

.notification-header {
  display: flex;
  justify-content: space-between;
  align-items: center;
  position: relative;
  padding-right: 16px;
}

.notification-type {
  font-weight: 500;
  color: #606266;
}

.notification-content {
  color: #303133;
}

.user-info {
  display: flex;
  align-items: center;
  gap: 8px;
  margin-bottom: 8px;
}

.comment-content {
  margin: 8px 0;
  color: #606266;
  background-color: #f5f7fa;
  padding: 8px 12px;
  border-radius: 4px;
  font-size: 14px;
}

.follow-actions {
  margin-top: 12px;
}

.load-more {
  text-align: center;
  margin-top: 24px;
}

/* 时间线节点样式 */
:deep(.el-timeline-item__node--primary) {
  background-color: #409EFF !important;  /* 蓝色 */
}

:deep(.el-timeline-item__node--success) {
  background-color: #67C23A !important;  /* 绿色 */
}

:deep(.el-timeline-item__node--warning) {
  background-color: #E6A23C !important;  /* 黄色 */
}

:deep(.el-timeline-item__node--danger) {
  background-color: #F56C6C !important;  /* 红色 */
}

:deep(.el-timeline-item__node--info) {
  background-color: #909399 !important;  /* 灰色 */
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

/* 修改爱心图标样式 */
:deep(.anticon) {
  vertical-align: middle;
  transition: transform 0.3s ease;
}

:deep(.anticon:hover) {
  transform: scale(1.2);
}

:deep(.heart-filled) {
  color: #ff4949;
  animation: like-animation 0.3s ease;
}

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

/* 修改未读通知的样式 */
.notification-card.unread {
  background-color: #f0f9ff;
  border-left: 3px solid #409EFF;
}

.notification-card.unread .notification-header {
  position: relative;
}

.notification-card.unread .notification-header::after {
  content: '';
  position: absolute;
  right: 0;
  top: 50%;
  transform: translateY(-50%);
  width: 8px;
  height: 8px;
  border-radius: 50%;
  background-color: #ff4949;
}

/* 添加开关样式 */
:deep(.el-switch) {
  margin-left: 0;
}

:deep(.el-switch__label) {
  color: #606266;
}

:deep(.el-switch.is-checked .el-switch__label--right) {
  color: #409EFF;
}

/* 添加未读徽标样式 */
.unread-badge {
  margin-left: 4px;
}

:deep(.el-badge__content) {
  background-color: #ff4949;
}

.action-buttons {
  display: flex;
  align-items: center;
  gap: 16px;
}

/* 修改全部已读按钮样式 */
.action-buttons :deep(.el-button) {
  font-size: 14px;
  padding: 8px 16px;
  height: 36px;
}

.action-buttons :deep(.el-button .el-icon) {
  font-size: 16px;
  margin-right: 4px;
}

/* 添加未读红点样式 */
.unread-dot {
  position: absolute;
  right: 0;
  top: 50%;
  transform: translateY(-50%);
  width: 8px;
  height: 8px;
  border-radius: 50%;
  background-color: #ff4949;
}
</style>