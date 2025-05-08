<template>
  <div class="test-list">
    <!-- 添加头部区域 -->
    <div class="list-header">
      <h3 class="section-title">测验记录</h3>
      
      <!-- 只在当前用户访问自己的主页时显示隐私设置 -->
      <el-tooltip
        v-if="isOwnProfile"
        content="设置测验记录是否对其他用户可见"
        placement="top"
      >
        <el-switch
          :model-value="testHistoryPublic"
          @update:model-value="handlePrivacyChange"
          active-text="公开"
          inactive-text="私密"
        />
      </el-tooltip>
    </div>

    <!-- 判断是否可以查看内容 -->
    <template v-if="canViewContent">
      <!-- 已完成的测验卡片网格 -->
      <div class="test-grid">
        <el-card 
          v-for="test in displayedTests" 
          :key="test.id" 
          class="test-card completed"
        >
          <div class="test-content">
            <h3>{{ test.name }}</h3>
            <p class="test-desc">{{ test.description }}</p>
            
            <div class="test-footer">
              <div class="score-info">
                <span class="score-label">得分：</span>
                <span class="score-value">{{ test.score }}</span>
              </div>
              <!-- 只在当前用户访问自己的主页时显示重新测试按钮 -->
              <el-button 
                v-if="isOwnProfile"
                type="primary" 
                @click="handleRetake(test)"
              >
                重新测试
              </el-button>
            </div>
          </div>
        </el-card>

        <!-- 只在当前用户访问自己的主页时显示更多测验卡片 -->
        <el-card 
          v-if="isOwnProfile && uncompletedTests.length > 0"
          class="test-card more-card" 
          @click="showMoreDialog = true"
        >
          <div class="more-content">
            <el-icon class="more-icon"><Plus /></el-icon>
            <span>更多测验</span>
          </div>
        </el-card>
      </div>

      <!-- 修改对话框标题和内容 -->
      <el-dialog
        v-model="showMoreDialog"
        title="可用的心理测验"
        width="80%"
        :close-on-click-modal="true"
        style="margin-top: 30px;"
      >
        <div class="all-tests-grid">
          <el-card 
            v-for="test in uncompletedTests" 
            :key="test.id" 
            class="test-card"
          >
            <div class="test-content">
              <h3>{{ test.name }}</h3>
              <p class="test-desc">{{ test.description }}</p>
              
              <div class="test-footer">
                <el-button type="primary" @click="handleStart(test)">开始测试</el-button>
              </div>
            </div>
          </el-card>
        </div>
      </el-dialog>
    </template>
    <template v-else>
      <private-content message="该用户的测验记录已设为私密" />
    </template>
  </div>
</template>

<script setup lang="ts">
import { ref, computed } from 'vue'
import { Plus } from '@element-plus/icons-vue'
import { useRouter, useRoute } from 'vue-router'
import { useUserStore } from '@/stores/user'
import { ElMessage } from 'element-plus'
import type { UserInfo } from '@/types/user'
import PrivateContent from './PrivateContent.vue'

const router = useRouter()
const route = useRoute()
const userStore = useUserStore()
const showMoreDialog = ref(false)

// 判断是否是当前用户的主页
const isOwnProfile = computed(() => {
  return route.params.id === userStore.userInfo?.id
})

// 获取用户信息
const userInfo = computed(() => {
  return userStore.userInfo
})

// 添加测试记录可见性的计算属性
const testHistoryPublic = computed(() => {
  return userStore.userInfo?.testHistoryPublic ?? false
})

// 修改处理隐私设置变更函数
const handlePrivacyChange = (value: boolean) => {
  if (userStore.userInfo) {
    userStore.updateUserInfo({
      ...userStore.userInfo,
      testHistoryPublic: value
    })
    ElMessage.success(`测验记录已设为${value ? '公开' : '私密'}`)
  }
}

// 修改测验数据
const tests = [
  {
    id: 1,
    name: '焦虑自评量表',
    description: '通过20个选择题评估您当前的焦虑水平，帮助了解自己的心理状态',
    score: 75
  },
  {
    id: 2,
    name: '抑郁倾向测试',
    description: '包含25道选择题，评估抑郁倾向，及早发现情绪问题',
    score: null
  },
  {
    id: 3,
    name: '人格特质测试',
    description: '30道性格测试题，了解自己的性格特点和行为模式',
    score: 88
  },
  {
    id: 4,
    name: '压力源评估',
    description: '15个选择题帮助您识别生活中的压力来源，提供应对建议',
    score: null
  },
  {
    id: 5,
    name: '情商测试',
    description: '通过25道选择题测评情绪智力水平，提升人际交往能力',
    score: 92
  },
  {
    id: 6,
    name: '社交焦虑测试',
    description: '20道选择题评估社交场合中的焦虑程度，提供改善建议',
    score: 65
  },
  {
    id: 7,
    name: '自尊心评估',
    description: '15道选择题测量自尊水平，帮助建立健康的自我认知',
    score: null
  },
  {
    id: 8,
    name: '学习压力测试',
    description: '25个选择题评估学习压力程度，提供缓解方法',
    score: 85
  },
  {
    id: 9,
    name: '人际关系测评',
    description: '30道选择题分析人际交往模式，改善社交关系',
    score: null
  },
  {
    id: 10,
    name: '情绪管理能力测试',
    description: '20道选择题评估情绪调节能力，提供情绪管理技巧',
    score: 78
  }
]

// 添加计算属性来过滤测验
const completedTests = computed(() => 
  tests.filter(test => test.score !== null)
)

const uncompletedTests = computed(() => 
  tests.filter(test => test.score === null)
)

// 修改显示的测验，只显示已完成的测验
const displayedTests = computed(() => 
  completedTests.value.slice(0, 3)
)

// 开始测试
const handleStart = (test: any) => {
  router.push(`/test/${test.id}`)
}

// 重新测试
const handleRetake = (test: any) => {
  router.push(`/test/${test.id}?retake=true`)
}

// 判断是否可以查看内容
const canViewContent = computed(() => {
  const targetUser = userStore.getUserById(route.params.id as string)
  return isOwnProfile.value || 
         userStore.userInfo?.roles === 'admin' || 
         targetUser?.testHistoryPublic
})
</script>

<style scoped>
.test-list {
  padding: 20px;
}

.test-grid {
  display: grid;
  grid-template-columns: repeat(auto-fill, minmax(280px, 1fr));
  gap: 20px;
}

.test-card {
  height: 200px;
  transition: transform 0.3s;
}

.test-card:hover {
  transform: translateY(-5px);
}

.test-content {
  height: 100%;
  display: flex;
  flex-direction: column;
  padding: 16px;
}

.test-content h3 {
  margin: 0 0 12px;
  font-size: 18px;
  color: #303133;
}

.test-desc {
  flex: 1;
  margin: 0;
  font-size: 14px;
  color: #606266;
  line-height: 1.6;
}

.test-footer {
  margin-top: 12px;
  display: flex;
  justify-content: space-between;
  align-items: center;
}

.score-info {
  display: flex;
  align-items: center;
  gap: 8px;
}

.score-label {
  font-size: 14px;
  color: #606266;
}

.score-value {
  font-size: 20px;
  font-weight: 600;
  color: #409EFF;
}

.completed {
  border: 1px solid #409EFF;
}

.more-card {
  cursor: pointer;
  border: 2px dashed #dcdfe6;
  background-color: #f5f7fa;
  height: 200px;
  display: flex;
  align-items: center;
  justify-content: center;
}

.more-card:hover {
  border-color: #409EFF;
  color: #409EFF;
}

.more-card :deep(.el-card__body) {
  width: 100%;
  height: 100%;
  display: flex;
  align-items: center;
  justify-content: center;
}

.more-content {
  height: auto;
  display: flex;
  flex-direction: column;
  align-items: center;
  gap: 12px;
  color: #909399;
}

.more-icon {
  font-size: 32px;
}

.more-content span {
  font-size: 16px;
}

/* 添加对话框内的网格样式 */
.all-tests-grid {
  display: grid;
  grid-template-columns: repeat(auto-fill, minmax(280px, 1fr));
  gap: 20px;
  padding: 20px;
  max-height: 70vh;
  overflow-y: auto;
}

/* 对话框内的卡片样式调整 */
:deep(.el-dialog__body) {
  padding: 0;
}

:deep(.el-dialog__header) {
  padding: 20px;
  margin: 0;
  border-bottom: 1px solid #e4e7ed;
}

.list-header {
  display: flex;
  justify-content: space-between;
  align-items: center;
  margin-bottom: 20px;
}

.section-title {
  margin: 0;
  font-size: 18px;
  font-weight: 600;
  color: #303133;
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