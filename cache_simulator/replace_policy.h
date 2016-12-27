//
//  replace_policy.h
//  cache_simulator
//
//  Created by 龔逸中 on 2016/12/26.
//  Copyright © 2016年 龔逸中. All rights reserved.
//

#ifndef replace_policy_h
#define replace_policy_h

enum {
    FIFO_,
    LFU_,
    LRU_,
    MRU_
} replaceAlg;

int FIFO(int cacheIdxBase, int assoc){
    
    /* FIFO */
    
    cacheIdxBase *= assoc;
    
    if (FIFO_pointer[cacheIdxBase] + 1 == assoc) FIFO_pointer[cacheIdxBase] = -1;
    
    FIFO_pointer[cacheIdxBase]++;
    
    return FIFO_pointer[cacheIdxBase] + cacheIdxBase;
    
    
}

int LFU(int cacheIdxBase, int assoc){
    
    /* Least Freq Usage */
    
    cacheIdxBase *= assoc;
    
    int min = 1000000000, minCacheBlock = -1;
    
    for (int i = 0; i < assoc; i++) {
        
        /* Find the space first; if not, apply the LFU alg */
        
        if (cache[cacheIdxBase + i].ES_valid == 0) {
            
            return (cacheIdxBase + i);
            
        }else if (cache[cacheIdxBase + i].ES_used < min) {
            
            min = cache[cacheIdxBase + i].ES_used;
            
            minCacheBlock = cacheIdxBase + i;
            
        }
    }
    
    return minCacheBlock;
    
}

int LRU(int cacheIdxBase, int assoc){
    
    /* Least Recent Usage */
    
    cacheIdxBase *= assoc;
    
    int min = 1000000000, minCacheBlock = -1;
    
    for (int i = 0; i < assoc; i++) {
        
        /* Find the space first; if not, apply the LRU alg */
        
        if (cache[cacheIdxBase + i].ES_valid == 0) {
            
            return (cacheIdxBase + i);
            
        }else if (cache[cacheIdxBase + i].ES_ins < min) {
            
            min = cache[cacheIdxBase + i].ES_ins;
            
            minCacheBlock = cacheIdxBase + i;
            
        }
    }
    
    return minCacheBlock;
    
}

int MRU(int cacheIdxBase, int assoc){
    
    /* Most Recent Usage */
    
    cacheIdxBase *= assoc;
    
    int max = 0, maxCacheBlock = -1;
    
    for (int i = 0; i < assoc; i++) {
        
        if (cache[cacheIdxBase + i].ES_valid == 0) {
            
            /* Find the space first; if not, apply the MRU alg */
            
            return (cacheIdxBase + i);
            
        }else if (cache[cacheIdxBase + i].ES_ins > max) {
            
            max = cache[cacheIdxBase + i].ES_ins;
            
            maxCacheBlock = cacheIdxBase + i;
            
        }
    }
    
    return maxCacheBlock;
    
}

int replacePolicyController(int replacePolicy, int cacheIdxBase, int assoc) {
    
    if (replacePolicy == 0) {
        return FIFO(cacheIdxBase, assoc);
    }else if(replacePolicy == 1) {
        return LFU(cacheIdxBase, assoc);
    }else if(replacePolicy == 2) {
        return LRU(cacheIdxBase, assoc);
    }else if(replacePolicy == 3) {
        return MRU(cacheIdxBase, assoc);
    }
    return -1;
}

#endif /* replace_policy_h */
