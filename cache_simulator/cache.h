//
//  cache.h
//  cache_simulator
//
//  Created by 龔逸中 on 2016/12/25.
//  Copyright © 2016年 龔逸中. All rights reserved.
//

#ifndef cache_h
#define cache_h

void boot() {
    for(int i = 0; i < 1000000; i++) {
        instructionSet[i].IS_method = 0;
        memset(instructionSet[i].IS_tag, 0, 32);
        memset(instructionSet[i].IS_index, 0, 32);
        memset(instructionSet[i].IS_offset, 0, 32);
        cache[i].ES_valid = 0;
        cache[i].ES_dirty = 0;
        cache[i].ES_used = 0;
        cache[i].ES_ins = 0;
        memset(cache[i].ES_tag, 0, 32);
        memset(cache[i].ES_data, 0, 32);
    }
    
}

int hit(int cacheIdxBase, int assoc, int instructionIdx) {
    
    /* Least Recent Usage */
    
    cacheIdxBase *= assoc;
    
    for (int i = 0; i < assoc; i++) {
        
        /* Find the space first; if not, apply the LRU alg */
        
        if (!strncmp(cache[cacheIdxBase + i].ES_tag, instructionSet[instructionIdx].IS_tag, tag) && cache[cacheIdxBase + i].ES_valid) {
            
            return (cacheIdxBase + i);
            
        }
        
    }
    
    return -1;
    
}

void nWay(int instructionIdx, int replacePolicy){
    
    int cacheIdxBase = binToInt(instructionSet[instructionIdx].IS_index, idx);
    
    int hitLocation = hit(cacheIdxBase, assoc, instructionIdx);
    
    if(hitLocation != -1) {
        
        cacheHit++;
        //printf("HIT:%d\n", instructionIdx);
        if (DEBUG) puts("hit");
        cache[hitLocation].ES_used++;
        cache[hitLocation].ES_ins = instructionIdx;
        
        if (instructionSet[instructionIdx].IS_method == '0' || instructionSet[instructionIdx].IS_method == '2' /* READ */) {
            
            return /* data */;
            
        } else if (instructionSet[instructionIdx].IS_method == '1' /* WRITE */) {
            
            /* Performing Writing New Data into the Cache Block */
            
            /* Mark the cache block as dirty */
            
            cache[hitLocation].ES_dirty = 1;
            
        }
        
    }else{
        
        int targetBlock = replacePolicyController(replacePolicy, cacheIdxBase, assoc);
        
        cacheMiss++;
        if (DEBUG) puts("miss");
        //printf("MISS:%d\n", instructionIdx);
        
        /* Locate a cache block to use (Remember the Policy) */
        
        /* - Replace algorithm is useless here - */
        
        /* If Dirty: Write the previous data back to the lower mem. */
        
        if (cache[targetBlock].ES_dirty == 1) {
            
            bytesToMem += blockSize;
            
        }
        
        /* Read data from lower mem. */
        
        bytesFromMem += blockSize;
        
        cache[targetBlock].ES_valid = 1;
        
        strncpy(cache[targetBlock].ES_tag, instructionSet[instructionIdx].IS_tag, tag);
        
        cache[targetBlock].ES_used = 0;
        
        cache[targetBlock].ES_ins = instructionIdx;
        
        if (instructionSet[instructionIdx].IS_method == '0' || instructionSet[instructionIdx].IS_method == '2' /* READ */) {
            
            /* Mark the cache block as NOT dirty */
            
            cache[targetBlock].ES_dirty = 0;
            
        } else if (instructionSet[instructionIdx].IS_method == '1' /* WRITE */) {
            
            /* Performing Writing New Data into the Cache Block */
            
            /* Mark the cache block as dirty */
            
            cache[targetBlock].ES_dirty = 1;
            
        }
        
    }
    
}

void cleanup(){
    for (int i = 0; i < 1000000; i++) {
        if (cache[i].ES_dirty == 1) {
            bytesToMem += blockSize;
        }
    }
}


#endif /* cache_h */
