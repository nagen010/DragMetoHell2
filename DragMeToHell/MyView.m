//
//  MyView.m
//  DragMeToHell
//
//  Created by Robert Irwin on 2/18/12.
//  Copyright (c) 2012 Robert J. Irwin. All rights reserved.
//

#import "MyView.h"

@implementation MyView

@synthesize dw, dh, row, col, x, y, inMotion, s;

static BOOL flag = NO;
static int rowSet[25] ;
static int colSet[25] ;
int life = 0;

- (id)initWithFrame:(CGRect)frame
{
    NSLog( @"initWithFrame:" );
    return self = [super initWithFrame:frame];
}
// Funciton to Restart the Game
- (void) alertView: (UIAlertView*) alertView didDismissWithButtonIndex:(NSInteger)buttonIndex
{
    flag = NO;
    self.x = 0;
    self.y = 0;
    self.row = 0;
    self.col = 0;
    life = 0;
    
    for (int i=0;i<25;i++)
    {
        rowSet[i]=0;
        colSet[i]=0;
    }
    [self setNeedsDisplay];
    
}

- (void)drawRect:(CGRect)rect
{
    NSLog( @"drawRect:" );
    CGContextRef context = UIGraphicsGetCurrentContext();  // obtain graphics context
    // CGContextScaleCTM( context, 0.5, 0.5 );  // shrink into upper left quadrant
    CGRect bounds = [self bounds];          // get view's location and size
    CGFloat w = CGRectGetWidth( bounds );   // w = width of view (in points)
    CGFloat h = CGRectGetHeight ( bounds ); // h = height of view (in points)
    dw = w/10.0f;                           // dw = width of cell (in points)
    dh = h/10.0f;                           // dh = height of cell (in points)
    
    NSLog( @"view (width,height) = (%g,%g)", w, h );
    NSLog( @"cell (width,height) = (%g,%g)", dw, dh );   
    
    // draw lines to form a 10x10 cell grid
    CGContextBeginPath( context );               // begin collecting drawing operations
    for ( int i = 1;  i < 10;  ++i ) 
    {
        // draw horizontal grid line
        CGContextMoveToPoint( context, 0, i*dh );
        CGContextAddLineToPoint( context, w, i*dh );
    }
    for ( int i = 1;  i < 10;  ++i ) 
    {
        // draw vertical grid line
        CGContextMoveToPoint( context, i*dw, 0 );
        CGContextAddLineToPoint( context, i*dw, h );
    }
    [[UIColor grayColor] setStroke];             // use gray as stroke color
    CGContextDrawPath( context, kCGPathStroke ); // execute collected drawing ops
    
    // establish bounding box for image
    CGPoint tl = self.inMotion ? CGPointMake( x, y )     
                               : CGPointMake( row*dw, col*dh );
    CGRect imageRect = CGRectMake(tl.x, tl.y, dw, dh);

    // place appropriate image where dragging stopped
    UIImage *img;

    if (flag == NO)
    {
        flag = YES;
        
        for (int i=0;i<25;i++)
        {
            rowSet[i]=0;
            colSet[i]=0;
        }
        
        for(int k=0;k<25;k++)
        {
            //Random Number Generator
            int r = arc4random_uniform(9);
            int c = arc4random_uniform(9);
            
            if ((r == 0 || c == 0))
            {
                r = 1;
                c = 1;
            }
            rowSet[k] = r;
            colSet[k] = c;
                
            CGPoint tl =CGPointMake(r, c);
            CGRect imageRect = CGRectMake(tl.x*dw, tl.y*dh, dw, dh);
            NSString *value = [NSString stringWithFormat:@"pic%d",k];
            img = [UIImage imageNamed:value];
            [img drawInRect:imageRect];
        }
    }
    
    else
    {
        for (int i= 0 ;i < 25;i++)
        {
            x = rowSet[i];
            y = colSet[i];
            
            if ((x != 0 && y != 0))
            {
                NSString *value = [NSString stringWithFormat:@"pic%d",i];
                img = [UIImage imageNamed:value];
                
                CGPoint tl =CGPointMake(x, y);
                CGRect imageRect = CGRectMake(tl.x*dw, tl.y*dh, dw, dh);
                if ((life<=3) && (self.row == x && self.col == y))
                {
                    imageRect = CGRectMake((tl.x*dw)-7, (tl.y*dh)-20, dw*1.5, dh*1.5);
                }
                [img drawInRect:imageRect];
            }
        }
    }

    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Game Lost!"
                                                    message:@""
                                                   delegate:self
                                          cancelButtonTitle:@"Restart"
                                          otherButtonTitles:nil];
    
    if (life>3)
    {
        [alert show];
        [self setBackgroundColor: [UIColor cyanColor]];
        [self.backgroundColor setFill];
    }
    
    if ( self.row == 9  &&  self.col == 9 )
    {
        img = [UIImage imageNamed:@"devil1"];
    }
    else
    {
        if (life <= 3)
        {
            if (life==1)
            {
                imageRect = CGRectMake((tl.x)+2, (tl.y)+2, dw/1.2, dh/1.2);
            }
            if (life==2)
            {
                imageRect = CGRectMake((tl.x)+4, (tl.y)+5, dw/1.4, dh/1.4);
            }
            if (life==3)
            {
                imageRect = CGRectMake((tl.x)+8, (tl.y)+12, dw/2, dh/2);
            }
            img = [UIImage imageNamed:@"angel1"];
        }
        else
        {
            //imageRect = CGRectMake((tl.x)+8, (tl.y)+12, dw/2, dh/2);
            //imageRect = CGRectMake(150, 240, dw, dh);
            img = [UIImage imageNamed:@"refresh"];
        }
    }
    [img drawInRect:imageRect];
}



-(void) touchesBegan: (NSSet *) touches withEvent: (UIEvent *) event
{
    int touchRow, touchCol;
    CGPoint xy;
    
    NSLog( @"touchesBegan:withEvent:" );
    [super touchesBegan: touches withEvent: event];
    for ( id t in touches )
    {
        xy = [t locationInView: self];
        self.x = xy.x;  self.y = xy.y;
        touchRow = self.x / self.dw;  touchCol = self.y / self.dh;
        self.inMotion = (self.row == touchRow  &&  self.col == touchCol);
        NSLog( @"touch point (x,y) = (%g,%g)", self.x, self.y );
        NSLog( @"  falls in cell (row,col) = (%d,%d)", touchRow, touchCol );
    }
}

-(void) touchesMoved: (NSSet *) touches withEvent: (UIEvent *) event
{    
    int touchRow, touchCol;
    CGPoint xy;

    NSLog( @"touchesMoved:withEvent:" );
    [super touchesMoved: touches withEvent: event];
    
    for ( id t in touches )
    {
        xy = [t locationInView: self];
        self.x = xy.x;  self.y = xy.y;
        touchRow = self.x / self.dw;  touchCol = self.y / self.dh;
        NSLog( @"touch point (x,y) = (%g,%g)", self.x, self.y );
        NSLog( @"  falls in cell (row,col) = (%d,%d)", touchRow, touchCol );
    }
    
    if ( self.inMotion )
    {
        [self setNeedsDisplay];
    }
}


-(void) touchesEnded: (NSSet *) touches withEvent: (UIEvent *) event
{    
    NSLog( @"touchesEnded:withEvent:" );
    [super touchesEnded: touches withEvent: event];
    if ( self.inMotion )
    {
        int touchRow = 0, touchCol = 0;
        CGPoint xy ;
        
        for ( id t in touches )
        {
            xy = [t locationInView: self];
            self.x = xy.x;  self.y = xy.y;
            touchRow = self.x / self.dw;  touchCol = self.y / self.dh;
            NSLog( @"touch point (x,y) = (%g,%g)", x, y );
            NSLog( @"  falls in cell (row,col) = (%d,%d)", touchRow, touchCol );
        }
        self.inMotion = NO;
        self.row = touchRow;  self.col = touchCol;
        
        for (int i = 0; i <25; i++)
        {
            if (rowSet[i]!=0 && colSet[i] != 0)
            {
                if (self.row == rowSet[i] && self.col == colSet[i])
                {
                    life++;
                    break;
                }
            }
            
        }
    
        if ( self.row == 9  &&  self.col == 9 )
            [self setBackgroundColor: [UIColor redColor]];
        else
            [self setBackgroundColor: [UIColor cyanColor]];
            
        [self setNeedsDisplay];
    }
}


-(void) touchesCancelled: (NSSet *) touches withEvent: (UIEvent *) event
{
    NSLog( @"touchesCancelled:withEvent:" );
    [super touchesCancelled: touches withEvent: event];    
}

@end
