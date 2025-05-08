<template>
  <el-scrollbar class="community-container" ref="scrollbarRef">
    <div class="content-wrapper">
      <!-- 添加筛选按钮 -->
      <div class="filter-section">
        <el-radio-group v-model="viewMode" size="large">
          <el-radio-button label="latest">
            <el-icon><Timer /></el-icon>
            最新
          </el-radio-button>
          <el-radio-button label="hot">
            <el-icon><TrendCharts /></el-icon>
            热门
          </el-radio-button>
          <el-radio-button label="following">
            <el-icon><UserFilled /></el-icon>
            关注
          </el-radio-button>
        </el-radio-group>
      </div>

      <!-- 帖子列表 -->
      <div class="posts-section">
        <div v-for="post in filteredPosts" :key="post.id" class="post-card" :ref="(el) => addPostElement(post.id, el as HTMLElement)">
          <!-- 帖子内容 -->
          <div class="post-content">
            <div class="post-header">
              <div class="author-info" @click="toggleAuthorInfo(post.author)">
                <el-avatar :src="post.author.avatar" :size="40" />
                <div class="author-meta">
                  <span class="author-name">{{ post.author.name }}</span>
                  <span class="post-time">{{ post.createTime }}</span>
                </div>
              </div>
            </div>
            <div class="post-text-wrapper">
              <div class="post-text markdown-content" v-html="renderMarkdown(post.content)"></div>
              <div class="content-mask" @click="viewFullPost(post.id)">
                <div class="view-more">
                  <el-icon><ArrowRight /></el-icon>
                  <span>查看全文</span>
                </div>
              </div>
            </div>
            <!-- 帖子统计信息 -->
            <div class="post-stats">
              <span>
                <el-icon style="margin-right: 4px"><View /></el-icon>
                {{ post.views }}
              </span>
              <span class="like-btn" @click="handleLike(post)">
                <HeartOutlined v-if="!post.isLiked" style="margin-right: 4px; font-size: 14px" />
                <HeartFilled v-else style="margin-right: 4px; font-size: 14px" class="liked" />
                {{ post.likes }}
              </span>
              <span class="collect-btn" @click="handleCollect(post)">
                <el-icon style="margin-right: 4px">
                  <Star v-if="!post.isCollected" />
                  <StarFilled v-else class="collected"/>
                </el-icon>
                {{ post.collects }}
              </span>
              <span class="comment-btn" @click="toggleComments(post)">
                <el-icon style="margin-right: 4px"><ChatDotRound /></el-icon>
                {{ post.comments.length }}
              </span>
            </div>
          </div>
          
          <!-- 评论区 -->
          <div v-show="post.showComments" class="comments-section">
            <div class="comments-list">
              <div v-for="comment in post.comments" :key="comment.id" class="comment-item">
                <el-avatar :src="comment.author.avatar" :size="32" />
                <div class="comment-content">
                  <div class="comment-header">
                    <span class="comment-author">{{ comment.author.name }}</span>
                    <span class="comment-time">{{ comment.createTime }}</span>
                  </div>
                  <div class="comment-text" :class="{ 'expanded': comment.isExpanded }">
                    {{ comment.content }}
                  </div>
                  <div v-if="comment.content.length > 100" class="expand-btn" @click="toggleComment(comment)">
                    {{ comment.isExpanded ? '收起' : '展开全文' }}
                  </div>
                  <div class="comment-actions">
                    <span 
                      class="action-btn" 
                      @click="handleCommentLike(comment)"
                      :class="{ 'disabled': isOwnComment(comment) }"
                      :title="isOwnComment(comment) ? '不能给自己的评论点赞' : ''"
                    >
                      <LikeOutlined v-if="!comment.isLiked" />
                      <LikeFilled v-else class="liked" />
                      {{ comment.likes }}
                    </span>
                    <span 
                      class="action-btn" 
                      @click="handleCommentDislike(comment)"
                      :class="{ 'disabled': isOwnComment(comment) }"
                      :title="isOwnComment(comment) ? '不能给自己的评论点踩' : ''"
                    >
                      <DislikeOutlined v-if="!comment.isDisliked" />
                      <DislikeFilled v-else class="disliked" />
                      {{ comment.dislikes }}
                    </span>
                  </div>
                </div>
              </div>
            </div>
            <!-- 评论输入框 -->
            <div class="comment-input">
              <el-input
                type="textarea"
                v-model="newComment"
                placeholder="请输入评论..."
                rows="3"
                @keyup.enter="submitComment(post)"
              />
              <el-button 
                type="primary" 
                @click="submitComment(post)"
              >
                提交
              </el-button>
            </div>
          </div>
        </div>
      </div>

      <!-- 独立的用户信息卡片 -->
      <div class="author-info-card" :class="{ 'show': showAuthorInfo }" v-if="selectedAuthor">
        <div class="card-header">
          <div class="close-btn" @click="toggleAuthorInfo()">
            <el-icon><Close /></el-icon>
          </div>
        </div>
        <div class="card-content">
          <div class="author-header">
            <el-avatar :src="selectedAuthor.avatar" :size="60" />
            <div class="author-name">{{ selectedAuthor.name }}</div>
          </div>
          <div class="author-bio">
            <div :class="{ 'bio-text': true, 'expanded': bioExpanded }">
              {{ selectedAuthor.bio }}
            </div>
            <div 
              v-if="selectedAuthor.bio.length > 100" 
              class="expand-bio" 
              @click="bioExpanded = !bioExpanded"
            >
              {{ bioExpanded ? '收起' : '展开全文' }}
            </div>
          </div>
          <div class="author-stats">
            <div class="stat-item">
              <div class="stat-value">{{ selectedAuthor.posts }}</div>
              <div class="stat-label">帖子</div>
            </div>
            <div class="stat-item">
              <div class="stat-value">{{ selectedAuthor.followers }}</div>
              <div class="stat-label">粉丝</div>
            </div>
            <div class="stat-item">
              <div class="stat-value">{{ selectedAuthor.following }}</div>
              <div class="stat-label">关注</div>
            </div>
          </div>
          <div class="action-buttons">
            <el-button type="primary" plain>关注</el-button>
            <el-button 
              type="primary" 
              plain 
              @click="goToUserPage(selectedAuthor.id)"
            >
              <template #icon>
                <el-icon><User /></el-icon>
              </template>
              主页
            </el-button>
          </div>
        </div>
      </div>

      <!-- 返回顶部按钮 -->
      <div 
        class="back-to-top" 
        v-show="showBackToTop"
        @click="scrollToTop"
      >
        <el-icon><Top /></el-icon>
      </div>

      <!-- 写专题按钮 -->
      <div class="write-topic" @click="goToWrite">
        <el-icon><Edit /></el-icon>
        <span>分享</span>
      </div>
  </div>
  </el-scrollbar>
</template>

<script setup lang="ts">
import { ref, onMounted, onBeforeUnmount, computed, onUnmounted } from 'vue'
import { View, Star, StarFilled, ChatDotRound, Close, User, UserFilled, Top, Edit, Timer, TrendCharts, ArrowRight } from '@element-plus/icons-vue'
import { HeartOutlined, HeartFilled, LikeOutlined, LikeFilled, DislikeOutlined, DislikeFilled } from '@ant-design/icons-vue'
import { useUserStore } from '@/stores/user'
import { ElMessage } from 'element-plus'
import { marked } from 'marked'
import { useRouter } from 'vue-router'
import { EventType } from '@/utils/eventBus'
import { eventBus } from '@/utils/eventBus'

// 初始化 store 和 router
const router = useRouter()
const userStore = useUserStore()

// 定义接口
interface Author {
  id: string
  name: string
  avatar: string
  posts: number
  followers: number
  following: number
  bio: string
}

interface Comment {
  id: number
  content: string
  createTime: string
  likes: number
  dislikes: number
  isLiked: boolean
  isDisliked: boolean
  isExpanded: boolean
  author: {
    name: string
    avatar: string
  }
}

interface Post {
  id: number
  content: string
  createTime: string
  views: number
  likes: number
  collects: number
  isLiked: boolean
  isCollected: boolean
  showComments: boolean
  author: Author
  comments: Comment[]
}

const renderMarkdown = (content: string) => {
  return marked(content)
}

// 帖子数据
const posts = ref<Post[]>([
  {
    id: 1,
    content: `# 如何应对焦虑情绪

在日常生活中，我们经常会遇到焦虑的情况。以下是一些实用的应对方法：

1. **深呼吸练习**
   - 慢慢吸气数4秒
   - 屏住呼吸4秒
   - 缓慢呼气6秒

2. **正念冥想**
   - 每天花10分钟进行冥想练习
   - 专注于当下的感受
   - 不评判任何想法和感受

3. **运动**
   - 有氧运动（跑步、游泳）
   - 瑜伽和拉伸
   - 每天散步30分钟

4. **建立日常规律**
   - 保持规律的作息时间
   - 健康的饮食习惯
   - 充足的睡眠时间

5. **社交支持**
   - 与亲友分享感受
   - 参加支持小组
   - 必要时寻求专业帮助

> 记住：焦虑是正常的情绪反应，关键是如何管理它。
> 通过持续练习这些方法，我们可以逐步建立起应对焦虑的能力。

### 补充建议

* 避免过度摄入咖啡因
* 保持工作和休息的平衡
* 学会设定合理的界限
* 培养放松的兴趣爱好`,
    createTime: '2024-03-15 14:30',
    views: 1234,
    likes: 89,
    collects: 45,
    isLiked: false,
    isCollected: false,
    showComments: false,
    author: {
      id: '4',
      name: '心理咨询师小李',
      avatar: '/avatars/1.jpg',
      posts: 128,
      followers: 1234,
      following: 45,
      bio: '国家二级心理咨询师，专注于焦虑、抑郁等心理问题的干预和治疗。'
    },
    comments: [
      {
        id: 1,
        content: '非常实用的建议，感谢分享！这些内容对于我们理解和处理心理健康问题非常有帮助。希望以后能看到更多类似的分享，让更多人受益。我觉得这种形式的交流平台很有意义，可以让大家互相学习和支持。',
        createTime: '2024-03-15 15:00',
        likes: 12,
        dislikes: 2,
        isLiked: false,
        isDisliked: false,
        isExpanded: false,
        author: {
          name: '王同学',
          avatar: '/avatars/5.jpg'
        }
      },
      {
        id: 2,
        content: '作为一名心理咨询师，我想补充一些专业的建议。首先，我们要认识到每个人的心理状态都是独特的，不能用统一的标准来衡量。其次，在面对心理问题时，及时寻求专业帮助非常重要。很多人可能会觉得心理咨询是一件难以启齿的事情，但实际上这是一个非常正常和积极的选择。在日常生活中，我们也可以通过正念冥想、规律运动、保持良好的作息等方式来维护心理健康。最后，我想强调的是，心理健康和身体健康同样重要，需要我们持续关注和维护。',
        createTime: '2024-03-15 16:30',
        likes: 45,
        dislikes: 3,
        isLiked: false,
        isDisliked: false,
        isExpanded: false,
        author: {
          name: '李咨询师',
          avatar: '/avatars/3.jpg'
        }
      }
    ]
  },
  {
    id: 2,
    content: `## 读书笔记分享：《认知疗法与情绪管理》

今天读到一个很有趣的观点：

> 我们往往不是被事情本身困扰，而是被我们对事情的解读所困扰。

这让我对情绪管理有了新的认识：

1. **情绪源于想法**
   - 事件本身是中性的
   - 我们的解读赋予了事件意义
   - 不同的视角会带来不同的情绪体验

2. **想法决定感受**
   - 识别自动化思维
   - 挑战消极想法
   - 寻找平衡的观点

3. **改变思维方式能改变情绪状态**
   - 学会重新框架
   - 寻找积极的替代性解释
   - 关注事实而非假设

### 实践建议

* 每天记录自己的想法和情绪
* 学会识别认知偏差
* 培养弹性思维方式
* 练习同理心

### 一些具体的练习方法

1. **情绪日记**
   记录：
   - 触发事件
   - 自动化想法
   - 情绪反应
   - 替代性思维

2. **认知重构**
   - 找出消极想法
   - 收集支持和反对证据
   - 形成平衡的观点

> 通过持续练习，我们可以逐步建立起更健康的思维模式。`,
    createTime: '2024-03-15 16:45',
    views: 856,
    likes: 67,
    collects: 38,
    isLiked: false,
    isCollected: false,
    showComments: false,
    author: {
      id: '5',
      name: '张教授',
      avatar: '/avatars/4.jpg',
      posts: 256,
      followers: 3456,
      following: 123,
      bio: '心理学教授，从事心理健康研究20年，著有《情绪管理与认知治疗》等书籍。'
    },
    comments: [
      {
        id: 11,
        content: '这个观点很有启发性，确实我们经常会被自己的想法所困扰。改变思维方式，或许就能看到不一样的风景。',
        createTime: '2024-03-15 17:00',
        likes: 23,
        dislikes: 1,
        isLiked: false,
        isDisliked: false,
        isExpanded: false,
        author: {
          name: '王同学',
          avatar: '/avatars/5.jpg'
        }
      }
    ]
  }
])

const selectedAuthor = ref<Author | null>(null)
const postElements = ref<Map<number, HTMLElement>>(new Map())

const addPostElement = (postId: number, element: HTMLElement | null) => {
  if (element) {
    postElements.value.set(postId, element)
  }
}

const updateSelectedAuthor = () => {
  const scrollTop = window.scrollY
  const windowHeight = window.innerHeight
  const centerY = scrollTop + windowHeight / 2
  
  let closestPost: { distance: number; author: Author | null } = {
    distance: Infinity,
    author: null
  }
  
  postElements.value.forEach((element, postId) => {
    const rect = element.getBoundingClientRect()
    const postCenterY = rect.top + rect.height / 2
    const distance = Math.abs(postCenterY - windowHeight / 2)
    
    const post = posts.value.find(p => p.id === postId)
    if (post && distance < closestPost.distance) {
      closestPost = {
        distance,
        author: post.author
      }
    }
  })
  
  if (closestPost.author) {
    selectedAuthor.value = closestPost.author
  }
}

const scrollbarRef = ref()
const showBackToTop = ref(false)

// 监听滚动事件，控制返回顶部按钮的显示
const handleScroll = () => {
  if (scrollbarRef.value) {
    const { scrollTop } = scrollbarRef.value.wrapRef
    showBackToTop.value = scrollTop > 300
  }
}

// 返回顶部
const scrollToTop = () => {
  if (scrollbarRef.value) {
    const currentScroll = scrollbarRef.value.wrapRef.scrollTop
    const scrollStep = () => {
      if (currentScroll <= 0) return
      
      const newScroll = Math.max(0, scrollbarRef.value.wrapRef.scrollTop - Math.max(currentScroll / 10, 50))
      scrollbarRef.value.setScrollTop(newScroll)
      
      if (newScroll > 0) {
        requestAnimationFrame(scrollStep)
      }
    }
    
    requestAnimationFrame(scrollStep)
  }
}

onMounted(() => {
  if (posts.value.length > 0) {
    selectedAuthor.value = posts.value[0].author
  }
  
  window.addEventListener('scroll', updateSelectedAuthor)
  if (scrollbarRef.value) {
    scrollbarRef.value.wrapRef.addEventListener('scroll', handleScroll)
  }

  eventBus.on(EventType.CLOSE_USER_CARD, () => {
    showAuthorInfo.value = false
    selectedAuthor.value = null
    bioExpanded.value = false
  })
})

onBeforeUnmount(() => {
  window.removeEventListener('scroll', updateSelectedAuthor)
  if (scrollbarRef.value) {
    scrollbarRef.value.wrapRef.removeEventListener('scroll', handleScroll)
  }

  eventBus.off(EventType.CLOSE_USER_CARD)
})

const newComment = ref('')

const formatDateTime = (date: Date) => {
  const year = date.getFullYear()
  const month = String(date.getMonth() + 1).padStart(2, '0')
  const day = String(date.getDate()).padStart(2, '0')
  const hours = String(date.getHours()).padStart(2, '0')
  const minutes = String(date.getMinutes()).padStart(2, '0')
  return `${year}-${month}-${day} ${hours}:${minutes}`
}

const handleLike = (post: Post) => {
  post.isLiked = !post.isLiked
  post.likes += post.isLiked ? 1 : -1
}

const handleCollect = (post: Post) => {
  post.isCollected = !post.isCollected
  post.collects += post.isCollected ? 1 : -1
}

const toggleComments = (post: Post) => {
  post.showComments = !post.showComments
}

const submitComment = (post: Post) => {
  if (!newComment.value.trim()) {
    ElMessage.warning('评论内容不能为空')
    return
  }

  // 创建评论对象
  const comment = {
    id: Date.now(), // 临时ID，实际应该由后端生成
    content: newComment.value,
    author: {
      name: userStore.userInfo.username,
      avatar: userStore.userInfo.avatar
    },
    createTime: new Date().toLocaleString()
  }

  // TODO: 发送请求到后端保存评论
  post.comments.push(comment) // 更新本地评论列表
  newComment.value = '' // 清空输入框
}

const isOwnComment = (comment: Comment) => {
  return comment.author.name === userStore.userInfo?.username
}

const handleCommentLike = (comment: Comment) => {
  if (isOwnComment(comment)) {
    ElMessage.warning('不能给自己的评论点赞')
    return
  }
  
  if (comment.isDisliked) {
    comment.isDisliked = false
    comment.dislikes--
  }
  comment.isLiked = !comment.isLiked
  if (comment.isLiked) {
    comment.likes++
  } else {
    comment.likes--
  }
}

const handleCommentDislike = (comment: Comment) => {
  if (isOwnComment(comment)) {
    ElMessage.warning('不能给自己的评论点踩')
    return
  }
  
  if (comment.isLiked) {
    comment.isLiked = false
    comment.likes--
  }
  comment.isDisliked = !comment.isDisliked
  if (comment.isDisliked) {
    comment.dislikes++
  } else {
    comment.dislikes--
  }
}

const toggleComment = (comment: Comment) => {
  comment.isExpanded = !comment.isExpanded
}

const showAuthorInfo = ref(false)
const bioExpanded = ref(false)

const toggleAuthorInfo = (author?: Author) => {
  if (author) {
    selectedAuthor.value = author
    showAuthorInfo.value = true
    bioExpanded.value = false
    eventBus.emit(EventType.CLOSE_CHAT)
  } else {
    showAuthorInfo.value = false
  }
}

const goToUserPage = (userId: string) => {
  // 在新窗口打开用户主页
  window.open(`/user/${userId}`, '_blank')
}

const viewMode = ref('latest')

// 根据视图模式筛选帖子
const filteredPosts = computed(() => {
  switch (viewMode.value) {
    case 'latest':
      // 按发布时间排序，最新的在前
      return [...posts.value].sort((a, b) => 
        new Date(b.createTime).getTime() - new Date(a.createTime).getTime()
      )
    case 'hot':
      // 按热度（点赞数+评论数）排序
      return [...posts.value].sort((a, b) => 
        (b.likes + b.comments.length) - (a.likes + a.comments.length)
      )
    case 'following':
      // 筛选出关注的作者的帖子
      return posts.value.filter(post => {
        // 这里需要根据实际的数据结构来判断是否关注
        // 示例：return userStore.followingUsers.includes(post.author.id)
        return true // 临时返回所有帖子
      })
    default:
      return posts.value
  }
})

const goToWrite = () => {
  router.push('/community/add')
}

// 查看完整帖子
const viewFullPost = (postId: number) => {
  const post = posts.value.find(p => p.id === postId)
  if (post) {
    // 将帖子数据存储到 localStorage
    localStorage.setItem('currentPost', JSON.stringify(post))
    // 在新窗口打开
    window.open(`/share/${postId}`, '_blank')
  }
}
</script>

<style scoped>
.community-container {
  height: calc(100vh - 20px);
  background-color: #f5f7fa;
  padding-top: 20px;
}

.content-wrapper {
  display: grid;
  grid-template-columns: 1fr;
  padding: 0 20px;
  min-height: calc(100vh - 20px);
  max-width: 1200px;
  margin: 0 auto;
}

.posts-section {
  margin: 0 auto;
  width: 940px;
  display: flex;
  flex-direction: column;
  gap: 24px;
  padding-bottom: 40px;
}

.post-card {
  background: white;
  border-radius: 8px;
  padding: 20px;
  padding-right: 50px;
  box-shadow: 0 2px 12px rgba(0, 0, 0, 0.05);
  border: 1px solid #ebeef5;
  position: relative;
  overflow: hidden;
  margin-bottom: 12px;
}

.post-card:last-child {
  margin-bottom: 0;
}

.post-header {
  display: flex;
  align-items: center;
  margin-bottom: 16px;
}

.author-info {
  cursor: pointer;
  transition: opacity 0.3s;
  display: flex;
  align-items: center;
  gap: 12px;
}

.author-meta {
  display: flex;
  flex-direction: column;
  gap: 4px;
}

.author-name {
  font-weight: 500;
  color: #303133;
}

.post-time {
  color: #909399;
  font-size: 12px;
}

.author-info:hover {
  opacity: 0.8;
}

.post-text-wrapper {
  position: relative;
  max-height: 300px;
  overflow: hidden;
  margin-bottom: 16px;
}

.post-text {
  margin-bottom: 16px;
  line-height: 1.6;
  color: #303133;
  padding-right: 20px;
}

.content-mask {
  position: absolute;
  bottom: 0;
  left: 0;
  right: 0;
  height: 120px;
  background: linear-gradient(
    to bottom,
    rgba(255, 255, 255, 0) 0%,
    rgba(255, 255, 255, 0.8) 40%,
    rgba(255, 255, 255, 0.9) 60%,
    rgba(255, 255, 255, 1) 100%
  );
  display: flex;
  justify-content: center;
  align-items: flex-end;
  padding-bottom: 20px;
  cursor: pointer;
  transition: all 0.3s;
}

.view-more {
  display: flex;
  align-items: center;
  gap: 8px;
  background: white;
  padding: 8px 16px;
  border-radius: 20px;
  box-shadow: 0 2px 12px rgba(0, 0, 0, 0.1);
  transition: all 0.3s;
}

.view-more:hover {
  transform: translateY(-2px);
  box-shadow: 0 4px 12px rgba(0, 0, 0, 0.15);
}

.view-more .el-icon {
  font-size: 20px;
  color: #409EFF;
}

.view-more span {
  color: #409EFF;
  font-size: 14px;
  font-weight: 500;
}

.content-mask:hover .view-more .el-icon {
  transform: translateX(4px);
  transition: transform 0.3s;
}

.post-stats {
  display: flex;
  gap: 24px;
  color: #909399;
  font-size: 14px;
}

.post-stats span {
  display: flex;
  align-items: center;
  cursor: pointer;
}

.post-stats .anticon {
  color: #909399;
  transition: all 0.3s;
}

.post-stats .liked {
  color: #F56C6C;
}

.post-stats .collected {
  color: #E6A23C;
  transform: scale(1.2);
}

.post-stats .like-btn,
.post-stats .collect-btn {
  transition: all 0.3s;
}

.post-stats .like-btn:hover {
  color: #F56C6C;
  transform: scale(1.1);
}

.post-stats .like-btn:hover .anticon {
  color: #F56C6C;
}

.post-stats .collect-btn:hover {
  color: #E6A23C;
  transform: scale(1.1);
}

.comments-section {
  margin-top: 20px;
  padding-top: 20px;
  border-top: 1px solid #ebeef5;
}

.comments-list {
  display: flex;
  flex-direction: column;
  gap: 16px;
  margin-bottom: 20px;
}

.comment-item {
  display: flex;
  gap: 12px;
}

.comment-content {
  flex: 1;
  max-width: 95%;
}

.comment-header {
  display: flex;
  align-items: center;
  gap: 8px;
  margin-bottom: 4px;
}

.comment-author {
  font-weight: 500;
  color: #303133;
}

.comment-time {
  font-size: 12px;
  color: #909399;
}

.comment-text {
  color: #606266;
  font-size: 14px;
  line-height: 1.6;
  overflow: hidden;
  text-overflow: ellipsis;
  display: -webkit-box;
  -webkit-line-clamp: 2;
  -webkit-box-orient: vertical;
  transition: all 0.3s;
  padding-right: 20px;
}

.comment-text.expanded {
  -webkit-line-clamp: unset;
}

.comment-input {
  display: flex;
  align-items: flex-start; /* 确保按钮与文本框顶部齐平 */
  margin-top: 16px;
}

.comment-input .el-input {
  flex: 1;
  margin-right: 8px; /* 添加右侧间隔 */
}

.comment-input .el-button {
  margin-top: 0px; /* 添加顶部间隔，使按钮与文本框顶部齐平 */
  margin-left: 10px; /* 添加左侧间隔 */
}

.author-info-card {
  position: fixed;
  right: -350px;
  top: 10px;
  width: 320px;
  background: white;
  border-radius: 8px;
  box-shadow: 0 2px 12px rgba(0, 0, 0, 0.1);
  transition: right 0.3s ease;
  z-index: 99;
}

.author-info-card.show {
  right: 20px;
}

.card-header {
  padding: 12px;
  display: flex;
  justify-content: flex-end;
}

.close-btn {
  cursor: pointer;
  padding: 4px;
  border-radius: 4px;
  transition: background-color 0.3s;
}

.close-btn:hover {
  background-color: #f5f7fa;
}

.card-content {
  padding: 0 20px 20px;
}

.author-header {
  text-align: center;
  margin-bottom: 20px;
}

.author-header .author-name {
  margin-top: 12px;
  font-size: 18px;
  font-weight: 600;
}

.author-bio {
  margin: 16px 0;
  padding: 12px;
  background-color: #f5f7fa;
  border-radius: 4px;
  color: #606266;
  font-size: 14px;
  line-height: 1.6;
  word-break: break-word;
}

.author-stats {
  display: flex;
  justify-content: space-around;
  margin-top: 20px;
  padding: 16px 0;
  border-top: 1px solid #ebeef5;
}

.stat-item {
  text-align: center;
}

.stat-value {
  font-weight: 600;
  color: #303133;
}

.stat-label {
  font-size: 12px;
  color: #909399;
  margin-top: 4px;
}

.comment-actions {
  display: flex;
  gap: 16px;
  margin-top: 8px;
}

.action-btn {
  cursor: pointer;
  margin-right: 16px;
  color: #606266;
  transition: color 0.3s;
  font-size: 12px;
  display: inline-flex;
  align-items: center;
  gap: 4px;
}

.action-btn.disabled {
  cursor: not-allowed;
  opacity: 0.5;
}

.action-btn:hover:not(.disabled) {
  color: #409EFF;
}

.liked {
  color: #409EFF;
}

.disliked {
  color: #F56C6C;
}

.action-btn :deep(svg) {
  width: 18px;
  height: 18px;
}

.expand-btn {
  color: #409EFF;
  font-size: 12px;
  cursor: pointer;
  margin: 4px 0;
  transition: all 0.3s;
}

.expand-btn:hover {
  opacity: 0.8;
}

.markdown-content {
  font-size: 14px;
  line-height: 1.6;
  color: #303133;
}

.markdown-content :deep(h1) {
  font-size: 20px;
  margin: 16px 0;
}

.markdown-content :deep(h2) {
  font-size: 18px;
  margin: 14px 0;
}

.markdown-content :deep(h3) {
  font-size: 16px;
  margin: 12px 0;
}

.markdown-content :deep(ul),
.markdown-content :deep(ol) {
  padding-left: 20px;
  margin: 8px 0;
}

.markdown-content :deep(blockquote) {
  border-left: 4px solid #409EFF;
  padding: 8px 12px;
  margin: 12px 0;
  color: #606266;
  background: #f8f9fa;
}

.markdown-content :deep(pre) {
  background: #f8f9fa;
  padding: 12px;
  border-radius: 4px;
  overflow-x: auto;
}

.markdown-content :deep(code) {
  font-family: Consolas, Monaco, 'Andale Mono', monospace;
}

.markdown-content :deep(p) {
  margin: 8px 0;
}

.post-scroll-container {
  position: absolute;
  top: 0;
  left: 0;
  right: 0;
  bottom: 0;
  overflow: visible;
  padding: 20px;
  scrollbar-width: thin;
  scrollbar-color: #909399 #f4f4f5;
}

/* 自定义滚动条样式 */
.author-info-card::-webkit-scrollbar {
  width: 4px;
}

.author-info-card::-webkit-scrollbar-track {
  background: #f4f4f5;
}

.author-info-card::-webkit-scrollbar-thumb {
  background-color: #909399;
  border-radius: 2px;
}

.bio-text {
  overflow: hidden;
  text-overflow: ellipsis;
  display: -webkit-box;
  -webkit-line-clamp: 3;
  -webkit-box-orient: vertical;
  transition: all 0.3s;
}

.bio-text.expanded {
  -webkit-line-clamp: unset;
}

.expand-bio {
  color: #409EFF;
  font-size: 13px;
  cursor: pointer;
  margin-top: 8px;
  text-align: right;
  transition: opacity 0.3s;
}

.expand-bio:hover {
  opacity: 0.8;
}

.action-buttons {
  display: flex;
  gap: 12px;
  margin-top: 20px;
}

.action-buttons :deep(.el-button) {
  flex: 1;
  display: flex;
  align-items: center;
  justify-content: center;
  gap: 4px;
  height: 36px;
}

.action-buttons :deep(.el-icon) {
  margin: 0;
}

.action-buttons :deep(.el-button:last-child) {
  opacity: 0.9;
}

.filter-section {
  display: flex;
  justify-content: center;
  margin-bottom: 24px;
}

.filter-section :deep(.el-radio-group) {
  background: white;
  padding: 2px;
  border-radius: 8px;
  box-shadow: 0 2px 12px rgba(0, 0, 0, 0.05);
}

.filter-section :deep(.el-radio-button__inner) {
  display: flex;
  align-items: center;
  gap: 6px;
  padding: 8px 24px;
  border: none;
}

.filter-section :deep(.el-radio-button:first-child .el-radio-button__inner) {
  border-radius: 6px 0 0 6px;
}

.filter-section :deep(.el-radio-button:last-child .el-radio-button__inner) {
  border-radius: 0 6px 6px 0;
}

.filter-section :deep(.el-icon) {
  font-size: 16px;
}

.back-to-top {
  position: fixed;
  right: 70px;
  bottom: 60px;
  width: 48px;
  height: 48px;
  background-color: white;
  border-radius: 50%;
  display: flex;
  align-items: center;
  justify-content: center;
  cursor: pointer;
  box-shadow: 0 2px 12px rgba(0, 0, 0, 0.1);
  transition: all 0.3s, transform 0.2s;
  z-index: 99;
}

.back-to-top:hover {
  transform: translateY(-2px);
  box-shadow: 0 4px 12px rgba(0, 0, 0, 0.15);
}

.back-to-top:active {
  transform: translateY(0);
  transition: transform 0.1s;
}

.back-to-top .el-icon {
  font-size: 28px;
  color: #409EFF;
  transform: translateY(2px);
}

.write-topic {
  position: fixed;
  right: 40px;  /* 向右移动 */
  bottom: 120px;
  height: 48px;
  background-color: #409EFF;
  color: white;
  border-radius: 24px;
  display: flex;
  align-items: center;
  padding: 0 24px;
  cursor: pointer;
  box-shadow: 0 2px 12px rgba(64, 158, 255, 0.3);
  transition: all 0.3s;
  z-index: 99;
}

.write-topic:hover {
  transform: translateY(-2px);
  box-shadow: 0 4px 12px rgba(64, 158, 255, 0.4);
  background-color: #66b1ff;
}

.write-topic:active {
  transform: translateY(0);
  transition: transform 0.1s;
}

.write-topic .el-icon {
  font-size: 20px;
  margin-right: 8px;
}

.write-topic span {
  font-size: 16px;
  font-weight: 500;
}
</style> 