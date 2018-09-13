//
//  WTAVPlayer.h
//  WTAVPlayerView
//
//  Created by 吕成翘 on 2017/10/11.
//  Copyright © 2017年 Weitac. All rights reserved.
//

#ifndef WTAVPlayer_h
#define WTAVPlayer_h

#define WTAVPlayerViewSrcName(file) [@"WTAVPlayerView.bundle" stringByAppendingPathComponent:file]
#define WTAVPlayerViewFrameworkSrcName(file) [@"Frameworks/WTAVPlayer.framework/WTAVPlayerView.bundle" stringByAppendingPathComponent:file]
#define WTAVPlayerViewImage(file) [UIImage imageNamed:WTAVPlayerViewSrcName(file)] ? :[UIImage imageNamed:WTAVPlayerViewFrameworkSrcName(file)]

#endif /* WTAVPlayer_h */
