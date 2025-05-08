-- 创建数据库
DROP DATABASE IF EXISTS `imhsp_project`;
CREATE DATABASE `imhsp_project` CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;

USE `imhsp_project`;

SET NAMES utf8mb4;
SET FOREIGN_KEY_CHECKS = 0;

-- 用户表
DROP TABLE IF EXISTS `users`;
CREATE TABLE `users` (
    `id` bigint(20) NOT NULL AUTO_INCREMENT COMMENT '用户唯一标识',
    `username` varchar(50) NOT NULL COMMENT '用户名',
    `password` varchar(255) NOT NULL COMMENT '密码',
    `email` varchar(100) DEFAULT NULL COMMENT '邮箱',
    `phone` varchar(20) DEFAULT NULL COMMENT '手机号',
    `gender` enum('male','female') DEFAULT 'male' COMMENT '性别',
    `location` varchar(100) DEFAULT NULL COMMENT '所在地',
    `bio` text DEFAULT NULL COMMENT '个人简介',
    `avatar` varchar(255) DEFAULT NULL COMMENT '头像URL',
    `roles` enum('explorer','counselor','admin') DEFAULT 'explorer' COMMENT '用户角色',
    `visit_count` int(11) DEFAULT 0 COMMENT '主页访问量',
    `followers_count` int(11) DEFAULT 0 COMMENT '粉丝数',
    `following_count` int(11) DEFAULT 0 COMMENT '关注数',
    `created_at` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '注册时间',
    `updated_at` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
    `is_qualified` tinyint(1) DEFAULT 0 COMMENT '咨询师资格认证状态',
    `specialties` json DEFAULT NULL COMMENT '咨询师专业领域',
    `experience` int(11) DEFAULT NULL COMMENT '咨询师从业年限',
    `price` decimal(10,2) DEFAULT NULL COMMENT '咨询价格/次',
    `is_free` tinyint(1) DEFAULT 0 COMMENT '是否提供免费咨询',
    `available` tinyint(1) DEFAULT 1 COMMENT '是否接受预约',
    PRIMARY KEY (`id`),
    UNIQUE KEY `uk_username` (`username`),
    UNIQUE KEY `uk_email` (`email`),
    KEY `idx_phone` (`phone`),
    KEY `idx_roles` (`roles`)
) ENGINE=InnoDB AUTO_INCREMENT=1 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='用户表';

-- 隐私设置表
DROP TABLE IF EXISTS `privacy_settings`;
CREATE TABLE `privacy_settings` (
    `id` bigint(20) NOT NULL AUTO_INCREMENT,
    `user_id` bigint(20) NOT NULL,
    `email_public` tinyint(1) DEFAULT 0,
    `phone_public` tinyint(1) DEFAULT 0,
    `gender_public` tinyint(1) DEFAULT 0,
    `location_public` tinyint(1) DEFAULT 0,
    `bio_public` tinyint(1) DEFAULT 0,
    `activities_public` tinyint(1) DEFAULT 0,
    `follow_list_public` tinyint(1) DEFAULT 0,
    `follower_list_public` tinyint(1) DEFAULT 0,
    `notifications_public` tinyint(1) DEFAULT 0,
    `test_history_public` tinyint(1) DEFAULT 0,
    `created_at` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
    `updated_at` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    PRIMARY KEY (`id`),
    KEY `idx_user_id` (`user_id`),
    CONSTRAINT `fk_privacy_user` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=1 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='隐私设置表';

-- 动态表
DROP TABLE IF EXISTS `activities`;
CREATE TABLE `activities` (
    `id` bigint(20) NOT NULL AUTO_INCREMENT,
    `user_id` bigint(20) NOT NULL,
    `type` enum('post','topic','comment','like','dislike','star','test') NOT NULL,
    `target_type` enum('post','topic','comment'),
    `target_id` bigint(20),
    `created_at` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
    PRIMARY KEY (`id`),
    KEY `idx_user_created` (`user_id`, `created_at`),
    CONSTRAINT `fk_activities_user` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=1 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='动态表';

-- 关注表
DROP TABLE IF EXISTS `follows`;
CREATE TABLE `follows` (
    `id` bigint(20) NOT NULL AUTO_INCREMENT,
    `follower_id` bigint(20) NOT NULL,
    `following_id` bigint(20) NOT NULL,
    `created_at` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
    PRIMARY KEY (`id`),
    KEY `idx_follower` (`follower_id`),
    KEY `idx_following` (`following_id`),
    CONSTRAINT `fk_follows_follower` FOREIGN KEY (`follower_id`) REFERENCES `users` (`id`) ON DELETE CASCADE,
    CONSTRAINT `fk_follows_following` FOREIGN KEY (`following_id`) REFERENCES `users` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=1 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='关注表';

-- 通知表
DROP TABLE IF EXISTS `notifications`;
CREATE TABLE `notifications` (
    `id` bigint(20) NOT NULL AUTO_INCREMENT,
    `user_id` bigint(20) NOT NULL,
    `type` enum('comment','like','star','follow','dislike') NOT NULL,
    `sender_id` bigint(20) NOT NULL,
    `target_type` enum('post','topic','comment'),
    `target_id` bigint(20),
    `is_read` BOOLEAN DEFAULT FALSE,
    `created_at` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
    PRIMARY KEY (`id`),
    KEY `idx_user_read` (`user_id`, `is_read`),
    CONSTRAINT `fk_notifications_user` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`) ON DELETE CASCADE,
    CONSTRAINT `fk_notifications_sender` FOREIGN KEY (`sender_id`) REFERENCES `users` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=1 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='通知表';

-- 预约表
DROP TABLE IF EXISTS `appointments`;
CREATE TABLE `appointments` (
    `id` bigint(20) NOT NULL AUTO_INCREMENT,
    `user_id` bigint(20) NOT NULL,
    `counselor_id` bigint(20) NOT NULL,
    `date` date NOT NULL,
    `time_slot` varchar(20) NOT NULL,
    `is_read` BOOLEAN DEFAULT FALSE,
    `status` enum('waiting','ongoing','cancelled','completed','reviewed') DEFAULT 'waiting',
    `created_at` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
    `updated_at` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    PRIMARY KEY (`id`),
    KEY `idx_user_date` (`user_id`, `date`),
    KEY `idx_counselor_date` (`counselor_id`, `date`),
    CONSTRAINT `fk_appointments_user` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`) ON DELETE CASCADE,
    CONSTRAINT `fk_appointments_counselor` FOREIGN KEY (`counselor_id`) REFERENCES `users` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=1 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='预约表';

-- 咨询评价表
DROP TABLE IF EXISTS `reviews`;
CREATE TABLE `reviews` (
    `id` bigint(20) NOT NULL AUTO_INCREMENT,
    `appointment_id` bigint(20) NOT NULL,
    `user_id` bigint(20) NOT NULL,
    `counselor_id` bigint(20) NOT NULL,
    `type` enum('good','bad') NOT NULL,
    `content` text,
    `is_anonymous` BOOLEAN DEFAULT FALSE,
    `created_at` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
    PRIMARY KEY (`id`),
    KEY `idx_appointment` (`appointment_id`),
    KEY `idx_counselor` (`counselor_id`),
    CONSTRAINT `fk_reviews_appointment` FOREIGN KEY (`appointment_id`) REFERENCES `appointments` (`id`) ON DELETE CASCADE,
    CONSTRAINT `fk_reviews_user` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`) ON DELETE CASCADE,
    CONSTRAINT `fk_reviews_counselor` FOREIGN KEY (`counselor_id`) REFERENCES `users` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=1 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='咨询评价表';

-- 咨询评价点赞表
CREATE TABLE `review_likes` (
    `id` BIGINT PRIMARY KEY AUTO_INCREMENT,
    `type` ENUM('like', 'dislike') NOT NULL,
    `user_id` BIGINT NOT NULL,
    `review_id` BIGINT NOT NULL,
    `created_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (`user_id`) REFERENCES `users`(`id`) ON DELETE CASCADE,
    FOREIGN KEY (`review_id`) REFERENCES `reviews`(`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='咨询评价点赞表';

-- 心理测验表
CREATE TABLE `tests` (
    `id` BIGINT PRIMARY KEY AUTO_INCREMENT,
    `name` VARCHAR(100) NOT NULL,
    `description` TEXT,
    `count` INT NOT NULL,
    `questions` JSON NOT NULL,
    `created_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    `updated_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='心理测验表';

-- 测验记录表
CREATE TABLE `test_records` (
    `id` BIGINT PRIMARY KEY AUTO_INCREMENT,
    `user_id` BIGINT NOT NULL,
    `test_id` BIGINT NOT NULL,
    `answers` JSON NOT NULL,
    `score` INT,
    `result` TEXT,
    `created_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (`user_id`) REFERENCES `users`(`id`) ON DELETE CASCADE,
    FOREIGN KEY (`test_id`) REFERENCES `tests`(`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='测验记录表';

-- 专题表
CREATE TABLE `topics` (
    `id` BIGINT PRIMARY KEY AUTO_INCREMENT,
    `title` VARCHAR(100) NOT NULL,
    `introduction` TEXT,
    `content` TEXT,
    `cover` VARCHAR(255),
    `type` ENUM('free', 'paid') DEFAULT 'free',
    `price` DECIMAL(10,2),
    `author_id` BIGINT NOT NULL,
    `views` INT DEFAULT 0,
    `likes` INT DEFAULT 0,
    `collects` INT DEFAULT 0,
    `created_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    `updated_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    FOREIGN KEY (`author_id`) REFERENCES `users`(`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='专题表';

-- 帖子表
CREATE TABLE `posts` (
    `id` BIGINT PRIMARY KEY AUTO_INCREMENT,
    `title` VARCHAR(100) NOT NULL,
    `content` TEXT,
    `author_id` BIGINT NOT NULL,
    `views` INT DEFAULT 0,
    `likes` INT DEFAULT 0,
    `collects` INT DEFAULT 0,
    `created_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    `updated_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    FOREIGN KEY (`author_id`) REFERENCES `users`(`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='帖子表';

-- 评论表
CREATE TABLE `comments` (
    `id` BIGINT PRIMARY KEY AUTO_INCREMENT,
    `content` TEXT NOT NULL,
    `author_id` BIGINT NOT NULL,
    `target_type` ENUM('post', 'topic') NOT NULL,
    `target_id` BIGINT NOT NULL,
    `likes` INT DEFAULT 0,
    `dislikes` INT DEFAULT 0,
    `created_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (`author_id`) REFERENCES `users`(`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='评论表';

-- 点赞表
DROP TABLE IF EXISTS `likes`;
CREATE TABLE `likes` (
    `id` bigint(20) NOT NULL AUTO_INCREMENT,
    `type` enum('like','dislike') NOT NULL,
    `user_id` bigint(20) NOT NULL,
    `target_type` enum('post','topic','comment') NOT NULL,
    `target_id` bigint(20) NOT NULL,
    `created_at` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
    PRIMARY KEY (`id`),
    KEY `idx_user_target` (`user_id`, `target_type`, `target_id`),
    CONSTRAINT `fk_likes_user` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=1 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='点赞表';

-- 收藏表
DROP TABLE IF EXISTS `collections`;
CREATE TABLE `collections` (
    `id` bigint(20) NOT NULL AUTO_INCREMENT,
    `user_id` bigint(20) NOT NULL,
    `target_type` enum('post','topic') NOT NULL,
    `target_id` bigint(20) NOT NULL,
    `created_at` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
    PRIMARY KEY (`id`),
    KEY `idx_user_target` (`user_id`, `target_type`, `target_id`),
    CONSTRAINT `fk_collections_user` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=1 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='收藏表';

-- 聊天记录表
DROP TABLE IF EXISTS `messages`;
CREATE TABLE `messages` (
    `id` bigint(20) NOT NULL AUTO_INCREMENT,
    `sender_id` bigint(20) NOT NULL,
    `receiver_id` bigint(20) NOT NULL,
    `content` text NOT NULL,
    `is_read` BOOLEAN DEFAULT FALSE,
    `created_at` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
    PRIMARY KEY (`id`),
    KEY `idx_sender_receiver` (`sender_id`, `receiver_id`),
    KEY `idx_receiver_read` (`receiver_id`, `is_read`),
    CONSTRAINT `fk_messages_sender` FOREIGN KEY (`sender_id`) REFERENCES `users` (`id`) ON DELETE CASCADE,
    CONSTRAINT `fk_messages_receiver` FOREIGN KEY (`receiver_id`) REFERENCES `users` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=1 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='聊天记录表';

-- 设置外键检查
SET FOREIGN_KEY_CHECKS = 1;