<template>
  <div ref="container" class="container" :class="{ 'active': isRegister }">
    <div class="form-box login">
      <el-form
        ref="loginFormRef"
        :model="loginForm"
        :rules="loginRules"
        class="login-form"
      >
        <h1>登录</h1>
        <el-form-item class="input-box" prop="username">
          <input type="text" placeholder="用户名" v-model="loginForm.username" @keyup.enter="handleLogin" required />
        </el-form-item>

        <el-form-item class="input-box" prop="password">
          <input type="password" placeholder="密码" v-model="loginForm.password" show-password @keyup.enter="handleLogin" required />
        </el-form-item>

        <div class="forgot-link">
          <el-link type="primary" :underline="false" @click="showForgotDialog">忘记密码?</el-link>
        </div>

        <el-form-item>
          <el-button
            :loading="loading"
            type="primary"
            class="btn"
            @click="handleLogin"
          >
            {{ loading ? '登录中...' : '登录' }}
          </el-button>
        </el-form-item>
      </el-form>
    </div>

    <div class="form-box register">
      <el-form ref="registerFormRef" :model="registerForm" :rules="registerRules">
        <h1>注册</h1>
        <el-form-item class="input-box" prop="username">
          <input type="text" placeholder="用户名" v-model="registerForm.username" @keyup.enter="handleRegister" required />
        </el-form-item>

        <el-form-item class="input-box" prop="email">
          <input type="email" placeholder="邮箱" v-model="registerForm.email" @keyup.enter="handleRegister" required />
        </el-form-item>

        <el-form-item class="input-box" prop="password">
          <input type="password" placeholder="密码" v-model="registerForm.password" @keyup.enter="handleRegister" required />
        </el-form-item>

        <el-form-item class="input-box" prop="phone">
          <input type="text" placeholder="手机号" v-model="registerForm.phone" @keyup.enter="handleRegister" required />
        </el-form-item>

        <el-form-item class="role-select" prop="roles">
          <el-radio-group v-model="registerForm.roles" class="role-group">
            <el-radio label="explorer" value="explorer">心灵探索者</el-radio>
            <el-radio label="counselor" value="counselor">心灵疗愈师</el-radio>
          </el-radio-group>
        </el-form-item>

        <el-form-item>
          <el-button
            :loading="loading"
            type="primary"
            class="btn"
            @click="handleRegister"
          >
            {{ loading ? '注册中...' : '注册' }}
          </el-button>
        </el-form-item>
      </el-form>
    </div>

    <div class="toggle-box">
      <div class="toggle-panel toggle-left">
        <h1>你好，欢迎!</h1>
        <p>没有账号?</p>
        <el-button class="btn register-btn" @click="clickRegister">注册</el-button>
      </div>

      <div class="toggle-panel toggle-right">
        <h1>欢迎回来!</h1>
        <p>已有账号?</p>
        <el-button class="btn login-btn" @click="clickLogin">登录</el-button>
      </div>
    </div>
  </div>

  <!-- 修改忘记密码对话框 -->
  <el-dialog
    v-model="forgotDialogVisible"
    title="重置密码"
    width="400px"
    :close-on-click-modal="false"
  >
    <el-form
      ref="forgotFormRef"
      :model="forgotForm"
      :rules="forgotRules"
      label-width="80px"
      class="forgot-form"
    >
      <el-form-item label="用户名" prop="username">
        <el-input v-model="forgotForm.username" placeholder="请输入用户名" />
      </el-form-item>
      
      <el-form-item label="验证方式" prop="verifyType">
        <el-radio-group v-model="forgotForm.verifyType">
          <el-radio label="email" style="margin-right: 20px;">邮箱验证</el-radio>
          <el-radio label="phone">手机验证</el-radio>
        </el-radio-group>
      </el-form-item>

      <el-form-item 
        :label="forgotForm.verifyType === 'email' ? '邮箱' : '手机号'" 
        prop="verifyValue"
      >
        <el-input 
          v-model="forgotForm.verifyValue" 
          :placeholder="forgotForm.verifyType === 'email' ? '请输入邮箱' : '请输入手机号'"
        />
      </el-form-item>

      <el-form-item label="新密码" prop="newPassword">
        <el-input 
          v-model="forgotForm.newPassword" 
          type="password" 
          placeholder="请输入新密码"
          show-password
        />
      </el-form-item>

      <el-form-item label="确认密码" prop="confirmPassword">
        <el-input 
          v-model="forgotForm.confirmPassword" 
          type="password" 
          placeholder="请再次输入新密码"
          show-password
        />
      </el-form-item>
    </el-form>

    <template #footer>
      <el-button size="large" style="width: 100px;" @click="forgotDialogVisible = false">取消</el-button>
      <el-button size="large" style="width: 100px;" type="primary" :loading="resetLoading" @click="handleResetPassword">
        确认重置
      </el-button>
    </template>
  </el-dialog>
</template>

<script setup lang="ts">
import { ref, reactive, computed, onMounted } from 'vue'
import { useRouter, useRoute } from 'vue-router'
import { ElMessage } from 'element-plus'
import { User, Lock, View, Hide } from '@element-plus/icons-vue'
import type { FormInstance } from 'element-plus'
import { useUserStore } from '@/stores/user'
import { UserInfo } from '@/api/types'
import { auth } from '@/api/auth'
import { setToken } from '@/utils/auth'
import type { LoginRequest, RegisterRequest } from '@/types/auth'
import eventBus from '@/utils/eventBus'

const router = useRouter()
const route = useRoute()
const userStore = useUserStore()
const isRegister = ref(false)
const loginFormRef = ref<FormInstance>()
const registerFormRef = ref<FormInstance>()
const loading = ref(false)
const passwordVisible = ref(false)

const loginForm = reactive<LoginRequest>({
  username: '',
  password: ''
})

const loginRules = {
  username: [
    { required: true, message: '请输入用户名', trigger: 'blur' },
    { min: 4, max: 12, message: '长度在 4 到 12 个字符', trigger: 'blur' }
  ],
  password: [
    { required: true, message: '请输入密码', trigger: 'blur' },
    { min: 8, message: '密码不能少于8个字符', trigger: 'blur' }
  ]
}

// 不要使用 UserInfo 类型，而是创建一个新的注册表单类型
interface RegisterFormState {
    username: string
    password: string
    email: string
    phone: string
    roles: 'explorer' | 'counselor' | 'admin'
}

const registerForm = reactive<RegisterFormState>({
    username: '',
    password: '',
    email: '',
    phone: '',
    roles: 'explorer'
})

// 处理注册按钮点击
const clickRegister = () => {
  isRegister.value = true
}

// 处理登录按钮点击
const clickLogin = () => {
  isRegister.value = false
}

const handleLogin = async () => {
  if (!loginFormRef.value) return
  
  try {
    await loginFormRef.value.validate()
    loading.value = true
    
    const loginRequest: LoginRequest = {
      username: loginForm.username,
      password: loginForm.password
    }
    
    const res = await auth.login(loginRequest)
    
    // 只在登录成功时处理
    if (res.code === 200) {
      setToken(res.data)
      router.push('/dashboard')
    }
  } catch (error) {
    // 这里只处理表单验证错误或网络错误
    // 业务错误（如用户名密码错误）已经在响应拦截器中处理了
  } finally {
    loading.value = false
  }
}

const handleRegister = async () => {
  if (!registerFormRef.value) return
  
  try {
    await registerFormRef.value.validate()
    loading.value = true
    
    const registerRequest: RegisterRequest = {
      username: registerForm.username,
      password: registerForm.password,
      email: registerForm.email,
      phone: registerForm.phone,
      roles: registerForm.roles
    }
    
    const res = await auth.register(registerRequest)
    
    if (res.code === 200) {
      isRegister.value = false
      registerFormRef.value.resetFields()
      // ElMessage.success('注册成功，请登录')
    }
    
  } catch (error) {
    // 这里只处理表单验证错误或网络错误
    console.error('注册失败:', error)
  } finally {
    loading.value = false
  }
}

// 注册表单验证规则
const registerRules = {
  username: [
    { required: true, message: '请输入用户名', trigger: 'blur' },
    { min: 4, max: 12, message: '长度在 4 到 12 个字符', trigger: 'blur' }
  ],
  password: [
    { required: true, message: '请输入密码', trigger: 'blur' },
    { min: 8, message: '密码不能少于8个字符', trigger: 'blur' }
  ],
  email: [
    { required: true, message: '请输入邮箱', trigger: 'blur' },
    { type: 'email', message: '请输入正确的邮箱地址', trigger: 'blur' }
  ],
  phone: [
    { required: true, message: '请输入手机号', trigger: 'blur' },
    { pattern: /^1[3-9]\d{9}$/, message: '请输入正确的手机号', trigger: 'blur' }
  ]
}

// 忘记密码相关
const forgotDialogVisible = ref(false)
const forgotFormRef = ref<FormInstance>()
const resetLoading = ref(false)

const forgotForm = reactive({
  username: '',
  verifyType: 'email' as 'email' | 'phone',
  verifyValue: '',
  newPassword: '',
  confirmPassword: ''
})

// 移除验证码相关的规则
const forgotRules = {
  username: [
    { required: true, message: '请输入用户名', trigger: 'blur' },
    { min: 4, max: 12, message: '长度在 4 到 12 个字符', trigger: 'blur' }
  ],
  verifyType: [
    { required: true, message: '请选择验证方式', trigger: 'change' }
  ],
  verifyValue: [
    { required: true, message: '请输入验证信息', trigger: 'blur' },
    { 
      validator: (rule: any, value: string, callback: any) => {
        if (forgotForm.verifyType === 'email') {
          const emailRegex = /^[^\s@]+@[^\s@]+\.[^\s@]+$/
          if (!emailRegex.test(value)) {
            callback(new Error('请输入正确的邮箱格式'))
          }
        } else {
          const phoneRegex = /^1[3-9]\d{9}$/
          if (!phoneRegex.test(value)) {
            callback(new Error('请输入正确的手机号格式'))
          }
        }
        callback()
      },
      trigger: 'blur'
    }
  ],
  newPassword: [
    { required: true, message: '请输入新密码', trigger: 'blur' },
    { min: 8, message: '密码不能少于8个字符', trigger: 'blur' }
  ],
  confirmPassword: [
    { required: true, message: '请确认密码', trigger: 'blur' },
    { 
      validator: (rule: any, value: string, callback: any) => {
        if (value !== forgotForm.newPassword) {
          callback(new Error('两次输入的密码不一致'))
        } else {
          callback()
        }
      },
      trigger: ['blur', 'change']
    }
  ]
}

const showForgotDialog = () => {
  forgotDialogVisible.value = true
}

const handleResetPassword = async () => {
  if (!forgotFormRef.value) return
  
  try {
    await forgotFormRef.value.validate()
    resetLoading.value = true
    
    const res = await auth.resetPassword({
      username: forgotForm.username,
      verifyType: forgotForm.verifyType,
      verifyValue: forgotForm.verifyValue,
      newPassword: forgotForm.newPassword,
      confirmPassword: forgotForm.confirmPassword
    })

    if (res.code === 200) {
      forgotDialogVisible.value = false
      ElMessage.success('密码重置成功，请使用新密码登录')
    }
  } catch (error) {
    console.error('重置密码失败:', error)
  } finally {
    resetLoading.value = false
  }
}
</script>

<style lang="css" scoped>
@import url("https://fonts.googleapis.com/css2?family=Poppins:wght@300;400;500;600;700;800;900&display=swap");

* {
  margin: 0;
  padding: 0;
  box-sizing: border-box;
  font-family: "Poppins", sans-serif;
}

body {
  display: flex;
  align-items: center;
  justify-content: center;
  min-height: 100vh;
  background: linear-gradient(90deg, #e2e2e2, #c9d6ff);
}

.container {
  position: relative;
  width: 850px;
  height: 550px;
  background: #fff;
  border-radius: 30px;
  box-shadow: 0 0 30px rgba(0, 0, 0, 0.2);
  margin-left: 50%;
  margin-top: 5%;
  transform: translateX(-50%);
  overflow: hidden;
}

.form-box {
  position: absolute;
  right: 0;
  width: 50%;
  height: 100%;
  background: #fff;
  display: flex;
  align-items: center;
  color: #333;
  text-align: center;
  padding: 40px;
  z-index: 1;
  transition: 0.6s ease-in-out 1.2s, visibility 0s 1s;
}

.container.active .form-box {
  right: 50%;
}

.form-box.register {
  visibility: hidden;
}

.container.active .form-box.register {
  visibility: visible;
}

form {
  width: 100%;
}

.container h1 {
  font-size: 36px;
  margin: -10px 0;
}

.input-box {
  position: relative;
  margin: 30px 0;
}

.input-box input {
  width: 100%;
  padding: 13px 50px 13px 20px;
  background: #eee;
  border-radius: 8px;
  border: none;
  outline: none;
  font-size: 16px;
  color: #333;
  font-weight: 500;
}

.input-box input::placeholder {
  color: #888;
  font-weight: 400;
}

.input-box i {
  position: absolute;
  right: 20px;
  top: 50%;
  transform: translateY(-50%);
  font-size: 20px;
  color: #888;
}

.forgot-link {
  margin: -15px 0 15px;
}

.forgot-link a {
  font-size: 14.5px;
  color: #333;
  text-decoration: none;
  &:hover {
    color: #409EFF;
  }
}

.btn {
  width: 100%;
  height: 48px;
  background-color: #409EFF;
  border-radius: 8px;
  box-shadow: 0 2px 12px rgba(64, 158, 255, 0.2);
  border: none;
  cursor: pointer;
  font-size: 16px;
  color: #fff;
  font-weight: 600;
  transition: all 0.3s ease;
}

.btn:hover {
  background-color: #66b1ff;
  box-shadow: 0 2px 12px rgba(64, 158, 255, 0.4);
}

.btn[disabled] {
  background-color: #a0cfff;
  cursor: not-allowed;
}

/* 加载中的动画效果 */
.el-button.is-loading {
  position: relative;
  pointer-events: none;
}

.el-button.is-loading:before {
  pointer-events: none;
  content: '';
  position: absolute;
  left: -1px;
  top: -1px;
  right: -1px;
  bottom: -1px;
  border-radius: inherit;
  background-color: rgba(255, 255, 255, 0.35);
}

.container p {
  font-size: 14.5px;
  margin: 15px 0;
}

.social-icons {
  display: flex;
  justify-content: center;
}

.social-icons a {
  display: inline-flex;
  padding: 10px;
  border: 2px solid #ccc;
  border-radius: 8px;
  font-size: 24px;
  color: #333;
  text-decoration: none;
  margin: 0 8px;
}

.toggle-box {
  position: absolute;
  width: 100%;
  height: 100%;
}

.toggle-box::before {
  content: "";
  position: absolute;
  left: -250%;
  width: 300%;
  height: 100%;
  background: #409EFF;
  border-radius: 150px;
  z-index: 2;
  transition: 1.8s ease-in-out;
}

.container.active .toggle-box::before {
  left: 50%;
}

.toggle-panel {
  position: absolute;
  width: 50%;
  height: 100%;
  color: #fff;
  display: flex;
  flex-direction: column;
  align-items: center;
  justify-content: center;
  z-index: 2;
  transition: 0.6s ease-in-out;
}

.toggle-panel.toggle-left {
  left: 0;
  transition-delay: 1.2s;
}

.container.active .toggle-panel.toggle-left {
  left: -50%;
  transition-delay: 0.6s;
}

.toggle-panel.toggle-right {
  right: -50%;
  transition-delay: 0.6s;
}

.container.active .toggle-panel.toggle-right {
  right: 0;
  transition-delay: 1.2s;
}

.toggle-panel p {
  margin-bottom: 20px;
}

.toggle-panel .btn {
  width: 160px;
  height: 46px;
  background: transparent;
  border: 2px solid #fff;
  box-shadow: none;
  outline: none;
}

@media screen and (max-width: 650px) {
  .container {
    height: calc(100vh - 40px);
  }
  .form-box {
    bottom: 0;
    width: 100%;
    height: 70%;
  }

  .container.active .form-box {
    right: 0;
    bottom: 30%;
  }

  .toggle-box::before {
    left: 0;
    top: -270%;
    width: 100%;
    height: 300%;
  }

  .container.active .toggle-box::before {
    left: 0;
    top: 70%;
  }

  .toggle-panel {
    width: 100%;
    height: 30%;
  }

  .toggle-panel.toggle-left {
    top: 0;
  }

  .container.active .toggle-panel.toggle-left {
    left: 0;
    top: -30%;
  }

  .toggle-panel.toggle-right {
    right: 0;
    bottom: -30%;
  }

  .container.active .toggle-panel.toggle-right {
    bottom: 0;
  }
}

@media screen and (max-width: 400px) {
  .form-box {
    padding: 20px;
  }

  .toggle-panel h1 {
    font-size: 30px;
  }
}

.role-select {
  margin: 20px 0;
  text-align: center;
}

.role-group {
  display: flex;
  justify-content: space-around;
  width: 100%;
  margin-top: -10px;
}

:deep(.el-radio) {
  margin-right: 0;
  color: #333;
}

:deep(.el-radio__input.is-checked + .el-radio__label) {
  color: #409EFF;
}

:deep(.el-radio__input.is-checked .el-radio__inner) {
  background-color: #409EFF;
  border-color: #409EFF;
}

:deep(.el-radio__inner:hover) {
  border-color: #409EFF;
}

.cursor-pointer {
  cursor: pointer;
}

.forgot-form {
  padding: 20px;
  padding-bottom: 0px;
}

.forgot-form :deep(.el-form-item) {
  margin-bottom: 20px;
}

.forgot-form :deep(.el-radio-group) {
  display: flex;
  justify-content: space-around;
}
</style>