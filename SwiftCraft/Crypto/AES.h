//
//  AES.h
//  SwiftCraft
//
//  Created by Noah Peeters on 22.05.18.
//  Copyright © 2018 Noah Peeters. All rights reserved.
//

#ifndef AES_h
#define AES_h

#define MODULE_NAME_AES

#define BLOCK_SIZE 16
#define KEY_SIZE 0

#define MAXKC    (256/32)
#define MAXKB    (256/8)
#define MAXNR    14

typedef unsigned char    u8;
typedef unsigned short    u16;
typedef unsigned int    u32;

typedef struct {
    u32 ek[ 4*(MAXNR+1) ];
    u32 dk[ 4*(MAXNR+1) ];
    int rounds;
} block_state;

void block_init(block_state *state, unsigned char *key, int keylen);
void block_encrypt(block_state *self, u8 *in, u8 *out);
void block_decrypt(block_state *self, u8 *in, u8 *out);

#endif /* AES_h */
