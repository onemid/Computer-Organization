//
//  main.c
//  cache_simulator
//
//  Created by 龔逸中 on 2016/12/25.
//  Copyright © 2016年 龔逸中. All rights reserved.
//

#include <stdio.h>
#include <math.h>
#include <stdlib.h>
#include <string.h>

#define DEBUG 0

#include "struct.h"
#include "arithmetic.h"
#include "replace_policy.h"
#include "cache.h"


int main(int argc, const char * argv[]) {
    
    cacheSize = atoi(argv[1]); blockSize = atoi(argv[2]);
    
    
    if (!strcmp(argv[4], "FIFO")) {
        replacePolicy = 0;
    }else if (!strcmp(argv[4], "LFU")) {
        replacePolicy = 1;
    }else if (!strcmp(argv[4], "LRU")) {
        replacePolicy = 2;
    }else if (!strcmp(argv[4], "MRU")) {
        replacePolicy = 3;
    }
    
    
    if (!strncmp(argv[3], "1", 1)) {
        assoc = 1;
    }else if (!strncmp(argv[3], "2", 1)) {
        assoc = 2;
    }else if (!strncmp(argv[3], "4", 1)) {
        assoc = 4;
    }else if (!strncmp(argv[3], "8", 1)) {
        assoc = 8;
    }else if (!strncmp(argv[3], "f", 1)) {
        assoc = cacheSize * 1024 / blockSize;
    }
    
    n = log2((cacheSize * 1024) / (blockSize * assoc));// n = 0 assoc =
    m = log2(blockSize) - 2;
    idx = n;
    cacheTotalIdx = fastPow(2, idx);
    tag = 32 - (n + m + 2);
    
    FILE *input = fopen(argv[5], "r");
    int stringLen;
    char inputString[13];
    
    /*
     * 開機囉！
     *
     */
    
    boot();
    
    /*
     * Handling Input
     *
     */
    
    while(fgets(inputString, 13, input)){
        
        char *instructionBase = (char *)malloc(sizeof(char)*32);
        memset(instructionBase, 0, 32);
        
        if (DEBUG) printf("%s\n", inputString);
        
        stringLen = (int)strlen(inputString) - 1;
        
        instructionSet[demandFetch].IS_method = inputString[0];
        
        
        if (inputString[0] == '2' || stringLen < 10) {
            
            strcat(instructionBase, "00000000");
            
        }
        
        for(int i = 2; i < stringLen; i++) {
            strcat(instructionBase, hex_to_bin_quad(inputString[i]));
        }
        
        strncpy(instructionSet[demandFetch].IS_tag, instructionBase, tag);
        strncpy(instructionSet[demandFetch].IS_index, instructionBase + tag, idx);
        strncpy(instructionSet[demandFetch].IS_offset, instructionBase + tag + idx, m + 2);
        
        if (DEBUG) printf("%s\n\n", instructionBase);
        
        if (DEBUG) printf("%s%s%s\n\n", instructionSet[demandFetch].IS_tag, instructionSet[demandFetch].IS_index, instructionSet[demandFetch].IS_offset);
        
        if (instructionSet[demandFetch].IS_method == '0' /* READ */) {
            readData++;
        } else if (instructionSet[demandFetch].IS_method == '1' /* WRITE */) {
            writeData++;
        }
        
        nWay(demandFetch, replacePolicy);
        
        demandFetch++;
        
        if(instructionBase != 0) free(instructionBase);
        
    }
    
    cleanup();
    
    printf("Input file = %s\n", argv[5]);
    printf("Demand Fetch = %d\n", demandFetch);
    printf("Cache hit = %d\n", cacheHit);
    printf("Cache miss = %d\n", cacheMiss);
    printf("Miss rate = %.4f\n", ((double)cacheMiss / (double)demandFetch));
    printf("Read data = %d\n", readData);
    printf("Write data = %d\n", writeData);
    printf("Bytes from memory = %d\n", bytesFromMem);
    printf("Bytes to memory = %d\n", bytesToMem);
    
    return 0;
}


