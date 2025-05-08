<template>
  <div class="service-container">
    <!-- 添加头部区域 -->
    <div class="service-header">
      <!-- 搜索栏 -->
      <div class="search-section">
        <el-input
          v-model="searchQuery"
          placeholder="搜索咨询师姓名或专业领域"
          class="search-input"
          :prefix-icon="Search"
          clearable
          @input="handleSearch"
        >
          <template #append>
            <el-button :icon="Search">搜索</el-button>
          </template>
        </el-input>
      </div>

      <!-- 根据用户状态显示不同按钮 -->
      <div class="apply-button">
        <el-button-group>
          <el-button 
            type="primary" 
            @click="handleButtonClick"
          >
            <el-icon>
              <template v-if="isCounselor">
                <Setting />
              </template>
              <template v-else>
                <Plus />
              </template>
            </el-icon>
            {{ isCounselor ? '修改服务设置' : '申请提供服务' }}
          </el-button>
          <el-button 
            v-if="isCounselor"
            type="primary"
            @click="showScheduleDialog = true"
          >
            <el-icon><Calendar /></el-icon>
            排班设置
          </el-button>
        </el-button-group>
      </div>
    </div>

    <!-- 分类标签 -->
    <div class="category-section">
      <el-radio-group v-model="currentCategory" size="large">
        <el-radio-button label="recommended">付费推荐</el-radio-button>
        <el-radio-button label="free">免费推荐</el-radio-button>
      </el-radio-group>
    </div>

    <!-- 咨询师列表 -->
    <div class="counselors-grid">
      <el-card 
        v-for="counselor in filteredCounselors" 
        :key="counselor.id" 
        class="counselor-card"
        @click="goToUserPage(counselor.id)"
      >
        <div class="counselor-header">
          <el-avatar :src="counselor.avatar" :size="60" />
          <div class="counselor-info">
            <div class="name-and-title">
              <span class="counselor-name">{{ counselor.username }}</span>
            </div>
            <div class="counselor-tags">
              <el-tag 
                v-for="tag in counselor.specialties" 
                :key="tag"
                size="small"
                effect="plain"
                class="specialty-tag"
              >
                {{ tag }}
              </el-tag>
            </div>
          </div>
        </div>

        <div class="counselor-stats">
          <div class="stats-row">
            <div class="stat-item">
              <el-icon><Timer /></el-icon>
              <span>{{ counselor.experience }}年从业经验</span>
            </div>
            <div class="stat-divider"></div>
            <div class="stat-item">
              <el-icon><User /></el-icon>
              <span>已咨询{{ counselor.consultations }}人</span>
            </div>
          </div>
        </div>

        <div class="review-stats">
          <div class="positive-reviews">
            <el-icon color="#67C23A"><CircleCheckFilled /></el-icon>
            <span>好评 {{ counselor.positiveReviews }}</span>
          </div>
          <div class="negative-reviews">
            <el-icon color="#F56C6C"><CircleCloseFilled /></el-icon>
            <span>差评 {{ counselor.negativeReviews }}</span>
          </div>
        </div>

        <div class="price-section">
          <span class="price">¥{{ counselor.price }}/次</span>
          <el-tooltip
            :content="isSelfCounselor(counselor) ? '不能预约自己' : ''"
            placement="top"
            :disabled="!isSelfCounselor(counselor)"
          >
            <el-button 
              type="primary" 
              @click.stop="showAppointmentDialog"
              :disabled="isSelfCounselor(counselor)"
              class="appointment-button"
            >
              <el-icon><Calendar /></el-icon>
              立即预约
            </el-button>
          </el-tooltip>
        </div>
      </el-card>
    </div>

    <!-- 申请表单对话框 -->
    <el-dialog
      v-model="showApplyForm"
      title="申请成为咨询师"
      width="600px"
    >
      <el-form
        ref="applyFormRef"
        :model="applyForm"
        :rules="applyRules"
        label-width="100px"
      >
        <!-- 专业标签 -->
        <el-form-item label="专业领域" prop="specialties">
          <el-select
            v-model="applyForm.specialties"
            multiple
            filterable
            allow-create
            default-first-option
            placeholder="请选择或输入专业领域（最多5个）"
            :max-collapse-tags="3"
            :max="5"
          >
            <el-option
              v-for="tag in commonTags"
              :key="tag"
              :label="tag"
              :value="tag"
            />
          </el-select>
        </el-form-item>

        <!-- 从业经验 -->
        <el-form-item label="从业经验" prop="experience">
          <el-input-number
            v-model="applyForm.experience"
            :min="0"
            :max="50"
            :precision="0"
          />
          <span class="unit-text">年</span>
        </el-form-item>

        <!-- 服务类型 -->
        <el-form-item label="服务类型" prop="serviceType">
          <el-radio-group v-model="applyForm.serviceType">
            <el-radio label="paid">付费服务</el-radio>
            <el-radio label="free">免费服务</el-radio>
          </el-radio-group>
        </el-form-item>

        <!-- 咨询价格 -->
        <el-form-item 
          label="咨询价格" 
          prop="price"
          v-if="applyForm.serviceType === 'paid'"
        >
          <el-input-number
            v-model="applyForm.price"
            :min="0"
            :precision="0"
            :step="10"
          />
          <span class="unit-text">元/次</span>
        </el-form-item>

        <!-- 资质文件 -->
        <el-form-item label="资质文件" prop="documents">
          <el-upload
            ref="uploadRef"
            v-model:file-list="applyForm.documents"
            action="/api/upload"
            multiple
            :limit="5"
            :before-upload="beforeUpload"
            :on-success="handleUploadSuccess"
            :on-error="handleUploadError"
            :on-progress="handleUploadProgress"
            :on-exceed="handleExceed"
            :on-remove="handleRemoveFile"
            :headers="{
              Authorization: 'Bearer ' + userToken // 假设需要认证token
            }"
          >
            <el-button type="primary" :loading="uploadLoading">
              <el-icon><Upload /></el-icon>
              上传文件
            </el-button>
            <template #tip>
              <div class="upload-tip">
                <p>请上传学历、证书、实习或工作经历等证明文件</p>
                <p>支持 jpg、png、pdf 格式，每个文件不超过 5MB</p>
                <p>最多上传 5 个文件</p>
              </div>
            </template>
          </el-upload>
        </el-form-item>

        <!-- 个人简介 -->
        <!-- <el-form-item label="个人简介" prop="introduction">
          <el-input
            v-model="applyForm.introduction"
            type="textarea"
            :rows="4"
            placeholder="请简要介绍您的专业背景和咨询经验"
          />
        </el-form-item> -->
      </el-form>

      <template #footer>
        <span class="dialog-footer">
          <el-button @click="showApplyForm = false">取消</el-button>
          <el-button type="primary" @click="submitApplication">
            提交申请
          </el-button>
        </span>
      </template>
    </el-dialog>

    <!-- 添加服务设置对话框 -->
    <el-dialog
      v-model="showSettingsForm"
      title="修改服务设置"
      width="600px"
    >
      <el-form
        ref="settingsFormRef"
        :model="settingsForm"
        label-width="100px"
        :rules="applyRules"
      >
        <!-- 专业领域 -->
        <el-form-item label="专业领域" prop="specialties">
          <el-select
            v-model="settingsForm.specialties"
            multiple
            filterable
            allow-create
            default-first-option
            placeholder="请选择或输入专业领域（最多5个）"
            :max-collapse-tags="3"
            :max="5"
          >
            <el-option
              v-for="tag in commonTags"
              :key="tag"
              :label="tag"
              :value="tag"
            />
          </el-select>
        </el-form-item>

        <!-- 服务类型 -->
        <el-form-item label="服务类型" prop="serviceType">
          <el-radio-group v-model="settingsForm.serviceType">
            <el-radio label="paid">付费服务</el-radio>
            <el-radio label="free">免费服务</el-radio>
          </el-radio-group>
        </el-form-item>

        <!-- 咨询价格 -->
        <el-form-item 
          label="咨询价格" 
          prop="price"
          v-if="settingsForm.serviceType === 'paid'"
        >
          <el-input-number
            v-model="settingsForm.price"
            :min="0"
            :precision="0"
            :step="10"
          />
          <span class="unit-text">元/次</span>
        </el-form-item>

        <!-- 服务状态 -->
        <el-form-item label="服务状态" prop="available">
          <el-switch
            v-model="settingsForm.available"
            active-text="接受预约"
            inactive-text="暂停服务"
          />
        </el-form-item>

        <!-- 个人简介 -->
        <!-- <el-form-item label="个人简介" prop="introduction">
          <el-input
            v-model="settingsForm.introduction"
            type="textarea"
            :rows="4"
            placeholder="请简要介绍您的专业背景和咨询经验"
          />
        </el-form-item> -->
      </el-form>

      <template #footer>
        <span class="dialog-footer">
          <el-button @click="showSettingsForm = false">取消</el-button>
          <el-button type="primary" @click="submitSettings">
            保存设置
          </el-button>
        </span>
      </template>
    </el-dialog>

    <!-- 修改排班设置对话框 -->
    <el-dialog
      v-model="showScheduleDialog"
      title="排班设置"
      width="900px"
      style="margin-top: 22px;"
    >
      <div class="schedule-container">
        <!-- 左侧星期选择 -->
        <div class="weekday-section">
          <div 
            v-for="day in weekDays" 
            :key="day.value"
            class="weekday-item"
            :class="{ 'active': selectedDay === day.value }"
            @click="selectedDay = day.value"
          >
            <span class="day-name">{{ day.label }}</span>
            <div class="day-actions">
              <el-checkbox 
                v-model="day.enabled"
                @change="(val) => handleDayToggle(day.value, val)"
              >
                工作日
              </el-checkbox>
              <el-tooltip 
                v-if="day.enabled && day.value !== selectedDay && getCurrentDay?.enabled"
                content="复制当前日期的时间段到此日期"
                placement="top"
              >
                <el-icon 
                  class="copy-icon"
                  @click.stop="copyTimeSlots(day.value)"
                >
                  <CopyDocument />
                </el-icon>
              </el-tooltip>
            </div>
          </div>
        </div>

        <!-- 右侧时间段设置 -->
        <div class="timeslots-section">
          <template v-if="getCurrentDay?.enabled">
            <div class="timeslots-header">
              <h3>{{ getCurrentDay.label }}时间段设置</h3>
              <div class="quick-actions">
                <el-button size="small" @click="selectAllSlots">全选</el-button>
                <el-button size="small" @click="clearAllSlots">清空</el-button>
                <el-button size="small" @click="selectMorningSlots">上午</el-button>
                <el-button size="small" @click="selectAfternoonSlots">下午</el-button>
                <el-button size="small" @click="selectEveningSlots">晚上</el-button>
              </div>
            </div>

            <div class="timeslots-grid">
              <el-checkbox-group 
                v-model="getCurrentDay.slots"
                class="slots-group"
                @mousedown="startDragSelect"
                @mousemove="handleDragSelect"
                @mouseup="endDragSelect"
                @mouseleave="endDragSelect"
              >
                <el-checkbox 
                  v-for="slot in timeSlots" 
                  :key="slot.value"
                  :label="slot.value"
                  border
                  class="slot-checkbox"
                  :ref="el => checkboxRefs[slot.value] = el"
                >
                  {{ slot.label }}
                </el-checkbox>
              </el-checkbox-group>
            </div>
          </template>
          <div v-else class="no-slots-tip">
            <el-empty description="请先设置为工作日" />
          </div>
        </div>
      </div>

      <template #footer>
        <span class="dialog-footer">
          <el-button @click="showScheduleDialog = false">取消</el-button>
          <el-button type="primary" @click="saveSchedule">保存设置</el-button>
        </span>
      </template>
    </el-dialog>

    <!-- 修改预约对话框组件的使用方式 -->
    <AppointmentDialog
      :visible="appointmentDialogVisible"
      @update:visible="appointmentDialogVisible = $event"
      @confirm="handleAppointmentConfirm"
    />
  </div>
</template>

<script setup lang="ts">
import { ref, computed } from 'vue'
import { useRouter } from 'vue-router'
import { Search, CircleCheckFilled, CircleCloseFilled, Timer, User, Plus, Upload, Setting, Calendar, CopyDocument } from '@element-plus/icons-vue'
import { ElMessage } from 'element-plus'
import type { FormInstance, UploadProps, UploadInstance, UploadRawFile } from 'element-plus'
import { useUserStore } from '@/stores/user'
import type { UserInfo } from '@/types/user'
import AppointmentDialog from '@/components/AppointmentDialog.vue'

const router = useRouter()
const searchQuery = ref('')
const currentCategory = ref('recommended')

// 获取用户状态
const userStore = useUserStore()
// const isCounselor = computed(() => userStore.userInfo?.isCounselor || false)
const isCounselor = ref(true)

// 获取咨询师列表
const getCounselors = computed(() => {
  return userStore.getUserList().filter(user => user.roles === 'counselor').map(counselor => ({
    id: counselor.id,
    username: counselor.username,
    avatar: counselor.avatar || '/avatars/default.jpg',
    specialties: counselor.specialties || [],
    experience: counselor.experience || 0,
    consultations: counselor.consultations || 0,
    positiveReviews: counselor.positiveReviews || 0,
    negativeReviews: counselor.negativeReviews || 0,
    price: counselor.price || 0,
    isFree: counselor.isFree || false
  }))
})

// 修改筛选方法
const filteredCounselors = computed(() => {
  let counselors = getCounselors.value

  // 搜索过滤
  if (searchQuery.value) {
    const query = searchQuery.value.toLowerCase()
    counselors = counselors.filter(c => 
      c.username.toLowerCase().includes(query) ||
      c.specialties?.some(s => s.toLowerCase().includes(query))
    )
  }

  // 分类过滤
  if (currentCategory.value === 'free') {
    counselors = counselors.filter(c => c.isFree)
  } else if (currentCategory.value === 'recommended') {
    counselors = counselors.filter(c => !c.isFree)
  }

  return counselors
})

const handleSearch = () => {
  // 可以在这里添加搜索延迟或其他逻辑
}

const goToUserPage = (userId: number) => {
  router.push(`/user/${userId}`)
}

const bookConsultation = (counselor: UserInfo) => {
  if (!userStore.userInfo) {
    ElMessage.warning('请先登录后再预约')
    return
  }

  // TODO: 实现预约逻辑
  ElMessage.success(`已预约 ${counselor.username} 的咨询服务`)
}

// 申请表单相关
const showApplyForm = ref(false)
const applyFormRef = ref<FormInstance>()
const applyForm = ref({
  specialties: [],
  experience: 0,
  serviceType: 'paid',
  price: 200,
  documents: []
})

// 常用专业标签
const commonTags = [
  '抑郁症', '焦虑障碍', '人际关系', '婚恋情感',
  '家庭关系', '职场压力', '青少年心理', '学习困扰',
  '情绪管理', '心理评估', '危机干预', '人格障碍'
]

// 表单验证规则
const applyRules = {
  specialties: [
    { required: true, message: '请至少选择一个专业领域', trigger: 'change' },
    { type: 'array', max: 5, message: '最多选择5个专业领域', trigger: 'change' }
  ],
  experience: [
    { required: true, message: '请填写从业经验', trigger: 'blur' }
  ],
  serviceType: [
    { required: true, message: '请选择服务类型', trigger: 'change' }
  ],
  price: [
    { required: true, message: '请设置咨询价格', trigger: 'blur' }
  ],
  documents: [
    { required: true, message: '请上传资质证明文件', trigger: 'change' }
  ]
}

// 处理文件超出限制
const handleExceed: UploadProps['onExceed'] = (files) => {
  ElMessage.warning(
    `最多只能上传5个文件，本次选择了 ${files.length} 个文件，共超出 ${
      files.length + applyForm.value.documents.length - 5
    } 个文件`
  )
}

// 提交申请
const submitApplication = async () => {
  if (!applyFormRef.value) return
  
  await applyFormRef.value.validate((valid, fields) => {
    if (valid) {
      ElMessage.success('申请已提交，请等待审核')
      showApplyForm.value = false
    } else {
      console.log('验证失败:', fields)
    }
  })
}

// 文件上传相关
const uploadRef = ref<UploadInstance>()
const uploadLoading = ref(false)

// 文件类型和大小限制
const fileTypes = ['image/jpeg', 'image/png', 'application/pdf']
const maxFileSize = 5 * 1024 * 1024 // 5MB

// 上传前验证
const beforeUpload: UploadProps['beforeUpload'] = (file) => {
  // 验证文件类型
  if (!fileTypes.includes(file.type)) {
    ElMessage.error('只能上传 JPG、PNG 或 PDF 格式的文件')
    return false
  }
  
  // 验证文件大小
  if (file.size > maxFileSize) {
    ElMessage.error('文件大小不能超过 5MB')
    return false
  }
  
  return true
}

// 上传成功回调
const handleUploadSuccess: UploadProps['onSuccess'] = (response, uploadFile) => {
  ElMessage.success('文件上传成功')
  // 将文件信息添加到表单数据中
  const fileInfo = {
    name: uploadFile.name,
    url: response.url, // 假设服务器返回文件访问URL
    type: uploadFile.raw.type
  }
  applyForm.value.documents.push(fileInfo)
}

// 上传失败回调
const handleUploadError: UploadProps['onError'] = (error, uploadFile) => {
  ElMessage.error(`文件 ${uploadFile.name} 上传失败：${error.message}`)
}

// 上传进度回调
const handleUploadProgress: UploadProps['onProgress'] = (evt, uploadFile) => {
  uploadFile.percentage = Math.round(evt.progress * 100)
}

// 移除文件
const handleRemoveFile: UploadProps['onRemove'] = (uploadFile) => {
  const index = applyForm.value.documents.findIndex(doc => doc.name === uploadFile.name)
  if (index > -1) {
    applyForm.value.documents.splice(index, 1)
  }
}

// 修改按钮点击处理
const handleButtonClick = () => {
  if (isCounselor.value) {
    showSettingsForm.value = true
  } else {
    showApplyForm.value = true
  }
}

// 添加服务设置表单相关
const showSettingsForm = ref(false)
const settingsFormRef = ref<FormInstance>()
const settingsForm = ref({
  specialties: [],
  serviceType: 'paid',
  price: 200,
  available: true,
  introduction: ''
})

// 提交设置修改
const submitSettings = async () => {
  if (!settingsFormRef.value) return
  
  await settingsFormRef.value.validate((valid, fields) => {
    if (valid) {
      ElMessage.success('设置已更新')
      showSettingsForm.value = false
    } else {
      console.log('验证失败:', fields)
    }
  })
}

// 排班设置相关
const showScheduleDialog = ref(false)
const selectedDate = ref(new Date())
const selectedTimeSlots = ref<string[]>([])

// 只有在 isCounselor 为 true 时才初始化这些变量
const timeSlots = computed(() => {
  if (!isCounselor.value) return []
  return Array.from({ length: 28 }, (_, i) => {
    const hour = Math.floor(i / 2) + 8
    const minute = i % 2 === 0 ? '00' : '30'
    const value = `${hour}:${minute}`
    const nextHour = minute === '30' ? (hour + 1) : hour
    const nextMinute = minute === '30' ? '00' : '30'
    const label = `${value}-${nextHour}:${nextMinute}`
    return { label, value }
  })
})

// 存储每天的排班时间
const scheduleMap = ref(new Map<string, string[]>())

// 日期格式化
const formatDate = (date: Date) => {
  return date.toLocaleDateString('zh-CN', {
    year: 'numeric',
    month: 'long',
    day: 'numeric',
    weekday: 'long'
  })
}

// 选择月份
const selectMonth = (type: 'current' | 'next') => {
  const date = new Date(selectedDate.value)
  if (type === 'next') {
    date.setMonth(date.getMonth() + 1)
  } else {
    date.setMonth(new Date().getMonth())
  }
  selectedDate.value = date
}

// 处理日期点击
const handleDateClick = (data: any) => {
  const clickedDate = new Date(data.day)
  selectedDate.value = clickedDate
  // 加载该日期已有的时间段设置
  const dateKey = data.day
  selectedTimeSlots.value = scheduleMap.value.get(dateKey) || []
}

// 检查日期是否有排班
const hasSchedule = (data: any) => {
  return scheduleMap.value.has(data.day)
}

// 获取排班时段数量
const getScheduleCount = (data: any) => {
  return scheduleMap.value.get(data.day)?.length || 0
}

// 快速选择时间段
const selectAllSlots = () => {
  if (getCurrentDay.value?.enabled) {
    getCurrentDay.value.slots = timeSlots.value.map(slot => slot.value)
  }
}

const clearAllSlots = () => {
  if (getCurrentDay.value?.enabled) {
    getCurrentDay.value.slots = []
  }
}

const selectMorningSlots = () => {
  if (getCurrentDay.value?.enabled) {
    getCurrentDay.value.slots = timeSlots.value
      .filter(slot => parseInt(slot.value.split(':')[0]) < 12)
      .map(slot => slot.value)
  }
}

const selectAfternoonSlots = () => {
  if (getCurrentDay.value?.enabled) {
    getCurrentDay.value.slots = timeSlots.value
      .filter(slot => {
        const hour = parseInt(slot.value.split(':')[0])
        return hour >= 12 && hour < 18
      })
      .map(slot => slot.value)
  }
}

const selectEveningSlots = () => {
  if (getCurrentDay.value?.enabled) {
    getCurrentDay.value.slots = timeSlots.value
      .filter(slot => parseInt(slot.value.split(':')[0]) >= 18)
      .map(slot => slot.value)
  }
}

// 保存排班设置
const saveSchedule = () => {
  const dateKey = selectedDate.value.toISOString().split('T')[0]
  if (selectedTimeSlots.value.length > 0) {
    scheduleMap.value.set(dateKey, selectedTimeSlots.value)
  } else {
    scheduleMap.value.delete(dateKey)
  }
  ElMessage.success('排班设置已保存')
}

// 添加拖动选择相关的状态
const isDragging = ref(false)
const dragStartValue = ref<string | null>(null)
const dragStartSelected = ref(false)
const checkboxRefs = ref<Record<string, any>>({})

// 开始拖动选择
const startDragSelect = (e: MouseEvent) => {
  const checkbox = (e.target as HTMLElement).closest('.el-checkbox')
  if (!checkbox) return

  isDragging.value = true
  const value = checkbox.querySelector('input')?.value
  if (value) {
    dragStartValue.value = value
    // 记录开始拖动时的选中状态
    dragStartSelected.value = getCurrentDay.value.slots.includes(value)
  }
}

// 处理拖动选择
const handleDragSelect = (e: MouseEvent) => {
  if (!isDragging.value || !dragStartValue.value || !getCurrentDay.value?.enabled) return

  const checkbox = (e.target as HTMLElement).closest('.el-checkbox')
  if (!checkbox) return

  const currentValue = checkbox.querySelector('input')?.value
  if (!currentValue) return

  // 获取开始和当前时间段的索引
  const startIndex = timeSlots.value.findIndex(slot => slot.value === dragStartValue.value)
  const currentIndex = timeSlots.value.findIndex(slot => slot.value === currentValue)
  
  if (startIndex === -1 || currentIndex === -1) return

  // 计算需要选择的范围
  const start = Math.min(startIndex, currentIndex)
  const end = Math.max(startIndex, currentIndex)

  // 根据开始拖动时的状态决定是选中还是取消选中
  const newSelection = new Set(getCurrentDay.value.slots)
  for (let i = start; i <= end; i++) {
    const value = timeSlots.value[i].value
    if (dragStartSelected.value) {
      newSelection.delete(value)
    } else {
      newSelection.add(value)
    }
  }
  getCurrentDay.value.slots = Array.from(newSelection)
}

// 结束拖动选择
const endDragSelect = () => {
  isDragging.value = false
  dragStartValue.value = null
}

// 添加星期数据
const weekDays = ref([
  { label: '周一', value: 'monday', enabled: false, slots: [] },
  { label: '周二', value: 'tuesday', enabled: false, slots: [] },
  { label: '周三', value: 'wednesday', enabled: false, slots: [] },
  { label: '周四', value: 'thursday', enabled: false, slots: [] },
  { label: '周五', value: 'friday', enabled: false, slots: [] },
  { label: '周六', value: 'saturday', enabled: false, slots: [] },
  { label: '周日', value: 'sunday', enabled: false, slots: [] }
])

const selectedDay = ref('monday')

// 获取当前选中的日期数据
const getCurrentDay = computed(() => {
  const day = weekDays.value.find(day => day.value === selectedDay.value)
  return day || weekDays.value[0] // 如果没找到，返回第一天作为默认值
})

// 处理工作日切换
const handleDayToggle = (dayValue: string, enabled: boolean) => {
  const day = weekDays.value.find(d => d.value === dayValue)
  if (day && !enabled) {
    day.slots = []
  }
}

// 添加复制时间段的函数
const copyTimeSlots = (targetDayValue: string) => {
  const targetDay = weekDays.value.find(day => day.value === targetDayValue)
  if (targetDay && getCurrentDay.value) {
    targetDay.slots = [...getCurrentDay.value.slots]
    ElMessage.success(`已复制时间段到${targetDay.label}`)
  }
}

const appointmentDialogVisible = ref(false)

const showAppointmentDialog = () => {
  appointmentDialogVisible.value = true
}

const handleAppointmentConfirm = (appointmentData: any) => {
  console.log('预约信息：', appointmentData)
  // 这里处理预约确认逻辑
}

// 判断是否是咨询师自己
const isSelfCounselor = (counselor: any) => {
  return counselor.id === userStore.userInfo?.id
}

// 处理预约
const handleAppointment = (counselor: any) => {
  if (isSelfCounselor(counselor)) {
    return
  }
  // ... 预约处理逻辑 ...
}
</script>

<style scoped>
.service-container {
  padding: 20px;
  max-width: 1200px;
  margin: 0 auto;
}

/* 添加头部样式 */
.service-header {
  display: flex;
  justify-content: space-between;
  align-items: center;
  margin-bottom: 24px;
}

.search-section {
  flex: 1;
  max-width: 500px;
  margin-right: 24px;
}

.apply-button {
  flex-shrink: 0;
}

.search-input {
  max-width: 500px;
}

.category-section {
  margin-bottom: 24px;
}

.counselors-grid {
  display: grid;
  grid-template-columns: repeat(auto-fill, minmax(300px, 1fr));
  gap: 24px;
}

.counselor-card {
  cursor: pointer;
  transition: all 0.3s;
}

.counselor-card:hover {
  transform: translateY(-4px);
  box-shadow: 0 4px 12px rgba(0, 0, 0, 0.1);
}

.counselor-header {
  display: flex;
  gap: 16px;
  margin-bottom: 16px;
}

.counselor-info {
  flex: 1;
  display: flex;
  flex-direction: column;
  gap: 8px;
}

.name-and-title {
  display: flex;
  align-items: center;
  gap: 8px;
}

.counselor-name {
  font-size: 18px;
  font-weight: 600;
  color: #303133;
}

.counselor-tags {
  display: flex;
  flex-wrap: wrap;
  gap: 6px;
  margin-top: 4px;
}

.specialty-tag {
  margin: 0;
}

.counselor-stats {
  margin: 16px 0;
  padding: 16px 0;
  border-top: 1px solid #ebeef5;
  border-bottom: 1px solid #ebeef5;
}

.stats-row {
  display: flex;
  align-items: center;
  justify-content: center;
  gap: 24px;
}

.stat-item {
  display: flex;
  align-items: center;
  gap: 8px;
  color: #606266;
  font-size: 14px;
}

.stat-item .el-icon {
  font-size: 16px;
  color: #909399;
}

.stat-divider {
  width: 1px;
  height: 14px;
  background-color: #dcdfe6;
}

.review-stats {
  display: flex;
  justify-content: space-around;
  margin: 16px 0;
}

.positive-reviews,
.negative-reviews {
  display: flex;
  align-items: center;
  gap: 8px;
  color: #606266;
}

.price-section {
  display: flex;
  justify-content: space-between;
  align-items: center;
  margin-top: 16px;
}

.price {
  font-size: 20px;
  font-weight: 600;
  color: #F56C6C;
}

.unit-text {
  margin-left: 8px;
  color: #606266;
}

.upload-tip {
  font-size: 12px;
  color: #909399;
  margin-top: 8px;
  line-height: 1.6;
}

.upload-tip p {
  margin: 4px 0;
}

:deep(.el-upload-list) {
  margin-top: 12px;
}

:deep(.el-upload-list__item) {
  transition: all 0.3s;
}

:deep(.el-upload-list__item:hover) {
  background-color: #f5f7fa;
}

:deep(.el-progress) {
  margin-top: 4px;
}

:deep(.el-upload-list__item-status-label) {
  right: 10px;
}

.dialog-footer {
  display: flex;
  justify-content: flex-end;
  gap: 12px;
}

.schedule-container {
  display: flex;
  gap: 24px;
  height: 500px;
}

.weekday-section {
  width: 200px;
  border-right: 1px solid #dcdfe6;
  padding-right: 24px;
}

.weekday-item {
  display: flex;
  justify-content: space-between;
  align-items: center;
  padding: 12px;
  margin-bottom: 8px;
  border-radius: 6px;
  cursor: pointer;
  transition: all 0.3s;
}

.weekday-item:hover {
  background-color: #f5f7fa;
}

.weekday-item.active {
  position: relative;
}

.weekday-item.active::before {
  content: '';
  position: absolute;
  left: 0;
  top: 0;
  bottom: 0;
  width: 3px;
  background-color: #409EFF;
  border-radius: 2px;
}

.weekday-item.active .day-name {
  color: #409EFF;
  font-weight: 600;
}

.day-actions {
  z-index: 1;
  background-color: transparent;
  display: flex;
  align-items: center;
  gap: 8px;
}

.copy-icon {
  font-size: 16px;
  color: #909399;
  cursor: pointer;
  transition: all 0.3s;
}

.copy-icon:hover {
  color: #409EFF;
  transform: scale(1.1);
}

/* 防止图标点击时触发父元素的点击事件 */
.copy-icon:active {
  transform: scale(0.95);
}

:deep(.el-checkbox) {
  margin: 0;
  width: 100%;
  transition: all 0.2s;
  background-color: transparent;
}

:deep(.el-checkbox.is-checked) {
  background-color: transparent;
}

:deep(.el-checkbox__label) {
  color: #606266;
}

:deep(.el-checkbox.is-checked .el-checkbox__label) {
  color: #409EFF;
}

.timeslots-section {
  flex: 1;
  display: flex;
  flex-direction: column;
}

.timeslots-header {
  display: flex;
  justify-content: space-between;
  align-items: center;
  margin-bottom: 20px;
}

.timeslots-header h3 {
  margin: 0;
  font-size: 16px;
  color: #303133;
}

.quick-actions {
  display: flex;
  gap: 8px;
}

.timeslots-grid {
  flex: 1;
  overflow-y: auto;
}

.slots-group {
  display: grid;
  grid-template-columns: repeat(4, 1fr);
  gap: 12px;
  padding: 4px;
  user-select: none; /* 防止文本选择影响拖动 */
}

.slot-checkbox {
  margin: 0 !important;
  cursor: pointer;
}

.no-slots-tip {
  flex: 1;
  display: flex;
  justify-content: center;
  align-items: center;
}

.appointment-button {
  display: flex;
  align-items: center;
  gap: 8px;
}

.appointment-button:disabled {
  cursor: not-allowed;
  opacity: 0.6;
}

/* 添加 tooltip 样式 */
:deep(.el-tooltip__trigger) {
  display: flex;
}
</style> 