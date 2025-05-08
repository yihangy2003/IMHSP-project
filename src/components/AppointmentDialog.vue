<template>
  <el-dialog
    :model-value="visible"
    @update:model-value="emit('update:visible', $event)"
    title="预约咨询"
    width="700px"
    class="appointment-dialog"
    :before-close="handleClose"
    style="margin-top: 50px;"
  >
    <div class="appointment-content">
      <div class="calendar-section">
        <div class="calendar-header">
          <h3>选择日期</h3>
          <div class="month-selector">
            <el-button 
              text 
              :disabled="!canGoPrevMonth"
              @click="handlePrevMonth"
            >
              <el-icon><ArrowLeft /></el-icon>
            </el-button>
            <span class="current-month">{{ currentMonthText }}</span>
            <el-button 
              text 
              :disabled="!canGoNextMonth"
              @click="handleNextMonth"
            >
              <el-icon><ArrowRight /></el-icon>
            </el-button>
          </div>
        </div>
        
        <el-calendar v-model="selectedDate">
          <template #dateCell="{ data }">
            <div 
              class="calendar-cell" 
              :class="getDateClass(data)"
              @click="handleDateClick(data.day)"
            >
              <span class="date-text">{{ data.day.split('-')[2] }}</span>
              <div class="time-slots-preview" v-if="hasAvailableSlots(data.day)">
                <span class="available-text">可预约</span>
                <span class="slots-count">{{ getAvailableSlotsCount(data.day) }}个时段</span>
              </div>
            </div>
          </template>
        </el-calendar>
        
        <!-- 添加预约时间范围提示 -->
        <div class="booking-notice">
          <el-icon><InfoFilled /></el-icon>
          <span>可预约时间：{{ bookingDateRange }}</span>
        </div>
      </div>

      <div class="time-slots-section" v-if="selectedDate">
        <h3>选择时间段</h3>
        <div class="time-slots-grid">
          <el-button
            v-for="slot in availableTimeSlots"
            :key="slot.time"
            :class="['time-slot-btn', { 'is-selected': isSelectedTimeSlot(slot) }]"
            :disabled="!slot.available"
            @click="handleTimeSlotSelect(slot)"
          >
            {{ slot.time }}
            <span class="slot-status">{{ slot.available ? '可预约' : '已约满' }}</span>
          </el-button>
        </div>
      </div>
    </div>

    <template #footer>
      <div class="dialog-footer">
        <el-button @click="handleClose">取消</el-button>
        <el-button 
          type="primary" 
          :disabled="!canConfirm"
          @click="handleConfirm"
        >
          确认预约
        </el-button>
      </div>
    </template>
  </el-dialog>
</template>

<script setup lang="ts">
import { ref, computed, watch } from 'vue'
import { ArrowLeft, ArrowRight, InfoFilled } from '@element-plus/icons-vue'
import { ElMessage } from 'element-plus'

const props = defineProps<{
  visible: boolean
}>()

const emit = defineEmits(['update:visible', 'confirm'])

// 选中的日期和时间段
const selectedDate = ref(new Date())
const selectedTimeSlot = ref<TimeSlot | null>(null)

// 时间段接口
interface TimeSlot {
  time: string
  available: boolean
}

// 生成时间段数据的函数
const generateTimeSlots = () => {
  const slots: TimeSlot[] = []
  const startHour = 8
  const endHour = 22
  
  for (let hour = startHour; hour < endHour; hour++) {
    // 添加整点时间段
    slots.push({
      time: `${hour.toString().padStart(2, '0')}:00-${hour.toString().padStart(2, '0')}:30`,
      available: Math.random() > 0.3 // 随机设置是否可用，实际应该从后端获取
    })
    
    // 添加半点时间段
    slots.push({
      time: `${hour.toString().padStart(2, '0')}:30-${(hour + 1).toString().padStart(2, '0')}:00`,
      available: Math.random() > 0.3 // 随机设置是否可用，实际应该从后端获取
    })
  }
  
  return slots
}

// 修改可用时间段数据
const availableTimeSlots = computed(() => generateTimeSlots())

// 当前月份文本
const currentMonthText = computed(() => {
  const date = selectedDate.value
  return `${date.getFullYear()}年${date.getMonth() + 1}月`
})

// 月份切换控制
const canGoPrevMonth = computed(() => {
  const now = new Date()
  const currentMonth = new Date(now.getFullYear(), now.getMonth(), 1)
  const selectedMonth = new Date(selectedDate.value.getFullYear(), selectedDate.value.getMonth(), 1)
  return selectedMonth > currentMonth
})

const canGoNextMonth = computed(() => {
  const now = new Date()
  const threeMonthsLater = new Date(now.getFullYear(), now.getMonth() + 3, 1)
  const selectedMonth = new Date(selectedDate.value.getFullYear(), selectedDate.value.getMonth(), 1)
  return selectedMonth < threeMonthsLater
})

// 处理月份切换
const handlePrevMonth = () => {
  selectedDate.value = new Date(selectedDate.value.getFullYear(), selectedDate.value.getMonth() - 1)
}

const handleNextMonth = () => {
  selectedDate.value = new Date(selectedDate.value.getFullYear(), selectedDate.value.getMonth() + 1)
}

// 添加日期点击处理函数
const handleDateClick = (day: string) => {
  const clickedDate = new Date(day)
  const today = new Date()
  
  // 设置时间为 00:00:00 以便正确比较日期
  today.setHours(0, 0, 0, 0)
  clickedDate.setHours(0, 0, 0, 0)
  
  // 如果点击的是过去的日期，直接返回
  if (clickedDate.getTime() < today.getTime()) {
    return
  }
  
  // 如果是有效日期，则更新选中日期
  selectedDate.value = clickedDate
}

// 修改日期单元格样式判断
const getDateClass = (data: any) => {
  const cellDate = new Date(data.day)
  const today = new Date()
  
  // 设置时间为 00:00:00 以便正确比较日期
  today.setHours(0, 0, 0, 0)
  cellDate.setHours(0, 0, 0, 0)
  
  return {
    'is-today': cellDate.getTime() === today.getTime(),
    'is-disabled': cellDate.getTime() < today.getTime(),
    'has-slots': hasAvailableSlots(data.day),
    'is-selected': selectedDate.value && 
      cellDate.getTime() === new Date(selectedDate.value).setHours(0, 0, 0, 0)
  }
}

// 检查日期是否有可用时间段
const hasAvailableSlots = (day: string) => {
  const date = new Date(day)
  const today = new Date()
  today.setHours(0, 0, 0, 0)
  
  // 获取后天的日期
  const dayAfterTomorrow = new Date(today)
  dayAfterTomorrow.setDate(today.getDate() + 2)
  
  // 获取15天后的日期（改为15天）
  const fifteenDaysLater = new Date(today)
  fifteenDaysLater.setDate(today.getDate() + 15)
  
  // 检查日期是否在有效范围内
  if (date < dayAfterTomorrow || date > fifteenDaysLater) return false
  
  // 周末不可预约
  const dayOfWeek = date.getDay()
  if (dayOfWeek === 0 || dayOfWeek === 6) return false
  
  return true
}

// 获取可用时间段数量
const getAvailableSlotsCount = (day: string) => {
  if (!hasAvailableSlots(day)) return 0
  return availableTimeSlots.value.filter(slot => slot.available).length
}

// 检查时间段是否被选中
const isSelectedTimeSlot = (slot: TimeSlot) => {
  return selectedTimeSlot.value?.time === slot.time
}

// 处理时间段选择
const handleTimeSlotSelect = (slot: TimeSlot) => {
  selectedTimeSlot.value = slot
}

// 是否可以确认预约
const canConfirm = computed(() => {
  return selectedDate.value && selectedTimeSlot.value
})

// 检查日期是否在有效范围内的函数
const isDateInValidRange = (date: Date) => {
  const today = new Date()
  today.setHours(0, 0, 0, 0)
  
  // 获取后天的日期
  const dayAfterTomorrow = new Date(today)
  dayAfterTomorrow.setDate(today.getDate() + 2)
  
  // 获取15天后的日期
  const fifteenDaysLater = new Date(today)
  fifteenDaysLater.setDate(today.getDate() + 15)
  
  // 设置要检查的日期时间为 00:00:00
  const checkDate = new Date(date)
  checkDate.setHours(0, 0, 0, 0)
  
  return checkDate >= dayAfterTomorrow && checkDate <= fifteenDaysLater
}

// 修改处理确认预约的函数
const handleConfirm = () => {
  if (!selectedTimeSlot.value || !selectedDate.value) return
  
  // 检查选择的日期是否在有效范围内
  if (!isDateInValidRange(selectedDate.value)) {
    // 获取后天和15天后的日期
    const today = new Date()
    const dayAfterTomorrow = new Date(today)
    dayAfterTomorrow.setDate(today.getDate() + 2)
    const fifteenDaysLater = new Date(today)
    fifteenDaysLater.setDate(today.getDate() + 15)
    
    // 格式化日期
    const formatDate = (date: Date) => {
      const month = date.getMonth() + 1
      const day = date.getDate()
      return `${month}月${day}日`
    }
    
    ElMessage.warning(
      `请选择 ${formatDate(dayAfterTomorrow)} - ${formatDate(fifteenDaysLater)} 之间的日期进行预约`
    )
    return
  }
  
  // 检查是否为周末
  const dayOfWeek = selectedDate.value.getDay()
  if (dayOfWeek === 0 || dayOfWeek === 6) {
    const formatDate = (date: Date) => {
      const month = date.getMonth() + 1
      const day = date.getDate()
      return `${month}月${day}日`
    }
    ElMessage.warning(`${formatDate(selectedDate.value)}是周${dayOfWeek === 0 ? '日' : '六'}，请选择工作日预约`)
    return
  }
  
  // 所有检查通过，进行预约
  emit('confirm', {
    date: selectedDate.value,
    timeSlot: selectedTimeSlot.value
  })
  
  ElMessage.success('预约成功！')
  handleClose()
}

// 监听 visible 属性的变化
watch(() => props.visible, (newValue) => {
  if (newValue) {
    // 当对话框打开时重置所有状态
    resetDialog()
  }
})

// 添加重置函数
const resetDialog = () => {
  // 重置选中的日期为当前日期
  selectedDate.value = new Date()
  // 重置选中的时间段
  selectedTimeSlot.value = null
}

// 修改处理关闭对话框的函数
const handleClose = () => {
  // 重置所有状态
  resetDialog()
  emit('update:visible', false)
}

// 添加预约日期范围的计算属性
const bookingDateRange = computed(() => {
  const today = new Date()
  
  // 获取后天的日期
  const dayAfterTomorrow = new Date(today)
  dayAfterTomorrow.setDate(today.getDate() + 2)
  
  // 获取15天后的日期（改为15天）
  const fifteenDaysLater = new Date(today)
  fifteenDaysLater.setDate(today.getDate() + 15)
  
  // 格式化日期
  const formatDate = (date: Date) => {
    const month = date.getMonth() + 1
    const day = date.getDate()
    return `${month}月${day}日`
  }
  
  return `${formatDate(dayAfterTomorrow)} - ${formatDate(fifteenDaysLater)}`
})
</script>

<style scoped>
.appointment-dialog {
  :deep(.el-dialog__body) {
    padding: 0;
  }
}

.appointment-content {
  display: flex;
  gap: 24px;
  padding: 20px;
}

.calendar-section {
  flex: 1;
  min-width: 0;
}

.calendar-header {
  display: flex;
  justify-content: space-between;
  align-items: center;
  margin-bottom: 16px;
}

.calendar-header h3 {
  font-size: 16px;
  font-weight: 600;
  color: #303133;
  margin: 0;
}

.month-selector {
  display: flex;
  align-items: center;
  gap: 8px;
}

.current-month {
  font-size: 14px;
  color: #606266;
  min-width: 100px;
  text-align: center;
}

.calendar-cell {
  height: 100%;
  display: flex;
  flex-direction: column;
  justify-content: space-between;
  padding: 4px;
  font-size: 13px;
  cursor: pointer;  /* 添加指针样式 */
  transition: all 0.3s;  /* 添加过渡效果 */
}

.date-text {
  font-size: 14px;
  color: #303133;
}

.time-slots-preview {
  display: flex;
  flex-direction: column;
  align-items: center;
  font-size: 11px;
  color: #67c23a;
  margin-top: 2px;
}

.available-text {
  font-weight: 500;
}

.slots-count {
  color: #909399;
  font-size: 10px;
}

.calendar-cell.is-today {
  background-color: #ecf5ff;
}

.calendar-cell.is-disabled {
  opacity: 0.5;
  cursor: not-allowed;
  background-color: #f5f7fa;
  pointer-events: none;  /* 禁用鼠标事件 */
}

.calendar-cell.is-disabled .date-text {
  color: #c0c4cc;
}

.calendar-cell.is-disabled .time-slots-preview {
  display: none;
}

.calendar-cell.is-selected {
  background-color: #ecf5ff;
  color: #409eff;
}

.time-slots-section {
  width: 240px;
  border-left: 1px solid #e4e7ed;
  padding-left: 24px;
  max-height: 350px; /* 减小最大高度，从 500px 改为 350px */
  display: flex;
  flex-direction: column;
}

.time-slots-section h3 {
  font-size: 16px;
  font-weight: 600;
  color: #303133;
  margin: 0 0 12px; /* 减小下边距 */
}

.time-slots-grid {
  display: flex;
  flex-direction: column;
  gap: 8px;  /* 增加按钮之间的间距 */
  overflow-y: auto;
  padding-right: 8px;
  padding-bottom: 4px;
}

/* 添加滚动条样式 */
.time-slots-grid::-webkit-scrollbar {
  width: 6px;
}

.time-slots-grid::-webkit-scrollbar-thumb {
  background-color: #dcdfe6;
  border-radius: 3px;
}

.time-slots-grid::-webkit-scrollbar-thumb:hover {
  background-color: #c0c4cc;
}

.time-slots-grid::-webkit-scrollbar-track {
  background-color: #f5f7fa;
  border-radius: 3px;
}

.time-slot-btn {
  width: 100%;
  display: flex;
  flex-direction: column;
  align-items: center;
  gap: 4px;  /* 增加内部间距 */
  height: auto;
  padding: 8px 6px;  /* 增加上下内边距 */
  margin: 0;
  font-size: 13px;
}

.time-slot-btn.is-selected {
  background-color: #ecf5ff;
  border-color: #409eff;
  color: #409eff;
}

.slot-status {
  font-size: 11px;
  color: #909399;
  margin-top: 2px;  /* 添加一点上边距 */
}

.dialog-footer {
  padding: 16px 20px;
  border-top: 1px solid #e4e7ed;
  display: flex;
  justify-content: flex-end;
  gap: 12px;
}

:deep(.el-calendar) {
  --el-calendar-border: none;
  --el-calendar-header-border-bottom: 1px solid #e4e7ed;
}

:deep(.el-calendar__header) {
  display: none;
}

:deep(.el-calendar-day) {
  height: 45px;
  padding: 0;
}

:deep(.el-calendar-day:hover) {
  background-color: #f5f7fa;
}

.calendar-cell:not(.is-disabled):hover {
  background-color: #f5f7fa;
}

/* 添加预约提示样式 */
.booking-notice {
  display: flex;
  align-items: center;
  gap: 6px;
  padding: 12px;
  margin-top: 12px;
  background-color: #fdf6ec;
  border-radius: 4px;
  color: #e6a23c;
  font-size: 13px;
}

.booking-notice .el-icon {
  font-size: 14px;
}
</style> 