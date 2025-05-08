<template>
  <div class="test-page">
    <!-- 测验头部信息 -->
    <el-card class="test-header">
      <h1>{{ currentTest?.name }}</h1>
      <p class="test-description">{{ currentTest?.description }}</p>
      <el-divider />
      <div class="test-info">
        <span>题目数量：{{ currentTest?.questions.length }}题</span>
        <span>预计用时：{{ Math.ceil(currentTest?.questions.length || 0 * 0.5) }}分钟</span>
      </div>
    </el-card>

    <!-- 测验内容 -->
    <el-card v-if="isStarted" class="test-content">
      <div class="question-header">
        <span class="question-progress">第 {{ currentQuestionIndex + 1 }}/{{ currentTest?.questions.length }} 题</span>
        <el-progress 
          :percentage="(currentQuestionIndex + 1) / (currentTest?.questions.length || 1) * 100" 
          :format="() => ''"
          :stroke-width="8"
        />
      </div>

      <div class="question-content">
        <h3>{{ currentQuestion?.content }}</h3>
        <el-radio-group v-model="selectedAnswer" class="answer-list">
          <el-radio 
            v-for="option in currentQuestion?.options" 
            :key="option.value" 
            :label="option.value"
            class="answer-item"
          >
            {{ option.label }}
          </el-radio>
        </el-radio-group>
      </div>

      <div class="question-actions">
        <el-button 
          v-if="currentQuestionIndex > 0" 
          @click="handlePrevQuestion"
        >
          上一题
        </el-button>
        <el-button 
          type="primary" 
          @click="handleNextQuestion"
        >
          {{ isLastQuestion ? '提交' : '下一题' }}
        </el-button>
      </div>
    </el-card>

    <!-- 开始测试按钮 -->
    <div v-else class="test-start">
      <el-button type="primary" size="large" @click="startTest">开始测试</el-button>
    </div>
  </div>
</template>

<script setup lang="ts">
import { ref, computed } from 'vue'
import { useRoute, useRouter } from 'vue-router'
import { ElMessage, ElMessageBox } from 'element-plus'

const route = useRoute()
const router = useRouter()
const testId = route.params.id as string

// 测验数据示例
const testData = {
  id: 1,
  name: '焦虑自评量表',
  description: '通过20个选择题评估您当前的焦虑水平，帮助了解自己的心理状态。本测验将帮助您了解自己的焦虑程度，并提供相应的建议。',
  questions: [
    {
      id: 1,
      content: '在过去的一周里，您是否经常感到紧张或焦虑？',
      options: [
        { value: 'A', label: '从不' },
        { value: 'B', label: '偶尔' },
        { value: 'C', label: '经常' },
        { value: 'D', label: '总是' }
      ]
    },
    // ... 更多题目
  ]
}

const currentTest = ref(testData)
const isStarted = ref(false)
const currentQuestionIndex = ref(0)
const selectedAnswer = ref('')
const answers = ref<string[]>([])

// 当前问题
const currentQuestion = computed(() => 
  currentTest.value?.questions[currentQuestionIndex.value]
)

// 是否为最后一题
const isLastQuestion = computed(() => 
  currentQuestionIndex.value === (currentTest.value?.questions.length || 0) - 1
)

// 开始测试
const startTest = () => {
  isStarted.value = true
  answers.value = new Array(currentTest.value?.questions.length).fill('')
}

// 处理上一题
const handlePrevQuestion = () => {
  if (currentQuestionIndex.value > 0) {
    currentQuestionIndex.value--
    selectedAnswer.value = answers.value[currentQuestionIndex.value]
  }
}

// 处理下一题或提交
const handleNextQuestion = async () => {
  if (!selectedAnswer.value) {
    ElMessage.warning('请选择一个选项')
    return
  }

  // 保存当前答案
  answers.value[currentQuestionIndex.value] = selectedAnswer.value

  if (isLastQuestion.value) {
    // 提交测试
    const confirm = await ElMessageBox.confirm(
      '确定要提交测试吗？提交后将无法修改答案。',
      '提示',
      {
        confirmButtonText: '确定',
        cancelButtonText: '取消',
        type: 'warning'
      }
    ).catch(() => false)

    if (confirm) {
      // TODO: 调用API提交答案
      ElMessage.success('测试提交成功')
      router.push('/user')
    }
  } else {
    // 进入下一题
    currentQuestionIndex.value++
    selectedAnswer.value = answers.value[currentQuestionIndex.value]
  }
}
</script>

<style scoped>
.test-page {
  padding: 20px;
  max-width: 800px;
  margin: 0 auto;
}

.test-header {
  margin-bottom: 20px;
}

.test-header h1 {
  margin: 0 0 16px;
  font-size: 24px;
  color: #303133;
}

.test-description {
  color: #606266;
  line-height: 1.6;
  margin-bottom: 16px;
}

.test-info {
  display: flex;
  gap: 24px;
  color: #909399;
}

.test-content {
  margin-bottom: 20px;
}

.question-header {
  margin-bottom: 24px;
}

.question-progress {
  display: block;
  margin-bottom: 8px;
  color: #606266;
}

.question-content {
  margin: 24px 0;
}

.question-content h3 {
  margin: 0 0 20px;
  font-size: 18px;
  color: #303133;
}

.answer-list {
  display: flex;
  flex-direction: column;
  gap: 16px;
}

.answer-item {
  margin: 0;
  padding: 12px 16px;
  border-radius: 4px;
  transition: all 0.3s;
}

.answer-item:hover {
  background-color: #f5f7fa;
}

.question-actions {
  display: flex;
  justify-content: space-between;
  margin-top: 24px;
}

.test-start {
  display: flex;
  justify-content: center;
  margin-top: 40px;
}
</style> 