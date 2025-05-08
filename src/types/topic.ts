export interface Topic {
  id: number
  title: string
  cover: string
  views: number
  likes: number
  collects: number
  author: string
  authorId: number
  type: 'free' | 'paid'
  price?: number
  introduction?: string
  content?: string
} 