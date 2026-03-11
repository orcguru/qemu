/**
 * simple_tb_counter_fixed.c - 简单的QEMU插件，统计翻译块中的指令数
 * 编译: gcc -shared -fPIC -I/path/to/qemu/include -o libsimple_tb_counter.so simple_tb_counter_fixed.c
 */

#include <stdio.h>
#include <stdint.h>
#include <glib.h>
#include <qemu-plugin.h>

QEMU_PLUGIN_EXPORT int qemu_plugin_version = QEMU_PLUGIN_VERSION;

/* 全局计数器 */
static uint64_t instruction_counter = 0;
static GMutex counter_lock;

/* 翻译块执行结束时的回调 */
static void tb_exec_end_callback(unsigned int cpu_index, void *userdata)
{
    /* 从userdata中获取指令数 */
    size_t num_insns = (size_t)(uintptr_t)userdata;
    
    /* 更新全局计数器 */
    g_mutex_lock(&counter_lock);
    instruction_counter += num_insns;
    g_mutex_unlock(&counter_lock);
}

/* 翻译块翻译时的回调 - 用于注册执行回调 */
static void tb_translate_callback(qemu_plugin_id_t id, struct qemu_plugin_tb *tb)
{
    /* 获取翻译块中的指令数 */
    size_t num_insns = qemu_plugin_tb_n_insns(tb);
    
    /* 将指令数作为指针传递，避免内存分配/释放问题 */
    /* 注意：这里将size_t转换为void*，在64位系统上是安全的 */
    void *num_insns_ptr = (void *)(uintptr_t)num_insns;
    
    /* 注册翻译块执行结束时的回调 */
    qemu_plugin_register_vcpu_tb_exec_cb(
        tb, 
        tb_exec_end_callback,      // 执行结束回调函数
        QEMU_PLUGIN_CB_NO_REGS,    // 回调标志
        num_insns_ptr              // 用户数据，直接传递指令数
    );
}

/* 插件退出时的回调 */
static void plugin_exit_callback(qemu_plugin_id_t id, void *userdata)
{
    /* 输出最终结果 */
    printf("\n=== QEMU Plugin Instruction Counter Results ===\n");
    printf("Total Instructions Executed: %lu\n", instruction_counter);
    printf("===============================================\n");
}

/* 插件安装入口 */
QEMU_PLUGIN_EXPORT
int qemu_plugin_install(qemu_plugin_id_t id, const qemu_info_t *info,
                        int argc, char **argv)
{
    printf("Simple TB Counter plugin installed\n");
    
    /* 初始化互斥锁 */
    g_mutex_init(&counter_lock);
    
    /* 注册翻译块翻译时的回调 */
    qemu_plugin_register_vcpu_tb_trans_cb(id, tb_translate_callback);
    
    /* 注册插件退出回调 */
    qemu_plugin_register_atexit_cb(id, plugin_exit_callback, NULL);
    
    return 0;
}
