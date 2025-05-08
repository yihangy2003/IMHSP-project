<template>
    <div class="home">
      <el-row>
        <el-col :span="24">
          <h1>欢迎来到 IMHSP 项目</h1>
          <el-button type="primary" @click="counter.increment">
            计数: {{ counter.count }}
          </el-button>
        </el-col>
      </el-row>
    </div>
  </template>
  
  <script setup lang="ts">
  import { useCounterStore } from '../stores/counter'
  
  const counter = useCounterStore()
  </script>