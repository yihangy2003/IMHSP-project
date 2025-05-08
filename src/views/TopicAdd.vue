<template>
  <div class="topic-add">
    <div class="editor-container">
      <div class="editor-header">
        <h2>发布新专题</h2>
      </div>

      <div class="editor-content">
        <!-- 基本信息表单 -->
        <el-form :model="topicForm" label-width="80px" class="topic-form">
          <el-form-item label="标题">
            <el-input 
              v-model="topicForm.title" 
              placeholder="请输入专题标题"
              maxlength="50"
              show-word-limit
            />
          </el-form-item>

          <el-form-item label="简介">
            <el-input 
              v-model="topicForm.introduction" 
              type="textarea"
              :rows="3"
              placeholder="请输入专题简介"
              maxlength="200"
              show-word-limit
            />
          </el-form-item>

          <el-form-item label="付费设置">
            <el-radio-group v-model="topicForm.type">
              <el-radio label="free">免费</el-radio>
              <el-radio label="paid">付费</el-radio>
            </el-radio-group>
          </el-form-item>

          <el-form-item label="价格" v-if="topicForm.type === 'paid'">
            <el-input-number 
              v-model="topicForm.price"
              :min="1"
              :precision="2"
              :step="0.01"
            >
              <template #prefix>¥</template>
            </el-input-number>
          </el-form-item>

          <el-form-item label="封面">
            <el-upload
              class="cover-uploader"
              action="#"
              :show-file-list="false"
              :before-upload="beforeCoverUpload"
            >
              <img v-if="topicForm.cover" :src="topicForm.cover" class="cover-preview">
              <el-icon v-else class="cover-uploader-icon"><Plus /></el-icon>
            </el-upload>
          </el-form-item>
        </el-form>

        <!-- Markdown 编辑器 -->
        <div class="markdown-editor">
          <h3>专题内容</h3>
          <div id="vditor"></div>
        </div>
      </div>

      <div class="editor-footer">
        <el-button @click="cancel">取消</el-button>
        <el-button type="primary" @click="publish">发布</el-button>
      </div>
    </div>
  </div>
</template>

<script setup lang="ts">
import { ref, onMounted, onBeforeUnmount } from 'vue'
import { useRouter } from 'vue-router'
import { ElMessage } from 'element-plus'
import { Plus } from '@element-plus/icons-vue'
import Vditor from 'vditor'
import 'vditor/dist/index.css'

const router = useRouter()
const vditor = ref()

// 专题表单数据
const topicForm = ref({
  title: '',
  introduction: '',
  type: 'free',
  price: 0,
  cover: '',
  content: ''
})

// 初始化编辑器
onMounted(() => {
  vditor.value = new Vditor('vditor', {
    height: 500,
    mode: 'wysiwyg',
    placeholder: '请输入专题内容...',
    preview: {
      delay: 300,
      maxWidth: 1000,
      mode: 'both'
    },
    upload: {
      accept: 'image/*',
      multiple: true,
      handler: async (files: File[]) => {
        return files.map(file => {
          const reader = new FileReader()
          return new Promise((resolve) => {
            reader.onload = () => {
              resolve({
                url: reader.result,
                alt: file.name
              })
            }
            reader.readAsDataURL(file)
          })
        })
      }
    },
    cache: {
      enable: true,
      id: 'topic-editor'
    },
    after: () => {
      // 编辑器初始化完成后的回调
    }
  })
})

// 组件销毁前清理编辑器
onBeforeUnmount(() => {
  vditor.value?.destroy()
})

// 处理封面上传
const beforeCoverUpload = (file: File) => {
  // 这里应该处理图片上传逻辑
  const reader = new FileReader()
  reader.readAsDataURL(file)
  reader.onload = () => {
    topicForm.value.cover = reader.result as string
  }
  return false
}

// 取消编辑
const cancel = () => {
  router.back()
}

// 发布专题
const publish = async () => {
  if (!topicForm.value.title.trim()) {
    ElMessage.warning('请输入专题标题')
    return
  }

  if (!topicForm.value.introduction.trim()) {
    ElMessage.warning('请输入专题简介')
    return
  }

  if (!topicForm.value.cover) {
    ElMessage.warning('请上传专题封面')
    return
  }

  const content = vditor.value?.getValue()
  if (!content?.trim()) {
    ElMessage.warning('请输入专题内容')
    return
  }

  // TODO: 发送请求保存专题
  ElMessage.success('专题发布成功')
  router.push('/topic')
}
</script>

<style scoped>
.topic-add {
  padding: 20px;
}

.editor-container {
  background: #fff;
  border-radius: 8px;
  box-shadow: 0 2px 12px rgba(0, 0, 0, 0.04);
}

.editor-header {
  padding: 20px;
  border-bottom: 1px solid #ebeef5;
}

.editor-header h2 {
  margin: 0;
  font-size: 20px;
  color: #303133;
}

.editor-content {
  padding: 20px;
}

.topic-form {
  margin-bottom: 24px;
}

.cover-uploader {
  border: 1px dashed #d9d9d9;
  border-radius: 6px;
  cursor: pointer;
  position: relative;
  overflow: hidden;
  width: 240px;
  height: 135px;
  display: flex;
  justify-content: center;
  align-items: center;
}

.cover-uploader:hover {
  border-color: #409EFF;
}

.cover-uploader-icon {
  font-size: 28px;
  color: #8c939d;
  width: 32px;
  height: 32px;
}

.cover-preview {
  width: 100%;
  height: 100%;
  object-fit: cover;
}

.markdown-editor {
  margin-top: 24px;
}

.markdown-editor h3 {
  margin: 0 0 16px;
  font-size: 16px;
  color: #303133;
}

#vditor {
  border: 1px solid #dcdfe6;
  border-radius: 4px;
}

.editor-footer {
  padding: 20px;
  border-top: 1px solid #ebeef5;
  display: flex;
  justify-content: flex-end;
  gap: 12px;
  margin-bottom: 15px;
}

:deep(.el-form-item__label) {
  font-weight: 500;
}

:deep(.el-radio-group) {
  display: flex;
  gap: 24px;
}

/* 调整编辑器样式 */
:deep(.vditor) {
  border: 1px solid #dcdfe6;
  border-radius: 4px;
}

:deep(.vditor-toolbar) {
  border-bottom: 1px solid #dcdfe6;
  background-color: #fafafa;
}

:deep(.vditor-toolbar__item) {
  padding: 6px;
  border-radius: 4px;
}

:deep(.vditor-toolbar__item:hover) {
  background-color: #f0f2f5;
}

:deep(.vditor-reset) {
  padding: 16px;
}

:deep(.vditor-preview) {
  background-color: #fafafa;
  padding: 16px;
}
</style> 