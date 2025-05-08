<template>
  <el-container class="layout-container">
    <SideNav />
    <el-container>
      <el-main class="main">
        <router-view></router-view>
      </el-main>
    </el-container>
  </el-container>
</template>

<script setup lang="ts">
import SideNav from '@/components/SideNav.vue'
</script>

<style scoped>
@import url("https://fonts.googleapis.com/css2?family=Poppins:wght@300;400;500;600;700;800;900&display=swap");

* {
  margin: 0;
  padding: 0;
  box-sizing: border-box;
  font-family: "Poppins", sans-serif;
}

.layout-container {
  height: 97.5vh;
  background-color: #f5f7fa;
}

.main {
  background-color: #fff;
  /* padding: 20px; */
  border-radius: 8px;
  /* margin: 16px; */
  box-shadow: 0 2px 12px rgba(64, 158, 255, 0.05);
}
</style>
