<template>
  <div class="follow-list">
    <!-- 添加头部区域 -->
    <div class="list-header">
      <div class="search-box">
        <el-input
          v-model="searchText"
          placeholder="搜索关注的用户"
          :prefix-icon="Search"
          clearable
        />
      </div>
      <!-- 只在当前用户访问自己的主页时显示隐私设置 -->
      <el-tooltip
        v-if="isOwnProfile"
        content="设置关注列表是否对其他用户可见"
        placement="top"
      >
        <el-switch
          :model-value="followListPublic"
          @update:model-value="handlePrivacyChange"
          active-text="公开"
          inactive-text="私密"
        />
      </el-tooltip>
    </div>

    <!-- 判断是否可以查看内容 -->
    <template v-if="canViewContent">
      <!-- 用户列表 -->
      <div class="user-list">
        <el-card v-for="user in filteredUsers" :key="user.id" class="user-card">
          <div class="user-info">
            <!-- 头像和基本信息 -->
            <div class="user-basic">
              <el-avatar :size="50" :src="user.avatar" />
              <div class="user-detail">
                <h3 class="username">{{ user.username }}</h3>
                <p class="bio">{{ user.bio }}</p>
              </div>
            </div>

            <!-- 关注按钮 -->
            <el-button
              :type="getButtonType(user)"
              :plain="!user.isFollowing"
              @click="handleFollow(user)"
              class="follow-button"
            >
              {{ getFollowButtonText(user) }}
            </el-button>
          </div>

          <!-- 用户统计信息 -->
          <div class="user-stats">
            <div class="stat-item">
              <span class="stat-value">{{ user.followersCount }}</span>
              <span class="stat-label">关注者</span>
            </div>
            <div class="stat-item">
              <span class="stat-value">{{ user.followingCount }}</span>
              <span class="stat-label">正在关注</span>
            </div>
          </div>
        </el-card>
      </div>

      <!-- 加载更多 -->
      <div class="load-more" v-if="hasMore">
        <el-button :loading="loading" @click="loadMore">加载更多</el-button>
      </div>
    </template>
    <template v-else>
      <private-content message="该用户的关注列表已设为私密" />
    </template>
  </div>
</template>

<script setup lang="ts">
import { ref, computed } from 'vue'
import { Search } from '@element-plus/icons-vue'
import { ElMessage } from 'element-plus'
import { useUserStore } from '@/stores/user'
import { useRoute } from 'vue-router'
import PrivateContent from './PrivateContent.vue'

interface FollowUser {
  id: number
  username: string
  avatar: string
  bio: string
  isFollowing: boolean    // 当前用户是否关注此用户
  isFollowedBy: boolean   // 此用户是否关注当前用户
  followersCount: number
  followingCount: number
  postsCount: number
}

const route = useRoute()
const userStore = useUserStore()

const searchText = ref('')
const loading = ref(false)
const hasMore = ref(true)

// 判断是否是当前用户的主页
const isOwnProfile = computed(() => {
  return route.params.id === userStore.userInfo?.id
})

// 获取关注列表可见性设置
const followListPublic = computed(() => {
  return userStore.userInfo?.followListPublic ?? false
})

// 判断是否可以查看内容
const canViewContent = computed(() => {
  const targetUser = userStore.getUserById(route.params.id as string)
  return isOwnProfile.value || 
         userStore.userInfo?.roles === 'admin' || 
         targetUser?.followListPublic
})

// 模拟关注列表数据
const followList = ref<FollowUser[]>([
  {
    id: 1,
    username: '心理咨询师小王',
    avatar: '',
    bio: '专业心理咨询师，擅长处理情绪和压力问题',
    isFollowing: true,
    isFollowedBy: true,
    followersCount: 1280,
    followingCount: 356,
    postsCount: 89
  },
  {
    id: 2,
    username: '阳光探索者',
    avatar: '',
    bio: '在这里寻找内心的平静',
    isFollowing: true,
    isFollowedBy: false,
    followersCount: 234,
    followingCount: 167,
    postsCount: 45
  },
  {
    id: 3,
    username: '心理学研究生小李',
    avatar: '',
    bio: '正在攻读心理学硕士学位，分享专业知识',
    isFollowing: true,
    isFollowedBy: true,
    followersCount: 892,
    followingCount: 245,
    postsCount: 156
  }
])

// 过滤用户列表
const filteredUsers = computed(() => {
  if (!searchText.value) return followList.value
  const searchLower = searchText.value.toLowerCase()
  return followList.value.filter(user => 
    user.username.toLowerCase().includes(searchLower) ||
    user.bio.toLowerCase().includes(searchLower)
  )
})

// 获取关注按钮文本
const getFollowButtonText = (user: FollowUser) => {
  if (user.isFollowing && user.isFollowedBy) {
    return '相互关注'
  }
  return user.isFollowing ? '已关注' : '关注'
}

// 获取按钮类型
const getButtonType = (user: FollowUser) => {
  if (user.isFollowing) {
    return 'primary'  // 已关注和相互关注都用蓝色
  }
  return 'info'  // 未关注用灰色
}

// 处理关注/取消关注
const handleFollow = async (user: FollowUser) => {
  try {
    if (user.isFollowing) {
      // 取消关注
      user.isFollowing = false
      ElMessage.success(`已取消关注 ${user.username}`)
    } else {
      // 关注
      user.isFollowing = true
      ElMessage.success(`已关注 ${user.username}`)
    }
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

// 修改处理隐私设置变更函数
const handlePrivacyChange = (value: boolean) => {
  if (userStore.userInfo) {
    userStore.updateUserInfo({
      ...userStore.userInfo,
      followListPublic: value
    })
    ElMessage.success(`关注列表已设为${value ? '公开' : '私密'}`)
  }
}
</script>

<style scoped>
.follow-list {
  padding: 20px;
}

.list-header {
  display: flex;
  justify-content: space-between;
  align-items: center;
  margin-bottom: 24px;
}

.search-box {
  flex: 1;
  margin-right: 24px;
  margin-bottom: 0;
}

.user-list {
  display: flex;
  flex-direction: column;
  gap: 16px;
}

.user-card {
  transition: all 0.3s ease;
}

.user-card:hover {
  transform: translateY(-2px);
  box-shadow: 0 4px 12px rgba(0, 0, 0, 0.1);
}

.user-info {
  display: flex;
  justify-content: space-between;
  align-items: center;
  margin-bottom: 16px;
}

.user-basic {
  display: flex;
  align-items: center;
  gap: 16px;
}

.user-detail {
  display: flex;
  flex-direction: column;
  gap: 4px;
}

.username {
  margin: 0;
  font-size: 16px;
  font-weight: 600;
  color: #303133;
}

.bio {
  margin: 0;
  font-size: 14px;
  color: #606266;
  display: -webkit-box;
  -webkit-line-clamp: 2;
  -webkit-box-orient: vertical;
  overflow: hidden;
  text-overflow: ellipsis;
}

.user-stats {
  display: flex;
  justify-content: space-around;
  padding-top: 16px;
  border-top: 1px solid #ebeef5;
}

.stat-item {
  display: flex;
  flex-direction: column;
  align-items: center;
  gap: 4px;
}

.stat-value {
  font-size: 16px;
  font-weight: 600;
  color: #303133;
}

.stat-label {
  font-size: 12px;
  color: #909399;
}

.load-more {
  text-align: center;
  margin-top: 24px;
}

/* 添加按钮样式 */
.follow-button {
  min-width: 90px;  /* 保持按钮宽度一致 */
}

/* 覆盖 Element Plus 的默认样式 */
:deep(.el-button--info) {
  --el-button-bg-color: #909399;
  --el-button-border-color: #909399;
  --el-button-hover-bg-color: #a6a9ad;
  --el-button-hover-border-color: #a6a9ad;
}

:deep(.el-button--info.is-plain) {
  --el-button-text-color: #909399;
  --el-button-bg-color: #f4f4f5;
  --el-button-border-color: #d3d4d6;
  --el-button-hover-text-color: #409EFF;
  --el-button-hover-bg-color: #ecf5ff;
  --el-button-hover-border-color: #409EFF;
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
</style> 