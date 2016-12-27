//
//  struct.h
//  cache_simulator
//
//  Created by 龔逸中 on 2016/12/25.
//  Copyright © 2016年 龔逸中. All rights reserved.
//

#ifndef struct_h
#define struct_h

typedef struct{
    int IS_method;
    char IS_tag[32];
    char IS_index[32];
    char IS_offset[32];
}instructionSetStruct;

typedef struct{
    int ES_ins;
    int ES_valid;
    int ES_dirty;
    char ES_tag[32];
    char ES_data[32];
    int ES_used;
}cacheStruct;

instructionSetStruct instructionSet[10000000];
cacheStruct cache[10000000];
int FIFO_pointer[10000000] = {0};

char inputFile[10];
int cacheSize, blockSize, assoc, replacePolicy;
int demandFetch, cacheHit, cacheMiss, readData, writeData, bytesFromMem, bytesToMem;
double missRate;
int m, n, idx, tag, cacheTotalIdx;

#endif /* struct_h */
