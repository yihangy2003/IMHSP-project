<template>
    <!-- 侧边栏 -->
    <el-aside width="210px" class="aside">
      <div class="logo">
        <img src="@/assets/logo.png" alt="logo" />
        <span><b>IMHS</b> Platform</span>
      </div>

      <div class="user-panel">
        <div class="user-info-container">
          <el-avatar
            :size="56"
            :src="currentUser?.avatar || defaultAvatar"
            class="user-avatar"
            shape="square"
          >
            <img :src="currentUser?.avatar || defaultAvatar" @error="handleAvatarError">
          </el-avatar>
          <div class="user-text">
            <h3 class="username">{{ currentUser?.username || '未登录' }}</h3>
            <p class="user-bio">
              {{ currentUser?.roles === 'explorer' ? '探索内心，寻找自我' : '用爱心治愈他人' }}
            </p>
          </div>
        </div>
      </div>

      <!-- 添加导航菜单 -->
      <el-menu
        :default-active="getDefaultActive"
        class="el-menu-vertical"
        :router="true"
      >
        <!-- <el-menu-item index="/home">
          <div class="menu-item">
            <el-icon><House /></el-icon>
            <span>首页</span>
          </div>
        </el-menu-item> -->

        <el-menu-item index="/topic">
          <div class="menu-item">
            <el-icon><Reading /></el-icon>
            <span>心理专题</span>
          </div>
        </el-menu-item>

        <el-menu-item index="/community">
          <div class="menu-item">
            <el-icon><Connection /></el-icon>
            <span>社区</span>
          </div>
        </el-menu-item>

        <el-menu-item :index="`/user/${userStore.userInfo?.id}`">
          <div class="menu-item">
            <el-icon><User /></el-icon>
            <span>个人中心</span>
            <el-badge v-if="notificationUnreadCount > 0" :value="notificationUnreadCount" class="notification-badge" />
          </div>
        </el-menu-item>

        <el-menu-item index="/service">
          <div class="menu-item">
            <el-icon><Service /></el-icon>
            <span>心理咨询</span>
          </div>
        </el-menu-item>

        <el-menu-item index="/chatroom">
          <div class="menu-item">
            <el-icon><ChatRound /></el-icon>
            <span>交流室</span>
            <el-badge v-if="unreadAppointments > 0" :value="unreadAppointments" class="notification-badge" />
          </div>
        </el-menu-item>

      </el-menu>
      
      <!-- 移除聊天分割线 -->
      <!-- <el-divider class="menu-divider">
        <el-icon><ChatDotRound /></el-icon>
      </el-divider> -->

      <div class="chat-container" :class="{ 'minimized': isMinimized }">
        <div class="chat-header" @click="toggleChat">
          <div class="chat-header-title">
            <h3>在线聊天</h3>
            <el-badge 
              v-if="totalUnreadCount > 0" 
              :value="totalUnreadCount" 
              :max="99"
              class="chat-unread-badge"
            />
          </div>
          <el-icon>
            <component :is="isMinimized ? Plus : Minus" />
          </el-icon>
        </div>
        <div class="chat-content" :class="{ 'minimized': isMinimized }">
          <el-scrollbar 
            ref="messageScrollbar"
            class="messages-container" 
            view-class="messages-view"
          >
            <div class="chat-list">
              <template v-if="recentChats.length">
                <div v-for="(chat, index) in recentChats" :key="chat.id" class="chat-item" @click="handleChatClick(chat)">
                  <el-avatar :size="32" :src="chat.avatar" />
                  <div class="chat-info">
                    <div class="chat-header-info">
                      <span class="chat-name">{{ chat.name }}</span>
                      <span class="chat-time">{{ chat.time }}</span>
                    </div>
                    <div class="chat-message-wrapper">
                      <span class="chat-message" v-html="formatMessage(chat.lastMessage)"></span>
                      <el-badge v-if="chat.unread" :value="chat.unread" class="unread-badge" type="danger" />
                    </div>
                  </div>
                  <div v-if="index !== recentChats.length - 1" class="chat-divider"></div>
                </div>
              </template>
              <div v-else class="empty-chat">
                <el-icon class="empty-icon"><ChatLineRound /></el-icon>
                <p class="empty-text">暂无聊天记录</p>
                <p class="empty-tip">去社区认识更多新朋友吧！</p>
              </div>
            </div>
          </el-scrollbar>
        </div>
      </div>

      <el-divider class="bottom-divider" />
      
      <div class="bottom-menu">
        <div class="menu-item" @click="showGuide">
          <el-icon><Guide /></el-icon>
          <span>平台指引</span>
        </div>
        <div class="menu-item" @click="showAbout">
          <el-icon><InfoFilled /></el-icon>
          <span>关于我们</span>
        </div>
      </div>

      <!-- 添加退出登录按钮 -->
      <div class="logout-section">
        <el-button 
          type="danger" 
          plain
          class="logout-button"
          @click="handleLogout"
        >
          <el-icon><SwitchButton /></el-icon>
          退出登录
        </el-button>
      </div>
    </el-aside>

    <!-- 平台指引对话框 -->
    <el-dialog
        v-model="guideVisible"
        :title="null"
        :show-close="false"
        :modal="true"
        :close-on-click-modal="true"
        class="guide-dialog"
        width="800px"
        style="margin-top: 70px;"
    >
        <template #header>
        <div class="guide-header">
            <div class="guide-title">
            <el-icon><Guide /></el-icon>
            <span>平台指引</span>
            </div>
            <el-icon class="close-icon" @click="guideVisible = false"><Close /></el-icon>
        </div>
        </template>

        <el-carousel
        height="460px"
        :autoplay="false"
        :initial-index="currentGuideIndex"
        @change="handleSlideChange"
        trigger="click"
        indicator-position="outside"
        class="guide-carousel"
        >
            <el-carousel-item v-for="(guide, index) in guideImages" :key="index">
                <div class="guide-slide">
                    <img :src="guide.url" :alt="guide.title" class="guide-image" />
                </div>
            </el-carousel-item>
        </el-carousel>
    </el-dialog>

    <!-- 关于我们对话框 -->
    <el-dialog
        v-model="aboutVisible"
        :title="null"
        width="600px"
        :show-close="true"
        class="about-dialog"
    >
        <template #header>
        <div class="about-header">
            <el-icon><InfoFilled /></el-icon>
            <span>关于我们</span>
        </div>
        </template>
        <div class="about-content">
        <h3>平台宗旨</h3>
        <p>致力于为每个人提供专业、温暖的心理支持，让心理健康服务更加普及和便捷。</p>
        
        <h3>我们的团队</h3>
        <p>由心理学专家、资深咨询师和技术专家组成的专业团队，致力于打造最优质的心理健康服务平台。</p>
        
        <h3>发展目标</h3>
        <p>建立覆盖全面的心理健康生态系统，让每个人都能便捷地获得优质的心理健康服务。</p>
        
        <h3>联系我们</h3>
        <p>邮箱：contact@imhsp.com</p>
        <p>地址：XX省XX市XX区XX路XX号</p>
        </div>
    </el-dialog>

    <!-- 修改聊天对话框内容 -->
    <el-dialog
      v-model="showChatDialog"
      :title="currentChat?.name"
      width="600px"
      class="chat-dialog"
      :before-close="handleCloseChatDialog"
      style="margin-top: 70px;"
    >
      <div class="chat-dialog-content">
        <el-scrollbar 
          ref="messageScrollbar"
          class="messages-container" 
          view-class="messages-view"
        >
          <div class="messages-list">
            <div class="chat-notice">
              <el-icon><CircleCheckFilled /></el-icon>
              <span>你们已经相互关注，可以开始聊天啦！</span>
            </div>
            
            <div v-for="message in currentMessages" 
              :key="message.id" 
              class="message-item" 
              :class="{ 'self': message.isSelf }"
            >
              <el-avatar :size="36" :src="message.senderAvatar" class="message-avatar" />
              <div class="message-content">
                <div class="message-info">
                  <span class="sender-name">{{ message.senderName }}</span>
                  <span class="message-time">{{ message.timestamp }}</span>
                </div>
                <div class="message-bubble" v-html="formatMessage(message.content)"></div>
              </div>
            </div>
          </div>
        </el-scrollbar>
        <div class="chat-input-area">
          <el-input
            v-model="messageText"
            type="textarea"
            :rows="2"
            placeholder="输入消息..."
            @keydown.enter="handleEnterPress"
          />
          <el-button type="primary" @click="sendMessage">发送</el-button>
        </div>
      </div>
    </el-dialog>
</template>

<script setup lang="ts">
import { ref, computed, onMounted, onUnmounted, nextTick } from 'vue'
import { useRouter, useRoute } from 'vue-router'
import { ElMessageBox } from 'element-plus'
import { 
  House, 
  Reading, 
  Connection,
  Service,
  User,
  ChatDotRound,
  Message,
  ChatLineRound,
  Guide,
  InfoFilled,
  Close,
  Minus,
  ChatRound,
  Plus,
  CircleCheckFilled,
  SwitchButton,
} from '@element-plus/icons-vue'
import { useUserStore } from '@/stores/user'
import type { UserInfo } from '@/types/user'
import eventBus, { EventType } from '@/utils/eventBus'
import { auth } from '@/api/auth'
import { getToken } from '@/utils/auth'

const router = useRouter()
const route = useRoute()
const userStore = useUserStore()

const getDefaultActive = computed(() => {
  const path = route.path
  if (path.startsWith('/community/')) {
    return '/community'
  }
  if (path.startsWith('/topic/')) {
    return '/topic'
  }
  return path
})

const handleLogout = async () => {
  try {
    await userStore.logout()
    router.push('/login')
  } catch (error) {
    console.error('退出登录失败:', error)
  }
}

console.log(userStore.userInfo)

// 修改聊天数据
const recentChats = ref([
  {
    id: 1,
    name: '张医生',
    avatar: '/avatars/doctor1.jpg',
    lastMessage: '记得按时吃药，保持良好的作息',
    unread: 2,
    time: '12:30'
  },
  {
    id: 2,
    name: '李咨询师',
    avatar: '/avatars/counselor1.jpg',
    lastMessage: '下周二下午3点见，不要迟到哦',
    unread: 1,
    time: '11:45'
  },
  {
    id: 3,
    name: '王医生',
    avatar: '/avatars/doctor2.jpg',
    lastMessage: '最近感觉怎么样？有好转吗？',
    unread: 0,
    time: '昨天'
  },
  {
    id: 4,
    name: '心理互助群',
    avatar: '/avatars/group1.jpg',
    lastMessage: '[群消息] 小王：分享一下我的经历...',
    unread: 5,
    time: '昨天'
  },
  {
    id: 5,
    name: '赵咨询师',
    avatar: '/avatars/counselor2.jpg',
    lastMessage: '这是我推荐的一些放松练习',
    unread: 0,
    time: '周二'
  },
  {
    id: 6,
    name: '心理成长群',
    avatar: '/avatars/group2.jpg',
    lastMessage: '[群消息] 管理员：今晚8点线上分享会',
    unread: 3,
    time: '周一'
  },
  {
    id: 7,
    name: '陈医生',
    avatar: '/avatars/doctor3.jpg',
    lastMessage: '如果有不适随时联系我',
    unread: 0,
    time: '上周'
  },
  {
    id: 8,
    name: '情绪管理小组',
    avatar: '/avatars/group3.jpg',
    lastMessage: '[群消息] 小李：谢谢大家的建议',
    unread: 0,
    time: '上周'
  },
  {
    id: 9,
    name: '吴咨询师',
    avatar: '/avatars/counselor3.jpg',
    lastMessage: '建议你尝试一下正念冥想',
    unread: 0,
    time: '上周'
  },
  {
    id: 10,
    name: '压力缓解群',
    avatar: '/avatars/group4.jpg',
    lastMessage: '[群消息] 小张：分享一个减压方法',
    unread: 0,
    time: '上周'
  }
])

interface ChatMessage {
  id: number
  content: string
  senderId: number | string
  senderName: string
  senderAvatar: string
  timestamp: string
  type: 'text' | 'image'
  isSelf: boolean
}

// 添加聊天消息数据
const chatMessages = ref<Record<number, ChatMessage[]>>({
  1: [
    {
      id: 1,
      content: '最近睡眠质量怎么样？',
      senderId: 'doctor1',
      senderName: '张医生',
      senderAvatar: '/avatars/doctor1.jpg',
      timestamp: '昨天 14:30',
      type: 'text',
      isSelf: false
    },
    {
      id: 2,
      content: '还是有点失眠，但比之前好多了',
      senderId: 'self',
      senderName: '我',
      senderAvatar: userStore.userInfo?.avatar || defaultAvatar,
      timestamp: '昨天 14:35',
      type: 'text',
      isSelf: true
    },
    {
      id: 3,
      content: '记得按时吃药，保持良好的作息，晚上尽量不要玩手机',
      senderId: 'doctor1',
      senderName: '张医生',
      senderAvatar: '/avatars/doctor1.jpg',
      timestamp: '昨天 14:36',
      type: 'text',
      isSelf: false
    },
    {
      id: 4,
      content: '别忘了！',
      senderId: 'doctor1',
      senderName: '张医生',
      senderAvatar: '/avatars/doctor1.jpg',
      timestamp: '昨天 14:36',
      type: 'text',
      isSelf: false
    },
    {
      id: 5,
      content: '别忘了！',
      senderId: 'doctor1',
      senderName: '张医生',
      senderAvatar: '/avatars/doctor1.jpg',
      timestamp: '昨天 14:36',
      type: 'text',
      isSelf: false
    },
    {
      id: 6,
      content: '别忘了！',
      senderId: 'doctor1',
      senderName: '张医生',
      senderAvatar: '/avatars/doctor1.jpg',
      timestamp: '昨天 14:36',
      type: 'text',
      isSelf: false
    }
  ]
})

// 当前聊天消息
const currentMessages = computed(() => {
  return chatMessages.value[currentChat.value?.id] || []
})

// 添加聊天相关状态
const showChatDialog = ref(false)
const currentChat = ref<any>(null)
const messageText = ref('')

// 添加 ref 用于获取滚动组件实例
const messageScrollbar = ref()

// 修改滚动到底部的函数
const scrollToBottom = () => {
  if (messageScrollbar.value) {
    const scrollbarRef = messageScrollbar.value
    const wrapperRef = scrollbarRef.$refs.wrapRef
    if (wrapperRef) {
      const scrollHeight = wrapperRef.scrollHeight
      scrollbarRef.setScrollTop(scrollHeight)
    }
  }
}

// 修改聊天点击处理函数
const handleChatClick = (chat: any) => {
  currentChat.value = chat
  showChatDialog.value = true
  // 清除未读消息
  chat.unread = 0
  
  // 等待对话框完全打开后再滚动到底部
  nextTick(() => {
    setTimeout(() => {
      scrollToBottom()
    }, 200) // 增加延时确保对话框完全打开
  })
}

// 添加消息格式化函数
const formatMessage = (content: string) => {
  return content.replace(/\n/g, '<br>')
}

// 修改发送消息处理函数
const sendMessage = () => {
  if (!messageText.value.trim()) return
  
  const newMessage: ChatMessage = {
    id: Date.now(),
    content: messageText.value.replace(/\r\n/g, '\n'), // 统一换行符
    senderId: 'self',
    senderName: '我',
    senderAvatar: userStore.userInfo?.avatar || defaultAvatar,
    timestamp: new Date().toLocaleTimeString(),
    type: 'text',
    isSelf: true
  }

  if (!chatMessages.value[currentChat.value.id]) {
    chatMessages.value[currentChat.value.id] = []
  }
  chatMessages.value[currentChat.value.id].push(newMessage)
  messageText.value = ''

  // 使用新的滚动函数，添加小延时确保内容已更新
  nextTick(() => {
    setTimeout(() => {
      scrollToBottom()
    }, 100)
  })
}

// 添加关闭对话框处理函数（之前被误删了）
const handleCloseChatDialog = () => {
  showChatDialog.value = false
  currentChat.value = null
  messageText.value = ''
}

// 修改计算总未读消息数的方法
const totalUnreadCount = computed(() => 
  recentChats.value.reduce((sum, chat) => sum + (chat.unread || 0), 0)
)

// 指引相关
const guideVisible = ref(false)
const currentGuideIndex = ref(0)
const guideImages = [
  {
    url: '/guide/guide1.png',
    title: '首页介绍',
    description: '了解平台的主要功能和服务'
  },
  {
    url: '/guide/guide2.png',
    title: '社区功能',
    description: '探索社区互动和交流方式'
  },
  {
    url: '/guide/guide3.png',
    title: '咨询服务',
    description: '了解如何预约和进行心理咨询'
  }
]

const showGuide = () => {
  guideVisible.value = true
}

const handleSlideChange = (index: number) => {
  currentGuideIndex.value = index
}

// 关于我们
const aboutVisible = ref(false)
const showAbout = () => {
  aboutVisible.value = true
}

const defaultAvatar = 'https://cube.elemecdn.com/0/88/03b0d39583f48206768a7534e55bcpng.png'

// 处理头像加载错误
const handleAvatarError = (e: Event) => {
  const target = e.target as HTMLImageElement
  target.src = defaultAvatar
}

// 使用计算属性获取用户信息
const currentUser = computed<UserInfo | null>(() => userStore.userInfo)

const notificationUnreadCount = ref(6)

// 直接在脚本顶层设置事件监听
const handleNotificationsRead = () => {
  nextTick(() => {
    notificationUnreadCount.value = 0
  })
}

// 在组件挂载时添加事件监听
onMounted(() => {
  eventBus.on(EventType.NOTIFICATIONS_READ, handleNotificationsRead)
  eventBus.on(EventType.CLOSE_CHAT, () => {
    isMinimized.value = true
  })
})

// 在组件卸载时移除事件监听
onUnmounted(() => {
  eventBus.off(EventType.NOTIFICATIONS_READ, handleNotificationsRead)
  eventBus.off(EventType.CLOSE_CHAT)
})

// 修改初始状态为关闭
const isMinimized = ref(true)

const toggleChat = () => {
  isMinimized.value = !isMinimized.value
  if (!isMinimized.value) {
    // 打开聊天框时，发送关闭用户卡片事件
    eventBus.emit(EventType.CLOSE_USER_CARD)
  }
}

// 监听关闭聊天框事件
onMounted(() => {
  eventBus.on(EventType.CLOSE_CHAT, () => {
    isMinimized.value = true
  })
})

onUnmounted(() => {
  eventBus.off(EventType.CLOSE_CHAT)
})

// 修改回车键处理函数
const handleEnterPress = (e: KeyboardEvent) => {
  if (e.shiftKey) {
    // Shift + Enter，允许换行
    return
  } else {
    // 仅按 Enter，发送消息
    e.preventDefault()
    if (messageText.value.trim()) {
      sendMessage()
    }
  }
}

// 获取未读预约数量
const unreadAppointments = computed(() => {
  return userStore.userInfo?.unreadAppointments || 0
})
</script>

<style scoped>
@import url("https://fonts.googleapis.com/css2?family=Poppins:wght@300;400;500;600;700;800;900&display=swap");

* {
  margin: 0;
  padding: 0;
  box-sizing: border-box;
  font-family: "Poppins", sans-serif;
}

.aside {
  background-color: #fff;
  transition: width 0.3s;
  overflow: hidden;
  border-right: 1px solid #e6e6e6;
  position: relative;
  height: 100%;
}

.logo {
  height: 45px;
  display: flex;
  align-items: center;
  padding: 0 25px;
  color: #000;
}

.logo img {
  width: 32px;
  height: 32px;
  margin-right: 12px;
}

.el-menu-vertical {
  border-right: none;
  /* margin-top: 10px; */
  margin-top: 30px;
}

.header {
  background-color: #fff;
  border-bottom: 1px solid #e6e6e6;
  display: flex;
  align-items: center;
  justify-content: space-between;
  padding: 0 20px;
}

.header-left {
  display: flex;
  align-items: center;
}

.fold-btn {
  font-size: 20px;
  margin-right: 20px;
  cursor: pointer;
}

.header-right {
  display: flex;
  align-items: center;
}

.user-info {
  display: flex;
  align-items: center;
  cursor: pointer;
}

.username {
  margin-left: 8px;
  font-size: 14px;
}

:deep(.el-menu) {
  border-right: none;
}

:deep(.el-menu-item) {
  height: 50px;
  line-height: 50px;
  padding: 0 20px !important;
  background-color: transparent !important;
  color: inherit !important;
  margin-bottom: 8px;
}

:deep(.el-menu-item:hover) {
  background-color: transparent !important;
}

.menu-item {
  width: 165px;
  display: flex;
  align-items: center;
  height: 88%;
  padding: 0 10px;
  border-radius: 8px;
  transition: all 0.3s;
  color: #79797c;
  font-weight: 600;
  margin: 4px 0;
  position: relative;
}

.menu-item span {
  font-weight: 600;
  font-size: 14px;
  letter-spacing: 0.5px;
}

.menu-item:hover {
  background-color: #f0f2f5;
  color: #454647;
  box-shadow: 0 2px 12px rgba(0, 0, 0, 0.15);
}

:deep(.el-menu-item.is-active) .menu-item {
  background-color: #ecf5ff;
  color: #409EFF;
  box-shadow: 0 4px 10px rgba(64, 158, 255, 0.2);
  border-radius: 8px;
}

.menu-item .el-icon {
  margin-right: 10px;
  font-size: 18px;
  color: inherit;
}

.user-panel {
  padding: 10px 16px;
  padding-bottom: 0px;
}

.user-info-container {
  display: flex;
  align-items: center;
  gap: 12px;
}

.user-text {
  flex: 1;
  text-align: left;
}

.user-panel .username {
  margin: 0 0 4px;
  font-size: 15px;
  font-weight: 600;
  color: #333;
}

.user-panel .user-bio {
  font-size: 12px;
  color: #666;
  margin: 0;
  line-height: 1.4;
}

:deep(.el-avatar) {
  flex-shrink: 0;
}

:deep(.el-menu) {
  --el-menu-text-color: inherit;
  --el-menu-hover-text-color: inherit;
  --el-menu-active-color: inherit;
}

:deep(.el-menu-item:last-child) {
  margin-bottom: 0;
}

/* 移除分割线相关样式 */
/* .menu-divider {
  margin: 16px 0;
} */

.chat-container {
  position: fixed;
  right: 20px;
  bottom: 0;
  width: 300px;
  background-color: #fff;
  border-radius: 8px 8px 0 0;
  box-shadow: 0 -2px 12px rgba(0, 0, 0, 0.1);
  z-index: 100;
  transform: translateY(0);
  transition: all 0.3s cubic-bezier(0.4, 0, 0.2, 1);
}

.chat-container.minimized {
  transform: translateY(calc(100% - 48px));
  box-shadow: none;
}

.chat-header {
  display: flex;
  justify-content: space-between;
  align-items: center;
  padding: 12px 16px;  /* 增加一点水平内边距 */
  border-bottom: 1px solid #e4e7ed;
  cursor: pointer;
  user-select: none;
  transition: all 0.3s;
  background-color: #fff;
  height: 48px;
}

.chat-header h3 {
  font-size: 15px;
  font-weight: 600;
  color: #303133;
  margin: 0;
}

.chat-container.minimized .chat-header {
  box-shadow: 0 -2px 8px rgba(0, 0, 0, 0.1);
  border-bottom: none;
}

.chat-header:hover {
  background-color: #f5f7fa;
}

.chat-title {
  font-size: 14px;
  font-weight: 600;
  color: #606266;
}

.chat-content {
  padding: 16px;
  background-color: #fff;
  min-height: 500px;
  transform-origin: top;
  transition: all 0.3s cubic-bezier(0.4, 0, 0.2, 1);
  opacity: 1;
  transform: scaleY(1);
  height: 500px;
}

.chat-content.minimized {
  transform: scaleY(0);
  height: 0;
  padding: 0 16px;
  opacity: 0;
}

.chat-list-container {
  margin-right: -8px;
  padding-right: 8px;
  margin-bottom: 8px;
}

.chat-list {
  display: flex;
  flex-direction: column;
  gap: 8px;
  padding-right: 4px;
}

.chat-item {
  height: 64px;
  min-height: 64px;
  display: flex;
  align-items: center;
  padding: 12px;
  border-radius: 8px;
  cursor: pointer;
  transition: all 0.3s;
  position: relative;
}

.chat-item:hover {
  background-color: #ecf5ff;
}

.chat-info {
  margin-left: 12px;
  flex: 1;
  overflow: hidden;
  padding: 4px 0;
}

.chat-header-info {
  display: flex;
  justify-content: space-between;
  align-items: center;
  margin-bottom: 4px;
}

.chat-name {
  display: block;
  font-size: 14px;
  font-weight: 500;
  color: #303133;
  margin-bottom: 2px;
}

.chat-right {
  display: flex;
  flex-direction: column;
  align-items: flex-end;
  gap: 4px;
}

.chat-time {
  font-size: 12px;
  color: #909399;
}

.chat-message-wrapper {
  display: flex;
  align-items: center;
  justify-content: space-between;
  gap: 8px;
}

.chat-message {
  flex: 1;
  font-size: 12px;
  color: #909399;
  white-space: nowrap;
  overflow: hidden;
  text-overflow: ellipsis;
}

.unread-badge {
  flex-shrink: 0;
  transform: scale(0.8);
}

:deep(.el-badge__content.is-fixed) {
  position: static;
  transform: none;
}

.empty-chat {
  padding: 20px 0;
  text-align: center;
  color: #909399;
}

.empty-icon {
  font-size: 24px;
  margin-bottom: 8px;
  color: #c0c4cc;
}

.empty-text {
  font-size: 14px;
  margin-bottom: 4px;
}

.empty-tip {
  font-size: 12px;
  color: #c0c4cc;
}

.chat-divider {
  position: absolute;
  bottom: -4px;
  left: 8px;
  right: 8px;
  height: 1px;
  background-color: #e4e7ed;
}

.bottom-divider {
  margin: 12px 0;
}

.bottom-menu {
  padding: 0 16px;
  margin-top: 8px;
}

.bottom-menu .menu-item {
  display: flex;
  align-items: center;
  padding: 12px;
  border-radius: 8px;
  cursor: pointer;
  transition: all 0.3s;
  color: #606266;
  margin-bottom: 8px;
}

.bottom-menu .menu-item:hover {
  background-color: #ecf5ff;
  color: #409EFF;
}

.bottom-menu .menu-item .el-icon {
  margin-right: 12px;
  font-size: 18px;
}

.guide-slide {
  display: flex;
  align-items: center;
  justify-content: center;
  height: 100%;
  background: #fff;
  padding: 10px 20px;
}

.guide-image {
  width: 100%;
  height: 420px;
  object-fit: contain;
  border-radius: 8px;
}

.guide-info {
  display: none;
}

.guide-info h3 {
  display: none;
}

.guide-info p {
  display: none;
}

:deep(.el-carousel__indicators) {
  bottom: -25px;
}

:deep(.el-carousel__indicator) {
  padding: 12px 4px;
}

:deep(.el-carousel__button) {
  width: 30px;
  height: 3px;
  background-color: #dcdfe6;
  border-radius: 3px;
}

:deep(.el-carousel__indicator.is-active .el-carousel__button) {
  background-color: #409EFF;
}

:deep(.guide-dialog .el-overlay) {
  background-color: rgba(0, 0, 0, 0.7);
  backdrop-filter: blur(4px);
}

.about-content {
  padding: 20px;
}

.about-content h3 {
  color: #303133;
  margin: 20px 0 10px;
  font-size: 16px;
}

.about-content h3:first-child {
  margin-top: 0;
}

.about-content p {
  color: #606266;
  line-height: 1.6;
  margin: 0 0 10px;
  font-size: 14px;
}

.about-header {
  display: flex;
  align-items: center;
  gap: 8px;
  font-size: 16px;
  font-weight: 600;
  color: #303133;
}

.about-header .el-icon {
  font-size: 18px;
  color: #409EFF;
}

.guide-header {
  display: flex;
  align-items: center;
  justify-content: space-between;
  padding: 0 20px 0 20px;
  border-bottom: none;
}

.guide-title {
  display: flex;
  align-items: center;
  gap: 8px;
  font-size: 16px;
  font-weight: 600;
  color: #303133;
  height: 32px;
}

.guide-title .el-icon {
  font-size: 18px;
  color: #409EFF;
}

.close-icon {
  font-size: 20px;
  color: #909399;
  cursor: pointer;
  transition: color 0.3s;
}

.close-icon:hover {
  color: #606266;
}

.user-avatar {
  border: 2px solid #fff;
  box-shadow: 0 2px 8px rgba(0, 0, 0, 0.1);
  width: 56px;
  height: 56px;
}

.user-avatar :deep(img) {
  width: 100%;
  height: 100%;
  object-fit: cover;
  border-radius: 4px;
}

/* 修改通知徽标样式 */
.notification-badge {
  position: absolute;
  right: 22px;
  top: 16%;
  transform: translateY(-50%);
}

:deep(.el-badge__content) {
  background-color: #ff4949;
  border: none;
  font-size: 13px;  /* 增大字体 */
  height: 18px;     /* 增加高度 */
  line-height: 18px; /* 调整行高 */
  padding: 0 6px;   /* 增加内边距 */
  border-radius: 9px; /* 调整圆角 */
  font-weight: 600;  /* 加粗字体 */
}

.chat-dialog {
  :deep(.el-dialog__body) {
    padding: 0;
  }

  :deep(.el-dialog__header) {
    padding: 16px 20px;
    margin: 0;
    border-bottom: 1px solid #e4e7ed;
  }

  :deep(.el-dialog__title) {
    font-size: 16px;
    font-weight: 600;
  }

  :deep(.el-dialog) {
    border-radius: 8px;
    overflow: hidden;
    padding: 0;
  }
}

.chat-dialog-content {
  height: 500px;
  display: flex;
  flex-direction: column;
}

.messages-container {
  flex: 1;
  background-color: #f5f7fa;
  height: 100%;
}

.messages-view {
  padding: 20px 0;
}

.messages-list {
  min-height: 100%;
  display: flex;
  flex-direction: column;
}

.chat-input-area {
  padding: 16px 20px;
  border-top: 1px solid #e4e7ed;
  display: flex;
  gap: 12px;
  align-items: flex-start;
  background-color: #fff;
}

.chat-input-area .el-input {
  flex: 1;
}

:deep(.chat-input-area .el-textarea__inner) {
  resize: none;
  border-radius: 8px;
  padding: 8px 12px;
  min-height: 54px;
  font-size: 14px;
  line-height: 1.6;
  box-shadow: 0 2px 6px rgba(0, 0, 0, 0.04);
  transition: all 0.3s;
  
  /* 添加滚动条样式 */
  &::-webkit-scrollbar {
    width: 6px;
  }

  &::-webkit-scrollbar-thumb {
    background-color: #dcdfe6;
    border-radius: 3px;
  }

  &::-webkit-scrollbar-thumb:hover {
    background-color: #c0c4cc;
  }

  &::-webkit-scrollbar-track {
    background-color: transparent;
  }
}

:deep(.chat-input-area .el-textarea__inner:focus) {
  box-shadow: 0 2px 12px rgba(64, 158, 255, 0.1);
}

.chat-input-area .el-button {
  height: 36px;
  padding: 0 20px;
  font-size: 14px;
  border-radius: 8px;
  margin-top: 1px;
}

.message-item {
  display: flex;
  gap: 12px;
  margin-bottom: 20px;
  padding: 0 12px;
}

.message-item.self {
  flex-direction: row-reverse;
}

.message-content {
  max-width: 70%;
}

.message-info {
  margin-bottom: 4px;
  display: flex;
  gap: 8px;
  align-items: center;
}

.message-item.self .message-info {
  flex-direction: row-reverse;
}

.sender-name {
  font-size: 13px;
  color: #909399;
}

.message-time {
  font-size: 12px;
  color: #c0c4cc;
}

.message-bubble {
  padding: 10px 16px;
  background-color: #fff;
  border-radius: 12px;
  font-size: 14px;
  line-height: 1.5;
  color: #303133;
  box-shadow: 0 2px 8px rgba(0, 0, 0, 0.04);
}

.message-item.self .message-bubble {
  background-color: #ecf5ff;
  color: #409EFF;
}

.chat-notice {
  display: flex;
  align-items: center;
  justify-content: center;
  gap: 8px;
  padding: 12px;
  margin-bottom: 20px;
  color: #67c23a;
  font-size: 14px;
  background-color: #f0f9eb;
  border-radius: 8px;
  box-shadow: 0 2px 6px rgba(0, 0, 0, 0.04);
}

.chat-notice .el-icon {
  font-size: 16px;
}

.chat-header-title {
  display: flex;
  align-items: center;
  gap: 8px;
}

.chat-unread-badge {
  transform: scale(0.8);
  transform-origin: left center;
}

.chat-unread-badge :deep(.el-badge__content) {
  background-color: #ff4949;
  border: 2px solid #fff;
}

/* 添加未读徽标样式 */
.menu-item {
  position: relative;
  display: flex;
  align-items: center;
}

:deep(.el-badge__content) {
  background-color: #ff4949;
  border: 2px solid #fff;
  transform: scale(0.8);
  transform-origin: center;
}

:deep(.el-badge__content.is-fixed) {
  top: -5px;
  right: -15px;
}

/* 确保徽标在菜单项hover时仍然可见 */
:deep(.el-menu-item:hover .el-badge__content) {
  z-index: 2;
}

/* 添加退出登录按钮样式 */
.logout-section {
  position: absolute;
  bottom: 20px;
  left: 0;
  right: 0;
  padding: 0 16px;
}

.logout-button {
  width: 100%;
  display: flex;
  align-items: center;
  justify-content: center;
  gap: 8px;
}

.logout-button .el-icon {
  font-size: 16px;
}
</style> 