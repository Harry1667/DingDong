-------------------------------------
Translated Report (Full Report Below)
-------------------------------------
Process:             DingDong [21054]
Path:                /Users/USER/Library/Developer/CoreSimulator/Devices/23D3538E-995E-4C6E-87E0-57C9DB4AB84E/data/Containers/Bundle/Application/7A559C59-0AF3-4B32-85E9-03DB34E9212F/DingDong.app/DingDong
Identifier:          com.ajz.dingdong
Version:             1.0.0 (1)
Code Type:           ARM-64 (Native)
Role:                Foreground
Parent Process:      launchd_sim [19899]
Coalition:           com.apple.CoreSimulator.SimDevice.23D3538E-995E-4C6E-87E0-57C9DB4AB84E [3008]
Responsible Process: SimulatorTrampoline [2153]
User ID:             501

Date/Time:           2026-05-15 15:59:15.5866 +0800
Launch Time:         2026-05-15 15:58:59.7481 +0800
Hardware Model:      Macmini9,1
OS Version:          macOS 26.3 (25D125)
Release Type:        User

Crash Reporter Key:  60EB8E1D-85B2-0095-8042-A678A9CC4889
Incident Identifier: E765D67E-3851-4E91-9C48-ED06D22CCE6F

Time Awake Since Boot: 9500 seconds

System Integrity Protection: enabled

Triggered by Thread: 0, Dispatch Queue: com.apple.main-thread

Exception Type:    EXC_CRASH (SIGABRT)
Exception Codes:   0x0000000000000000, 0x0000000000000000

Termination Reason:  Namespace SIGNAL, Code 6, Abort trap: 6
Terminating Process: DingDong [21054]


Last Exception Backtrace:
0   CoreFoundation                	       0x1804f39dc __exceptionPreprocess + 160
1   libobjc.A.dylib               	       0x18009c084 objc_exception_throw + 72
2   CoreFoundation                	       0x1804f38f8 -[NSException initWithCoder:] + 0
3   AVFAudio                      	       0x1d221c630 AVAudioEngineGraph::Initialize(NSError**) + 500
4   AVFAudio                      	       0x1d22cce28 AVAudioEngineImpl::Initialize(NSError**) + 228
5   AVFAudio                      	       0x1d22c48f4 -[AVAudioEngine startAndReturnError:] + 308
6   DingDong.debug.dylib          	       0x1053f3d44 SoundService.play(_:) + 788 (SoundService.swift:49)
7   DingDong.debug.dylib          	       0x1053f44d0 SoundService.send() + 172 (SoundService.swift:26)
8   DingDong.debug.dylib          	       0x1054498fc closure #4 in closure #1 in TrackingSetupView.keypad.getter + 188 (TrackingSetupView.swift:165)
9   SwiftUI                       	       0x1d8e05358 <deduplicated_symbol> + 24
10  SwiftUI                       	       0x1d9536624 specialized static MainActor.assumeIsolated<A>(_:file:line:) + 132
11  SwiftUI                       	       0x1d95014e8 ButtonAction.callAsFunction() + 388
12  SwiftUI                       	       0x1d87c55f0 <deduplicated_symbol> + 52
13  SwiftUI                       	       0x1d8d9cd94 ButtonBehavior.ended() + 224
14  SwiftUI                       	       0x1d8da2800 partial apply for implicit closure #2 in implicit closure #1 in ButtonBehavior.body.getter + 32
15  SwiftUI                       	       0x1d94adf34 partial apply for closure #1 in closure #2 in closure #1 in _ButtonGesture.internalBody.getter + 28
16  SwiftUI                       	       0x1d9536624 specialized static MainActor.assumeIsolated<A>(_:file:line:) + 132
17  SwiftUI                       	       0x1d94a9174 closure #2 in closure #1 in _ButtonGesture.internalBody.getter + 80
18  SwiftUI                       	       0x1d94af0c4 partial apply for closure #2 in PrimitiveButtonGestureCallbacks.dispatch(phase:state:) + 84
19  SwiftUICore                   	       0x1d9983484 <deduplicated_symbol> + 20
20  SwiftUICore                   	       0x1d9983484 <deduplicated_symbol> + 20
21  SwiftUI                       	       0x1d899db48 <deduplicated_symbol> + 20
22  SwiftUI                       	       0x1d8c515e4 <deduplicated_symbol> + 44
23  SwiftUICore                   	       0x1d9d9d5a4 static Update.dispatchActions() + 1092
24  SwiftUICore                   	       0x1d9d9c5fc static Update.end() + 124
25  SwiftUICore                   	       0x1d9d9c334 static Update.enqueueAction(reason:_:) + 188
26  SwiftUI                       	       0x1d9062318 UIKitResponderEventBindingBridge.flushActions() + 400
27  SwiftUI                       	       0x1d9062374 @objc UIKitResponderEventBindingBridge.flushActions() + 24
28  UIKitCore                     	       0x185d408ec -[UIGestureRecognizerTarget _sendActionWithGestureRecognizer:] + 76
29  UIKitCore                     	       0x185d499ec _UIGestureRecognizerSendTargetActions + 88
30  UIKitCore                     	       0x185d46760 _UIGestureRecognizerSendActions + 296
31  UIKitCore                     	       0x185d46324 -[UIGestureRecognizer _updateGestureForActiveEvents] + 320
32  UIKitCore                     	       0x185d4af30 -[UIGestureRecognizer gestureNode:didUpdatePhase:] + 296
33  Gestures                      	       0x22efc764c 0x22efbb000 + 50764
34  Gestures                      	       0x22efe4858 0x22efbb000 + 170072
35  Gestures                      	       0x22f00f0ac 0x22efbb000 + 344236
36  Gestures                      	       0x22f03690c 0x22efbb000 + 506124
37  UIKitCore                     	       0x185d37e18 -[UIGestureEnvironment _updateForEvent:window:] + 468
38  UIKitCore                     	       0x18629b3d4 -[UIWindow sendEvent:] + 2796
39  UIKitCore                     	       0x186279714 -[UIApplication sendEvent:] + 376
40  UIKitCore                     	       0x18630dc6c __dispatchPreprocessedEventFromEventQueue + 1184
41  UIKitCore                     	       0x186310920 __processEventQueue + 4800
42  UIKitCore                     	       0x186308ecc updateCycleEntry + 168
43  UIKitCore                     	       0x185773878 _UIUpdateSequenceRunNext + 120
44  UIKitCore                     	       0x18617ec90 schedulerStepScheduledMainSectionContinue + 56
45  UpdateCycle                   	       0x25094e2b4 UC::DriverCore::continueProcessing() + 80
46  CoreFoundation                	       0x1804114ac __CFMachPortPerform + 164
47  CoreFoundation                	       0x18044dbe0 __CFRUNLOOP_IS_CALLING_OUT_TO_A_SOURCE1_PERFORM_FUNCTION__ + 56
48  CoreFoundation                	       0x18044d1f8 __CFRunLoopDoSource1 + 480
49  CoreFoundation                	       0x18044c2c0 __CFRunLoopRun + 2100
50  CoreFoundation                	       0x180446e24 _CFRunLoopRunSpecificWithOptions + 496
51  GraphicsServices              	       0x1925319bc GSEventRunModal + 116
52  UIKitCore                     	       0x18625fc3c -[UIApplication _run] + 772
53  UIKitCore                     	       0x186263e64 UIApplicationMain + 124
54  SwiftUI                       	       0x1d8ec523c closure #1 in KitRendererCommon(_:) + 164
55  SwiftUI                       	       0x1d8ec4f84 runApp<A>(_:) + 180
56  SwiftUI                       	       0x1d8c4e9cc static App.main() + 148
57  DingDong.debug.dylib          	       0x10530d110 static DingDongApp.$main() + 40
58  DingDong.debug.dylib          	       0x10530f328 __debug_main_executable_dylib_entry_point + 12
59  ???                           	       0x104b393d0 ???
60  dyld                          	       0x104970d54 start + 7184

Thread 0 Crashed::  Dispatch queue: com.apple.main-thread
0   libsystem_kernel.dylib        	       0x104d4885c __pthread_kill + 8
1   libsystem_pthread.dylib       	       0x104aa22a8 pthread_kill + 264
2   libsystem_c.dylib             	       0x1801ad950 abort + 100
3   libc++abi.dylib               	       0x1802fa26c __abort_message + 128
4   libc++abi.dylib               	       0x1802ea1a4 demangling_terminate_handler() + 268
5   libobjc.A.dylib               	       0x180077218 _objc_terminate() + 124
6   libc++abi.dylib               	       0x1802f9758 std::__terminate(void (*)()) + 12
7   libc++abi.dylib               	       0x1802fc7c0 __cxxabiv1::failed_throw(__cxxabiv1::__cxa_exception*) + 32
8   libc++abi.dylib               	       0x1802fc7a0 __cxa_throw + 88
9   libobjc.A.dylib               	       0x18009c1bc objc_exception_throw + 384
10  CoreFoundation                	       0x1804f38f8 +[NSException raise:format:] + 124
11  AVFAudio                      	       0x1d221c630 AVAudioEngineGraph::Initialize(NSError**) + 500
12  AVFAudio                      	       0x1d22cce28 AVAudioEngineImpl::Initialize(NSError**) + 228
13  AVFAudio                      	       0x1d22c48f4 -[AVAudioEngine startAndReturnError:] + 308
14  DingDong.debug.dylib          	       0x1053f3d44 SoundService.play(_:) + 788 (SoundService.swift:49)
15  DingDong.debug.dylib          	       0x1053f44d0 SoundService.send() + 172 (SoundService.swift:26)
16  DingDong.debug.dylib          	       0x1054498fc closure #4 in closure #1 in TrackingSetupView.keypad.getter + 188 (TrackingSetupView.swift:165)
17  SwiftUI                       	       0x1d8e05358 <deduplicated_symbol> + 24
18  SwiftUI                       	       0x1d9536624 specialized static MainActor.assumeIsolated<A>(_:file:line:) + 132
19  SwiftUI                       	       0x1d95014e8 ButtonAction.callAsFunction() + 388
20  SwiftUI                       	       0x1d87c55f0 <deduplicated_symbol> + 52
21  SwiftUI                       	       0x1d8d9cd94 ButtonBehavior.ended() + 224
22  SwiftUI                       	       0x1d8da2800 partial apply for implicit closure #2 in implicit closure #1 in ButtonBehavior.body.getter + 32
23  SwiftUI                       	       0x1d94adf34 partial apply for closure #1 in closure #2 in closure #1 in _ButtonGesture.internalBody.getter + 28
24  SwiftUI                       	       0x1d9536624 specialized static MainActor.assumeIsolated<A>(_:file:line:) + 132
25  SwiftUI                       	       0x1d94a9174 closure #2 in closure #1 in _ButtonGesture.internalBody.getter + 80
26  SwiftUI                       	       0x1d94af0c4 partial apply for closure #2 in PrimitiveButtonGestureCallbacks.dispatch(phase:state:) + 84
27  SwiftUICore                   	       0x1d9983484 <deduplicated_symbol> + 20
28  SwiftUICore                   	       0x1d9983484 <deduplicated_symbol> + 20
29  SwiftUI                       	       0x1d899db48 <deduplicated_symbol> + 20
30  SwiftUI                       	       0x1d8c515e4 <deduplicated_symbol> + 44
31  SwiftUICore                   	       0x1d9d9d5a4 static Update.dispatchActions() + 1092
32  SwiftUICore                   	       0x1d9d9c5fc static Update.end() + 124
33  SwiftUICore                   	       0x1d9d9c334 static Update.enqueueAction(reason:_:) + 188
34  SwiftUI                       	       0x1d9062318 UIKitResponderEventBindingBridge.flushActions() + 400
35  SwiftUI                       	       0x1d9062374 @objc UIKitResponderEventBindingBridge.flushActions() + 24
36  UIKitCore                     	       0x185d408ec -[UIGestureRecognizerTarget _sendActionWithGestureRecognizer:] + 76
37  UIKitCore                     	       0x185d499ec _UIGestureRecognizerSendTargetActions + 88
38  UIKitCore                     	       0x185d46760 _UIGestureRecognizerSendActions + 296
39  UIKitCore                     	       0x185d46324 -[UIGestureRecognizer _updateGestureForActiveEvents] + 320
40  UIKitCore                     	       0x185d4af30 -[UIGestureRecognizer gestureNode:didUpdatePhase:] + 296
41  Gestures                      	       0x22efc764c 0x22efbb000 + 50764
42  Gestures                      	       0x22efe4858 0x22efbb000 + 170072
43  Gestures                      	       0x22f00f0ac 0x22efbb000 + 344236
44  Gestures                      	       0x22f03690c 0x22efbb000 + 506124
45  UIKitCore                     	       0x185d37e18 -[UIGestureEnvironment _updateForEvent:window:] + 468
46  UIKitCore                     	       0x18629b3d4 -[UIWindow sendEvent:] + 2796
47  UIKitCore                     	       0x186279714 -[UIApplication sendEvent:] + 376
48  UIKitCore                     	       0x18630dc6c __dispatchPreprocessedEventFromEventQueue + 1184
49  UIKitCore                     	       0x186310920 __processEventQueue + 4800
50  UIKitCore                     	       0x186308ecc updateCycleEntry + 168
51  UIKitCore                     	       0x185773878 _UIUpdateSequenceRunNext + 120
52  UIKitCore                     	       0x18617ec90 schedulerStepScheduledMainSectionContinue + 56
53  UpdateCycle                   	       0x25094e2b4 UC::DriverCore::continueProcessing() + 80
54  CoreFoundation                	       0x1804114ac __CFMachPortPerform + 164
55  CoreFoundation                	       0x18044dbe0 __CFRUNLOOP_IS_CALLING_OUT_TO_A_SOURCE1_PERFORM_FUNCTION__ + 56
56  CoreFoundation                	       0x18044d1f8 __CFRunLoopDoSource1 + 480
57  CoreFoundation                	       0x18044c2c0 __CFRunLoopRun + 2100
58  CoreFoundation                	       0x180446e24 _CFRunLoopRunSpecificWithOptions + 496
59  GraphicsServices              	       0x1925319bc GSEventRunModal + 116
60  UIKitCore                     	       0x18625fc3c -[UIApplication _run] + 772
61  UIKitCore                     	       0x186263e64 UIApplicationMain + 124
62  SwiftUI                       	       0x1d8ec523c closure #1 in KitRendererCommon(_:) + 164
63  SwiftUI                       	       0x1d8ec4f84 runApp<A>(_:) + 180
64  SwiftUI                       	       0x1d8c4e9cc static App.main() + 148
65  DingDong.debug.dylib          	       0x10530d110 static DingDongApp.$main() + 40
66  DingDong.debug.dylib          	       0x10530f328 __debug_main_executable_dylib_entry_point + 12
67  ???                           	       0x104b393d0 ???
68  dyld                          	       0x104970d54 start + 7184

Thread 1:: com.apple.uikit.eventfetch-thread
0   libsystem_kernel.dylib        	       0x104d40b70 mach_msg2_trap + 8
1   libsystem_kernel.dylib        	       0x104d5190c mach_msg2_internal + 72
2   libsystem_kernel.dylib        	       0x104d48c10 mach_msg_overwrite + 480
3   libsystem_kernel.dylib        	       0x104d40ee4 mach_msg + 20
4   CoreFoundation                	       0x18044cd3c __CFRunLoopServiceMachPort + 156
5   CoreFoundation                	       0x18044bef4 __CFRunLoopRun + 1128
6   CoreFoundation                	       0x180446e24 _CFRunLoopRunSpecificWithOptions + 496
7   Foundation                    	       0x1810f1cac -[NSRunLoop(NSRunLoop) runMode:beforeDate:] + 208
8   Foundation                    	       0x1810f1ecc -[NSRunLoop(NSRunLoop) runUntilDate:] + 60
9   UIKitCore                     	       0x1863170f8 -[UIEventFetcher threadMain] + 392
10  Foundation                    	       0x181118b78 __NSThread__start__ + 716
11  libsystem_pthread.dylib       	       0x104aa25ac _pthread_start + 104
12  libsystem_pthread.dylib       	       0x104a9d998 thread_start + 8

Thread 2:

Thread 3:: com.apple.UIKit.inProcessAnimationManager
0   libsystem_kernel.dylib        	       0x104d40aec semaphore_wait_trap + 8
1   libdispatch.dylib             	       0x1801ba258 _dispatch_sema4_wait + 24
2   libdispatch.dylib             	       0x1801ba7e0 _dispatch_semaphore_wait_slow + 128
3   UIKitCore                     	       0x1855ab434 0x185156000 + 4543540
4   UIKitCore                     	       0x1855af980 0x185156000 + 4561280
5   UIKitCore                     	       0x185192ee0 0x185156000 + 249568
6   Foundation                    	       0x181118b78 __NSThread__start__ + 716
7   libsystem_pthread.dylib       	       0x104aa25ac _pthread_start + 104
8   libsystem_pthread.dylib       	       0x104a9d998 thread_start + 8

Thread 4:

Thread 5:: com.apple.SwiftUI.AsyncRenderer
0   libsystem_kernel.dylib        	       0x104d40b70 mach_msg2_trap + 8
1   libsystem_kernel.dylib        	       0x104d5190c mach_msg2_internal + 72
2   libsystem_kernel.dylib        	       0x104d48c10 mach_msg_overwrite + 480
3   libsystem_kernel.dylib        	       0x104d40ee4 mach_msg + 20
4   CoreFoundation                	       0x18044cd3c __CFRunLoopServiceMachPort + 156
5   CoreFoundation                	       0x18044bef4 __CFRunLoopRun + 1128
6   CoreFoundation                	       0x180446e24 _CFRunLoopRunSpecificWithOptions + 496
7   Foundation                    	       0x1810f1cac -[NSRunLoop(NSRunLoop) runMode:beforeDate:] + 208
8   Foundation                    	       0x1810f1e7c -[NSRunLoop(NSRunLoop) run] + 60
9   SwiftUICore                   	       0x1d9aeb8b4 specialized static ViewGraphDisplayLink.asyncThread(arg:) + 492
10  SwiftUICore                   	       0x1d9aea888 @objc static ViewGraphDisplayLink.asyncThread(arg:) + 68
11  Foundation                    	       0x181118b78 __NSThread__start__ + 716
12  libsystem_pthread.dylib       	       0x104aa25ac _pthread_start + 104
13  libsystem_pthread.dylib       	       0x104a9d998 thread_start + 8

Thread 6:: caulk.messenger.shared:17
0   libsystem_kernel.dylib        	       0x104d40aec semaphore_wait_trap + 8
1   caulk                         	       0x1b9f18cb0 caulk::semaphore::timed_wait(double) + 220
2   caulk                         	       0x1b9f20994 caulk::concurrent::details::worker_thread::run() + 28
3   caulk                         	       0x1b9f20a08 void* caulk::thread_proxy<std::__1::tuple<caulk::thread::attributes, void (caulk::concurrent::details::worker_thread::*)(), std::__1::tuple<caulk::concurrent::details::worker_thread*>>>(void*) + 48
4   libsystem_pthread.dylib       	       0x104aa25ac _pthread_start + 104
5   libsystem_pthread.dylib       	       0x104a9d998 thread_start + 8

Thread 7:: caulk.messenger.shared:high
0   libsystem_kernel.dylib        	       0x104d40aec semaphore_wait_trap + 8
1   caulk                         	       0x1b9f18cb0 caulk::semaphore::timed_wait(double) + 220
2   caulk                         	       0x1b9f20994 caulk::concurrent::details::worker_thread::run() + 28
3   caulk                         	       0x1b9f20a08 void* caulk::thread_proxy<std::__1::tuple<caulk::thread::attributes, void (caulk::concurrent::details::worker_thread::*)(), std::__1::tuple<caulk::concurrent::details::worker_thread*>>>(void*) + 48
4   libsystem_pthread.dylib       	       0x104aa25ac _pthread_start + 104
5   libsystem_pthread.dylib       	       0x104a9d998 thread_start + 8


Thread 0 crashed with ARM Thread State (64-bit):
    x0: 0x0000000000000000   x1: 0x0000000000000000   x2: 0x0000000000000000   x3: 0x0000000000000000
    x4: 0x00000001802fdcab   x5: 0x000000016b4b7fa0   x6: 0x000000000000006e   x7: 0x0000000000000000
    x8: 0x0000000104a15e40   x9: 0x73fb572eb94293a0  x10: 0x0000000000000051  x11: 0x000000000000000b
   x12: 0x000000000000000b  x13: 0x00000001807150d4  x14: 0x00000000000007fb  x15: 0x00000000fda01069
   x16: 0x0000000000000148  x17: 0x00000000fdc00868  x18: 0x0000000000000000  x19: 0x0000000000000006
   x20: 0x0000000000000103  x21: 0x0000000104a15f20  x22: 0x00000001f29bb000  x23: 0x0000000000000000
   x24: 0x00000001d22f0b2e  x25: 0x00000002635cbcd8  x26: 0x0000000000000000  x27: 0x000060000375a040
   x28: 0x000000016b4b9770   fp: 0x000000016b4b7f10   lr: 0x0000000104aa22a8
    sp: 0x000000016b4b7ef0   pc: 0x0000000104d4885c cpsr: 0x40001000
   far: 0x0000000000000000  esr: 0x56000080 (Syscall)

Binary Images:
       0x104968000 -        0x104a07fff dyld (*) <bc4db5f4-1c64-3706-8006-73b78c3e1f1a> /usr/lib/dyld
       0x104940000 -        0x104943fff com.ajz.dingdong (1.0.0) <7f624f77-fe9f-3c8d-8eca-d4b5ebfe03e9> /Users/USER/Library/Developer/CoreSimulator/Devices/23D3538E-995E-4C6E-87E0-57C9DB4AB84E/data/Containers/Bundle/Application/7A559C59-0AF3-4B32-85E9-03DB34E9212F/DingDong.app/DingDong
       0x1052d0000 -        0x1054bffff DingDong.debug.dylib (*) <d286b99c-b213-3ace-867b-24449dfb1827> /Users/USER/Library/Developer/CoreSimulator/Devices/23D3538E-995E-4C6E-87E0-57C9DB4AB84E/data/Containers/Bundle/Application/7A559C59-0AF3-4B32-85E9-03DB34E9212F/DingDong.app/DingDong.debug.dylib
       0x104b00000 -        0x104b07fff libsystem_platform.dylib (*) <9463fc06-cc7c-38e8-ad3c-1b9f2617df53> /usr/lib/system/libsystem_platform.dylib
       0x104d40000 -        0x104d7bfff libsystem_kernel.dylib (*) <1a15cc38-efcc-34ea-a261-cfd370f4b557> /usr/lib/system/libsystem_kernel.dylib
       0x104a9c000 -        0x104aabfff libsystem_pthread.dylib (*) <b1095734-2a4d-3e8c-839e-b10ae9598d61> /usr/lib/system/libsystem_pthread.dylib
       0x104d04000 -        0x104d0ffff libobjc-trampolines.dylib (*) <78c22921-6ad3-3681-bedb-525a69493719> /Volumes/VOLUME/*/libobjc-trampolines.dylib
       0x180139000 -        0x1801b627b libsystem_c.dylib (*) <d591507f-069e-335b-a3ba-95dbac2e9dfa> /Volumes/VOLUME/*/libsystem_c.dylib
       0x1802e9000 -        0x18030156f libc++abi.dylib (*) <5b496e0d-c60f-38e4-8d0a-0e27ad32b14a> /Volumes/VOLUME/*/libc++abi.dylib
       0x180070000 -        0x1800ad287 libobjc.A.dylib (*) <99860b81-03a1-3f42-a755-321cc0032934> /Volumes/VOLUME/*/libobjc.A.dylib
       0x1803ba000 -        0x1807dae3f com.apple.CoreFoundation (6.9) <7b44bd11-eb8c-337a-82fc-b81c10bd0b15> /Volumes/VOLUME/*/CoreFoundation.framework/CoreFoundation
       0x1d21d9000 -        0x1d232b07f com.apple.audio.AVFAudio (1.0) <38197aa2-28c6-364e-bcf2-f8220f74c69d> /Volumes/VOLUME/*/AVFAudio.framework/AVFAudio
       0x1d870f000 -        0x1d98bfe5f com.apple.SwiftUI (7.0.84.1.107) <2619b103-235a-3b1b-85f0-f29b4ebaeea4> /Volumes/VOLUME/*/SwiftUI.framework/SwiftUI
       0x1d98c0000 -        0x1da59d1bf com.apple.SwiftUICore (7.0.84.1.107) <455f824b-23c8-3df5-8e3a-4ad267868f23> /Volumes/VOLUME/*/SwiftUICore.framework/SwiftUICore
       0x185156000 -        0x1872d0b5f com.apple.UIKitCore (1.0) <718bdf15-89c6-3901-9eac-98ea2b8dc1bd> /Volumes/VOLUME/*/UIKitCore.framework/UIKitCore
       0x22efbb000 -        0x22f064b20 com.apple.Gestures (9088) <aa7518df-7242-3400-9458-362536e6291d> /Volumes/VOLUME/*/Gestures.framework/Gestures
       0x25094d000 -        0x25094ee9f com.apple.UpdateCycle (1) <fc49003c-75a7-3db2-84ca-8076eef1d8a7> /Volumes/VOLUME/*/UpdateCycle.framework/UpdateCycle
       0x19252f000 -        0x192536dbf com.apple.GraphicsServices (1.0) <02f377dd-50ff-356a-bcea-2c061ebe5045> /Volumes/VOLUME/*/GraphicsServices.framework/GraphicsServices
               0x0 - 0xffffffffffffffff ??? (*) <00000000-0000-0000-0000-000000000000> ???
       0x18085a000 -        0x1815b48ff com.apple.Foundation (6.9) <0525cd9f-cd95-31fe-856c-939c0851eb23> /Volumes/VOLUME/*/Foundation.framework/Foundation
       0x1801b7000 -        0x1801fc1bf libdispatch.dylib (*) <e4af9b0e-70f1-369d-8dd1-f07b9754834b> /Volumes/VOLUME/*/libdispatch.dylib
       0x1b9f09000 -        0x1b9f2f5bf com.apple.audio.caulk (1.0) <1057119c-e0f5-37a6-9854-c822458d76b8> /Volumes/VOLUME/*/caulk.framework/caulk

External Modification Summary:
  Calls made by other processes targeting this process:
    task_for_pid: 0
    thread_create: 0
    thread_set_state: 0
  Calls made by this process:
    task_for_pid: 0
    thread_create: 0
    thread_set_state: 0
  Calls made by all processes on this machine:
    task_for_pid: 4
    thread_create: 0
    thread_set_state: 42

VM Region Summary:
ReadOnly portion of Libraries: Total=1.5G resident=0K(0%) swapped_out_or_unallocated=1.5G(100%)
Writable regions: Total=696.9M written=2200K(0%) resident=2200K(0%) swapped_out=0K(0%) unallocated=694.8M(100%)

                                VIRTUAL   REGION 
REGION TYPE                        SIZE    COUNT (non-coalesced) 
===========                     =======  ======= 
Activity Tracing                   256K        1 
AttributeGraph Data               1024K        1 
CG raster data                    1536K        6 
ColorSync                          256K       12 
CoreAnimation                     3280K      136 
Foundation                          16K        1 
IOSurface                         8320K        3 
Kernel Alloc Once                   32K        1 
MALLOC                           666.0M       77 
MALLOC guard page                  192K       12 
SQLite page cache                  384K        3 
STACK GUARD                       56.1M        8 
Stack                             11.7M        8 
VM_ALLOCATE                       3360K        9 
__DATA                            28.2M      686 
__DATA_CONST                      86.1M      710 
__DATA_DIRTY                       139K       13 
__FONT_DATA                        2352        1 
__LINKEDIT                       704.8M        8 
__LLVM_COV                          48K        1 
__OBJC_RO                         62.5M        1 
__OBJC_RW                         2768K        1 
__TEXT                           797.0M      723 
__TPRO_CONST                       148K        2 
dyld private memory                2.1G       17 
mapped file                      425.2M       40 
page table in kernel              2200K        1 
shared memory                     1040K        2 
===========                     =======  ======= 
TOTAL                              4.9G     2484 


-----------
Full Report
-----------

{"app_name":"DingDong","timestamp":"2026-05-15 15:59:21.00 +0800","app_version":"1.0.0","slice_uuid":"7f624f77-fe9f-3c8d-8eca-d4b5ebfe03e9","build_version":"1","platform":7,"bundleID":"com.ajz.dingdong","share_with_app_devs":0,"is_first_party":0,"bug_type":"309","os_version":"macOS 26.3 (25D125)","roots_installed":0,"name":"DingDong","incident_id":"E765D67E-3851-4E91-9C48-ED06D22CCE6F"}
{
  "uptime" : 9500,
  "procRole" : "Foreground",
  "version" : 2,
  "userID" : 501,
  "deployVersion" : 210,
  "modelCode" : "Macmini9,1",
  "coalitionID" : 3008,
  "osVersion" : {
    "train" : "macOS 26.3",
    "build" : "25D125",
    "releaseType" : "User"
  },
  "captureTime" : "2026-05-15 15:59:15.5866 +0800",
  "codeSigningMonitor" : 1,
  "incident" : "E765D67E-3851-4E91-9C48-ED06D22CCE6F",
  "pid" : 21054,
  "translated" : false,
  "cpuType" : "ARM-64",
  "procLaunch" : "2026-05-15 15:58:59.7481 +0800",
  "procStartAbsTime" : 228726139550,
  "procExitAbsTime" : 229106159752,
  "procName" : "DingDong",
  "procPath" : "\/Users\/USER\/Library\/Developer\/CoreSimulator\/Devices\/23D3538E-995E-4C6E-87E0-57C9DB4AB84E\/data\/Containers\/Bundle\/Application\/7A559C59-0AF3-4B32-85E9-03DB34E9212F\/DingDong.app\/DingDong",
  "bundleInfo" : {"CFBundleShortVersionString":"1.0.0","CFBundleVersion":"1","CFBundleIdentifier":"com.ajz.dingdong"},
  "storeInfo" : {"deviceIdentifierForVendor":"2C52E1CB-213D-595E-B831-3C6DD5DA0CDE","thirdParty":true},
  "parentProc" : "launchd_sim",
  "parentPid" : 19899,
  "coalitionName" : "com.apple.CoreSimulator.SimDevice.23D3538E-995E-4C6E-87E0-57C9DB4AB84E",
  "crashReporterKey" : "60EB8E1D-85B2-0095-8042-A678A9CC4889",
  "appleIntelligenceStatus" : {"state":"available"},
  "developerMode" : 1,
  "bootProgressRegister" : "0x2f000000",
  "responsiblePid" : 2153,
  "responsibleProc" : "SimulatorTrampoline",
  "codeSigningID" : "com.ajz.dingdong",
  "codeSigningTeamID" : "",
  "codeSigningFlags" : 570425857,
  "codeSigningValidationCategory" : 10,
  "codeSigningTrustLevel" : 4294967295,
  "codeSigningAuxiliaryInfo" : 0,
  "instructionByteStream" : {"beforePC":"4wAAVP17v6n9AwCRKeP\/l78DAJH9e8GowANf1sADX9YQKYDSARAA1A==","atPC":"4wAAVP17v6n9AwCRH+P\/l78DAJH9e8GowANf1sADX9ZwCoDSARAA1A=="},
  "bootSessionUUID" : "CF8D436E-C811-4299-BD5D-EB41114F4262",
  "sip" : "enabled",
  "exception" : {"codes":"0x0000000000000000, 0x0000000000000000","rawCodes":[0,0],"type":"EXC_CRASH","signal":"SIGABRT"},
  "termination" : {"flags":0,"code":6,"namespace":"SIGNAL","indicator":"Abort trap: 6","byProc":"DingDong","byPid":21054},
  "extMods" : {"caller":{"thread_create":0,"thread_set_state":0,"task_for_pid":0},"system":{"thread_create":0,"thread_set_state":42,"task_for_pid":4},"targeted":{"thread_create":0,"thread_set_state":0,"task_for_pid":0},"warnings":0},
  "lastExceptionBacktrace" : [{"imageOffset":1284572,"symbol":"__exceptionPreprocess","symbolLocation":160,"imageIndex":10},{"imageOffset":180356,"symbol":"objc_exception_throw","symbolLocation":72,"imageIndex":9},{"imageOffset":1284344,"symbol":"-[NSException initWithCoder:]","symbolLocation":0,"imageIndex":10},{"imageOffset":276016,"symbol":"AVAudioEngineGraph::Initialize(NSError**)","symbolLocation":500,"imageIndex":11},{"imageOffset":998952,"symbol":"AVAudioEngineImpl::Initialize(NSError**)","symbolLocation":228,"imageIndex":11},{"imageOffset":964852,"symbol":"-[AVAudioEngine startAndReturnError:]","symbolLocation":308,"imageIndex":11},{"imageOffset":1195332,"sourceLine":49,"sourceFile":"SoundService.swift","symbol":"SoundService.play(_:)","imageIndex":2,"symbolLocation":788},{"imageOffset":1197264,"sourceLine":26,"sourceFile":"SoundService.swift","symbol":"SoundService.send()","imageIndex":2,"symbolLocation":172},{"imageOffset":1546492,"sourceLine":165,"sourceFile":"TrackingSetupView.swift","symbol":"closure #4 in closure #1 in TrackingSetupView.keypad.getter","imageIndex":2,"symbolLocation":188},{"imageOffset":7299928,"symbol":"<deduplicated_symbol>","symbolLocation":24,"imageIndex":12},{"imageOffset":14841380,"symbol":"specialized static MainActor.assumeIsolated<A>(_:file:line:)","symbolLocation":132,"imageIndex":12},{"imageOffset":14623976,"symbol":"ButtonAction.callAsFunction()","symbolLocation":388,"imageIndex":12},{"imageOffset":746992,"symbol":"<deduplicated_symbol>","symbolLocation":52,"imageIndex":12},{"imageOffset":6872468,"symbol":"ButtonBehavior.ended()","symbolLocation":224,"imageIndex":12},{"imageOffset":6895616,"symbol":"partial apply for implicit closure #2 in implicit closure #1 in ButtonBehavior.body.getter","symbolLocation":32,"imageIndex":12},{"imageOffset":14282548,"symbol":"partial apply for closure #1 in closure #2 in closure #1 in _ButtonGesture.internalBody.getter","symbolLocation":28,"imageIndex":12},{"imageOffset":14841380,"symbol":"specialized static MainActor.assumeIsolated<A>(_:file:line:)","symbolLocation":132,"imageIndex":12},{"imageOffset":14262644,"symbol":"closure #2 in closure #1 in _ButtonGesture.internalBody.getter","symbolLocation":80,"imageIndex":12},{"imageOffset":14287044,"symbol":"partial apply for closure #2 in PrimitiveButtonGestureCallbacks.dispatch(phase:state:)","symbolLocation":84,"imageIndex":12},{"imageOffset":799876,"symbol":"<deduplicated_symbol>","symbolLocation":20,"imageIndex":13},{"imageOffset":799876,"symbol":"<deduplicated_symbol>","symbolLocation":20,"imageIndex":13},{"imageOffset":2681672,"symbol":"<deduplicated_symbol>","symbolLocation":20,"imageIndex":12},{"imageOffset":5514724,"symbol":"<deduplicated_symbol>","symbolLocation":44,"imageIndex":12},{"imageOffset":5100964,"symbol":"static Update.dispatchActions()","symbolLocation":1092,"imageIndex":13},{"imageOffset":5096956,"symbol":"static Update.end()","symbolLocation":124,"imageIndex":13},{"imageOffset":5096244,"symbol":"static Update.enqueueAction(reason:_:)","symbolLocation":188,"imageIndex":13},{"imageOffset":9777944,"symbol":"UIKitResponderEventBindingBridge.flushActions()","symbolLocation":400,"imageIndex":12},{"imageOffset":9778036,"symbol":"@objc UIKitResponderEventBindingBridge.flushActions()","symbolLocation":24,"imageIndex":12},{"imageOffset":12495084,"symbol":"-[UIGestureRecognizerTarget _sendActionWithGestureRecognizer:]","symbolLocation":76,"imageIndex":14},{"imageOffset":12532204,"symbol":"_UIGestureRecognizerSendTargetActions","symbolLocation":88,"imageIndex":14},{"imageOffset":12519264,"symbol":"_UIGestureRecognizerSendActions","symbolLocation":296,"imageIndex":14},{"imageOffset":12518180,"symbol":"-[UIGestureRecognizer _updateGestureForActiveEvents]","symbolLocation":320,"imageIndex":14},{"imageOffset":12537648,"symbol":"-[UIGestureRecognizer gestureNode:didUpdatePhase:]","symbolLocation":296,"imageIndex":14},{"imageOffset":50764,"imageIndex":15},{"imageOffset":170072,"imageIndex":15},{"imageOffset":344236,"imageIndex":15},{"imageOffset":506124,"imageIndex":15},{"imageOffset":12459544,"symbol":"-[UIGestureEnvironment _updateForEvent:window:]","symbolLocation":468,"imageIndex":14},{"imageOffset":18109396,"symbol":"-[UIWindow sendEvent:]","symbolLocation":2796,"imageIndex":14},{"imageOffset":17970964,"symbol":"-[UIApplication sendEvent:]","symbolLocation":376,"imageIndex":14},{"imageOffset":18578540,"symbol":"__dispatchPreprocessedEventFromEventQueue","symbolLocation":1184,"imageIndex":14},{"imageOffset":18589984,"symbol":"__processEventQueue","symbolLocation":4800,"imageIndex":14},{"imageOffset":18558668,"symbol":"updateCycleEntry","symbolLocation":168,"imageIndex":14},{"imageOffset":6412408,"symbol":"_UIUpdateSequenceRunNext","symbolLocation":120,"imageIndex":14},{"imageOffset":16944272,"symbol":"schedulerStepScheduledMainSectionContinue","symbolLocation":56,"imageIndex":14},{"imageOffset":4788,"symbol":"UC::DriverCore::continueProcessing()","symbolLocation":80,"imageIndex":16},{"imageOffset":357548,"symbol":"__CFMachPortPerform","symbolLocation":164,"imageIndex":10},{"imageOffset":605152,"symbol":"__CFRUNLOOP_IS_CALLING_OUT_TO_A_SOURCE1_PERFORM_FUNCTION__","symbolLocation":56,"imageIndex":10},{"imageOffset":602616,"symbol":"__CFRunLoopDoSource1","symbolLocation":480,"imageIndex":10},{"imageOffset":598720,"symbol":"__CFRunLoopRun","symbolLocation":2100,"imageIndex":10},{"imageOffset":577060,"symbol":"_CFRunLoopRunSpecificWithOptions","symbolLocation":496,"imageIndex":10},{"imageOffset":10684,"symbol":"GSEventRunModal","symbolLocation":116,"imageIndex":17},{"imageOffset":17865788,"symbol":"-[UIApplication _run]","symbolLocation":772,"imageIndex":14},{"imageOffset":17882724,"symbol":"UIApplicationMain","symbolLocation":124,"imageIndex":14},{"imageOffset":8086076,"symbol":"closure #1 in KitRendererCommon(_:)","symbolLocation":164,"imageIndex":12},{"imageOffset":8085380,"symbol":"runApp<A>(_:)","symbolLocation":180,"imageIndex":12},{"imageOffset":5503436,"symbol":"static App.main()","symbolLocation":148,"imageIndex":12},{"imageOffset":250128,"sourceFile":"\/<compiler-generated>","symbol":"static DingDongApp.$main()","symbolLocation":40,"imageIndex":2},{"imageOffset":258856,"sourceFile":"DingDongApp.swift","symbol":"__debug_main_executable_dylib_entry_point","symbolLocation":12,"imageIndex":2},{"imageOffset":4373844944,"imageIndex":18},{"imageOffset":36180,"symbol":"start","symbolLocation":7184,"imageIndex":0}],
  "faultingThread" : 0,
  "threads" : [{"triggered":true,"id":195671,"threadState":{"x":[{"value":0},{"value":0},{"value":0},{"value":0},{"value":6445587627},{"value":6095077280},{"value":110},{"value":0},{"value":4372651584,"symbolLocation":0,"symbol":"_main_thread"},{"value":8357369391704347552},{"value":81},{"value":11},{"value":11},{"value":6449877204},{"value":2043},{"value":4255125609},{"value":328},{"value":4257220712},{"value":0},{"value":6},{"value":259},{"value":4372651808,"symbolLocation":224,"symbol":"_main_thread"},{"value":8365256704,"symbolLocation":1152,"symbol":"objc_debug_taggedpointer_ext_classes"},{"value":0},{"value":7821265710},{"value":10256956632,"symbolLocation":0,"symbol":"type metadata for MainActor"},{"value":0},{"value":105553174306880},{"value":6095083376}],"flavor":"ARM_THREAD_STATE64","lr":{"value":4373226152},"cpsr":{"value":1073745920},"fp":{"value":6095077136},"sp":{"value":6095077104},"esr":{"value":1442840704,"description":"(Syscall)"},"pc":{"value":4376004700,"matchesCrashFrame":1},"far":{"value":0}},"queue":"com.apple.main-thread","frames":[{"imageOffset":34908,"symbol":"__pthread_kill","symbolLocation":8,"imageIndex":4},{"imageOffset":25256,"symbol":"pthread_kill","symbolLocation":264,"imageIndex":5},{"imageOffset":477520,"symbol":"abort","symbolLocation":100,"imageIndex":7},{"imageOffset":70252,"symbol":"__abort_message","symbolLocation":128,"imageIndex":8},{"imageOffset":4516,"symbol":"demangling_terminate_handler()","symbolLocation":268,"imageIndex":8},{"imageOffset":29208,"symbol":"_objc_terminate()","symbolLocation":124,"imageIndex":9},{"imageOffset":67416,"symbol":"std::__terminate(void (*)())","symbolLocation":12,"imageIndex":8},{"imageOffset":79808,"symbol":"__cxxabiv1::failed_throw(__cxxabiv1::__cxa_exception*)","symbolLocation":32,"imageIndex":8},{"imageOffset":79776,"symbol":"__cxa_throw","symbolLocation":88,"imageIndex":8},{"imageOffset":180668,"symbol":"objc_exception_throw","symbolLocation":384,"imageIndex":9},{"imageOffset":1284344,"symbol":"+[NSException raise:format:]","symbolLocation":124,"imageIndex":10},{"imageOffset":276016,"symbol":"AVAudioEngineGraph::Initialize(NSError**)","symbolLocation":500,"imageIndex":11},{"imageOffset":998952,"symbol":"AVAudioEngineImpl::Initialize(NSError**)","symbolLocation":228,"imageIndex":11},{"imageOffset":964852,"symbol":"-[AVAudioEngine startAndReturnError:]","symbolLocation":308,"imageIndex":11},{"imageOffset":1195332,"sourceLine":49,"sourceFile":"SoundService.swift","symbol":"SoundService.play(_:)","imageIndex":2,"symbolLocation":788},{"imageOffset":1197264,"sourceLine":26,"sourceFile":"SoundService.swift","symbol":"SoundService.send()","imageIndex":2,"symbolLocation":172},{"imageOffset":1546492,"sourceLine":165,"sourceFile":"TrackingSetupView.swift","symbol":"closure #4 in closure #1 in TrackingSetupView.keypad.getter","imageIndex":2,"symbolLocation":188},{"imageOffset":7299928,"symbol":"<deduplicated_symbol>","symbolLocation":24,"imageIndex":12},{"imageOffset":14841380,"symbol":"specialized static MainActor.assumeIsolated<A>(_:file:line:)","symbolLocation":132,"imageIndex":12},{"imageOffset":14623976,"symbol":"ButtonAction.callAsFunction()","symbolLocation":388,"imageIndex":12},{"imageOffset":746992,"symbol":"<deduplicated_symbol>","symbolLocation":52,"imageIndex":12},{"imageOffset":6872468,"symbol":"ButtonBehavior.ended()","symbolLocation":224,"imageIndex":12},{"imageOffset":6895616,"symbol":"partial apply for implicit closure #2 in implicit closure #1 in ButtonBehavior.body.getter","symbolLocation":32,"imageIndex":12},{"imageOffset":14282548,"symbol":"partial apply for closure #1 in closure #2 in closure #1 in _ButtonGesture.internalBody.getter","symbolLocation":28,"imageIndex":12},{"imageOffset":14841380,"symbol":"specialized static MainActor.assumeIsolated<A>(_:file:line:)","symbolLocation":132,"imageIndex":12},{"imageOffset":14262644,"symbol":"closure #2 in closure #1 in _ButtonGesture.internalBody.getter","symbolLocation":80,"imageIndex":12},{"imageOffset":14287044,"symbol":"partial apply for closure #2 in PrimitiveButtonGestureCallbacks.dispatch(phase:state:)","symbolLocation":84,"imageIndex":12},{"imageOffset":799876,"symbol":"<deduplicated_symbol>","symbolLocation":20,"imageIndex":13},{"imageOffset":799876,"symbol":"<deduplicated_symbol>","symbolLocation":20,"imageIndex":13},{"imageOffset":2681672,"symbol":"<deduplicated_symbol>","symbolLocation":20,"imageIndex":12},{"imageOffset":5514724,"symbol":"<deduplicated_symbol>","symbolLocation":44,"imageIndex":12},{"imageOffset":5100964,"symbol":"static Update.dispatchActions()","symbolLocation":1092,"imageIndex":13},{"imageOffset":5096956,"symbol":"static Update.end()","symbolLocation":124,"imageIndex":13},{"imageOffset":5096244,"symbol":"static Update.enqueueAction(reason:_:)","symbolLocation":188,"imageIndex":13},{"imageOffset":9777944,"symbol":"UIKitResponderEventBindingBridge.flushActions()","symbolLocation":400,"imageIndex":12},{"imageOffset":9778036,"symbol":"@objc UIKitResponderEventBindingBridge.flushActions()","symbolLocation":24,"imageIndex":12},{"imageOffset":12495084,"symbol":"-[UIGestureRecognizerTarget _sendActionWithGestureRecognizer:]","symbolLocation":76,"imageIndex":14},{"imageOffset":12532204,"symbol":"_UIGestureRecognizerSendTargetActions","symbolLocation":88,"imageIndex":14},{"imageOffset":12519264,"symbol":"_UIGestureRecognizerSendActions","symbolLocation":296,"imageIndex":14},{"imageOffset":12518180,"symbol":"-[UIGestureRecognizer _updateGestureForActiveEvents]","symbolLocation":320,"imageIndex":14},{"imageOffset":12537648,"symbol":"-[UIGestureRecognizer gestureNode:didUpdatePhase:]","symbolLocation":296,"imageIndex":14},{"imageOffset":50764,"imageIndex":15},{"imageOffset":170072,"imageIndex":15},{"imageOffset":344236,"imageIndex":15},{"imageOffset":506124,"imageIndex":15},{"imageOffset":12459544,"symbol":"-[UIGestureEnvironment _updateForEvent:window:]","symbolLocation":468,"imageIndex":14},{"imageOffset":18109396,"symbol":"-[UIWindow sendEvent:]","symbolLocation":2796,"imageIndex":14},{"imageOffset":17970964,"symbol":"-[UIApplication sendEvent:]","symbolLocation":376,"imageIndex":14},{"imageOffset":18578540,"symbol":"__dispatchPreprocessedEventFromEventQueue","symbolLocation":1184,"imageIndex":14},{"imageOffset":18589984,"symbol":"__processEventQueue","symbolLocation":4800,"imageIndex":14},{"imageOffset":18558668,"symbol":"updateCycleEntry","symbolLocation":168,"imageIndex":14},{"imageOffset":6412408,"symbol":"_UIUpdateSequenceRunNext","symbolLocation":120,"imageIndex":14},{"imageOffset":16944272,"symbol":"schedulerStepScheduledMainSectionContinue","symbolLocation":56,"imageIndex":14},{"imageOffset":4788,"symbol":"UC::DriverCore::continueProcessing()","symbolLocation":80,"imageIndex":16},{"imageOffset":357548,"symbol":"__CFMachPortPerform","symbolLocation":164,"imageIndex":10},{"imageOffset":605152,"symbol":"__CFRUNLOOP_IS_CALLING_OUT_TO_A_SOURCE1_PERFORM_FUNCTION__","symbolLocation":56,"imageIndex":10},{"imageOffset":602616,"symbol":"__CFRunLoopDoSource1","symbolLocation":480,"imageIndex":10},{"imageOffset":598720,"symbol":"__CFRunLoopRun","symbolLocation":2100,"imageIndex":10},{"imageOffset":577060,"symbol":"_CFRunLoopRunSpecificWithOptions","symbolLocation":496,"imageIndex":10},{"imageOffset":10684,"symbol":"GSEventRunModal","symbolLocation":116,"imageIndex":17},{"imageOffset":17865788,"symbol":"-[UIApplication _run]","symbolLocation":772,"imageIndex":14},{"imageOffset":17882724,"symbol":"UIApplicationMain","symbolLocation":124,"imageIndex":14},{"imageOffset":8086076,"symbol":"closure #1 in KitRendererCommon(_:)","symbolLocation":164,"imageIndex":12},{"imageOffset":8085380,"symbol":"runApp<A>(_:)","symbolLocation":180,"imageIndex":12},{"imageOffset":5503436,"symbol":"static App.main()","symbolLocation":148,"imageIndex":12},{"imageOffset":250128,"sourceFile":"\/<compiler-generated>","symbol":"static DingDongApp.$main()","symbolLocation":40,"imageIndex":2},{"imageOffset":258856,"sourceFile":"DingDongApp.swift","symbol":"__debug_main_executable_dylib_entry_point","symbolLocation":12,"imageIndex":2},{"imageOffset":4373844944,"imageIndex":18},{"imageOffset":36180,"symbol":"start","symbolLocation":7184,"imageIndex":0}]},{"id":195693,"name":"com.apple.uikit.eventfetch-thread","threadState":{"x":[{"value":268451845},{"value":21592279046},{"value":8589934592},{"value":64884070940672},{"value":0},{"value":64884070940672},{"value":2},{"value":4294967295},{"value":0},{"value":17179869184},{"value":0},{"value":2},{"value":0},{"value":0},{"value":15107},{"value":3072},{"value":18446744073709551569},{"value":2},{"value":0},{"value":4294967295},{"value":2},{"value":64884070940672},{"value":0},{"value":64884070940672},{"value":6097952136},{"value":8589934592},{"value":21592279046},{"value":18446744073709550527},{"value":4412409862}],"flavor":"ARM_THREAD_STATE64","lr":{"value":4376041740},"cpsr":{"value":4096},"fp":{"value":6097951984},"sp":{"value":6097951904},"esr":{"value":1442840704,"description":"(Syscall)"},"pc":{"value":4375972720},"far":{"value":0}},"frames":[{"imageOffset":2928,"symbol":"mach_msg2_trap","symbolLocation":8,"imageIndex":4},{"imageOffset":71948,"symbol":"mach_msg2_internal","symbolLocation":72,"imageIndex":4},{"imageOffset":35856,"symbol":"mach_msg_overwrite","symbolLocation":480,"imageIndex":4},{"imageOffset":3812,"symbol":"mach_msg","symbolLocation":20,"imageIndex":4},{"imageOffset":601404,"symbol":"__CFRunLoopServiceMachPort","symbolLocation":156,"imageIndex":10},{"imageOffset":597748,"symbol":"__CFRunLoopRun","symbolLocation":1128,"imageIndex":10},{"imageOffset":577060,"symbol":"_CFRunLoopRunSpecificWithOptions","symbolLocation":496,"imageIndex":10},{"imageOffset":9010348,"symbol":"-[NSRunLoop(NSRunLoop) runMode:beforeDate:]","symbolLocation":208,"imageIndex":19},{"imageOffset":9010892,"symbol":"-[NSRunLoop(NSRunLoop) runUntilDate:]","symbolLocation":60,"imageIndex":19},{"imageOffset":18616568,"symbol":"-[UIEventFetcher threadMain]","symbolLocation":392,"imageIndex":14},{"imageOffset":9169784,"symbol":"__NSThread__start__","symbolLocation":716,"imageIndex":19},{"imageOffset":26028,"symbol":"_pthread_start","symbolLocation":104,"imageIndex":5},{"imageOffset":6552,"symbol":"thread_start","symbolLocation":8,"imageIndex":5}]},{"id":195695,"frames":[],"threadState":{"x":[{"value":6099103744},{"value":38763},{"value":6098567168},{"value":0},{"value":409604},{"value":18446744073709551615},{"value":0},{"value":0},{"value":0},{"value":0},{"value":0},{"value":0},{"value":0},{"value":0},{"value":0},{"value":0},{"value":0},{"value":0},{"value":0},{"value":0},{"value":0},{"value":0},{"value":0},{"value":0},{"value":0},{"value":0},{"value":0},{"value":0},{"value":0}],"flavor":"ARM_THREAD_STATE64","lr":{"value":0},"cpsr":{"value":4096},"fp":{"value":0},"sp":{"value":6099103744},"esr":{"value":1442840704,"description":"(Syscall)"},"pc":{"value":4373207428},"far":{"value":0}}},{"id":195716,"name":"com.apple.UIKit.inProcessAnimationManager","threadState":{"x":[{"value":14},{"value":18446744073709551615},{"value":1},{"value":1},{"value":25769803779},{"value":4},{"value":25769803779},{"value":4},{"value":35587},{"value":18446744073709551615},{"value":0},{"value":0},{"value":17179869187},{"value":4},{"value":8365244136,"symbolLocation":0,"symbol":"OBJC_CLASS_$_OS_dispatch_semaphore"},{"value":8365244136,"symbolLocation":0,"symbol":"OBJC_CLASS_$_OS_dispatch_semaphore"},{"value":18446744073709551580},{"value":6444258488,"symbolLocation":0,"symbol":"-[OS_object retain]"},{"value":0},{"value":105553151288608},{"value":105553151288544},{"value":18446744073709551615},{"value":4379097200},{"value":8510410752,"objc-selector":"performSelector:withObject:"},{"value":8510410752,"objc-selector":"performSelector:withObject:"},{"value":105553151288544},{"value":0},{"value":0},{"value":0}],"flavor":"ARM_THREAD_STATE64","lr":{"value":6444261976},"cpsr":{"value":1610616832},"fp":{"value":6100249664},"sp":{"value":6100249648},"esr":{"value":1442840704,"description":"(Syscall)"},"pc":{"value":4375972588},"far":{"value":0}},"frames":[{"imageOffset":2796,"symbol":"semaphore_wait_trap","symbolLocation":8,"imageIndex":4},{"imageOffset":12888,"symbol":"_dispatch_sema4_wait","symbolLocation":24,"imageIndex":20},{"imageOffset":14304,"symbol":"_dispatch_semaphore_wait_slow","symbolLocation":128,"imageIndex":20},{"imageOffset":4543540,"imageIndex":14},{"imageOffset":4561280,"imageIndex":14},{"imageOffset":249568,"imageIndex":14},{"imageOffset":9169784,"symbol":"__NSThread__start__","symbolLocation":716,"imageIndex":19},{"imageOffset":26028,"symbol":"_pthread_start","symbolLocation":104,"imageIndex":5},{"imageOffset":6552,"symbol":"thread_start","symbolLocation":8,"imageIndex":5}]},{"id":195734,"frames":[],"threadState":{"x":[{"value":6100824064},{"value":36959},{"value":6100287488},{"value":0},{"value":409604},{"value":18446744073709551615},{"value":0},{"value":0},{"value":0},{"value":0},{"value":0},{"value":0},{"value":0},{"value":0},{"value":0},{"value":0},{"value":0},{"value":0},{"value":0},{"value":0},{"value":0},{"value":0},{"value":0},{"value":0},{"value":0},{"value":0},{"value":0},{"value":0},{"value":0}],"flavor":"ARM_THREAD_STATE64","lr":{"value":0},"cpsr":{"value":4096},"fp":{"value":0},"sp":{"value":6100824064},"esr":{"value":1442840704,"description":"(Syscall)"},"pc":{"value":4373207428},"far":{"value":0}}},{"id":195878,"name":"com.apple.SwiftUI.AsyncRenderer","threadState":{"x":[{"value":268451845},{"value":21592279046},{"value":8589934592},{"value":181707181391872},{"value":0},{"value":181707181391872},{"value":2},{"value":4294967295},{"value":0},{"value":17179869184},{"value":0},{"value":2},{"value":0},{"value":0},{"value":42307},{"value":3072},{"value":18446744073709551569},{"value":2},{"value":0},{"value":4294967295},{"value":2},{"value":181707181391872},{"value":0},{"value":181707181391872},{"value":6095658200},{"value":8589934592},{"value":21592279046},{"value":18446744073709550527},{"value":4412409862}],"flavor":"ARM_THREAD_STATE64","lr":{"value":4376041740},"cpsr":{"value":4096},"fp":{"value":6095658048},"sp":{"value":6095657968},"esr":{"value":1442840704,"description":"(Syscall)"},"pc":{"value":4375972720},"far":{"value":0}},"frames":[{"imageOffset":2928,"symbol":"mach_msg2_trap","symbolLocation":8,"imageIndex":4},{"imageOffset":71948,"symbol":"mach_msg2_internal","symbolLocation":72,"imageIndex":4},{"imageOffset":35856,"symbol":"mach_msg_overwrite","symbolLocation":480,"imageIndex":4},{"imageOffset":3812,"symbol":"mach_msg","symbolLocation":20,"imageIndex":4},{"imageOffset":601404,"symbol":"__CFRunLoopServiceMachPort","symbolLocation":156,"imageIndex":10},{"imageOffset":597748,"symbol":"__CFRunLoopRun","symbolLocation":1128,"imageIndex":10},{"imageOffset":577060,"symbol":"_CFRunLoopRunSpecificWithOptions","symbolLocation":496,"imageIndex":10},{"imageOffset":9010348,"symbol":"-[NSRunLoop(NSRunLoop) runMode:beforeDate:]","symbolLocation":208,"imageIndex":19},{"imageOffset":9010812,"symbol":"-[NSRunLoop(NSRunLoop) run]","symbolLocation":60,"imageIndex":19},{"imageOffset":2275508,"symbol":"specialized static ViewGraphDisplayLink.asyncThread(arg:)","symbolLocation":492,"imageIndex":13},{"imageOffset":2271368,"symbol":"@objc static ViewGraphDisplayLink.asyncThread(arg:)","symbolLocation":68,"imageIndex":13},{"imageOffset":9169784,"symbol":"__NSThread__start__","symbolLocation":716,"imageIndex":19},{"imageOffset":26028,"symbol":"_pthread_start","symbolLocation":104,"imageIndex":5},{"imageOffset":6552,"symbol":"thread_start","symbolLocation":8,"imageIndex":5}]},{"id":195952,"name":"caulk.messenger.shared:17","threadState":{"x":[{"value":14},{"value":105553119360154},{"value":0},{"value":6096236650},{"value":105553119360128},{"value":25},{"value":0},{"value":0},{"value":0},{"value":4294967295},{"value":0},{"value":0},{"value":0},{"value":0},{"value":0},{"value":0},{"value":18446744073709551580},{"value":0},{"value":0},{"value":105553176111088},{"value":0},{"value":0},{"value":0},{"value":0},{"value":0},{"value":0},{"value":0},{"value":0},{"value":0}],"flavor":"ARM_THREAD_STATE64","lr":{"value":7414582448},"cpsr":{"value":2147487744},"fp":{"value":6096236416},"sp":{"value":6096236384},"esr":{"value":1442840704,"description":"(Syscall)"},"pc":{"value":4375972588},"far":{"value":0}},"frames":[{"imageOffset":2796,"symbol":"semaphore_wait_trap","symbolLocation":8,"imageIndex":4},{"imageOffset":64688,"symbol":"caulk::semaphore::timed_wait(double)","symbolLocation":220,"imageIndex":21},{"imageOffset":96660,"symbol":"caulk::concurrent::details::worker_thread::run()","symbolLocation":28,"imageIndex":21},{"imageOffset":96776,"symbol":"void* caulk::thread_proxy<std::__1::tuple<caulk::thread::attributes, void (caulk::concurrent::details::worker_thread::*)(), std::__1::tuple<caulk::concurrent::details::worker_thread*>>>(void*)","symbolLocation":48,"imageIndex":21},{"imageOffset":26028,"symbol":"_pthread_start","symbolLocation":104,"imageIndex":5},{"imageOffset":6552,"symbol":"thread_start","symbolLocation":8,"imageIndex":5}]},{"id":195953,"name":"caulk.messenger.shared:high","threadState":{"x":[{"value":14},{"value":105553119355772},{"value":0},{"value":6096810092},{"value":105553119355744},{"value":27},{"value":0},{"value":0},{"value":0},{"value":4294967295},{"value":0},{"value":0},{"value":0},{"value":0},{"value":0},{"value":0},{"value":18446744073709551580},{"value":0},{"value":0},{"value":105553176112128},{"value":0},{"value":0},{"value":0},{"value":0},{"value":0},{"value":0},{"value":0},{"value":0},{"value":0}],"flavor":"ARM_THREAD_STATE64","lr":{"value":7414582448},"cpsr":{"value":2147487744},"fp":{"value":6096809856},"sp":{"value":6096809824},"esr":{"value":1442840704,"description":"(Syscall)"},"pc":{"value":4375972588},"far":{"value":0}},"frames":[{"imageOffset":2796,"symbol":"semaphore_wait_trap","symbolLocation":8,"imageIndex":4},{"imageOffset":64688,"symbol":"caulk::semaphore::timed_wait(double)","symbolLocation":220,"imageIndex":21},{"imageOffset":96660,"symbol":"caulk::concurrent::details::worker_thread::run()","symbolLocation":28,"imageIndex":21},{"imageOffset":96776,"symbol":"void* caulk::thread_proxy<std::__1::tuple<caulk::thread::attributes, void (caulk::concurrent::details::worker_thread::*)(), std::__1::tuple<caulk::concurrent::details::worker_thread*>>>(void*)","symbolLocation":48,"imageIndex":21},{"imageOffset":26028,"symbol":"_pthread_start","symbolLocation":104,"imageIndex":5},{"imageOffset":6552,"symbol":"thread_start","symbolLocation":8,"imageIndex":5}]}],
  "usedImages" : [
  {
    "source" : "P",
    "arch" : "arm64e",
    "base" : 4371939328,
    "size" : 655360,
    "uuid" : "bc4db5f4-1c64-3706-8006-73b78c3e1f1a",
    "path" : "\/usr\/lib\/dyld",
    "name" : "dyld"
  },
  {
    "source" : "P",
    "arch" : "arm64",
    "base" : 4371775488,
    "CFBundleShortVersionString" : "1.0.0",
    "CFBundleIdentifier" : "com.ajz.dingdong",
    "size" : 16384,
    "uuid" : "7f624f77-fe9f-3c8d-8eca-d4b5ebfe03e9",
    "path" : "\/Users\/USER\/Library\/Developer\/CoreSimulator\/Devices\/23D3538E-995E-4C6E-87E0-57C9DB4AB84E\/data\/Containers\/Bundle\/Application\/7A559C59-0AF3-4B32-85E9-03DB34E9212F\/DingDong.app\/DingDong",
    "name" : "DingDong",
    "CFBundleVersion" : "1"
  },
  {
    "source" : "P",
    "arch" : "arm64",
    "base" : 4381802496,
    "size" : 2031616,
    "uuid" : "d286b99c-b213-3ace-867b-24449dfb1827",
    "path" : "\/Users\/USER\/Library\/Developer\/CoreSimulator\/Devices\/23D3538E-995E-4C6E-87E0-57C9DB4AB84E\/data\/Containers\/Bundle\/Application\/7A559C59-0AF3-4B32-85E9-03DB34E9212F\/DingDong.app\/DingDong.debug.dylib",
    "name" : "DingDong.debug.dylib"
  },
  {
    "source" : "P",
    "arch" : "arm64",
    "base" : 4373610496,
    "size" : 32768,
    "uuid" : "9463fc06-cc7c-38e8-ad3c-1b9f2617df53",
    "path" : "\/usr\/lib\/system\/libsystem_platform.dylib",
    "name" : "libsystem_platform.dylib"
  },
  {
    "source" : "P",
    "arch" : "arm64",
    "base" : 4375969792,
    "size" : 245760,
    "uuid" : "1a15cc38-efcc-34ea-a261-cfd370f4b557",
    "path" : "\/usr\/lib\/system\/libsystem_kernel.dylib",
    "name" : "libsystem_kernel.dylib"
  },
  {
    "source" : "P",
    "arch" : "arm64",
    "base" : 4373200896,
    "size" : 65536,
    "uuid" : "b1095734-2a4d-3e8c-839e-b10ae9598d61",
    "path" : "\/usr\/lib\/system\/libsystem_pthread.dylib",
    "name" : "libsystem_pthread.dylib"
  },
  {
    "source" : "P",
    "arch" : "arm64",
    "base" : 4375724032,
    "size" : 49152,
    "uuid" : "78c22921-6ad3-3681-bedb-525a69493719",
    "path" : "\/Volumes\/VOLUME\/*\/libobjc-trampolines.dylib",
    "name" : "libobjc-trampolines.dylib"
  },
  {
    "source" : "P",
    "arch" : "arm64",
    "base" : 6443732992,
    "size" : 512636,
    "uuid" : "d591507f-069e-335b-a3ba-95dbac2e9dfa",
    "path" : "\/Volumes\/VOLUME\/*\/libsystem_c.dylib",
    "name" : "libsystem_c.dylib"
  },
  {
    "source" : "P",
    "arch" : "arm64",
    "base" : 6445502464,
    "size" : 99696,
    "uuid" : "5b496e0d-c60f-38e4-8d0a-0e27ad32b14a",
    "path" : "\/Volumes\/VOLUME\/*\/libc++abi.dylib",
    "name" : "libc++abi.dylib"
  },
  {
    "source" : "P",
    "arch" : "arm64",
    "base" : 6442909696,
    "size" : 250504,
    "uuid" : "99860b81-03a1-3f42-a755-321cc0032934",
    "path" : "\/Volumes\/VOLUME\/*\/libobjc.A.dylib",
    "name" : "libobjc.A.dylib"
  },
  {
    "source" : "P",
    "arch" : "arm64",
    "base" : 6446358528,
    "CFBundleShortVersionString" : "6.9",
    "CFBundleIdentifier" : "com.apple.CoreFoundation",
    "size" : 4329024,
    "uuid" : "7b44bd11-eb8c-337a-82fc-b81c10bd0b15",
    "path" : "\/Volumes\/VOLUME\/*\/CoreFoundation.framework\/CoreFoundation",
    "name" : "CoreFoundation",
    "CFBundleVersion" : "4040.1"
  },
  {
    "source" : "P",
    "arch" : "arm64",
    "base" : 7820120064,
    "CFBundleShortVersionString" : "1.0",
    "CFBundleIdentifier" : "com.apple.audio.AVFAudio",
    "size" : 1384576,
    "uuid" : "38197aa2-28c6-364e-bcf2-f8220f74c69d",
    "path" : "\/Volumes\/VOLUME\/*\/AVFAudio.framework\/AVFAudio",
    "name" : "AVFAudio"
  },
  {
    "source" : "P",
    "arch" : "arm64",
    "base" : 7926247424,
    "CFBundleShortVersionString" : "7.0.84.1.107",
    "CFBundleIdentifier" : "com.apple.SwiftUI",
    "size" : 18550368,
    "uuid" : "2619b103-235a-3b1b-85f0-f29b4ebaeea4",
    "path" : "\/Volumes\/VOLUME\/*\/SwiftUI.framework\/SwiftUI",
    "name" : "SwiftUI",
    "CFBundleVersion" : "7.0.84.1.107"
  },
  {
    "source" : "P",
    "arch" : "arm64",
    "base" : 7944798208,
    "CFBundleShortVersionString" : "7.0.84.1.107",
    "CFBundleIdentifier" : "com.apple.SwiftUICore",
    "size" : 13488576,
    "uuid" : "455f824b-23c8-3df5-8e3a-4ad267868f23",
    "path" : "\/Volumes\/VOLUME\/*\/SwiftUICore.framework\/SwiftUICore",
    "name" : "SwiftUICore",
    "CFBundleVersion" : "7.0.84.1.107"
  },
  {
    "source" : "P",
    "arch" : "arm64",
    "base" : 6527737856,
    "CFBundleShortVersionString" : "1.0",
    "CFBundleIdentifier" : "com.apple.UIKitCore",
    "size" : 35105632,
    "uuid" : "718bdf15-89c6-3901-9eac-98ea2b8dc1bd",
    "path" : "\/Volumes\/VOLUME\/*\/UIKitCore.framework\/UIKitCore",
    "name" : "UIKitCore",
    "CFBundleVersion" : "9088.1.114"
  },
  {
    "source" : "P",
    "arch" : "arm64",
    "base" : 9378181120,
    "CFBundleShortVersionString" : "9088",
    "CFBundleIdentifier" : "com.apple.Gestures",
    "size" : 695073,
    "uuid" : "aa7518df-7242-3400-9458-362536e6291d",
    "path" : "\/Volumes\/VOLUME\/*\/Gestures.framework\/Gestures",
    "name" : "Gestures",
    "CFBundleVersion" : "9088"
  },
  {
    "source" : "P",
    "arch" : "arm64",
    "base" : 9941864448,
    "CFBundleShortVersionString" : "1",
    "CFBundleIdentifier" : "com.apple.UpdateCycle",
    "size" : 7840,
    "uuid" : "fc49003c-75a7-3db2-84ca-8076eef1d8a7",
    "path" : "\/Volumes\/VOLUME\/*\/UpdateCycle.framework\/UpdateCycle",
    "name" : "UpdateCycle",
    "CFBundleVersion" : "1"
  },
  {
    "source" : "P",
    "arch" : "arm64",
    "base" : 6749876224,
    "CFBundleShortVersionString" : "1.0",
    "CFBundleIdentifier" : "com.apple.GraphicsServices",
    "size" : 32192,
    "uuid" : "02f377dd-50ff-356a-bcea-2c061ebe5045",
    "path" : "\/Volumes\/VOLUME\/*\/GraphicsServices.framework\/GraphicsServices",
    "name" : "GraphicsServices",
    "CFBundleVersion" : "1.0"
  },
  {
    "size" : 0,
    "source" : "A",
    "base" : 0,
    "uuid" : "00000000-0000-0000-0000-000000000000"
  },
  {
    "source" : "P",
    "arch" : "arm64",
    "base" : 6451208192,
    "CFBundleShortVersionString" : "6.9",
    "CFBundleIdentifier" : "com.apple.Foundation",
    "size" : 14002432,
    "uuid" : "0525cd9f-cd95-31fe-856c-939c0851eb23",
    "path" : "\/Volumes\/VOLUME\/*\/Foundation.framework\/Foundation",
    "name" : "Foundation",
    "CFBundleVersion" : "4040.1"
  },
  {
    "source" : "P",
    "arch" : "arm64",
    "base" : 6444249088,
    "size" : 283072,
    "uuid" : "e4af9b0e-70f1-369d-8dd1-f07b9754834b",
    "path" : "\/Volumes\/VOLUME\/*\/libdispatch.dylib",
    "name" : "libdispatch.dylib"
  },
  {
    "source" : "P",
    "arch" : "arm64",
    "base" : 7414517760,
    "CFBundleShortVersionString" : "1.0",
    "CFBundleIdentifier" : "com.apple.audio.caulk",
    "size" : 157120,
    "uuid" : "1057119c-e0f5-37a6-9854-c822458d76b8",
    "path" : "\/Volumes\/VOLUME\/*\/caulk.framework\/caulk",
    "name" : "caulk"
  }
],
  "sharedCache" : {
  "base" : 6442450944,
  "size" : 4274012160,
  "uuid" : "381e4c14-b6bb-3905-a719-af30d2ed7840"
},
  "vmSummary" : "ReadOnly portion of Libraries: Total=1.5G resident=0K(0%) swapped_out_or_unallocated=1.5G(100%)\nWritable regions: Total=696.9M written=2200K(0%) resident=2200K(0%) swapped_out=0K(0%) unallocated=694.8M(100%)\n\n                                VIRTUAL   REGION \nREGION TYPE                        SIZE    COUNT (non-coalesced) \n===========                     =======  ======= \nActivity Tracing                   256K        1 \nAttributeGraph Data               1024K        1 \nCG raster data                    1536K        6 \nColorSync                          256K       12 \nCoreAnimation                     3280K      136 \nFoundation                          16K        1 \nIOSurface                         8320K        3 \nKernel Alloc Once                   32K        1 \nMALLOC                           666.0M       77 \nMALLOC guard page                  192K       12 \nSQLite page cache                  384K        3 \nSTACK GUARD                       56.1M        8 \nStack                             11.7M        8 \nVM_ALLOCATE                       3360K        9 \n__DATA                            28.2M      686 \n__DATA_CONST                      86.1M      710 \n__DATA_DIRTY                       139K       13 \n__FONT_DATA                        2352        1 \n__LINKEDIT                       704.8M        8 \n__LLVM_COV                          48K        1 \n__OBJC_RO                         62.5M        1 \n__OBJC_RW                         2768K        1 \n__TEXT                           797.0M      723 \n__TPRO_CONST                       148K        2 \ndyld private memory                2.1G       17 \nmapped file                      425.2M       40 \npage table in kernel              2200K        1 \nshared memory                     1040K        2 \n===========                     =======  ======= \nTOTAL                              4.9G     2484 \n",
  "legacyInfo" : {
  "threadTriggered" : {
    "queue" : "com.apple.main-thread"
  }
},
  "logWritingSignature" : "41215f4646e590b6ac85e3e651cb767ae3cefa27",
  "roots_installed" : 0,
  "bug_type" : "309",
  "trmStatus" : 8192,
  "trialInfo" : {
  "rollouts" : [
    {
      "rolloutId" : "64c17a9925d75a7281053d4c",
      "factorPackIds" : [
        "64d29746ad29a465b3bbeace"
      ],
      "deploymentId" : 240000002
    },
    {
      "rolloutId" : "6410af69ed1e1e7ab93ed169",
      "factorPackIds" : [

      ],
      "deploymentId" : 240000011
    }
  ],
  "experiments" : [
    {
      "treatmentId" : "84b40626-8c08-4a60-8e35-243ea991e0d5",
      "experimentId" : "687ad3eb2c0a4d3b710c5dcd",
      "deploymentId" : 400000016
    }
  ]
}
}

