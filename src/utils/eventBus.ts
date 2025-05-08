import mitt from 'mitt'
import type { Emitter } from 'mitt'

export const enum EventType {
  NOTIFICATIONS_READ = 'notifications-read',
  CLOSE_CHAT = 'close-chat',
  CLOSE_USER_CARD = 'close-user-card'
}

// 创建一个类型化的事件总线
type Events = {
  [EventType.NOTIFICATIONS_READ]: void;
  [EventType.CLOSE_CHAT]: void;
  [EventType.CLOSE_USER_CARD]: void;
  unauthorized: number;
  forbidden: number;
  error: number;
}

const eventBus: Emitter<Events> = mitt<Events>()

// 使用默认导出
export default eventBus