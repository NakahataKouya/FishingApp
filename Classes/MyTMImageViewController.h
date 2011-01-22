//
//  MyTMImageViewController.h
//  TMPuni2
//
//  Created by Toru Inoue on 10/11/28.
//  Copyright 2010 KISSAKI. All rights reserved.
//

#import <UIKit/UIKit.h>

/**
 TMをぷにぷにするアプリの、特に大事な
 TMのコントロールを行うクラスです。
 
 やさしくしてね！
 */

@interface MyTMImageViewController : UIViewController <UIAccelerometerDelegate> {
	IBOutlet UILabel *lbl;
	BOOL shaking;

	IBOutlet UIImageView * m_tm;
	
	//TMさんのXとY位置
	float m_tm_x;
	float m_tm_y;
	
	
	//TMさんにかかるパワー
	float m_horizontalPow;
	float m_verticalPow;
	
	
	//TMさんの幅
	float m_tm_width;
	float m_tm_height;
	
	
	//TMさんのもともとの大きさ
	float m_defaultTMWidth;
	float m_defaultTMHeight;
	

	
	
}

/**
 TMさんのアニメーションを開始します
 */
- (void) startTM;

/**
 TMさんの位置やサイズを更新します。
 */
- (void) updateTM;


/**
 TMさんのサイズが変わります。
 */
- (void) setTMSize:(float)size;

- (void)accelerometer:(UIAccelerometer *)accelerometer didAccelerate:(UIAcceleration *)acceleration;



@end
