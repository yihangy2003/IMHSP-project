import { createRouter, createWebHistory } from 'vue-router'
import type { RouteRecordRaw } from 'vue-router'

const routes: Array<RouteRecordRaw> = [
  {
    path: '/',
    redirect: '/login'
  },
  {
    path: '/login',
    component: () => import('@/views/Login.vue')
  },
  {
    path: '/resetPassword',
    component: () => import('@/views/Login.vue')
  },
  {
    path: '/dashboard',
    component: () => import('@/views/Dashboard.vue'),
    meta: { requiresAuth: true },
    children: [
      {
        path: '/dashboard',
        redirect: '/topic'
      },
      {
        path: '/topic/:id',
        component: () => import('@/views/Topic.vue'),
        meta: { requiresAuth: true }
      },
      {
        path: '/community',
        component: () => import('@/views/Community.vue'),
        meta: { requiresAuth: true }
      },
      {
        path: '/user/:id',
        component: () => import('@/views/User.vue'),
        meta: { requiresAuth: true }
      },
      {
        path: '/service',
        component: () => import('@/views/Service.vue'),
        meta: { requiresAuth: true }
      },
      {
        path: '/topic',
        component: () => import('@/views/Recommendation.vue'),
        meta: { requiresAuth: true }
      },
      {
        path: '/topic/add',
        component: () => import('@/views/TopicAdd.vue'),
        meta: {
          requiresAuth: true,
          roles: ['counselor']
        }
      },
      {
        path: '/community/add',
        component: () => import('@/views/CommunityAdd.vue'),
        meta: { requiresAuth: true }
      },
      {
        path: '/share/:id',
        name: 'Share',
        component: () => import('@/views/Share.vue'),
        meta: { requiresAuth: true }
      },
      {
        path: '/chatroom',
        name: 'ChatRoom',
        component: () => import('@/views/ChatRoom.vue'),
        meta: {
          requiresAuth: true,
          title: '交流室'
        }
      }
    ]
  },
  {
    path: '/test/:id',
    name: 'Test',
    component: () => import('@/views/TestPage.vue')
  },
  {
    path: '/topic/add',
    component: () => import('@/views/TopicAdd.vue')
  }
]

const router = createRouter({
  history: createWebHistory(),
  routes
})

export default router