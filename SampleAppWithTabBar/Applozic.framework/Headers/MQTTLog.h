//
//  MQTTLog.h
//  MQTTClient
//
//  Created by Christoph Krey on 10.02.16.
//  Copyright © 2016 Christoph Krey. All rights reserved.
//

#ifndef MQTTLog_h

#define MQTTLog_h

#ifdef DEBUG
        #define ALDDLogVerbose NSLog
        #define ALDDLogWarn NSLog
        #define ALDDLogInfo NSLog
        #define ALDDLogError NSLog
    #else
        #define ALDDLogVerbose(...)
        #define ALDDLogWarn(...)
        #define ALDDLogInfo(...)
        #define ALDDLogError(...)
        #endif
#endif /* MQTTLog_h */
