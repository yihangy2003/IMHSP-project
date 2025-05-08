@echo off

REM 设置图片存储路径
set IMHSP_UPLOAD_DIR=D:/IMHSP-project/uploads/images

REM 启动 Nacos
echo 启动 Nacos...
start cmd /k "cd /d D:\Programs\nacos\bin && startup.cmd -m standalone"

REM 启动 Redis
echo 启动 Redis...
start cmd /k "cd /d D:\Programs\Redis && redis-server.exe redis.windows.conf"

echo Nacos 和 Redis 已启动
pause 