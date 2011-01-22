//
//  MyTMImageViewController.m
//  TMPuni2
//
//  Created by Toru Inoue on 10/11/28.
//  Copyright 2010 KISSAKI. All rights reserved.
//

#import "MyTMImageViewController.h"



#define PARAM_GRAVITY (0.98)
#define PARAM_MAX_POW (10)
#define PARAM_REDUCE_POW_RATE (0.5)

#define PARAM_FRAMERATE (0.1)

#define PARAM_REBOUND_POW (0.5)

#define PARAM_TOUCHED_TM_SIZE (2.0)

#define PARAM_REDUCE_TM_SIZE_POW (4.0)

#define PARAM_SHOCK_WIDTH_RATE (0.75)
#define PARAM_SHOCK_HEIGHT_RATE (0.95)



@implementation MyTMImageViewController
int m_tm_x_a;

- (void) startTM {
	
	m_defaultTMWidth = m_tm.frame.size.width;
	m_defaultTMHeight = m_tm.frame.size.height;
	
	m_tm_x = m_tm.center.x - m_defaultTMWidth/2;
	m_tm_y = m_tm.center.y - m_defaultTMHeight/2;
	
	[self performSelector:@selector(updateTM) withObject:nil afterDelay:PARAM_FRAMERATE];
}


- (void) updateTM {
	
	m_tm_width = m_tm.frame.size.width;
	m_tm_height = m_tm.frame.size.height;
	
	
	//重力
	m_verticalPow += PARAM_GRAVITY;
	
	
	//下向きの力がデカかったら最大値で切る(空気抵抗?)
	if (PARAM_MAX_POW < m_verticalPow) {
		m_verticalPow = PARAM_MAX_POW;
	}
	
	
	
	//下の限界
	if (self.view.frame.size.height < m_tm.frame.origin.y + m_tm.frame.size.height) {
		m_tm_y = self.view.frame.size.height - m_tm.frame.size.height;
		
		//ぶつかったら力が減衰して反対側に。弾む。
		m_verticalPow = -m_verticalPow * PARAM_REDUCE_POW_RATE;
		
		
		//地面にぶつかったら上下に弾む
		m_tm_height = m_tm_height*PARAM_SHOCK_HEIGHT_RATE;
	}
	
	
	//左右のはみ出し限界、TMさんが左右どっちにより大きくはみ出しているかチェック
	float insertDepth = 0;
	
	if (m_tm.frame.origin.x < 0) {
		insertDepth = m_tm.frame.origin.x;//マイナスのはず
	}
	if (self.view.frame.size.width < m_tm.frame.origin.x + m_tm.frame.size.width)  {
		
		float rightDepth = m_tm.frame.origin.x + m_tm.frame.size.width - self.view.frame.size.width;//プラスのはず
		
		if (0 < rightDepth + insertDepth) {//右にはみ出しているTMさんの部分のほうが、左にはみ出しているTMさんのぶんより大きい
			insertDepth = m_tm.frame.origin.x + m_tm.frame.size.width - self.view.frame.size.width;//プラスのはず
		}
	}
	
	//左により大きくはみ出している
	if (insertDepth < 0) {
		m_tm_x = 0;
				
		//ぶつかったらそれまで持っていた力が減衰して反対側に。弾む。
		m_horizontalPow = -m_horizontalPow * PARAM_REDUCE_POW_RATE;
		
		//リバウンド力を加える
		m_horizontalPow -= insertDepth*PARAM_REBOUND_POW;
	}
	
	//右により大きくはみ出している
	if (0 < insertDepth) {
		m_tm_x = self.view.frame.size.width - m_tm.frame.size.width;
		
		//ぶつかったらそれまで持っていた力が減衰して反対側に。弾む。
		m_horizontalPow = -m_horizontalPow * PARAM_REDUCE_POW_RATE;
		
		//リバウンド力を加える
		m_horizontalPow -= insertDepth*PARAM_REBOUND_POW;
	}
	
	
	//壁にぶつかっていたら左右に弾む
	if (insertDepth != 0) {
		m_tm_width = m_tm_width*PARAM_SHOCK_WIDTH_RATE;
	}
	
	//存在している力で移動
	//m_tm_x += m_horizontalPow;
	m_tm_x += (int) (m_tm_x_a * 100);
	m_tm_y += m_verticalPow;
	
	
	//TMさんのサイズを元に戻します (初期のサイズに収束するような式)
	m_tm_width = m_tm_width + (m_defaultTMWidth - m_tm_width)/PARAM_REDUCE_TM_SIZE_POW;
	m_tm_height = m_tm_height + (m_defaultTMHeight - m_tm_height)/PARAM_REDUCE_TM_SIZE_POW;
	
	
	
	//begin~commitまでの間に書いた現象が、アニメーションとして描画されます
	[UIView beginAnimations:nil context:NULL];
	[UIView setAnimationDuration:PARAM_FRAMERATE];
	[m_tm setFrame:CGRectMake(m_tm_x, m_tm_y, m_tm_width, m_tm_height)];
	[UIView commitAnimations];
	
	
	//PARAM_FRAMERATE秒後、もう一度このメソッドを実行します
	[self performSelector:@selector(updateTM) withObject:nil afterDelay:PARAM_FRAMERATE];
}


/*
 // The designated initializer.  Override if you create the controller programmatically and want to perform customization that is not appropriate for viewDidLoad.
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    if ((self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil])) {
        // Custom initialization
    }
    return self;
}
*/


// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad {
 [[UIAccelerometer sharedAccelerometer] setUpdateInterval:0.1];
 [[UIAccelerometer sharedAccelerometer] setDelegate:self];

    [super viewDidLoad];
}


/*
// Override to allow orientations other than the default portrait orientation.
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}
*/


/**
 タッチが取得できます。
 */
-(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
	//TMさんに対するタッチだったら
	if ([event touchesForView:m_tm]) {
		[self setTMSize:PARAM_TOUCHED_TM_SIZE];
	}
}

/**
 タッチの動きが取得できます。
 */
-(void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event {
	
}


/**
 タッチの離れた瞬間が取得できます。
 */
-(void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event {
	
}




- (void) setTMSize:(float)size {
	[m_tm setFrame:CGRectMake(m_tm.center.x-m_tm.frame.size.width * size/2, 
							  m_tm.center.y-m_tm.frame.size.height * size/2, 
							  m_tm.frame.size.width * size, 
							  m_tm.frame.size.height * size)];
}

- (void)didReceiveMemoryWarning {
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

- (void)viewDidUnload {
    [super viewDidUnload];
	
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}


- (void)dealloc {
    [super dealloc];
}

- (void)accelerometer:(UIAccelerometer *)accelerometer didAccelerate:(UIAcceleration *)acceleration
{
	m_tm_x_a = acceleration.x;
	NSLog([NSString stringWithFormat:@"x:%f",acceleration.x]);
	NSLog([NSString stringWithFormat:@"y:%f",acceleration.y]);
	NSLog([NSString stringWithFormat:@"z:%f",acceleration.z]);
	
}
	


@end
