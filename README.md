# 智能心理健康服务平台 (IMHSP)

这是一个提供智能心理健康服务的综合平台，包括前端和后端部分。

## 项目结构

- `IMHSP-project-frontend`: 前端项目，使用Vue 3 + TypeScript + Vite构建
- `IMHSP-project-backend`: 后端项目，基于Spring Boot + Spring Cloud微服务架构

## 前端项目

前端项目采用Vue 3框架，使用TypeScript进行开发，Vite作为构建工具。

### 主要功能

- 用户认证与授权
- 心理健康测评
- 在线咨询服务
- 社区交流
- 个人中心
- 心理健康资源推荐

### 运行前端项目

```bash
cd IMHSP-project-frontend
npm install
npm run dev
```

## 后端项目

后端项目采用Spring Boot + Spring Cloud微服务架构，主要包括以下模块：

- `imhsp-gateway`: API网关服务
- `imhsp-auth`: 认证授权服务
- `imhsp-user`: 用户服务
- `imhsp-message`: 消息服务
- `imhsp-common`: 通用组件
- `imhsp-service`: 核心业务服务

### 运行后端项目

```bash
cd IMHSP-project-backend
mvn clean install
mvn spring-boot:run
```

## 技术栈

### 前端

- Vue 3
- TypeScript
- Vite
- Element Plus
- Vue Router
- Pinia
- Axios

### 后端

- Spring Boot
- Spring Cloud
- Spring Security
- MyBatis-Plus
- Redis
- RabbitMQ
- MySQL

## 贡献者

- [yeaheee](https://github.com/yeaheee)

## 许可证

本项目采用MIT许可证。
