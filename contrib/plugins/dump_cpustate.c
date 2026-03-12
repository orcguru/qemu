/**
 * dump_cpustate.c - QEMU插件，在vCPU退出前dump CPUState字段
 * 编译: gcc -shared -fPIC -I/path/to/qemu/include -o libdump_cpustate.so dump_cpustate.c
 */

#include <stdio.h>
#include <stdint.h>
#include <glib.h>
#include <qemu-plugin.h>

QEMU_PLUGIN_EXPORT int qemu_plugin_version = QEMU_PLUGIN_VERSION;
static GMutex lock;

/* 声明外部函数，但不使用CPUState类型 */
/* 这些函数在plugin-helpers.c中定义 */
extern void *qemu_plugin_get_current_cpu(void);
extern uint64_t *qemu_plugin_get_aot_cnt_ptr(void);

static void dump_cpustate_stats(void *cpu_opaque)
{   
    printf("  Plugin Statistics:\n");
    
    /* 获取计数器指针 */
    uint64_t *aot_cnt = qemu_plugin_get_aot_cnt_ptr();
    if (aot_cnt) {
        printf("    aot_cnt: %lu\n", *aot_cnt);
    } else {
        printf("    aot_cnt: NULL pointer (current_cpu might be NULL)\n");
    }
}

static void vcpu_exit_callback(qemu_plugin_id_t id, unsigned int cpu_index)
{   
    g_mutex_lock(&lock);
    
    printf("\n=== vCPU Exit Dump ===\n");
    printf("CPU Index: %u is exiting\n", cpu_index);
    
    /* 获取当前CPU的不透明指针 */
    void *cpu_opaque = qemu_plugin_get_current_cpu();
    if (!cpu_opaque) {
        printf("Warning: Could not get CPUState for CPU %u\n", cpu_index);
        g_mutex_unlock(&lock);
        return;
    }
    
    dump_cpustate_stats(cpu_opaque);
    printf("======================\n");
    
    g_mutex_unlock(&lock);
}

static void plugin_exit_callback(qemu_plugin_id_t id, void *userdata)
{
    printf("\n=== Plugin Exit Summary ===\n");
    
    /* 尝试获取最终状态 */
    void *cpu_opaque = qemu_plugin_get_current_cpu();
    if (cpu_opaque) {
        printf("Final CPUState available\n");
        dump_cpustate_stats(cpu_opaque);
    } else {
        printf("CPUState not available at exit\n");
    }
    
    printf("===========================\n");
}

static void register_vcpu_exit_callback(qemu_plugin_id_t id)
{
    /* 注册vCPU退出回调 */
    qemu_plugin_register_vcpu_exit_cb(id, vcpu_exit_callback);
    printf("Registered vCPU exit callback\n");
}

QEMU_PLUGIN_EXPORT
int qemu_plugin_install(qemu_plugin_id_t id, const qemu_info_t *info,
                        int argc, char **argv)
{
    printf("CPUState Dumper plugin installed\n");
    
    /* 初始化互斥锁 */
    g_mutex_init(&lock);
    
    /* 注册vCPU退出回调 */
    register_vcpu_exit_callback(id);
    
    /* 注册插件退出回调 */
    qemu_plugin_register_atexit_cb(id, plugin_exit_callback, NULL);
    
    return 0;
}
