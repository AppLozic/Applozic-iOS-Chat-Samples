//
// MQTTCFSocketEncoder.m
// MQTTClient.framework
//
// Copyright © 2013-2016, Christoph Krey
//

#import "MQTTCFSocketEncoder.h"

#import "MQTTLog.h"

@interface MQTTCFSocketEncoder()
@property (strong, nonatomic) NSMutableData *buffer;

@end

@implementation MQTTCFSocketEncoder

- (instancetype)init {
    self = [super init];
    self.state = MQTTCFSocketEncoderStateInitializing;
    self.buffer = [[NSMutableData alloc] init];
    
    self.stream = nil;
    self.runLoop = [NSRunLoop currentRunLoop];
    self.runLoopMode = NSRunLoopCommonModes;
    
    return self;
}

- (void)dealloc {
    [self close];
}

- (void)open {
    [self.stream setDelegate:self];
    [self.stream scheduleInRunLoop:self.runLoop forMode:self.runLoopMode];
    [self.stream open];
}

- (void)close {
    [self.stream close];
    [self.stream removeFromRunLoop:self.runLoop forMode:self.runLoopMode];
    [self.stream setDelegate:nil];
}

- (void)setState:(MQTTCFSocketEncoderState)state {
    ALDDLogVerbose(@"[MQTTCFSocketEncoder] setState %ld/%ld", (long)_state, (long)state);
    _state = state;
}

- (void)stream:(NSStream*)sender handleEvent:(NSStreamEvent)eventCode {
    
    if (eventCode & NSStreamEventOpenCompleted) {
        ALDDLogVerbose(@"[MQTTCFSocketEncoder] NSStreamEventOpenCompleted");

    }
    if (eventCode & NSStreamEventHasBytesAvailable) {
        ALDDLogVerbose(@"[MQTTCFSocketEncoder] NSStreamEventHasBytesAvailable");
    }
    
    if (eventCode & NSStreamEventHasSpaceAvailable) {
        ALDDLogVerbose(@"[MQTTCFSocketEncoder] NSStreamEventHasSpaceAvailable");
        if (self.state == MQTTCFSocketEncoderStateInitializing) {
            self.state = MQTTCFSocketEncoderStateReady;
            [self.delegate encoderDidOpen:self];
        }
        
        if (self.state == MQTTCFSocketEncoderStateReady) {
            if (self.buffer.length) {
                [self send:nil];
            }
        }
    }
    
    if (eventCode &  NSStreamEventEndEncountered) {
        ALDDLogVerbose(@"[MQTTCFSocketEncoder] NSStreamEventEndEncountered");
        self.state = MQTTCFSocketEncoderStateInitializing;
        self.error = nil;
        [self.delegate encoderdidClose:self];
    }
    
    if (eventCode &  NSStreamEventErrorOccurred) {
        ALDDLogVerbose(@"[MQTTCFSocketEncoder] NSStreamEventErrorOccurred");
        self.state = MQTTCFSocketEncoderStateError;
        self.error = self.stream.streamError;
        [self.delegate encoder:self didFailWithError:self.error];
    }
}

- (BOOL)send:(NSData *)data {
    @synchronized(self) {
        if (self.state != MQTTCFSocketEncoderStateReady) {
            ALDDLogInfo(@"[MQTTCFSocketEncoder] not MQTTCFSocketEncoderStateReady");
            return FALSE;
        }
        
        if (data) {
            [self.buffer appendData:data];
        }
        
        if (self.buffer.length) {
            ALDDLogVerbose(@"[MQTTCFSocketEncoder] buffer to write (%lu)=%@...",
                         (unsigned long)self.buffer.length,
                         [self.buffer subdataWithRange:NSMakeRange(0, MIN(256, self.buffer.length))]);
            
            NSInteger n = [self.stream write:self.buffer.bytes maxLength:self.buffer.length];
            
            if (n == -1) {
                ALDDLogVerbose(@"[MQTTCFSocketEncoder] streamError: %@", self.error);
                self.state = MQTTCFSocketEncoderStateError;
                self.error = self.stream.streamError;
                return FALSE;
            } else {
                if (n < self.buffer.length) {
                    ALDDLogVerbose(@"[MQTTCFSocketEncoder] buffer partially written: %ld", (long)n);
                }
                [self.buffer replaceBytesInRange:NSMakeRange(0, n) withBytes:NULL length:0];
            }
        }
        return TRUE;
    }
}

@end
