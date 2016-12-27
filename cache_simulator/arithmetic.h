//
//  arithmetic.h
//  cache_simulator
//
//  Created by 龔逸中 on 2016/12/25.
//  Copyright © 2016年 龔逸中. All rights reserved.
//

#ifndef arithmetic_h
#define arithmetic_h

const char *const quads[] = {  "0000", "0001", "0010", "0011", "0100", "0101",
    "0110", "0111", "1000", "1001", "1010", "1011",
    "1100", "1101", "1110", "1111"  };

const char *hex_to_bin_quad(unsigned char c)
{
    if (c >= '0' && c <= '9') return quads[     c - '0'];
    if (c >= 'A' && c <= 'F') return quads[10 + c - 'A'];
    if (c >= 'a' && c <= 'f') return quads[10 + c - 'a'];
    return NULL;
}

int fastPow(int a,int n) {
    int result = 1;
    int power = n;
    int value = a;
    while(power > 0) {
        if(power&1) {
            result = result * value;
            result = result % 1000000007;
        }
        value = value * value;
        value = value % 1000000007;
        power /= 2;
    }
    return result;
}

int binToInt(char *bin, int len) {
    int result = 0;
    for (int i = len - 1; i >= 0; i--) {
        if (bin[(len - 1) - i] == '1') result += fastPow(2, i);
    }
    return result;
}


#endif /* arithmetic_h */
