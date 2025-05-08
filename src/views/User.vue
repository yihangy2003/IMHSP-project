<template>
  <div class="user-container">
    <!-- 个人信息卡片 -->
    <el-card class="info-card">
      <div class="info-header">
        <h2>个人信息</h2>
        <div class="header-actions">
          <!-- 添加预约按钮 -->
          <el-tooltip
            :content="appointmentButtonTooltip"
            :disabled="showAppointmentButton"
            effect="dark"
            placement="top"
          >
            <div class="button-wrapper" v-if="!isOwnProfile">
              <div class="appointment-info">
                <el-button 
                  type="primary" 
                  @click="showAppointmentDialog"
                  class="appointment-button"
                  :disabled="!showAppointmentButton"
                  v-if="!isOwnProfile"
                >
                  <el-icon><Calendar /></el-icon>
                  立即预约
                </el-button>
                <!-- 只在具有咨询资格时显示价格 -->
                <template v-if="userInfo?.isQualified">
                  <span v-if="userInfo.price" class="price-tag">
                    ¥{{ userInfo.price }}/次
                  </span>
                  <el-tag v-if="userInfo.isFree" type="success" size="small">免费</el-tag>
                </template>
              </div>
            </div>
          </el-tooltip>
          
          <!-- 编辑按钮 -->
          <template v-if="canEdit">
            <el-button 
              v-if="!isEditing"
              type="primary" 
              @click="handleEdit"
            >
              编辑资料
            </el-button>
            <div v-else>
              <el-button type="primary" @click="handleSave">保存</el-button>
              <el-button @click="handleCancel">取消</el-button>
            </div>
          </template>
        </div>
      </div>

      <div class="user-profile">
        <div class="avatar-section">
          <el-image 
            class="user-avatar-wrapper"
            :preview-src-list="[userInfo.avatar || defaultAvatar]"
            :src="userInfo.avatar || defaultAvatar"
            :hide-on-click-modal="false"
            preview-teleported
          >
            <template #default>
              <el-avatar 
                :size="200" 
                class="user-avatar"
                shape="square"
              >
                <img :src="userInfo.avatar || defaultAvatar" @error="handleAvatarError">
              </el-avatar>
            </template>
          </el-image>
          <div class="avatar-actions" v-if="canEdit">
            <el-button 
              type="primary" 
              size="small"
              @click="showAvatarUpload"
            >
              修改头像
            </el-button>
            <el-button
              v-if="tempAvatar"
              type="warning"
              size="small"
              @click="handleRevertAvatar"
            >
              还原
            </el-button>
            <el-button
              v-if="tempAvatar"
              type="success"
              size="small"
              @click="handleConfirmAvatar"
            >
              确认修改
            </el-button>
          </div>
          <div class="visit-count">
            <el-icon><View /></el-icon>
            <span>访问量：{{ currentUser.visitCount }}</span>
          </div>
        </div>

        <div class="info-section">
          <div class="info-item">
            <span class="label">用户名</span>
            <div class="info-content">
              <el-input 
                v-if="isEditing" 
                v-model="editForm.username"
                placeholder="请输入用户名(2-12位中英文数字下划线)"
                :class="{ 'is-invalid': !validateUsername(editForm.username) }"
              />
              <span v-else>{{ currentUser.username }}</span>
            </div>
          </div>

          <div class="info-item">
            <span class="label">密码</span>
            <span v-if="!isEditing">••••••••</span>
            <el-button v-else type="primary" link @click="showChangePassword">
              修改密码
            </el-button>
          </div>

          <div class="info-item">
            <span class="label">邮箱</span>
            <div class="info-content">
              <el-input 
                v-if="isEditing" 
                v-model="editForm.email"
                placeholder="请输入邮箱"
                :class="{ 'is-invalid': editForm.email && !validateEmail(editForm.email) }"
              />
              <span v-else>{{ formatInfo(userInfo.email, userInfo.emailPublic) }}</span>
              <el-switch
                v-if="canEdit && !isEditing"
                v-model="userInfo.emailPublic"
                @change="handlePrivacyChange('emailPublic')"
                active-text="公开"
                inactive-text="私密"
              />
            </div>
          </div>

          <div class="info-item">
            <span class="label">手机号</span>
            <div class="info-content">
              <el-input 
                v-if="isEditing" 
                v-model="editForm.phone"
                placeholder="请输入手机号"
                :class="{ 'is-invalid': editForm.phone && !validatePhone(editForm.phone) }"
              />
              <span v-else>{{ formatInfo(userInfo.phone, userInfo.phonePublic) }}</span>
              <el-switch
                v-if="canEdit && !isEditing"
                v-model="userInfo.phonePublic"
                @change="handlePrivacyChange('phonePublic')"
                active-text="公开"
                inactive-text="私密"
              />
            </div>
          </div>

          <div class="info-item">
            <span class="label">性别</span>
            <div class="info-content">
              <template v-if="isEditing">
                <el-radio-group v-model="editForm.gender">
                  <el-radio label="male" style="margin-right: 30px;">男</el-radio>
                  <el-radio label="female">女</el-radio>
                </el-radio-group>
              </template>
              <span v-else>{{ formatGender(userInfo.gender, userInfo.genderPublic) }}</span>
              <el-switch
                v-if="canEdit && !isEditing"
                v-model="userInfo.genderPublic"
                @change="handlePrivacyChange('genderPublic')"
                active-text="公开"
                inactive-text="私密"
              />
            </div>
          </div>

          <div class="info-item">
            <span class="label">所在地</span>
            <div class="info-content">
              <el-cascader
                v-if="isEditing"
                v-model="locationValue"
                :options="locationOptions"
                :props="{
                  value: 'name',
                  label: 'name',
                  children: 'children',
                  expandTrigger: 'hover'
                }"
                @change="handleLocationChange"
                placeholder="请选择所在地"
                clearable
              />
              <span v-else>{{ formatLocation(userInfo.location, userInfo.locationPublic) }}</span>
              <el-switch
                v-if="canEdit && !isEditing"
                v-model="userInfo.locationPublic"
                @change="handlePrivacyChange('locationPublic')"
                active-text="公开"
                inactive-text="私密"
              />
            </div>
          </div>

          <div class="info-item">
            <span class="label">个人简介</span>
            <div class="info-content">
              <el-input
                v-if="isEditing"
                v-model="editForm.bio"
                type="textarea"
                :rows="3"
                maxlength="50"
                show-word-limit
                :placeholder="'请输入个人简介，最多50字'"
              />
              <span v-else>{{ formatInfo(userInfo.bio, userInfo.bioPublic) }}</span>
              <el-switch
                v-if="canEdit && !isEditing"
                v-model="userInfo.bioPublic"
                @change="handlePrivacyChange('bioPublic')"
                active-text="公开"
                inactive-text="私密"
              />
            </div>
          </div>
        </div>
      </div>
    </el-card>

    <!-- 用户数据展示区 -->
    <el-card class="data-card">
      <div class="tabs-section">
        <el-tabs v-model="activeTab" class="user-tabs">
          <el-tab-pane label="动态" name="activity">
            <activity-list />
          </el-tab-pane>
          <el-tab-pane 
            v-if="showFollowingList"
            label="关注" 
            name="following"
          >
            <follow-list />
          </el-tab-pane>
          <el-tab-pane 
            v-if="showFollowerList"
            label="粉丝" 
            name="followers"
          >
            <follower-list />
          </el-tab-pane>
          <el-tab-pane 
            v-if="showNotifications"
            name="notifications"
          >
            <template #label>
              <span class="notification-tab">
                通知
                <div 
                  v-if="isOwnProfile && notificationUnreadCount > 0" 
                  class="notification-dot"
                ></div>
              </span>
            </template>
            <notification-list 
              ref="notificationListRef"
              @update:unread-count="updateUnreadCount"
            />
          </el-tab-pane>
          <el-tab-pane 
            v-if="showTestHistory"
            label="测验记录" 
            name="tests"
          >
            <test-history-list />
          </el-tab-pane>
          <el-tab-pane 
            v-if="userInfo?.isQualified" 
            label="咨询评价" 
            name="reviews"
          >
            <div class="reviews-section">
              <!-- 评价统计卡片 -->
              <el-card class="review-stats">
                <div class="stats-header">
                  <div class="rating-box">
                    <div class="rating-header">
                      <h2>{{ userInfo.rating ?? 0 }}</h2>
                      <div class="rating-stars">
                        <el-rate
                          v-model="userInfo.rating"
                          disabled
                          :max="5"
                          :allow-half="true"
                          :colors="['#FFB800', '#FFB800', '#FFB800']"
                          :void-color="'#E1E1E1'"
                          :default-value="0"
                        />
                      </div>
                    </div>
                    <p>综合评分</p>
                  </div>
                  <div class="stats-divider"></div>
                  <div class="review-counts">
                    <div class="count-item">
                      <h3>{{ reviewStats.good || 0 }}</h3>
                      <p>好评数</p>
                    </div>
                    <div class="count-item">
                      <h3>{{ reviewStats.bad || 0 }}</h3>
                      <p>差评数</p>
                    </div>
                    <div class="count-item">
                      <h3>{{ reviewStats.total ? `${reviewStats.goodRate}%` : '--' }}</h3>
                      <p>好评率</p>
                    </div>
                  </div>
                </div>
              </el-card>

              <!-- 移除 el-scrollbar，直接显示内容 -->
              <div class="reviews-list">
                <div class="list-header">
                  <el-radio-group v-model="reviewType" size="large">
                    <el-radio-button label="all">全部评价</el-radio-button>
                    <el-radio-button label="good">好评</el-radio-button>
                    <el-radio-button label="bad">差评</el-radio-button>
                  </el-radio-group>
                  
                  <el-select v-model="sortBy" placeholder="排序方式">
                    <el-option label="最新优先" value="latest" />
                    <el-option label="点赞最多" value="likes" />
                  </el-select>
                </div>

                <!-- 评价卡片列表 -->
                <template v-if="filteredReviews.length > 0">
                  <div class="review-cards">
                    <el-card 
                      v-for="review in filteredReviews" 
                      :key="review.id" 
                      class="review-card"
                    >
                      <div class="review-header">
                        <div class="reviewer-info">
                          <el-avatar 
                            v-if="!review.isAnonymous" 
                            :src="review.user.avatar" 
                            :size="40" 
                          />
                          <el-avatar v-else :size="40">匿名</el-avatar>
                          <span class="reviewer-name">
                            {{ review.isAnonymous ? '匿名用户' : review.user.username }}
                          </span>
                        </div>
                        <div class="review-meta">
                          <el-tag 
                            :type="review.type === 'good' ? 'success' : 'danger'"
                            size="small"
                          >
                            {{ review.type === 'good' ? '好评' : '差评' }}
                          </el-tag>
                          <span class="review-time">{{ formatTime(review.createdAt) }}</span>
                        </div>
                      </div>

                      <div class="review-content">
                        <p>{{ review.content }}</p>
                      </div>

                      <div class="review-footer">
                        <div class="action-buttons">
                          <el-button 
                            text 
                            :class="['like-button', { 'is-liked': review.isLiked }]"
                            @click="handleLikeReview(review)"
                          >
                            <like-outlined v-if="!review.isLiked" />
                            <like-filled v-else />
                            {{ review.likes }}
                          </el-button>
                          <el-button 
                            text 
                            :class="['dislike-button', { 'is-disliked': review.isDisliked }]"
                            @click="handleDislikeReview(review)"
                          >
                            <dislike-outlined v-if="!review.isDisliked" />
                            <dislike-filled v-else />
                            {{ review.dislikes }}
                          </el-button>
                        </div>
                      </div>
                    </el-card>
                  </div>
                </template>
                <template v-else>
                  <el-empty 
                    :description="getEmptyReviewText" 
                    :image-size="200"
                  >
                    <template #image>
                      <el-icon :size="60" color="#909399">
                        <chat-round />
                      </el-icon>
                    </template>
                  </el-empty>
                </template>

                <!-- 加载更多 -->
                <div v-if="hasMore" class="load-more">
                  <el-button :loading="loading" @click="loadMore">加载更多</el-button>
                </div>
              </div>
            </div>
          </el-tab-pane>
        </el-tabs>
      </div>
    </el-card>

    <!-- 修改密码对话框 -->
    <el-dialog
      v-model="passwordDialogVisible"
      title="修改密码"
      width="400px"
    >
      <el-form :model="passwordForm" :rules="passwordRules" ref="passwordFormRef">
        <el-form-item label="原密码" prop="oldPassword">
          <el-input
            v-model="passwordForm.oldPassword"
            type="password"
            show-password
          />
        </el-form-item>
        <el-form-item label="新密码" prop="newPassword">
          <el-input
            v-model="passwordForm.newPassword"
            type="password"
            show-password
          />
        </el-form-item>
        <el-form-item label="确认密码" prop="confirmPassword">
          <el-input
            v-model="passwordForm.confirmPassword"
            type="password"
            show-password
          />
        </el-form-item>
      </el-form>
      <template #footer>
        <el-button @click="passwordDialogVisible = false">取消</el-button>
        <el-button type="primary" @click="handlePasswordChange">
          确认修改
        </el-button>
      </template>
    </el-dialog>

    <!-- 头像上传对话框 -->
    <el-dialog
      v-model="avatarDialogVisible"
      title="修改头像"
      width="600px"
    >
      <div class="avatar-upload-container">
        <div v-if="!tempImageUrl" class="upload-area">
          <el-upload
            class="avatar-uploader"
            :auto-upload="false"
            accept="image/*"
            :show-file-list="false"
            :on-change="handleImageChange"
          >
            <el-icon class="avatar-uploader-icon"><Plus /></el-icon>
            <div class="upload-text">点击或拖拽图片上传</div>
          </el-upload>
        </div>
        
        <div v-else class="preview-container">
          <div class="crop-container">
            <div 
              class="crop-area"
              ref="cropArea"
              :style="{
                backgroundImage: `url(${tempImageUrl})`
              }"
            >
              <div 
                class="crop-box"
                ref="cropBox"
                :style="{
                  width: cropSize + 'px',
                  height: cropSize + 'px',
                  left: cropPosition.x + 'px',
                  top: cropPosition.y + 'px'
                }"
                @mousedown="startDrag"
              >
                <div class="crop-border"></div>
                <div class="crop-corners">
                  <div class="corner top-left"></div>
                  <div class="corner top-right"></div>
                  <div class="corner bottom-left"></div>
                  <div class="corner bottom-right"></div>
                </div>
              </div>
            </div>
          </div>
        </div>
      </div>
      
      <template #footer>
        <div class="dialog-footer">
          <el-button @click="cancelAvatarUpload">取消</el-button>
          <el-button 
            type="primary" 
            @click="confirmAvatarUpload"
            :disabled="!tempImageUrl"
          >
            确认
          </el-button>
        </div>
      </template>
    </el-dialog>

    <!-- 添加预约对话框 -->
    <AppointmentDialog
      :visible="appointmentDialogVisible"
      @update:visible="appointmentDialogVisible = $event"
      @confirm="handleAppointmentConfirm"
    />

    <!-- 回复对话框 -->
    <el-dialog
      v-model="showReplyDialog"
      title="回复评价"
      width="500px"
    >
      <el-form :model="replyForm">
        <el-form-item>
          <el-input
            v-model="replyForm.content"
            type="textarea"
            :rows="4"
            placeholder="请输入回复内容"
          />
        </el-form-item>
      </el-form>
      <template #footer>
        <el-button @click="showReplyDialog = false">取消</el-button>
        <el-button type="primary" @click="submitReply">确认</el-button>
      </template>
    </el-dialog>
  </div>
</template>

<script setup lang="ts">
import { ref, reactive, computed, watch, onMounted, nextTick } from 'vue'
import { View, Plus, Calendar, ChatRound } from '@element-plus/icons-vue'
import { 
  LikeOutlined, 
  LikeFilled, 
  DislikeOutlined, 
  DislikeFilled 
} from '@ant-design/icons-vue'
import { useUserStore } from '@/stores/user'
import type { FormInstance, UploadFile } from 'element-plus'
import { ElMessage } from 'element-plus'
import type { UserInfo, UserEditForm, Gender } from '@/types/user'
import TestHistoryList from '@/components/TestHistoryList.vue'
import ActivityList from '@/components/ActivityList.vue'
import FollowList from '@/components/FollowList.vue'
import FollowerList from '@/components/FollowerList.vue'
import NotificationList from '@/components/NotificationList.vue'
import { locationOptions } from '@/data/locations'
import { useRoute } from 'vue-router'
import AppointmentDialog from '@/components/AppointmentDialog.vue'

const route = useRoute()
const userStore = useUserStore()

// 修改默认用户信息对象
const defaultUserInfo: UserInfo = {
  id: '',
  username: '',
  avatar: defaultAvatar,
  email: '',
  phone: '',
  gender: 'male' as Gender,
  location: '',
  bio: '这个人很懒，什么都没有留下...',
  roles: 'explorer',
  visitCount: 0,
  emailPublic: false,
  phonePublic: false,
  genderPublic: false,
  locationPublic: false,
  bioPublic: false,
  activitiesPublic: false,
  followListPublic: false,
  followerListPublic: false,
  notificationsPublic: false,
  testHistoryPublic: false,
  rating: 0,  // 设置默认评分为0
  positiveReviewsCount: 0,
  negativeReviewsCount: 0
}

// 当前用户信息
const currentUser = ref<UserInfo>(defaultUserInfo)

// 是否是当前登录用户的主页
const isOwnProfile = computed(() => {
  return route.params.id === userStore.userInfo?.id
})

// 是否可以编辑
const canEdit = computed(() => {
  return isOwnProfile.value || userStore.userInfo?.roles === 'admin'
})

// 获取用户信息并处理隐私设置
const getUserInfo = (userData: UserInfo) => {
  // 如果是自己的主页或是管理员，返回完整信息
  if (isOwnProfile.value || userStore.userInfo?.roles === 'admin') {
    return userData
  }

  // 否则根据隐私设置过滤信息
  const filteredInfo = { ...userData }
  
  // 处理邮箱隐私
  // if (!userData.emailPublic) {
  //   filteredInfo.email = ''
  // }
  
  // // 处理手机号隐私
  // if (!userData.phonePublic) {
  //   filteredInfo.phone = ''
  // }
  
  // // 处理性别隐私
  // if (!userData.genderPublic) {
  //   filteredInfo.gender = 'male'
  // }
  
  // // 处理地址隐私
  // if (!userData.locationPublic) {
  //   filteredInfo.location = ''
  // }
  
  // // 处理简介隐私
  // if (!userData.bioPublic) {
  //   filteredInfo.bio = '该用户设置了隐私保护'
  // }

  return filteredInfo
}

// 在组件挂载时获取用户信息
onMounted(async () => {
  const userId = route.params.id as string
  if (userId) {
    if (isOwnProfile.value && userStore.userInfo) {
      // 如果是查看自己的主页
      currentUser.value = userStore.userInfo
    } else {
      // 如果是查看其他用户的主页
      try {
        const userData = userStore.getUserById(userId)
        if (userData) {
          // 根据隐私设置过滤用户信息
          currentUser.value = getUserInfo(userData)
        } else {
          currentUser.value = defaultUserInfo
          ElMessage.error('用户不存在')
        }
      } catch (error) {
        currentUser.value = defaultUserInfo
        ElMessage.error('获取用户信息失败')
      }
    }
  } else {
    currentUser.value = defaultUserInfo
  }
})

// 编辑表单数据
const editForm = reactive({
  username: '',
  avatar: '',
  email: '',
  phone: '',
  gender: 'male',
  location: '',
  bio: '',
  emailPublic: false,
  phonePublic: false,
  genderPublic: false,
  locationPublic: false,
  bioPublic: false
})

// 监听当前用户信息变化，更新编辑表单
watch(() => currentUser.value, (newValue) => {
  if (newValue) {
    Object.assign(editForm, {
      username: newValue.username,
      avatar: newValue.avatar,
      email: newValue.email,
      phone: newValue.phone,
      gender: newValue.gender,
      location: newValue.location,
      bio: newValue.bio,
      emailPublic: newValue.emailPublic,
      phonePublic: newValue.phonePublic,
      genderPublic: newValue.genderPublic,
      locationPublic: newValue.locationPublic,
      bioPublic: newValue.bioPublic
    })
  }
}, { immediate: true })

// 根据用户权限显示不同的编辑选项
const isEditing = ref(false)
const activeTab = ref('activity')
const passwordDialogVisible = ref(false)
const passwordForm = ref<FormInstance>({
  oldPassword: '',
  newPassword: '',
  confirmPassword: ''
})
const avatarDialogVisible = ref(false)
const tempImageUrl = ref('')
const originalAvatar = ref('')
const tempAvatar = ref('')

const defaultAvatar = 'https://cube.elemecdn.com/0/88/03b0d39583f48206768a7534e55bcpng.png'

// 修改用户信息的计算属性
const userInfo = computed(() => {
  console.log(currentUser.value)
  return currentUser.value || defaultUserInfo
})

// 修改处理编辑函数
const handleEdit = () => {
  isEditing.value = true
  Object.assign(editForm, currentUser.value)
}

// 修改处理取消函数
const handleCancel = () => {
  Object.assign(editForm, currentUser.value)
  isEditing.value = false
}

// 添加验证规则
const validateEmail = (value: string) => {
  if (!value) return true // 允许为空
  const emailRegex = /^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$/
  return emailRegex.test(value)
}

const validatePhone = (value: string) => {
  if (!value) return true // 允许为空
  const phoneRegex = /^1[3-9]\d{9}$/
  return phoneRegex.test(value)
}

// 添加用户名验证规则
const validateUsername = (value: string) => {
  if (!value) return false // 用户名不能为空
  if (value.length > 12) return false // 长度不能超过20
  // 只允许中文、英文、数字和下划线
  const usernameRegex = /^[\u4e00-\u9fa5a-zA-Z0-9_]{2,12}$/
  return usernameRegex.test(value)
}

// 修改保存用户信息的方法
const handleSave = () => {
  // 验证用户名
  if (!validateUsername(editForm.username)) {
    ElMessage.error('用户名只能包含中文、英文、数字和下划线，长度2-12位')
    return
  }

  // 验证邮箱
  if (editForm.email && !validateEmail(editForm.email)) {
    ElMessage.error('请输入正确的邮箱格式')
    return
  }
  
  // 验证手机号
  if (editForm.phone && !validatePhone(editForm.phone)) {
    ElMessage.error('请输入正确的手机号格式')
    return
  }

  // 更新用户信息
  if (userStore.userInfo) {
    const newUserInfo = {
      ...userStore.userInfo,
      ...editForm
    }
    userStore.updateUserInfo(newUserInfo)
    currentUser.value = newUserInfo
    ElMessage.success('保存成功')
    isEditing.value = false
  }
}

// 显示修改密码对话框
const showChangePassword = () => {
  passwordDialogVisible.value = true
}

// 处理密码修改
const handlePasswordChange = async () => {
  if (!passwordForm.value) return
  
  await passwordForm.value.validate((valid) => {
    if (valid) {
      // TODO: 调用API修改密码
      passwordDialogVisible.value = false
      // 重置表单
      passwordForm.oldPassword = ''
      passwordForm.newPassword = ''
      passwordForm.confirmPassword = ''
    }
  })
}

// 修改格式化函数
const formatInfo = (info: string | null | undefined, isPublic: boolean) => {
  console.log(info)
  console.log(isPublic)
  console.log(isOwnProfile.value)
  // 如果是访问自己的主页，直接显示信息
  if (isOwnProfile.value) {
    return info || '未设置'
  }
  
  // 访问他人主页时，根据隐私设置显示
  if (!isPublic) {
    return '已设为私密'
  }
  return info || '未设置'
}

const formatLocation = (location: string | null | undefined, isPublic: boolean) => {
  // 如果是访问自己的主页，直接显示位置
  if (isOwnProfile.value) {
    return location || '未设置'
  }
  
  // 访问他人主页时，根据隐私设置显示
  if (!isPublic) {
    return '已设为私密'
  }
  return location || '未设置'
}

const formatGender = (gender: Gender, isPublic: boolean) => {
  const genderMap: Record<Gender, string> = {
    male: '男',
    female: '女'
  }
  if (isOwnProfile.value) return genderMap[gender] || '未设置'
  if (!isPublic) return '已设为私密'
  return genderMap[gender] || '未设置'
}

// 当前选中的地区值
const locationValue = ref<string[]>([])

// 处理地区选择变化
const handleLocationChange = (value: string[]) => {
  if (value && value.length === 2) {
    editForm.location = `${value[0]}-${value[1]}`
  } else {
    editForm.location = ''
  }
}

// 打开编辑对话框时，设置初始地区值
const openEditDialog = () => {
  isEditing.value = true
  Object.assign(editForm, currentUser.value)
  
  // 设置地区初始值
  if (currentUser.value.location) {
    const [province, city] = currentUser.value.location.split('-')
    locationValue.value = [province, city]
  } else {
    locationValue.value = []
  }
}

// 修改显示头像上传对话框函数
const showAvatarUpload = () => {
  // 只在第一次修改时保存原始头像
  if (!originalAvatar.value) {
    originalAvatar.value = currentUser.value.avatar || defaultAvatar
  }
  avatarDialogVisible.value = true
  tempImageUrl.value = ''
}

// 修改处理图片选择函数
const handleImageChange = (file: UploadFile) => {
  if (!file.raw) return
  
  const reader = new FileReader()
  reader.onload = (e) => {
    const img = new Image()
    img.onload = () => {
      // 创建canvas来处理图片
      const canvas = document.createElement('canvas')
      const ctx = canvas.getContext('2d')
      if (!ctx) return

      // 计算等比例缩放后的尺寸
      const maxPreviewSize = 400 // 预览区域最大尺寸
      let width = img.width
      let height = img.height
      
      if (width > height) {
        if (width > maxPreviewSize) {
          height = (height * maxPreviewSize) / width
          width = maxPreviewSize
        }
      } else {
        if (height > maxPreviewSize) {
          width = (width * maxPreviewSize) / height
          height = maxPreviewSize
        }
      }

      // 设置canvas尺寸为缩放后的尺寸
      canvas.width = width
      canvas.height = height

      // 绘制图片
      ctx.drawImage(img, 0, 0, width, height)

      // 保存图片数据
      tempImageUrl.value = canvas.toDataURL('image/jpeg', 1.0)

      // 重置裁剪框位置到中心
      if (cropArea.value) {
        const areaWidth = cropArea.value.clientWidth
        const areaHeight = cropArea.value.clientHeight
        cropSize.value = Math.min(200, Math.min(width, height))
        cropPosition.x = (areaWidth - cropSize.value) / 2
        cropPosition.y = (areaHeight - cropSize.value) / 2
      }
    }
    img.src = e.target?.result as string
  }
  reader.readAsDataURL(file.raw)
}

// 裁剪相关
const cropArea = ref<HTMLElement>()
const cropBox = ref<HTMLElement>()
const cropSize = ref(200)
const cropPosition = reactive({
  x: 50,
  y: 50
})

// 开始拖动或调整大小
const startDrag = (e: MouseEvent) => {
  e.preventDefault() // 防止默认行为
  const target = e.target as HTMLElement
  
  // 记录初始状态
  const initialState = {
    size: cropSize.value,
    x: cropPosition.x,
    y: cropPosition.y,
    mouseX: e.clientX,
    mouseY: e.clientY
  }

  let isResizing = false
  let resizeType = ''

  if (target.classList.contains('corner')) {
    isResizing = true
    resizeType = target.classList[1]
  }

  const handleMove = (e: MouseEvent) => {
    e.preventDefault()
    if (!cropArea.value) return

    const deltaX = e.clientX - initialState.mouseX
    const deltaY = e.clientY - initialState.mouseY
    const minSize = 100
    const maxSize = Math.min(cropArea.value.clientWidth, cropArea.value.clientHeight)

    if (isResizing) {
      let newSize = initialState.size
      let newX = initialState.x
      let newY = initialState.y

      switch (resizeType) {
        case 'top-left':
          newSize = initialState.size - Math.min(deltaX, deltaY)
          if (newSize >= minSize && newSize <= maxSize) {
            newX = initialState.x + (initialState.size - newSize)
            newY = initialState.y + (initialState.size - newSize)
          }
          break
        case 'top-right':
          newSize = initialState.size + Math.min(-deltaY, deltaX)
          if (newSize >= minSize && newSize <= maxSize) {
            newY = initialState.y - (newSize - initialState.size)
          }
          break
        case 'bottom-left':
          newSize = initialState.size + Math.min(-deltaX, deltaY)
          if (newSize >= minSize && newSize <= maxSize) {
            newX = initialState.x - (newSize - initialState.size)
          }
          break
        case 'bottom-right':
          newSize = initialState.size + Math.min(deltaX, deltaY)
          break
      }

      if (newSize >= minSize && newSize <= maxSize) {
        const maxX = cropArea.value.clientWidth - newSize
        const maxY = cropArea.value.clientHeight - newSize

        cropSize.value = newSize
        cropPosition.x = Math.max(0, Math.min(newX, maxX))
        cropPosition.y = Math.max(0, Math.min(newY, maxY))
      }
    } else {
      // 处理拖动
      const maxX = cropArea.value.clientWidth - cropSize.value
      const maxY = cropArea.value.clientHeight - cropSize.value

      cropPosition.x = Math.max(0, Math.min(initialState.x + deltaX, maxX))
      cropPosition.y = Math.max(0, Math.min(initialState.y + deltaY, maxY))
    }
  }

  const handleUp = (e: MouseEvent) => {
    e.preventDefault()
    document.removeEventListener('mousemove', handleMove)
    document.removeEventListener('mouseup', handleUp)
  }

  document.addEventListener('mousemove', handleMove)
  document.addEventListener('mouseup', handleUp)
}

// 修改确认头像上传函数
const confirmAvatarUpload = async () => {
  if (!cropArea.value || !cropBox.value) return

  const canvas = document.createElement('canvas')
  const ctx = canvas.getContext('2d')
  
  if (!ctx) return

  canvas.width = 150
  canvas.height = 150

  const img = new Image()
  img.src = tempImageUrl.value
  
  await new Promise((resolve) => {
    img.onload = resolve
  })

  // 获取裁剪区域的实际位置和尺寸
  const cropAreaRect = cropArea.value.getBoundingClientRect()
  const cropBoxRect = cropBox.value.getBoundingClientRect()
  const scale = img.width / cropArea.value.offsetWidth

  // 计算裁剪位置
  const sourceX = (cropBoxRect.left - cropAreaRect.left) * scale
  const sourceY = (cropBoxRect.top - cropAreaRect.top) * scale
  const sourceWidth = cropBoxRect.width * scale
  const sourceHeight = cropBoxRect.height * scale

  // 使用高质量的图像平滑
  ctx.imageSmoothingEnabled = true
  ctx.imageSmoothingQuality = 'high'

  // 绘制裁剪区域
  ctx.drawImage(
    img,
    sourceX,
    sourceY,
    sourceWidth,
    sourceHeight,
    0,
    0,
    150,
    150
  )

  canvas.toBlob(async (blob) => {
    if (!blob) return
    
    try {
      const tempUrl = URL.createObjectURL(blob)
      // 保存临时头像
      tempAvatar.value = tempUrl
      // 显示新头像
      currentUser.value.avatar = tempUrl
      
      avatarDialogVisible.value = false
      tempImageUrl.value = ''
      ElMessage.success('头像裁剪成功，请点击确认修改保存')
    } catch (error) {
      console.error('头像裁剪失败:', error)
      ElMessage.error('头像裁剪失败')
    }
  }, 'image/jpeg', 1.0)
}

// 修改最终确认头像函数
const handleConfirmAvatar = async () => {
  try {
    // TODO: 调用API保存头像
    // const response = await saveAvatar(tempAvatar.value)
    
    // 更新store中的用户信息
    userStore.login({
      ...currentUser.value,
      avatar: currentUser.value.avatar
    })
    
    // 清理所有临时状态
    originalAvatar.value = ''
    tempAvatar.value = ''
    tempImageUrl.value = ''
    
    ElMessage.success('头像修改成功')
  } catch (error) {
    // 如果保存失败，还原到原始头像
    currentUser.value.avatar = originalAvatar.value
    console.error('保存头像失败:', error)
    ElMessage.error('头像修改失败')
  }
}

// 取消头像上传
const cancelAvatarUpload = () => {
  avatarDialogVisible.value = false
  tempImageUrl.value = ''
}

// 处理隐私设置变更
const handlePrivacyChange = (field: keyof UserInfo) => {
  if (userStore.userInfo) {
    const value = userStore.userInfo[field]
    // 更新 store 中的状态
    userStore.userInfo = {
      ...userStore.userInfo,
      [field]: value
    }
    ElMessage.success(`设置修改成功`)
  }
}

// 添加还原头像函数
const handleRevertAvatar = () => {
  // 还原到原始头像
  if (originalAvatar.value) {
    currentUser.value.avatar = originalAvatar.value
  } else {
    currentUser.value.avatar = defaultAvatar
  }
  
  // 清理所有临时状态
  tempAvatar.value = ''
  tempImageUrl.value = ''
  avatarDialogVisible.value = false
}

const notificationListRef = ref()
const notificationUnreadCount = ref(6)  // 设置一个初始值，与模拟数据中的未读通知数量一致

// 更新未读通知数
const updateUnreadCount = (count: number) => {
  notificationUnreadCount.value = count
}

// 添加预约对话框的状态控制
const appointmentDialogVisible = ref(false)

// 打开预约对话框
const showAppointmentDialog = () => {
  appointmentDialogVisible.value = true
}

// 处理预约确认
const handleAppointmentConfirm = (appointmentData: any) => {
  // 这里处理预约确认的逻辑
  console.log('预约信息：', {
    counselorId: route.params.id,
    counselorName: userInfo.value?.username,
    ...appointmentData
  })
  appointmentDialogVisible.value = false
}

// 判断是否显示预约按钮
const showAppointmentButton = computed(() => {
  // 确保不是访问自己的主页
  if (userStore.userInfo?.id === route.params.id) return false
  
  // 确保被访问的用户是咨询师
  if (!userInfo.value?.roles.includes('counselor')) return false
  
  // 确保咨询师具有咨询资格
  if (!userInfo.value?.isQualified) return false
  
  // 确保咨询师当前接受预约
  if (!userInfo.value?.available) return false
  
  return true
})

// 添加预约按钮的提示信息
const appointmentButtonTooltip = computed(() => {
  if (!userInfo.value) return ''
  
  if (!userInfo.value.roles.includes('counselor')) {
    return '该用户不是咨询师'
  }
  
  if (!userInfo.value.isQualified) {
    return '该咨询师暂未获得咨询资格'
  }
  
  if (!userInfo.value.available) {
    return '该咨询师暂不接受预约'
  }
  
  return ''
})

// 修改评价相关的状态和接口
interface Review {
  id: number
  user: {
    username: string
    avatar: string
  }
  content: string
  createdAt: string
  isAnonymous: boolean
  likes: number
  dislikes: number
  isLiked: boolean
  isDisliked: boolean
  type: 'good' | 'bad'
}

const reviews = ref<Review[]>([])
const reviewType = ref('all')
const sortBy = ref('latest')
const currentPage = ref(1)
const pageSize = ref(10)
const loading = ref(false)
const hasMore = ref(true)

// 模拟评价数据
const mockReviews: Review[] = [
  {
    id: 1,
    user: {
      username: '用户A',
      avatar: '/default-avatar.png' // 使用本地默认头像
    },
    content: '非常专业的咨询师，帮助我解决了很多问题。',
    createdAt: '2024-01-15T10:00:00',
    isAnonymous: false,
    likes: 12,
    dislikes: 0,
    isLiked: false,
    isDisliked: false,
    type: 'good'
  },
  {
    id: 2,
    user: {
      username: '匿名用户',
      avatar: '/default-avatar.png'
    },
    content: '咨询过程很愉快，建议很实用。',
    createdAt: '2024-01-14T15:30:00',
    isAnonymous: true,
    likes: 8,
    dislikes: 1,
    isLiked: false,
    isDisliked: false,
    type: 'good'
  },
  {
    id: 3,
    user: {
      username: '用户B',
      avatar: '/default-avatar.png'
    },
    content: '感觉建议不够具体，希望能更有针对性。',
    createdAt: '2024-01-13T09:30:00',
    isAnonymous: false,
    likes: 3,
    dislikes: 5,
    isLiked: false,
    isDisliked: false,
    type: 'bad'
  }
]

// 修改获取评价列表函数
const fetchReviews = async () => {
  if (loading.value || !hasMore.value) return
  
  loading.value = true
  try {
    let filteredData = [...mockReviews]
    if (reviewType.value !== 'all') {
      filteredData = filteredData.filter(review => review.type === reviewType.value)
    }
    
    // 修改排序选项
    switch (sortBy.value) {
      case 'latest':
        filteredData.sort((a, b) => new Date(b.createdAt).getTime() - new Date(a.createdAt).getTime())
        break
      case 'likes':
        filteredData.sort((a, b) => b.likes - a.likes)
        break
    }
    
    const start = (currentPage.value - 1) * pageSize.value
    const end = start + pageSize.value
    const newReviews = filteredData.slice(start, end)
    
    if (currentPage.value === 1) {
      reviews.value = newReviews
    } else {
      reviews.value.push(...newReviews)
    }
    
    hasMore.value = newReviews.length === pageSize.value
    currentPage.value++
  } catch (error) {
    console.error('获取评价列表失败:', error)
    ElMessage.error('获取评价列表失败，请稍后重试')
  } finally {
    loading.value = false
  }
}

// 监听筛选条件变化
watch([reviewType, sortBy], () => {
  currentPage.value = 1
  hasMore.value = true
  reviews.value = [] // 清空现有数据
  fetchReviews()
})

// 在组件挂载时获取评价数据
onMounted(() => {
  fetchReviews()
})

// 处理评价操作
const handleLikeReview = (review: Review) => {
  if (review.isDisliked) {
    review.isDisliked = false
    review.dislikes--
  }
  review.isLiked = !review.isLiked
  review.likes += review.isLiked ? 1 : -1
}

const handleDislikeReview = (review: Review) => {
  if (review.isLiked) {
    review.isLiked = false
    review.likes--
  }
  review.isDisliked = !review.isDisliked
  review.dislikes += review.isDisliked ? 1 : -1
}

// 格式化时间
const formatTime = (timestamp: string) => {
  if (!timestamp) return ''
  const date = new Date(timestamp)
  return date.toLocaleDateString('zh-CN', {
    year: 'numeric',
    month: 'long',
    day: 'numeric',
    hour: '2-digit',
    minute: '2-digit'
  })
}

// 空状态文本
const getEmptyReviewText = computed(() => {
  if (reviewType.value === 'all') {
    return '暂无任何评价'
  } else if (reviewType.value === 'good') {
    return '暂无好评'
  } else {
    return '暂无差评'
  }
})

// 加载更多评价
const loadMore = () => {
  if (!loading.value && hasMore.value) {
    fetchReviews()
  }
}

// 过滤和排序评价
const filteredReviews = computed(() => {
  let result = reviews.value || []
  
  // 按类型筛选
  if (reviewType.value !== 'all') {
    result = result.filter(review => review.type === reviewType.value)
  }
  
  // 按选择的方式排序
  switch (sortBy.value) {
    case 'latest':
      result.sort((a, b) => new Date(b.createdAt).getTime() - new Date(a.createdAt).getTime())
      break
    case 'likes':
      result.sort((a, b) => b.likes - a.likes)
      break
  }
  
  return result
})

// 处理回复
const showReplyDialog = ref(false)
const replyForm = reactive({
  content: ''
})

const handleReply = (review: Review) => {
  showReplyDialog.value = true
}

const submitReply = () => {
  // 这里处理回复提交的逻辑
  console.log('回复内容：', replyForm.content)
  showReplyDialog.value = false
}

// 添加评价统计计算
const reviewStats = computed(() => {
  const total = mockReviews.length
  const good = mockReviews.filter(r => r.type === 'good').length
  const bad = mockReviews.filter(r => r.type === 'bad').length
  const goodRate = total > 0 ? ((good / total) * 100).toFixed(1) : '0.0'

  return {
    total,
    good,
    bad,
    goodRate
  }
})

// 监听评价统计变化，更新用户信息
watch(reviewStats, (newStats) => {
  if (userInfo.value) {
    userInfo.value.positiveReviewsCount = newStats.good
    userInfo.value.negativeReviewsCount = newStats.bad
  }
}, { immediate: true })

// 修改关注列表显示逻辑
const showFollowingList = computed(() => {
  return isOwnProfile.value || userInfo.value?.followingListPublic
})

// 修改粉丝列表显示逻辑
const showFollowerList = computed(() => {
  return isOwnProfile.value || userInfo.value?.followerListPublic
})

// 修改通知列表显示逻辑
const showNotifications = computed(() => {
  return isOwnProfile.value || userInfo.value?.notificationsPublic
})

// 修改测验记录显示逻辑
const showTestHistory = computed(() => {
  return isOwnProfile.value || userInfo.value?.testHistoryPublic
})
</script>

<style scoped>
.user-container {
  padding: 20px;
  display: flex;
  flex-direction: column;
  gap: 20px;
  background-color: #f5f7fa;  /* 添加整体背景色 */
  min-height: 100vh;  /* 确保背景色填充整个视图高度 */
}

.info-card {
  margin-bottom: 20px;
  background-color: #ffffff;  /* 确保卡片背景为白色 */
  border-radius: 8px;  /* 增加圆角 */
  box-shadow: 0 2px 12px rgba(0, 0, 0, 0.05);  /* 柔和的阴影 */
}

.info-header {
  display: flex;
  justify-content: space-between;
  align-items: center;
  margin-bottom: 24px;
}

.header-actions {
  display: flex;
  align-items: center;
  gap: 12px;
}

.user-profile {
  display: flex;
  gap: 40px;
}

.avatar-section {
  display: flex;
  flex-direction: column;
  align-items: center;
  gap: 16px;
}

.user-avatar-wrapper {
  cursor: pointer;
  display: inline-block;
  width: 200px;  /* 修改容器宽度为200px */
  height: 200px; /* 修改容器高度为200px */
}

.user-avatar {
  border: 4px solid #fff;
  box-shadow: 0 2px 12px rgba(0, 0, 0, 0.1);
  transition: transform 0.3s ease;
  width: 100%;    /* 填充容器宽度 */
  height: 100%;   /* 填充容器高度 */
}

.user-avatar :deep(img) {
  width: 100%;
  height: 100%;
  object-fit: cover;
  border-radius: 4px;
}

.user-avatar:hover {
  transform: scale(1.05);
}

.visit-count {
  display: flex;
  align-items: center;
  gap: 4px;
  color: #666;
}

.info-section {
  flex: 1;
  display: flex;
  flex-direction: column;
  gap: 16px;
}

.info-item {
  display: flex;
  align-items: center;
  min-height: 32px;
  padding-left: 12px;  /* 添加左侧内边距 */
}

.label {
  width: 80px;
  color: #666;
  flex-shrink: 0;     /* 防止标签宽度被压缩 */
  text-align: left;   /* 修改为左对齐 */
  padding-right: 12px; /* 保持右侧间距 */
  line-height: 32px;   /* 与内容区域行高一致 */
}

.info-content {
  flex: 1;
  display: flex;
  align-items: center;
  gap: 16px;
  min-height: 32px;    /* 与info-item保持一致 */
}

.info-content span {
  color: #606266;
  line-height: 32px;   /* 与标签行高一致 */
}

/* 处理文本域的特殊情况 */
.info-item:has(.el-textarea) {
  align-items: flex-start;  /* 文本域时顶部对齐 */
  padding-top: 5px;        /* 添加顶部间距 */
}

.info-content .el-textarea {
  width: 300px;
}

/* 确保开关垂直居中 */
.info-content .el-switch {
  margin-left: auto;  /* 将开关推到右侧 */
  cursor: pointer;    /* 确保鼠标指针样式正确 */
}

/* 添加开关的悬停效果 */
.info-content .el-switch:hover {
  opacity: 0.9;
}

/* 禁用状态的样式 */
.info-content .el-switch.is-disabled {
  cursor: not-allowed;
  opacity: 0.6;
}

:deep(.el-input) {
  width: 300px;
}

:deep(.el-select) {
  width: 300px;
}

:deep(.el-cascader) {
  width: 300px;
}

.data-card {
  min-height: 400px;
  background-color: #ffffff;
  border-radius: 8px;
  box-shadow: none;
  padding: 0;
}

.tabs-section {
  padding: 0 20px;
}

.user-tabs {
  border-radius: 4px;
}

:deep(.el-tabs__nav) {
  border-radius: 4px;
}

:deep(.el-tabs__item) {
  padding: 0 20px;
  height: 40px;
  line-height: 40px;
  font-size: 14px;
}

:deep(.el-tabs__nav-wrap::after) {
  height: 1px;
}

:deep(.el-tabs__active-bar) {
  height: 2px;
}

:deep(.el-tabs__item.is-active) {
  font-weight: 600;
}

:deep(.el-tabs__item) {
  margin: 0;
}

:deep(.el-tabs__nav-wrap) {
  padding: 0;
}

:deep(.el-tabs__header) {
  margin-bottom: 20px;
}

.avatar-upload-container {
  display: flex;
  justify-content: center;
  align-items: center;
  min-height: 400px;
}

.upload-area {
  width: 100%;
  height: 300px;
  border: 2px dashed #d9d9d9;
  border-radius: 8px;
  display: flex;
  justify-content: center;
  align-items: center;
  cursor: pointer;
  transition: border-color 0.3s;
}

.upload-area:hover {
  border-color: #409EFF;
}

.avatar-uploader {
  text-align: center;
}

.avatar-uploader-icon {
  font-size: 28px;
  color: #8c939d;
  margin-bottom: 8px;
}

.upload-text {
  color: #606266;
  font-size: 14px;
}

.preview-container {
  width: 100%;
  display: flex;
  flex-direction: column;
  align-items: center;
  gap: 20px;
}

.preview-image {
  max-width: 300px;
  max-height: 300px;
  object-fit: contain;
  transition: transform 0.3s ease;
}

.preview-controls {
  display: none;
}

.preview-buttons {
  display: none;
}

.dialog-footer {
  display: flex;
  justify-content: flex-end;
  align-items: center;
  padding: 10px;
}

.crop-container {
  width: 100%;
  height: 400px;
  position: relative;
  overflow: hidden;
  background-color: #000;
}

.crop-area {
  width: 100%;
  height: 100%;
  background-position: center;
  background-size: contain;
  background-repeat: no-repeat;
  position: relative;
  background-color: #f5f7fa;
  display: flex;
  justify-content: center;
  align-items: center;
}

.crop-box {
  position: absolute;
  cursor: move;
  box-shadow: 0 0 0 9999px rgba(0, 0, 0, 0.5);
  touch-action: none;
  user-select: none;
  -webkit-user-select: none;
}

.crop-border {
  position: absolute;
  top: 0;
  left: 0;
  right: 0;
  bottom: 0;
  border: 1px solid #fff;
}

.crop-corners .corner {
  position: absolute;
  width: 14px;
  height: 14px;
  border: 2px solid #fff;
  background: #409EFF;
  z-index: 1;
  user-select: none;
  -webkit-user-select: none;
}

.corner.top-left {
  top: -5px;
  left: -5px;
  cursor: nw-resize;
}

.corner.top-right {
  top: -5px;
  right: -5px;
  cursor: ne-resize;
}

.corner.bottom-left {
  bottom: -5px;
  left: -5px;
  cursor: sw-resize;
}

.corner.bottom-right {
  bottom: -5px;
  right: -5px;
  cursor: se-resize;
}

.avatar-actions {
  display: flex;
  gap: 8px;
  align-items: center;
}

.info-content span:empty::before {
  content: '暂未填写';
  color: #909399;
  font-style: italic;
}

/* 添加标签页样式 */
:deep(.el-tabs__nav) {
  margin-bottom: 20px;
}

:deep(.el-tabs__item) {
  font-size: 16px;
  padding: 0 24px;
  height: 50px;
  line-height: 50px;
}

:deep(.el-tabs__item.is-active) {
  font-weight: 600;
}

.tab-label {
  position: relative;
  display: inline-flex;
  align-items: center;
}

.notification-badge {
  position: absolute;
  top: -10px;
  right: -20px;
}

:deep(.el-badge__content) {
  background-color: #ff4949;
  border: none;
}

/* 移除之前的标签页样式修改 */
:deep(.el-tabs__item) {
  position: relative;
}

/* 添加单选框组样式 */
:deep(.el-radio-group) {
  display: flex;
  /* gap: 20px; */
}

:deep(.el-radio) {
  margin-right: 0;
}

:deep(.el-radio__label) {
  font-size: 14px;
  color: #606266;
}

:deep(.el-radio__input.is-checked + .el-radio__label) {
  color: #409EFF;
}

.is-invalid {
  border-color: #f56c6c;
}

.is-invalid:focus {
  border-color: #f56c6c;
  box-shadow: 0 0 0 2px rgba(245, 108, 108, 0.2);
}

/* 添加输入框提示样式 */
:deep(.el-input__inner::placeholder) {
  color: #909399;
  font-size: 13px;
}

/* 添加通知标签样式 */
.notification-tab {
  position: relative;
  padding-right: 12px;  /* 为红点预留空间 */
}

/* 添加通知红点样式 */
.notification-dot {
  position: absolute;
  right: 0;
  top: 0;
  width: 8px;
  height: 8px;
  border-radius: 50%;
  background-color: #ff4949;
}

.appointment-info {
  display: flex;
  align-items: center;
  gap: 8px;
}

.price-tag {
  font-size: 14px;
  color: #f56c6c;
  font-weight: 500;
}

.appointment-button {
  display: flex;
  align-items: center;
  gap: 8px;
  font-size: 14px;
  padding: 8px 16px;
  height: 32px;
}

.appointment-button .el-icon {
  font-size: 16px;
}

/* 移除原来的预约按钮样式 */
.appointment-section {
  display: none;
}

.reviews-section {
  display: flex;
  flex-direction: column;
  gap: 24px;
}

.review-stats {
  padding: 24px;
}

.stats-header {
  display: flex;
  align-items: center;
  gap: 48px;
}

.rating-box {
  text-align: center;
  padding: 16px 0;
}

.rating-header {
  display: flex;
  flex-direction: column;
  align-items: center;
  gap: 8px;
}

.rating-box h2 {
  font-size: 36px;
  color: #FFB800;
  margin: 0;
  position: relative;
  z-index: 1;
}

.rating-box h2::after {
  display: none;
}

.rating-stars {
  height: 24px;
  line-height: 1;
}

.rating-box p {
  margin: 8px 0 0;
  color: #909399;
  font-size: 14px;
}

.stats-divider {
  width: 1px;
  height: 80px;
  background-color: #dcdfe6;
}

.review-counts {
  display: flex;
  gap: 48px;
}

.count-item {
  text-align: center;
}

.count-item h3 {
  margin: 0;
  font-size: 24px;
  color: #303133;
  min-width: 60px; /* 添加最小宽度，防止数字变化时抖动 */
}

.count-item p {
  margin: 8px 0 0;
  color: #909399;
}

.reviews-list {
  display: flex;
  flex-direction: column;
  gap: 16px;
}

.list-header {
  display: flex;
  justify-content: space-between;
  align-items: center;
}

.review-cards {
  display: flex;
  flex-direction: column;
  gap: 16px;
  padding: 4px;  /* 添加内边距防止内容贴边 */
}

.review-card {
  .review-header {
    display: flex;
    justify-content: space-between;
    align-items: center;
    margin-bottom: 16px;
  }

  .reviewer-info {
    display: flex;
    align-items: center;
    gap: 12px;
  }

  .reviewer-name {
    font-weight: 500;
  }

  .review-meta {
    display: flex;
    align-items: center;
    gap: 12px;
  }

  .review-time {
    font-size: 12px;
    color: #909399;
  }

  .review-content {
    margin-bottom: 16px;
    line-height: 1.6;
  }

  .review-footer {
    display: flex;
    justify-content: space-between;
    align-items: center;
  }

  .action-buttons {
    display: flex;
    gap: 16px;
  }

  .like-button,
  .dislike-button {
    display: flex;
    align-items: center;
    gap: 4px;
    padding: 6px 12px;
    transition: all 0.3s;
  }

  .like-button:hover,
  .dislike-button:hover {
    background-color: #f5f7fa;
  }

  .like-button.is-liked {
    color: #409eff;
  }

  .dislike-button.is-disliked {
    color: #f56c6c;
  }
}

.load-more {
  text-align: center;
  padding: 20px 0;
}

/* Ant Design 图标样式 */
:deep(.anticon) {
  font-size: 16px;
  transition: transform 0.2s;
}

.like-button:hover :deep(.anticon),
.dislike-button:hover :deep(.anticon) {
  transform: scale(1.1);
}

/* 添加空状态样式 */
:deep(.el-empty) {
  padding: 40px 0;
}

:deep(.el-empty__description) {
  margin-top: 20px;
  font-size: 14px;
  color: #909399;
}

:deep(.el-empty__image) {
  display: flex;
  justify-content: center;
  align-items: center;
}

/* 图标样式 */
:deep(.el-icon) {
  opacity: 0.7;
}

/* 移除滚动条相关样式 */
:deep(.el-scrollbar__bar),
:deep(.el-scrollbar__wrap) {
  display: none;
}

/* 修改星级评分样式 */
:deep(.el-rate) {
  display: inline-flex;
  height: 24px;
  line-height: 1;
}

:deep(.el-rate__icon) {
  font-size: 20px;
  margin-right: 8px;  /* 增加间距，为更大的光晕留出空间 */
  color: #E1E1E1;
  transition: all 0.3s;
  position: relative;
}

:deep(.el-rate__icon.is-active) {
  color: #FFB800;
  filter: drop-shadow(0 0 3px rgba(255, 184, 0, 0.6))  /* 增加阴影强度 */
         drop-shadow(0 0 6px rgba(255, 184, 0, 0.4));  /* 添加第二层阴影 */
}

:deep(.el-rate__icon.is-active::before) {
  content: '';
  position: absolute;
  top: 50%;
  left: 50%;
  transform: translate(-50%, -50%);
  width: 28px;   /* 增加光晕大小 */
  height: 28px;  /* 增加光晕大小 */
  background: radial-gradient(
    circle, 
    rgba(255, 184, 0, 0.3) 0%,   /* 增加中心透明度 */
    rgba(255, 184, 0, 0.2) 30%,  /* 添加中间过渡层 */
    transparent 80%              /* 扩大渐变范围 */
  );
  border-radius: 50%;
  z-index: -1;
  animation: strongPulse 2s infinite;
}

/* 为最后一个星星移除右边距 */
:deep(.el-rate__item:last-child .el-rate__icon) {
  margin-right: 0;
}

/* 增强脉冲动画效果 */
@keyframes strongPulse {
  0% {
    transform: translate(-50%, -50%) scale(1);
    opacity: 0.8;  /* 增加初始透明度 */
  }
  50% {
    transform: translate(-50%, -50%) scale(1.3);  /* 增加缩放幅度 */
    opacity: 0.4;
  }
  100% {
    transform: translate(-50%, -50%) scale(1);
    opacity: 0.8;  /* 增加结束透明度 */
  }
}

/* 修改空状态样式 */
.rating-box h2:empty::before,
.rating-box h2:contains('暂无') {
  content: '0';  /* 修改为显示0 */
  color: #909399;
  font-size: 28px;
}

.count-item h3:empty::before {
  content: '--';
  color: #909399;
}

/* 优化评分样式 */
.rating-header {
  min-height: 80px; /* 确保有足够空间显示评分 */
  display: flex;
  flex-direction: column;
  justify-content: center;
  align-items: center;
}

/* 优化分隔线样式 */
.stats-divider {
  width: 1px;
  height: 80px;
  background-color: #DCDFE6;
  margin: 0 32px; /* 增加两侧间距 */
}

/* 优化计数器样式 */
.review-counts {
  display: flex;
  gap: 32px; /* 减小间距 */
  padding: 0 16px; /* 添加内边距 */
}

.count-item {
  text-align: center;
  min-width: 80px; /* 添加最小宽度 */
}

.count-item p {
  margin: 8px 0 0;
  color: #909399;
}

/* 添加私密信息样式 */
.private-info {
  color: #909399;
  font-style: italic;
}
</style> 