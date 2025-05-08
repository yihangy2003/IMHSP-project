<template>
  <div class="topic-add">
    <div class="editor-container">
      <div class="editor-header">
        <h2>发布新动态</h2>
      </div>
      <div class="editor-content">
        <el-input
          v-model="title"
          placeholder="请输入标题"
          class="title-input"
          @input="handleContentChange"
        />
        <div id="vditor"></div>
      </div>
      <div class="editor-footer">
        <el-button @click="cancel" :disabled="hasContent">取消</el-button>
        <el-button type="primary" @click="publish">发布</el-button>
      </div>
    </div>
  </div>
</template>

<script setup lang="ts">
import { ref, onMounted, onBeforeUnmount, watch } from 'vue'
import { useRouter } from 'vue-router'
import Vditor from 'vditor'
import 'vditor/dist/index.css'
import { ElMessage } from 'element-plus'
import { useUserStore } from '@/stores/user'

const router = useRouter()
const userStore = useUserStore()
const title = ref('')
const content = ref('')

const vditor = ref()
let hasContent = false

const cancel = () => {
  router.back()
}

const publish = () => {
  if (!title.value.trim()) {
    ElMessage.warning('请输入标题')
    return
  }

  if (!vditor.value?.getValue()?.trim()) {
    ElMessage.warning('请输入内容')
    return
  }

  // 创建新动态对象
  const newPost = {
    id: Date.now(),  // 临时ID，实际应该由后端生成
    title: title.value,
    content: vditor.value.getValue(),
    createTime: new Date().toLocaleString(),
    views: 0,
    likes: 0,
    collects: 0,
    isLiked: false,
    isCollected: false,
    showComments: false,
    author: {
      id: userStore.userInfo?.id || 1,
      name: userStore.userInfo?.username || '匿名用户',
      avatar: userStore.userInfo?.avatar || '',
      posts: 0,
      followers: 0,
      following: 0,
      bio: ''
    },
    comments: []
  }

  // TODO: 发送请求到后端保存动态
  // 这里模拟保存成功
  ElMessage.success('发布成功')
  
  // 跳转回社区页面
  router.push('/community')
}

// 添加刷新确认
const handleBeforeUnload = (e: BeforeUnloadEvent) => {
  if (hasContent) {
    const message = '您有未保存的内容，确定要离开吗？'
    e.preventDefault()
    e.returnValue = message
    return message
  }
}

// 监听编辑器内容变化
const handleContentChange = () => {
  const currentContent = vditor.value?.getValue()?.trim()
  hasContent = !!(title.value || currentContent)
}

onMounted(() => {
    vditor.value = new Vditor('vditor', {
        height: 540,
        minHeight: 540,
        placeholder: '请输入内容...',
        after: () => {
            // 编辑器初始化完成后的回调
            vditor.value?.focus()
            // 清空编辑器内容
            vditor.value?.setValue('')
        },
        input: handleContentChange,  // 监听输入事件
        cache: {
            enable: false  // 禁用缓存功能
        },
        debugger: true,
        typewriterMode: true,
        lang: "zh_CN",
        mode: "wysiwyg",
        value: '',  // 设置初始值为空
        preview: {
            markdown: {
                toc: true,
                mark: true,
                footnotes: true,
                autoSpace: true,
            },
            math: {
                engine: "KaTeX",
                inlineDigit: true,
            },
        },
        toolbarConfig: {
            pin: true,
        },
        counter: {
            enable: true,
            type: "text",
        },
        hint: {
            parse: false,
        },
        tab: "\t",
        upload: {
            accept: "image/*,.mp3, .wav, .rar",
            token: "test",
            url: "/api/upload/editor",
            linkToImgUrl: "/api/upload/fetch",
            filename(name) {
                return name.replace(/[^(a-zA-Z0-9\u4e00-\u9fa5\.)]/g, "").replace(/[\?\\/:|<>\*\[\]\(\)\$%\{\}@~]/g, "").replace("/\\s/g", "")
            },
        },
    })
    
    // 添加刷新确认监听
    window.addEventListener('beforeunload', handleBeforeUnload)
})

// 在组件卸载时销毁编辑器
onBeforeUnmount(() => {
  vditor.value?.destroy()
  window.removeEventListener('beforeunload', handleBeforeUnload)
})

// 监听标题变化
watch(() => title.value, handleContentChange)
</script>

<style scoped>
.topic-add {
  padding: 20px;
  min-height: 100vh;  /* 最小高度为视口高度 */
  background-color: #f5f7fa;
}

.editor-container {
  max-width: 1000px;
  margin: 0 auto;
  background: white;
  border-radius: 8px;
  box-shadow: 0 2px 12px rgba(0, 0, 0, 0.05);
  display: flex;
  flex-direction: column;
}

.editor-header {
  padding: 20px;
  border-bottom: 1px solid #ebeef5;
}

.editor-header h2 {
  margin: 0;
  color: #303133;
  font-size: 20px;
}

.editor-content {
  padding: 20px;
  flex: 1;
  display: flex;
  flex-direction: column;
  min-height: 600px;  /* 设置最小高度 */
  max-height: 700px;  /* 设置最大高度 */
  overflow: auto;  /* 内容超出时显示滚动条 */
}

.title-input {
  margin-bottom: 20px;
}

/* Vditor 编辑器样式调整 */
:deep(#vditor) {
  border-radius: 4px;
  border: 1px solid #dcdfe6;
  height: calc(100% - 80px) !important;  /* 调整高度，留出标题和底部间距 */
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

.editor-footer {
  padding: 20px;
  border-top: 1px solid #ebeef5;
  display: flex;
  justify-content: flex-end;
  gap: 12px;
}

/* 自定义滚动条样式 */
.editor-content::-webkit-scrollbar {
  width: 6px;
}

.editor-content::-webkit-scrollbar-track {
  background: #f4f4f5;
  border-radius: 3px;
}

.editor-content::-webkit-scrollbar-thumb {
  background: #909399;
  border-radius: 3px;
}

.editor-content::-webkit-scrollbar-thumb:hover {
  background: #606266;
}
</style> 