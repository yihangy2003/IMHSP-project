// 用户角色类型
export type UserRole = 'explorer' | 'counselor' | 'admin'

// 性别类型
export type Gender = 'male' | 'female'

// 用户信息类型
export interface UserInfo {
  // 基本信息
  id: number | string
  username: string
  avatar: string
  email: string
  phone: string
  gender: Gender
  location: string
  bio: string
  roles: UserRole
  visitCount: number

  // 统计信息
  followersCount?: number   // 粉丝数
  followingCount?: number   // 关注数
  postsCount?: number      // 帖子数

  // 咨询师特有信息
  specialties?: string[]    // 专业领域
  experience?: number       // 从业年限
  consultations?: number    // 咨询次数
  positiveReviews?: number  // 好评数
  negativeReviews?: number  // 差评数
  price?: number           // 咨询价格
  isFree?: boolean         // 是否提供免费咨询
  available?: boolean      // 是否接受预约
  introduction?: string    // 专业介绍
  isQualified?: boolean   // 是否具有咨询资格

  // 隐私设置
  emailPublic: boolean
  phonePublic: boolean
  genderPublic: boolean
  locationPublic: boolean
  bioPublic: boolean
  activitiesPublic: boolean
  followListPublic: boolean    // 关注列表可见性
  followerListPublic: boolean  // 粉丝列表可见性
  notificationsPublic: boolean  // 通知可见性设置
  testHistoryPublic: boolean   // 测验记录可见性

  // 添加未读预约数量字段
  unreadAppointments?: number
}

// 用户编辑表单类型
export interface UserEditForm {
  username: string
  avatar: string
  email: string
  phone: string
  gender: Gender
  location: string
  bio: string
  emailPublic: boolean
  phonePublic: boolean
  genderPublic: boolean
  locationPublic: boolean
  bioPublic: boolean
}

// 用户状态类型
export interface UserState {
  userInfo: UserInfo | null
  token: string | null
} 