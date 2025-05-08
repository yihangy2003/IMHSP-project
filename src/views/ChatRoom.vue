<template>
  <div class="chatroom">
    <div class="chatroom-header">
      <h2>交流室</h2>
      <div class="header-actions">
        <el-badge :value="unreadAppointments" :hidden="!unreadAppointments">
          <el-button @click="showAppointments">
            <el-icon><Calendar /></el-icon>
            预约记录
          </el-button>
        </el-badge>
      </div>
    </div>

    <!-- 视频区域 -->
    <div class="video-container">
      <div class="video-screen" :class="{ 'no-video': !hasVideo }">
        <template v-if="!hasVideo">
          <div class="ready-status">
            <template v-if="!selectedAppointment">
              <el-icon class="prompt-icon"><Calendar /></el-icon>
              <h3 class="prompt-title">请选择预约服务</h3>
              <p class="prompt-text">点击右上角查看预约记录，选择要进行的咨询服务</p>
              <el-button type="primary" @click="showAppointments">
                查看预约记录
              </el-button>
            </template>
            <template v-else>
              <el-button 
                type="primary" 
                size="large"
                :loading="isReady"
                @click="toggleReady"
              >
                {{ isReady ? '已准备' : '准备开始' }}
              </el-button>
              <p class="status-text">{{ getStatusText }}</p>
            </template>
          </div>
        </template>
        <video v-else ref="videoRef" autoplay class="video-element"></video>
      </div>
      
      <div class="video-controls" v-if="selectedAppointment">
        <el-button-group>
          <el-button type="primary" :icon="Microphone" circle />
          <el-button type="primary" :icon="VideoCamera" circle />
          <el-button type="danger" :icon="SwitchButton" circle @click="endCall" />
        </el-button-group>
      </div>
    </div>

    <!-- 预约记录对话框 -->
    <el-dialog
      v-model="showAppointmentDialog"
      title="预约记录"
      width="600px"
    >
      <el-table :data="appointments" style="width: 100%">
        <el-table-column prop="date" label="日期" width="140" />
        <el-table-column prop="time" label="时间" width="80" />
        <el-table-column prop="counselor" label="咨询师" width="100" />
        <el-table-column prop="status" label="状态" width="80">
          <template #default="{ row }">
            <el-tag :type="getStatusType(row.status)">
              {{ row.status }}
            </el-tag>
          </template>
        </el-table-column>
        <el-table-column label="操作" min-width="120">
          <template #default="{ row }">
            <template v-if="row.status === '已完成' && !row.hasReview">
              <el-button 
                type="primary" 
                link 
                @click="showReviewDialog(row)"
              >
                评价
              </el-button>
            </template>
            <template v-else-if="row.status === '待进行'">
              <el-button 
                type="primary" 
                link 
                @click="enterRoom(row)"
              >
                进入
              </el-button>
              <el-button 
                type="danger" 
                link 
                @click="cancelAppointment(row)"
              >
                取消
              </el-button>
            </template>
            <span v-else-if="row.hasReview">
              已评价
            </span>
          </template>
        </el-table-column>
      </el-table>
    </el-dialog>

    <!-- 评价对话框 -->
    <el-dialog
      v-model="showReviewDialogRef"
      title="服务评价"
      width="500px"
      @close="resetReviewForm"
    >
      <el-form :model="reviewForm" label-width="80px">
        <el-form-item label="评价类型">
          <el-radio-group v-model="reviewForm.type">
            <el-radio label="good">好评</el-radio>
            <el-radio label="bad">差评</el-radio>
          </el-radio-group>
        </el-form-item>
        <el-form-item label="评价内容">
          <el-input
            v-model="reviewForm.content"
            type="textarea"
            :rows="4"
            placeholder="请输入您的评价内容..."
          />
        </el-form-item>
      </el-form>
      <template #footer>
        <span class="dialog-footer">
          <el-button @click="closeReviewDialog">取消</el-button>
          <el-button type="primary" @click="submitReview">提交评价</el-button>
        </span>
      </template>
    </el-dialog>
  </div>
</template>

<script setup lang="ts">
import { ref, computed, onMounted, watch } from 'vue'
import { 
  Calendar,
  Microphone,
  VideoCamera,
  SwitchButton
} from '@element-plus/icons-vue'
import { ElMessage, ElMessageBox } from 'element-plus'
import { useUserStore } from '@/stores/user'

const userStore = useUserStore()

// 视频相关状态
const hasVideo = ref(false)
const isReady = ref(false)
const videoRef = ref<HTMLVideoElement>()

// 准备状态文本
const getStatusText = computed(() => {
  if (isReady.value) {
    return '等待对方准备...'
  }
  return '点击准备开始视频交流'
})

// 切换准备状态
const toggleReady = () => {
  isReady.value = !isReady.value
  if (isReady.value) {
    ElMessage.success('已准备就绪，等待对方准备')
  }
}

// 结束通话
const endCall = () => {
  ElMessage.warning('通话已结束')
  hasVideo.value = false
  isReady.value = false
}

interface Appointment {
  id: number
  date: string
  time: string
  counselor: string
  status: '待进行' | '已完成'
  hasReview?: boolean
  isRead: boolean
}

// 预约记录相关
const showAppointmentDialog = ref(false)
const selectedAppointment = ref<Appointment | null>(null)
const appointments = ref<Appointment[]>([
  {
    id: 1,
    date: '2024-03-20',
    time: '14:30',
    counselor: '张医生',
    status: '待进行',
    isRead: false
  },
  {
    id: 2,
    date: '2024-03-18',
    time: '10:00',
    counselor: '李医生',
    status: '已完成',
    hasReview: false,
    isRead: false
  }
])

// 添加未读预约记录计数
const unreadAppointments = computed(() => {
  return appointments.value.filter(a => !a.isRead).length
})

// 更新未读预约数量到 userStore
const updateUnreadCount = () => {
  const unreadCount = appointments.value.filter(a => !a.isRead).length
  if (userStore.userInfo) {
    userStore.userInfo.unreadAppointments = unreadCount
  }
}

// 在组件挂载时更新未读数量
onMounted(() => {
  updateUnreadCount()
})

// 修改 showAppointments 方法
const showAppointments = () => {
  showAppointmentDialog.value = true
  // 标记所有预约为已读
  appointments.value = appointments.value.map(a => ({
    ...a,
    isRead: true
  }))
  // 更新 store 中的未读数量
  updateUnreadCount()
}

// 监听预约数据变化
watch(appointments, () => {
  updateUnreadCount()
}, { deep: true })

const getStatusType = (status: string) => {
  switch (status) {
    case '待进行':
      return 'warning'
    case '已完成':
      return 'success'
    default:
      return 'info'
  }
}

// 评价相关
const showReviewDialogRef = ref(false)
const currentAppointment = ref<Appointment | null>(null)
const reviewForm = ref({
  type: 'good',
  content: ''
})

// 重置评价表单
const resetReviewForm = () => {
  reviewForm.value = {
    type: 'good',
    content: ''
  }
  currentAppointment.value = null
}

// 关闭评价对话框
const closeReviewDialog = () => {
  showReviewDialogRef.value = false
}

// 显示评价对话框
const showReviewDialog = (appointment: Appointment) => {
  resetReviewForm() // 打开前重置表单
  currentAppointment.value = appointment
  showReviewDialogRef.value = true
}

// 提交评价
const submitReview = () => {
  if (!reviewForm.value.content) {
    ElMessage.warning('请输入评价内容')
    return
  }
  
  if (currentAppointment.value) {
    currentAppointment.value.hasReview = true
    ElMessage.success('评价提交成功')
    showReviewDialogRef.value = false
  }
}

// 进入交流室
const enterRoom = (appointment: Appointment) => {
  selectedAppointment.value = appointment
  showAppointmentDialog.value = false
  ElMessage.success('已进入交流室')
}

// 取消预约
const cancelAppointment = (appointment: Appointment) => {
  ElMessageBox.confirm(
    '确定要取消这个预约吗？',
    '提示',
    {
      confirmButtonText: '确定',
      cancelButtonText: '取消',
      type: 'warning'
    }
  ).then(() => {
    appointments.value = appointments.value.filter(a => a.id !== appointment.id)
    ElMessage.success('预约已取消')
  })
}
</script>

<style scoped>
.chatroom {
  padding: 20px;
  max-width: 1200px;
  margin: 0 auto;
}

.chatroom-header {
  display: flex;
  justify-content: space-between;
  align-items: center;
  /* margin-bottom: 24px; */
}

.video-container {
  /* margin: 20px 0; */
  margin-bottom: 40px;
  background: #000;
  border-radius: 12px;
  overflow: hidden;
  position: relative;
  aspect-ratio: 16 / 9;
}

.video-screen {
  width: 100%;
  height: 100%;
  display: flex;
  align-items: center;
  justify-content: center;
  background: #1a1a1a;
}

.video-screen.no-video {
  background: #000;
}

.video-element {
  width: 100%;
  height: 100%;
  object-fit: cover;
}

.ready-status {
  text-align: center;
  color: #fff;
}

.status-text {
  margin-top: 12px;
  font-size: 14px;
  opacity: 0.8;
}

.video-controls {
  position: absolute;
  bottom: 20px;
  left: 50%;
  transform: translateX(-50%);
  display: flex;
  gap: 12px;
  background: rgba(0, 0, 0, 0.5);
  padding: 12px;
  border-radius: 50px;
}

.header-actions {
  display: flex;
  gap: 12px;
}

.prompt-icon {
  font-size: 48px;
  color: #fff;
  margin-bottom: 16px;
}

.prompt-title {
  font-size: 24px;
  color: #fff;
  margin: 0 0 12px;
}

.prompt-text {
  font-size: 16px;
  color: #fff;
  opacity: 0.8;
  margin: 0 0 24px;
  max-width: 400px;
  line-height: 1.5;
}

.dialog-footer {
  display: flex;
  justify-content: flex-end;
  gap: 12px;
}

/* 修改徽标样式 */
:deep(.el-badge__content) {
  background-color: #ff4949;
  border: 2px solid #fff;
}

:deep(.el-badge__content.is-fixed) {
  top: -5px;
  right: 5px;  /* 修改右边距，让红点靠左一些 */
  transform: translateX(50%);  /* 添加位移，保持居中对齐 */
}
</style> 