/*
 * Copyright (c) 2013 Mayur Pawashe
 * All rights reserved.
 *
 * Redistribution and use in source and binary forms, with or without
 * modification, are permitted provided that the following conditions
 * are met:
 *
 * Redistributions of source code must retain the above copyright notice,
 * this list of conditions and the following disclaimer.
 *
 * Redistributions in binary form must reproduce the above copyright
 * notice, this list of conditions and the following disclaimer in the
 * documentation and/or other materials provided with the distribution.
 *
 * Neither the name of the project's author nor the names of its
 * contributors may be used to endorse or promote products derived from
 * this software without specific prior written permission.
 *
 * THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS
 * "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT
 * LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS
 * FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT
 * HOLDER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL,
 * SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED
 * TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR
 * PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF
 * LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING
 * NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS
 * SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
 */

#import "ZGVirtualMemoryUserTags.h"
#import "ZGVirtualMemory.h"

#import <mach/mach_error.h>
#import <mach/mach_vm.h>

#define ZGUserTagPretty(x) [[[(x) stringByReplacingOccurrencesOfString:@"VM_MEMORY_" withString:@""] stringByReplacingOccurrencesOfString:@"_" withString:@" "] capitalizedString]

#define ZGHandleUserTagCase(result, value) \
case value: \
	result = ZGUserTagPretty(@(#value)); \
	break;

#define ZGHandleUserTagCaseWithDescription(result, value, description) \
	case value: \
		result = description; \
		break;

#ifndef MAC_OS_VERSION_14_0
#define MAC_OS_VERSION_14_0 140000
#endif

#if __MAC_OS_X_VERSION_MAX_ALLOWED > MAC_OS_VERSION_14_2
#pragma message("Need to update the user tag descriptions")
#endif

bool ZGUserTagIsSharedMemory(uint32_t userTag)
{
	// For shared memory / pmap, see https://developer.apple.com/library/archive/documentation/Darwin/Conceptual/KernelProgramming/vm/vm.html
	return userTag == VM_MEMORY_SHARED_PMAP;
}

bool ZGUserTagIsStackOrHeapData(uint32_t userTag)
{
	switch (userTag)
	{
		case VM_MEMORY_MALLOC:
		case VM_MEMORY_MALLOC_SMALL:
		case VM_MEMORY_MALLOC_LARGE:
		case VM_MEMORY_MALLOC_HUGE:
		case VM_MEMORY_REALLOC:
		case VM_MEMORY_MALLOC_TINY:
		case VM_MEMORY_MALLOC_LARGE_REUSABLE:
		case VM_MEMORY_MALLOC_LARGE_REUSED:
		case VM_MEMORY_MALLOC_NANO:
		case VM_MEMORY_MALLOC_MEDIUM:
		case VM_MEMORY_STACK:
		case VM_MEMORY_DYLIB:
		case VM_MEMORY_TCMALLOC:
		case VM_MEMORY_DYLD:
		case VM_MEMORY_DYLD_MALLOC:
			return true;
		default:
			return false;
	}
}

NSString *ZGUserTagDescription(uint32_t userTag)
{
	NSString *userTagDescription = nil;
	
	switch (userTag)
	{
			ZGHandleUserTagCase(userTagDescription, VM_MEMORY_MALLOC)
			ZGHandleUserTagCase(userTagDescription, VM_MEMORY_MALLOC_SMALL)
			ZGHandleUserTagCase(userTagDescription, VM_MEMORY_MALLOC_LARGE)
			ZGHandleUserTagCase(userTagDescription, VM_MEMORY_MALLOC_HUGE)
			ZGHandleUserTagCase(userTagDescription, VM_MEMORY_SBRK)
			ZGHandleUserTagCase(userTagDescription, VM_MEMORY_REALLOC)
			ZGHandleUserTagCase(userTagDescription, VM_MEMORY_MALLOC_TINY)
			ZGHandleUserTagCase(userTagDescription, VM_MEMORY_MALLOC_LARGE_REUSABLE)
			ZGHandleUserTagCase(userTagDescription, VM_MEMORY_MALLOC_LARGE_REUSED)
			ZGHandleUserTagCase(userTagDescription, VM_MEMORY_ANALYSIS_TOOL)
			ZGHandleUserTagCase(userTagDescription, VM_MEMORY_MALLOC_NANO)
			ZGHandleUserTagCase(userTagDescription, VM_MEMORY_MALLOC_MEDIUM)
			ZGHandleUserTagCaseWithDescription(userTagDescription, VM_MEMORY_MACH_MSG, @"Mach Message")
			ZGHandleUserTagCaseWithDescription(userTagDescription, VM_MEMORY_IOKIT, @"IOKit")
			ZGHandleUserTagCase(userTagDescription, VM_MEMORY_STACK)
			ZGHandleUserTagCase(userTagDescription, VM_MEMORY_GUARD)
			ZGHandleUserTagCase(userTagDescription, VM_MEMORY_SHARED_PMAP)
			ZGHandleUserTagCaseWithDescription(userTagDescription, VM_MEMORY_DYLIB, @"dylib")
			ZGHandleUserTagCaseWithDescription(userTagDescription, VM_MEMORY_OBJC_DISPATCHERS, @"Obj-C Dispatchers")
			ZGHandleUserTagCase(userTagDescription, VM_MEMORY_UNSHARED_PMAP)
			ZGHandleUserTagCaseWithDescription(userTagDescription, VM_MEMORY_APPKIT, @"AppKit")
			ZGHandleUserTagCase(userTagDescription, VM_MEMORY_FOUNDATION)
			ZGHandleUserTagCaseWithDescription(userTagDescription, VM_MEMORY_COREGRAPHICS, @"Core Graphics")
			ZGHandleUserTagCaseWithDescription(userTagDescription, VM_MEMORY_CORESERVICES, @"Core Services")
			ZGHandleUserTagCase(userTagDescription, VM_MEMORY_JAVA)
			ZGHandleUserTagCaseWithDescription(userTagDescription, VM_MEMORY_COREDATA, @"Core Data")
			ZGHandleUserTagCaseWithDescription(userTagDescription, VM_MEMORY_COREDATA_OBJECTIDS, @"Core Data Object IDs")
			ZGHandleUserTagCaseWithDescription(userTagDescription, VM_MEMORY_ATS, @"Apple Type Services")
			ZGHandleUserTagCaseWithDescription(userTagDescription, VM_MEMORY_LAYERKIT, @"LayerKit")
			ZGHandleUserTagCaseWithDescription(userTagDescription, VM_MEMORY_CGIMAGE, @"CGImage")
			ZGHandleUserTagCaseWithDescription(userTagDescription, VM_MEMORY_TCMALLOC, @"TCMalloc")
			ZGHandleUserTagCaseWithDescription(userTagDescription, VM_MEMORY_COREGRAPHICS_DATA, @"Core Graphics Data")
			ZGHandleUserTagCaseWithDescription(userTagDescription, VM_MEMORY_COREGRAPHICS_SHARED, @"Core Graphics Shared")
			ZGHandleUserTagCaseWithDescription(userTagDescription, VM_MEMORY_COREGRAPHICS_FRAMEBUFFERS, @"Core Graphics Framebuffers")
			ZGHandleUserTagCaseWithDescription(userTagDescription, VM_MEMORY_COREGRAPHICS_BACKINGSTORES, @"Core Graphics Backing Stores")
			ZGHandleUserTagCaseWithDescription(userTagDescription, VM_MEMORY_DYLD, @"dyld")
			ZGHandleUserTagCaseWithDescription(userTagDescription, VM_MEMORY_DYLD_MALLOC, @"dyld Malloc")
			ZGHandleUserTagCaseWithDescription(userTagDescription, VM_MEMORY_SQLITE, @"SQLite")
			ZGHandleUserTagCaseWithDescription(userTagDescription, VM_MEMORY_JAVASCRIPT_CORE, @"JavaScript Core")
			ZGHandleUserTagCaseWithDescription(userTagDescription, VM_MEMORY_JAVASCRIPT_JIT_EXECUTABLE_ALLOCATOR, @"JavaScript JIT Executable Allocator")
			ZGHandleUserTagCaseWithDescription(userTagDescription, VM_MEMORY_JAVASCRIPT_JIT_REGISTER_FILE, @"JavaScript JIT Register File")
			ZGHandleUserTagCaseWithDescription(userTagDescription, VM_MEMORY_GLSL, @"GLSL")
			ZGHandleUserTagCaseWithDescription(userTagDescription, VM_MEMORY_OPENCL, @"OpenCL")
			ZGHandleUserTagCaseWithDescription(userTagDescription, VM_MEMORY_COREIMAGE, @"Core Image")
			ZGHandleUserTagCaseWithDescription(userTagDescription, VM_MEMORY_WEBCORE_PURGEABLE_BUFFERS, @"WebCore Purgeable Buffers")
			ZGHandleUserTagCaseWithDescription(userTagDescription, VM_MEMORY_IMAGEIO, @"ImageIO")
			ZGHandleUserTagCaseWithDescription(userTagDescription, VM_MEMORY_COREPROFILE, @"Core Profile")
			ZGHandleUserTagCase(userTagDescription, VM_MEMORY_ASSETSD)
			ZGHandleUserTagCaseWithDescription(userTagDescription, VM_MEMORY_OS_ALLOC_ONCE, @"OS Alloc Once")
			ZGHandleUserTagCaseWithDescription(userTagDescription, VM_MEMORY_LIBDISPATCH, @"libdispatch")
			ZGHandleUserTagCase(userTagDescription, VM_MEMORY_ACCELERATE)
			ZGHandleUserTagCaseWithDescription(userTagDescription, VM_MEMORY_COREUI, @"CoreUI")
			
			ZGHandleUserTagCaseWithDescription(userTagDescription, VM_MEMORY_COREUIFILE, @"CoreUI File")
			ZGHandleUserTagCaseWithDescription(userTagDescription, VM_MEMORY_GENEALOGY, @"Genealogy");
			
			ZGHandleUserTagCaseWithDescription(userTagDescription, VM_MEMORY_RAWCAMERA, @"RAW Camera");
			ZGHandleUserTagCaseWithDescription(userTagDescription, VM_MEMORY_CORPSEINFO, @"Corpse Info");
			ZGHandleUserTagCaseWithDescription(userTagDescription, VM_MEMORY_ASL, @"Apple System Log (ASL)");
			
			ZGHandleUserTagCase(userTagDescription, VM_MEMORY_SWIFT_RUNTIME);
			ZGHandleUserTagCase(userTagDescription, VM_MEMORY_SWIFT_METADATA);
			ZGHandleUserTagCase(userTagDescription, VM_MEMORY_DHMM);
			ZGHandleUserTagCase(userTagDescription, VM_MEMORY_SCENEKIT);
			ZGHandleUserTagCase(userTagDescription, VM_MEMORY_SKYWALK);
			
			ZGHandleUserTagCase(userTagDescription, VM_MEMORY_IOSURFACE);
			ZGHandleUserTagCase(userTagDescription, VM_MEMORY_LIBNETWORK);
			ZGHandleUserTagCase(userTagDescription, VM_MEMORY_AUDIO);
			ZGHandleUserTagCaseWithDescription(userTagDescription, VM_MEMORY_VIDEOBITSTREAM, @"Video Bitstream");
			
#if defined(MAC_OS_X_VERSION_10_14) && MAC_OS_X_VERSION_MAX_ALLOWED >= MAC_OS_X_VERSION_10_14
			ZGHandleUserTagCaseWithDescription(userTagDescription, VM_MEMORY_CM_XPC, @"Core Media XPC");
			ZGHandleUserTagCaseWithDescription(userTagDescription, VM_MEMORY_CM_RPC, @"Core Media RPC");
			ZGHandleUserTagCaseWithDescription(userTagDescription, VM_MEMORY_CM_MEMORYPOOL, @"Core Media Memory Pool");
			ZGHandleUserTagCaseWithDescription(userTagDescription, VM_MEMORY_CM_READCACHE, @"Core Media Read Cache");
			ZGHandleUserTagCaseWithDescription(userTagDescription, VM_MEMORY_CM_CRABS, @"Core Media Crabs");
			ZGHandleUserTagCase(userTagDescription, VM_MEMORY_QUICKLOOK_THUMBNAILS);
			ZGHandleUserTagCase(userTagDescription, VM_MEMORY_ACCOUNTS);
#endif
			
#if defined(MAC_OS_X_VERSION_10_15) && MAC_OS_X_VERSION_MAX_ALLOWED >= MAC_OS_X_VERSION_10_15
			ZGHandleUserTagCase(userTagDescription, VM_MEMORY_SANITIZER);
			ZGHandleUserTagCase(userTagDescription, VM_MEMORY_IOACCELERATOR);
			ZGHandleUserTagCase(userTagDescription, VM_MEMORY_CM_REGWARP);
#endif
			
#if defined(MAC_OS_VERSION_11_0) && MAC_OS_X_VERSION_MAX_ALLOWED >= MAC_OS_VERSION_11_0
			ZGHandleUserTagCaseWithDescription(userTagDescription, VM_MEMORY_EAR_DECODER, @"Embedded Acoustic Recognition Decoder");
			
			ZGHandleUserTagCase(userTagDescription, VM_MEMORY_ROSETTA);
			ZGHandleUserTagCase(userTagDescription, VM_MEMORY_ROSETTA_THREAD_CONTEXT);
			ZGHandleUserTagCase(userTagDescription, VM_MEMORY_ROSETTA_INDIRECT_BRANCH_MAP);
			ZGHandleUserTagCase(userTagDescription, VM_MEMORY_ROSETTA_RETURN_STACK);
			ZGHandleUserTagCase(userTagDescription, VM_MEMORY_ROSETTA_EXECUTABLE_HEAP);
			ZGHandleUserTagCase(userTagDescription, VM_MEMORY_ROSETTA_USER_LDT);
			ZGHandleUserTagCase(userTagDescription, VM_MEMORY_ROSETTA_ARENA);
			ZGHandleUserTagCase(userTagDescription, VM_MEMORY_ROSETTA_10);
#endif
	}
	
	return userTagDescription;
}

NSString *ZGUserTagDescriptionFromAddress(ZGMemoryMap processTask, ZGMemoryAddress address, ZGMemorySize size)
{
	NSString *userTagDescription = nil;
	ZGMemoryAddress regionAddress = address;
	ZGMemorySize regionSize = size;
	ZGMemoryExtendedInfo extendedInfo;
	if (ZGRegionExtendedInfo(processTask, &regionAddress, &regionSize, &extendedInfo) && regionAddress <= address && address + size <= regionAddress + regionSize)
	{
		userTagDescription = ZGUserTagDescription(extendedInfo.user_tag);
	}
	return userTagDescription;
}
