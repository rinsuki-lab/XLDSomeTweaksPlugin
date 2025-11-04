//
//  Bridge.h
//  XLDSomeTweaksPlugin
//
//  Created by user on 2025/11/04.
//

#import <XLD/XLD_Prefix.pch>
#import <XLD/XLDDiscView.h>
#import <XLD/XLDController.h>
#import <XLD/XLDCueParser.h>
#import <XLD/XLDTrack.h>

@interface XLDController (Private)
- (void)cddbGetTracksWithAutoStart:(BOOL)start isManualQuery:(BOOL)manualQuery;
@end

@protocol XLDCDDBUtilProtocol <NSObject>
- (instancetype)initWithDelegate:(id)del;
- (void)setTracks:(NSArray *)tracks totalFrame:(int)frames;
- (XLDCDDBResult)readCDDBWithInfo:(NSArray *)info;
@end

@protocol XLDTrackProtocol <NSObject>
- (xldoffset_t)index;
- (xldoffset_t)frames;
- (NSDictionary*)metadata;
@end

@protocol XLDCueParserProtocol <NSObject>
- (NSArray<id<XLDTrackProtocol>> *)trackList;
- (xldoffset_t)totalFrames;
@end
