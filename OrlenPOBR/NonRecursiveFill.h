//
//  NonRecursiveFill.h
//  OrlenPOBR
//
//  Created by Tomasz Kuźma on 11-07-05.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#ifndef OrlenPOBR_NonRecursiveFill_h
#define OrlenPOBR_NonRecursiveFill_h



// The following is a rewrite of the seed fill algorithm by Paul Heckbert.

// The original was published in "Graphics Gems", Academic Press, 1990.

//

// I have rewitten it here, so that it matches the other examples

// of seed fill algorithms presented.


extern int nMinX, nMaxX, nMinY, nMaxY;
typedef struct { int x1, x2, y, dy; } LINESEGMENT;

#define MAXDEPTH 10000

#define PUSH(XL, XR, Y, DY) \
if( sp < stack+MAXDEPTH && Y+(DY) >= nMinX && Y+(DY) <= nMaxY ) \
{ sp->xl = XL; sp->xr = XR; sp->y = Y; sp->dy = DY; ++sp; }

#define POP(XL, XR, Y, DY) \
{ --sp; XL = sp->xl; XR = sp->xr; Y = sp->y+(DY = sp->dy); }

// Fill background with given color

void SeedFill_4(int x, int y, COLORREF new_color)
{
    int left, x1, x2, dy;
    COLORREF old_color;
    LINESEGMENT stack[MAXDEPTH], *sp = stack;
    
    old_color = GetPixel(x, y);
    if( old_color == new_color )
        return;
    
    if( x < nMinX || x > nMaxX || y < nMinX || y > nMaxY )
        return;
    
    PUSH(x, x, y, 1);        /* needed in some cases */
    PUSH(x, x, y+1, -1);    /* seed segment (popped 1st) */
    
    while( sp > stack ) {
        POP(x1, x2, y, dy);
        
        for( x = x1; x >= nMinX && GetPixel(x, y) == old_color; --x )
            SetPixel(x, y, new_color);
        
        if( x >= x1 )
            goto SKIP;
        
        left = x+1;
        if( left < x1 )
            PUSH(y, left, x1-1, -dy);    /* leak on left? */
        
        x = x1+1;
        
        do {
            for( ; x<=nMaxX && GetPixel(x, y) == old_color; ++x )
                SetPixel(x, y, new_color);
            
            PUSH(left, x-1, y, dy);
            
            if( x > x2+1 )
                PUSH(x2+1, x-1, y, -dy);    /* leak on right? */
            
        SKIP:        for( ++x; x <= x2 && GetPixel(x, y) != old_color; ++x ) {;}
            
            left = x;
        } while( x<=x2 );
    }
}



#endif
