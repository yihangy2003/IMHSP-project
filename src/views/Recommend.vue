<template>
  <div class="topic-container">
    <!-- 左侧区域 -->
    <div class="left-section">
      <!-- 热门专题 -->
      <div class="topic-section hot-topics">
        <div class="section-header">
          <h2>热门专题推荐</h2>
          <el-link type="primary" class="refresh-link" :underline="false" @click="refreshHotTopics">
            <el-icon class="refresh-icon"><Refresh /></el-icon>
            刷新
          </el-link>
        </div>
        <div class="topic-list">
          <div v-for="(topic, index) in hotTopics" :key="topic.id" class="topic-card">
            <div :class="['rank-badge', topic.type === 'free' ? 'free' : topic.type === 'paid' ? 'premium' : '']">
              {{ topic.type === 'free' ? '免费' : topic.type === 'paid' ? `￥${topic.price}` : index + 1 }}
            </div>
            <el-image :src="topic.cover" fit="cover" class="topic-cover" />
            <div class="topic-info">
              <div class="info-left">
                <h3 class="topic-title">{{ topic.title }}</h3>
                <span class="topic-author">{{ topic.author }}</span>
              </div>
              <div class="topic-stats">
                <span><el-icon><View /></el-icon>{{ topic.views }}</span>
                <span><el-icon><Star /></el-icon>{{ topic.likes }}</span>
              </div>
            </div>
          </div>
        </div>
      </div>

      <!-- 免费专题 -->
      <div class="topic-section free-topics">
        <div class="section-header">
          <h2>免费专题推荐</h2>
          <el-link type="primary" class="refresh-link" :underline="false" @click="refreshFreeTopics">
            <el-icon class="refresh-icon"><Refresh /></el-icon>
            刷新
          </el-link>
        </div>
        <div class="topic-list">
          <div v-for="(topic, index) in freeTopics" :key="topic.id" class="topic-card">
            <div class="rank-badge free">免费</div>
            <el-image :src="topic.cover" fit="cover" class="topic-cover" />
            <div class="topic-info">
              <div class="info-left">
                <h3 class="topic-title">{{ topic.title }}</h3>
                <span class="topic-author">{{ topic.author }}</span>
              </div>
              <div class="topic-stats">
                <span><el-icon><View /></el-icon>{{ topic.views }}</span>
                <span><el-icon><Star /></el-icon>{{ topic.likes }}</span>
              </div>
            </div>
          </div>
        </div>
      </div>
    </div>

    <!-- 右侧区域 -->
    <div class="right-section">
      <!-- 专题搜索 -->
      <div class="topic-section search-section">
        <el-input
          v-model="searchQuery"
          placeholder="搜索专题..."
          prefix-icon="Search"
          clearable
          @input="handleSearch"
        >
          <template #append>
            <el-button type="primary">搜索</el-button>
          </template>
        </el-input>

        <!-- 搜索建议 -->
        <div class="search-suggestions" v-if="!searchResults.length">
          <h4>热门搜索</h4>
          <div class="suggestion-tags">
            <el-tag
              v-for="tag in searchSuggestions"
              :key="tag"
              @click="handleTagClick(tag)"
              class="suggestion-tag"
            >
              {{ tag }}
            </el-tag>
          </div>
        </div>

        <!-- 搜索结果 -->
        <div class="search-results" v-if="searchResults.length">
          <div v-for="result in searchResults" :key="result.id" class="search-result-item">
            <div class="result-cover-wrapper">
              <div :class="['search-badge', result.type === 'free' ? 'free' : 'premium']">
                {{ result.type === 'free' ? '免费' : `￥${result.price}` }}
              </div>
              <el-image :src="result.cover" fit="cover" class="result-cover" />
            </div>
            <div class="result-info">
              <div class="info-left">
                <h3>{{ result.title }}</h3>
                <span class="author">{{ result.author }}</span>
              </div>
              <div class="stats">
                <span><el-icon><View /></el-icon>{{ result.views }}</span>
                <span><el-icon><Star /></el-icon>{{ result.likes }}</span>
              </div>
            </div>
          </div>
        </div>
      </div>

      <!-- 付费专题 -->
      <div class="topic-section paid-topics">
        <div class="section-header">
          <h2>付费专题推荐</h2>
          <el-link type="primary" class="refresh-link" :underline="false" @click="refreshPaidTopics">
            <el-icon class="refresh-icon"><Refresh /></el-icon>
            刷新
          </el-link>
        </div>
        <div class="topic-list">
          <div v-for="(topic, index) in paidTopics" :key="topic.id" class="topic-card">
            <div class="rank-badge premium">￥{{ topic.price }}</div>
            <el-image :src="topic.cover" fit="cover" class="topic-cover" />
            <div class="topic-info">
              <div class="info-left">
                <h3 class="topic-title">{{ topic.title }}</h3>
                <span class="topic-author">{{ topic.author }}</span>
              </div>
              <div class="topic-stats">
                <span><el-icon><View /></el-icon>{{ topic.views }}</span>
                <span><el-icon><Star /></el-icon>{{ topic.likes }}</span>
              </div>
            </div>
          </div>
        </div>
      </div>
    </div>
  </div>
</template>

<script setup lang="ts">
import { ref } from 'vue'
import { View, Star, Search, Refresh } from '@element-plus/icons-vue'

// 添加专题类型定义
interface Topic {
  id: number
  title: string
  cover: string
  views: string
  likes: number
  author: string
  type: 'free' | 'paid'
  price?: number // 可选字段，仅付费专题需要
}

// 搜索相关
const searchQuery = ref('')
const searchResults = ref<Topic[]>([])
const searchSuggestions = [
  '压力管理',
  '情绪调节',
  '人际关系',
  '自我成长',
  '心理健康',
  '职场心理'
]

// 修改 ref 的类型声明
const hotTopics = ref<Topic[]>([
  {
    id: 1,
    title: '走出抑郁：自我疗愈指南',
    cover: '/topics/1.jpg',
    views: '12.5k',
    likes: 2341,
    author: '张医生',
    type: 'free'
  },
  {
    id: 2,
    title: '焦虑管理：重获内心平静',
    cover: '/topics/2.jpg',
    views: '10.8k',
    likes: 1987,
    author: '李心理',
    type: 'paid',
    price: 199
  },
  {
    id: 3,
    title: '情绪调节的艺术',
    cover: '/topics/3.jpg',
    views: '9.2k',
    likes: 1756,
    author: '王教授',
    type: 'free'
  },
  {
    id: 4,
    title: '人际关系修复指南',
    cover: '/topics/4.jpg',
    views: '8.7k',
    likes: 1543,
    author: '赵咨询师',
    type: 'paid',
    price: 299
  },
  {
    id: 5,
    title: '职场压力应对策略',
    cover: '/topics/5.jpg',
    views: '7.9k',
    likes: 1432,
    author: '陈博士',
    type: 'free'
  }
])

const freeTopics = ref<Topic[]>([
  {
    id: 1,
    title: '心理健康入门指南',
    cover: '/topics/6.jpg',
    views: '6.3k',
    likes: 1234,
    author: '刘医生',
    type: 'free' // 添加缺失的 type 字段
  },
  {
    id: 2,
    title: '情绪觉察基础课程',
    cover: '/topics/7.jpg',
    views: '5.8k',
    likes: 1123,
    author: '孙老师',
    type: 'free' // 添加缺失的 type 字段
  },
  {
    id: 3,
    title: '自我认知探索',
    cover: '/topics/8.jpg',
    views: '5.2k',
    likes: 987,
    author: '吴教授',
    type: 'free' // 添加缺失的 type 字段
  },
  {
    id: 4,
    title: '压力纾解基础练习',
    cover: '/topics/9.jpg',
    views: '4.9k',
    likes: 876,
    author: '郑咨询师',
    type: 'free' // 添加缺失的 type 字段
  },
  {
    id: 5,
    title: '睡眠改善指南',
    cover: '/topics/10.jpg',
    views: '4.5k',
    likes: 765,
    author: '黄医生',
    type: 'free' // 添加缺失的 type 字段
  }
])

const paidTopics = ref<Topic[]>([
  {
    id: 1,
    title: '专业心理咨询课程',
    cover: '/topics/11.jpg',
    views: '7.8k',
    likes: 1876,
    author: '马教授',
    type: 'paid', // 添加缺失的 type 字段
    price: 299
  },
  {
    id: 2,
    title: '深度心理分析实践',
    cover: '/topics/12.jpg',
    views: '6.9k',
    likes: 1654,
    author: '林专家',
    type: 'paid', // 添加缺失的 type 字段
    price: 399
  },
  {
    id: 3,
    title: '高效情绪管理进阶',
    cover: '/topics/13.jpg',
    views: '6.2k',
    likes: 1432,
    author: '徐博士',
    type: 'paid', // 添加缺失的 type 字段
    price: 259
  },
  {
    id: 4,
    title: '人际关系进阶指导',
    cover: '/topics/14.jpg',
    views: '5.7k',
    likes: 1321,
    author: '朱咨询师',
    type: 'paid', // 添加缺失的 type 字段
    price: 199
  },
  {
    id: 5,
    title: '职业心理辅导专题',
    cover: '/topics/15.jpg',
    views: '5.1k',
    likes: 1234,
    author: '韩专家',
    type: 'paid', // 添加缺失的 type 字段
    price: 359
  }
])

// 添加标签点击处理函数
const handleTagClick = (tag: string) => {
  searchQuery.value = tag
  handleSearch() // 直接触发搜索
}

// 修改搜索处理函数，使其可以被其他函数调用
const handleSearch = () => {
  if (searchQuery.value) {
    searchResults.value = [
      {
        id: 1,
        title: '情绪管理与压力缓解',
        cover: '/topics/16.jpg',
        views: '3.2k',
        likes: 456,
        author: '赵医生',
        type: 'free'
      },
      {
        id: 2,
        title: '职场心理调适指南',
        cover: '/topics/17.jpg',
        views: '2.8k',
        likes: 389,
        author: '钱教授',
        type: 'paid',
        price: 199
      },
      {
        id: 3,
        title: '人际沟通技巧提升',
        cover: '/topics/18.jpg',
        views: '2.5k',
        likes: 345,
        author: '孙咨询师',
        type: 'free'
      },
      {
        id: 4,
        title: '自我认知与成长',
        cover: '/topics/19.jpg',
        views: '2.3k',
        likes: 312,
        author: '李博士',
        type: 'free'
      },
      {
        id: 5,
        title: '家庭关系心理调适',
        cover: '/topics/20.jpg',
        views: '2.1k',
        likes: 298,
        author: '周专家',
        type: 'free'
      }
    ]
  } else {
    searchResults.value = []
  }
}

// 修改专题池的类型
const topicPool: {
  hot: Topic[]
  free: Topic[]
  paid: Topic[]
} = {
  hot: [
    ...hotTopics.value,
    {
      id: 6,
      title: '认知行为疗法入门',
      cover: '/topics/21.jpg',
      views: '11.3k',
      likes: 2156,
      author: '周教授',
      type: 'paid',
      price: 259
    },
    {
      id: 7,
      title: '正念冥想练习',
      cover: '/topics/22.jpg',
      views: '10.1k',
      likes: 1897,
      author: '吴咨询师',
      type: 'free'
    },
  ],
  free: [
    ...freeTopics.value,
    {
      id: 6,
      title: '心理健康自测指南',
      cover: '/topics/23.jpg',
      views: '5.9k',
      likes: 1023,
      author: '郑医生',
      type: 'free'
    },
    {
      id: 7,
      title: '情绪日记写作',
      cover: '/topics/24.jpg',
      views: '5.5k',
      likes: 967,
      author: '林老师',
      type: 'free'
    },
  ],
  paid: [
    ...paidTopics.value,
    {
      id: 6,
      title: '家庭治疗实务',
      cover: '/topics/25.jpg',
      views: '6.7k',
      likes: 1543,
      author: '张专家',
      type: 'paid',
      price: 329
    },
    {
      id: 7,
      title: '心理评估技术',
      cover: '/topics/26.jpg',
      views: '6.1k',
      likes: 1432,
      author: '李博士',
      type: 'paid',
      price: 279
    },
  ]
}

// 修改刷新函数
const refreshHotTopics = () => {
  const shuffled = [...topicPool.hot].sort(() => Math.random() - 0.5)
  hotTopics.value = shuffled.slice(0, 5)
}

const refreshFreeTopics = () => {
  const shuffled = [...topicPool.free].sort(() => Math.random() - 0.5)
  freeTopics.value = shuffled.slice(0, 5)
}

const refreshPaidTopics = () => {
  const shuffled = [...topicPool.paid].sort(() => Math.random() - 0.5)
  paidTopics.value = shuffled.slice(0, 5)
}
</script>

<style scoped>
.topic-container {
  display: grid;
  grid-template-columns: 1fr 1fr;
  gap: 20px;
  padding: 20px;
}

.left-section,
.right-section {
  display: flex;
  flex-direction: column;
  gap: 20px;
}

.topic-section {
  background: white;
  border-radius: 8px;
  padding: 20px;
  box-shadow: 0 2px 12px rgba(0, 0, 0, 0.05);
  height: auto;
  display: flex;
  flex-direction: column;
}

.section-header {
  display: flex;
  justify-content: space-between;
  align-items: center;
  margin-bottom: 16px;
  flex-shrink: 0;
}

.section-header h2 {
  font-size: 18px;
  color: #303133;
  margin: 0;
}

.topic-list {
  display: flex;
  flex-direction: column;
  gap: 12px;
  padding: 0 4px;
}

.topic-card {
  position: relative;
  border-radius: 8px;
  overflow: hidden;
  transition: transform 0.3s;
  cursor: pointer;
  width: 100%;
  background: white;
  border: 1px solid #ebeef5;
  display: flex;
  height: 70px;
}

.topic-card:hover {
  transform: translateX(5px);
  box-shadow: 0 2px 12px rgba(0, 0, 0, 0.1);
}

.topic-cover {
  width: 105px;
  height: 70px;
  object-fit: cover;
  flex-shrink: 0;
}

.topic-info {
  flex: 1;
  padding: 10px 12px;
  display: flex;
  justify-content: space-between;
  align-items: center;
}

.info-left {
  flex: 1;
  min-width: 0; /* 防止文本溢出 */
}

.topic-title {
  font-size: 14px;
  font-weight: 600;
  color: #303133;
  margin: 0 0 4px;
  overflow: hidden;
  text-overflow: ellipsis;
  white-space: nowrap;
}

.topic-author {
  font-size: 12px;
  color: #909399;
}

.topic-stats {
  display: flex;
  gap: 12px;
  font-size: 12px;
  color: #909399;
  margin-left: 12px;
}

.topic-stats span {
  display: flex;
  align-items: center;
  gap: 4px;
}

.topic-stats .el-icon {
  font-size: 14px;
}

.rank-badge {
  position: absolute;
  top: 4px;
  left: 4px;
  background: #409EFF;
  color: white;
  padding: 1px 6px;
  border-radius: 3px;
  font-size: 11px;
  z-index: 1;
  opacity: 0.9;
}

.rank-badge.free {
  background: #67C23A;
  font-size: 10px;
  padding: 1px 4px;
}

.rank-badge.premium {
  background: #E6A23C;
  font-size: 10px;
  padding: 1px 4px;
}

.search-section {
  height: auto;
  min-height: 150px;
  padding: 16px;
}

.search-suggestions {
  margin-top: 12px;
}

.suggestion-tags {
  display: flex;
  flex-wrap: wrap;
  gap: 6px;
  margin-top: 6px;
}

.suggestion-tag {
  cursor: pointer;
}

.search-results {
  margin-top: 12px;
}

.search-result-item {
  display: flex;
  gap: 12px;
  padding: 8px 0;
  border-bottom: 1px solid #EBEEF5;
  transition: all 0.3s ease;
  cursor: pointer;
}

.search-result-item:hover {
  transform: translateX(5px);
  background-color: #f5f7fa;
  padding-left: 8px;
  padding-right: 8px;
}

.search-result-item:last-child {
  border-bottom: none;
}

.result-cover-wrapper {
  position: relative;
  flex-shrink: 0;
}

.search-badge {
  position: absolute;
  top: 4px;
  left: 4px;
  padding: 1px 6px;
  border-radius: 3px;
  font-size: 11px;
  color: white;
  z-index: 1;
  opacity: 0.9;
}

.search-badge.free {
  background: #67C23A;
  font-size: 10px;
  padding: 1px 4px;
}

.search-badge.premium {
  background: #E6A23C;
  font-size: 10px;
  padding: 1px 4px;
}

.result-cover {
  width: 105px;
  height: 70px;
  border-radius: 4px;
  object-fit: cover;
}

.result-info {
  flex: 1;
  display: flex;
  justify-content: space-between;
  align-items: center;
  padding: 0 4px;
}

.info-left {
  flex: 1;
  min-width: 0;
}

.info-left h3 {
  margin: 0 0 4px;
  font-size: 14px;
  font-weight: 600;
  color: #303133;
}

.author {
  font-size: 12px;
  color: #909399;
}

.stats {
  display: flex;
  gap: 12px;
  font-size: 12px;
  color: #909399;
  margin-left: 12px;
}

.stats span {
  display: flex;
  align-items: center;
  gap: 4px;
}

.stats .el-icon {
  font-size: 14px;
}

.refresh-link {
  display: flex;
  align-items: center;
  gap: 6px;
  font-size: 14px;
  padding: 4px 8px;
  border-radius: 4px;
  transition: all 0.3s ease;
}

.refresh-link:hover {
  background-color: #ecf5ff;
}

.refresh-icon {
  font-size: 16px;
  transition: transform 0.3s ease;
}

.refresh-link:hover .refresh-icon {
  transform: rotate(180deg);
}
</style> 