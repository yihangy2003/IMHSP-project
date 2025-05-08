import router from './index';
import { RouteLocationNormalized } from 'vue-router';
import { getToken } from '@/utils/auth';
import { ElMessage } from 'element-plus';

// 白名单路由
const whiteList = ['/login', '/register', '/resetPassword'];

router.beforeEach(async (to: RouteLocationNormalized, from: RouteLocationNormalized, next: any) => {
    const hasToken = getToken();

    console.log("Route guard triggered:");
    console.log("- To path:", to.path);
    console.log("- From path:", from.path);
    console.log("- Token exists:", !!hasToken);
    console.log("- Token value:", hasToken);
    
    // 设置页面标题
    document.title = to.meta.title ? `${to.meta.title} - IMHSP` : 'IMHSP';

    if (hasToken) {
        if (to.path === '/login') {
            // 已登录且要跳转的页面是登录页
            next({ path: '/dashboard' });
            ElMessage.info('您已登录，已为您跳转到首页');
        } else {
            next();
        }
    } else {
        // 未登录
        if (whiteList.includes(to.path)) {
            // 在免登录白名单中，直接进入
            next();
        } else {
            // 其他所有页面重定向到登录页
            ElMessage.warning('请先登录');
            next(`/login?redirect=${to.fullPath}`);
        }
    }
}); 