#!/bin/bash

# 监控SLAM运行时的GPU和CPU使用情况

echo "开始监控SLAM系统资源使用情况..."
echo "请在另一个终端运行: python slam.py"
echo "按 Ctrl+C 停止监控"
echo ""

# 创建日志文件
LOG_FILE="slam_monitor_$(date +%Y%m%d_%H%M%S).log"
echo "监控日志将保存到: $LOG_FILE"

# 监控函数
monitor_resources() {
    while true; do
        echo "==================== $(date) ====================" >> $LOG_FILE
        
        # GPU使用情况
        echo "GPU 使用情况:" >> $LOG_FILE
        nvidia-smi --query-gpu=utilization.gpu,memory.used,memory.total,temperature.gpu --format=csv,noheader,nounits >> $LOG_FILE
        
        # CPU使用情况
        echo "CPU 使用情况:" >> $LOG_FILE
        top -bn1 | grep "Cpu(s)" >> $LOG_FILE
        
        # 内存使用情况
        echo "内存使用情况:" >> $LOG_FILE
        free -h >> $LOG_FILE
        
        # Python进程
        echo "Python SLAM 进程:" >> $LOG_FILE
        ps aux | grep python | grep slam >> $LOG_FILE
        
        echo "" >> $LOG_FILE
        
        # 控制台输出
        clear
        echo "==================== $(date) ===================="
        echo "GPU 使用情况:"
        nvidia-smi --query-gpu=utilization.gpu,memory.used,memory.total,temperature.gpu --format=csv,header
        echo ""
        echo "CPU 使用情况:"
        top -bn1 | grep "Cpu(s)"
        echo ""
        echo "Python SLAM 进程:"
        ps aux | grep python | grep slam | head -5
        echo ""
        echo "监控日志: $LOG_FILE"
        echo "按 Ctrl+C 停止监控"
        
        sleep 2
    done
}

# 捕获Ctrl+C信号
trap 'echo "停止监控..."; exit 0' INT

# 开始监控
monitor_resources
