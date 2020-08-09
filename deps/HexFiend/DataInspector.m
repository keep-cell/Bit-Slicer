/* Copyright (c) 2005-2011, Peter Ammon
 * All rights reserved.
 * Redistribution and use in source and binary forms, with or without
 * modification, are permitted provided that the following conditions are met:
 *
 *     * Redistributions of source code must retain the above copyright
 *       notice, this list of conditions and the following disclaimer.
 *     * Redistributions in binary form must reproduce the above copyright
 *       notice, this list of conditions and the following disclaimer in the
 *       documentation and/or other materials provided with the distribution.
 *
 * THIS SOFTWARE IS PROVIDED BY THE REGENTS AND CONTRIBUTORS ``AS IS'' AND ANY
 * EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED
 * WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
 * DISCLAIMED. IN NO EVENT SHALL THE REGENTS AND CONTRIBUTORS BE LIABLE FOR ANY
 * DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES
 * (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES;
 * LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND
 * ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
 * (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS
 * SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
 */

//
//  DataInspector.m
//  HexFiend_2
//
//  Copyright © 2019 ridiculous_fish. All rights reserved.
//

#import "DataInspector.h"

#import <HexFiend/HFFunctions.h>
#import <HexFiend/HFController.h>
#import <AppKit/AppKit.h>

// Don't want to include these macros, so not using them

#ifndef HFASSERT
#define HFASSERT(x) ;
#endif

#define ZGDataInspectorLocalizationTable @"[Code] Data Inspector"

@implementation DataInspector

+ (DataInspector*)dataInspectorSupplementing:(NSArray*)inspectors {
	DataInspector *ret = [[DataInspector alloc] init];

	enum Endianness_t preferredEndian; // Prefer the most popular endianness among inspectors
	uint32_t present = 0; // Bit set of all inspector types that are already present.
	
	_Static_assert(eEndianCount <= 2, "This part of the code assumes only two supported endianesses.");
	int endianessVote = 0; // +1 for enum == 0, -1 enum != 0.
	for(DataInspector *di in inspectors) {
		endianessVote += !di->endianness ? 1 : -1;
		present |= (uint32_t)(1 << di->inspectorType << di->endianness*eInspectorTypeCount);
	}
	preferredEndian = endianessVote < 0;
	
	uint32_t pref = (~present >> preferredEndian*eInspectorTypeCount) & ((1<<eInspectorTypeCount)-1);
	if(pref) { // There is a missing inspector type for preffered endianness, pick that one.
		ret->endianness = preferredEndian;
		ret->inspectorType = (enum InspectorType_t)(__builtin_ffs((int32_t)pref)-1);
		return ret;
	}
	
	// Pick an absent inspector type.
	int x = (__builtin_ffs((int32_t)(~present))-1);
	enum Endianness_t y = (enum Endianness_t)(x/eInspectorTypeCount);
	enum InspectorType_t z = x % eInspectorTypeCount;
	
	if(x < 0 || y >= eEndianCount || z >= eInspectorTypeCount) // No absent inspector type
		return ret;
	
	ret->endianness = y;
	ret->inspectorType = z;
	return ret;
}

- (void)encodeWithCoder:(NSCoder *)coder {
	HFASSERT([coder allowsKeyedCoding]);
	[coder encodeInt32:(int32_t)inspectorType forKey:@"InspectorType"];
	[coder encodeInt32:(int32_t)endianness forKey:@"Endianness"];
	[coder encodeInt32:(int32_t)numberBase forKey:@"NumberBase"];
}

- (instancetype)initWithCoder:(NSCoder *)coder {
	HFASSERT([coder allowsKeyedCoding]);
	self = [super init];
	inspectorType = (enum InspectorType_t)[coder decodeInt32ForKey:@"InspectorType"];
	endianness = (enum Endianness_t)[coder decodeInt32ForKey:@"Endianness"];
	numberBase = (enum NumberBase_t)[coder decodeInt32ForKey:@"NumberBase"];
	return self;
}

- (void)setType:(enum InspectorType_t)type {
	inspectorType = type;
}

- (enum InspectorType_t)type {
	return inspectorType;
}

- (void)setEndianness:(enum Endianness_t)end {
	endianness = end;
}

- (enum Endianness_t)endianness {
	return endianness;
}

- (void)setNumberBase:(enum NumberBase_t)base {
	numberBase = base;
}

- (enum NumberBase_t)numberBase {
	return numberBase;
}

- (NSUInteger)hash {
	return inspectorType + (endianness << 8UL);
}

- (BOOL)isEqual:(id)him {
	if (! [(id <NSObject>)him isKindOfClass:[DataInspector class]]) return NO;
	return inspectorType == ((DataInspector *)him)->inspectorType && endianness == ((DataInspector *)him)->endianness && numberBase == ((DataInspector *)him)->numberBase;
}

static uint64_t reverse(uint64_t val, NSUInteger amount) {
	/* Transfer amount bytes from input to output in reverse order */
	uint64_t input = val, output = 0;
	NSUInteger remaining = amount;
	while (remaining--) {
		unsigned char byte = input & 0xFF;
		output = (output << CHAR_BIT) | byte;
		input >>= CHAR_BIT;
	}
	return output;
}

static void flip(void *val, NSUInteger amount) {
	uint8_t *bytes = (uint8_t *)val;
	NSUInteger i;
	for (i = 0; i < amount / 2; i++) {
		uint8_t tmp = bytes[amount - i - 1];
		bytes[amount - i - 1] = bytes[i];
		bytes[i] = tmp;
	}
}

#define FETCH(type) type s = *(const type *)(const void *)bytes;
#define FLIP(amount) if (endianness != eNativeEndianness) { flip(&s, amount); }
#define FORMAT(decSpecifier, hexSpecifier) return [NSString stringWithFormat:numberBase == eNumberBaseDecimal ? decSpecifier : hexSpecifier, s];
static id signedIntegerDescription(const unsigned char *bytes, NSUInteger length, enum Endianness_t endianness, enum NumberBase_t numberBase) {
	switch (length) {
		case 1:
		{
			FETCH(int8_t)
			FORMAT(@"%" PRId8, @"0x%" PRIX8);
		}
		case 2:
		{
			FETCH(int16_t)
			FLIP(2)
			FORMAT(@"%" PRId16, @"0x%" PRIX16)
		}
		case 4:
		{
			FETCH(int32_t)
			FLIP(4)
			FORMAT(@"%" PRId32, @"0x%" PRIX32)
		}
		case 8:
		{
			FETCH(int64_t)
			FLIP(8)
			FORMAT(@"%" PRId64, @"0x%" PRIX64)
		}
		case 16:
		{
			FETCH(__int128_t)
			FLIP(16)
			BOOL neg;
			if (s < 0) {
				s=-s;
				neg = YES;
			} else {
				neg = NO;
			}
			char buf[50], *b = buf;
			while(s) {
				*(b++) = (char)(s%10)+'0';
				s /= 10;
			}
			*b = 0;
			flip(buf, (NSUInteger)(b-buf));
			return [NSString stringWithFormat:@"%s%s", (neg?"-":""), buf];
		}
		default: return nil;
	}
}

static id unsignedIntegerDescription(const unsigned char *bytes, NSUInteger length, enum Endianness_t endianness, enum NumberBase_t numberBase) {
	switch (length) {
		case 1:
		{
			FETCH(uint8_t)
			FORMAT(@"%" PRIu8, @"0x%" PRIX8);
		}
		case 2:
		{
			FETCH(uint16_t)
			FLIP(2)
			FORMAT(@"%" PRIu16, @"0x%" PRIX16)
		}
		case 4:
		{
			FETCH(uint32_t)
			FLIP(4)
			FORMAT(@"%" PRIu32, @"0x%" PRIX32)
		}
		case 8:
		{
			FETCH(uint64_t)
			FLIP(8)
			FORMAT(@"%" PRIu64, @"0x%" PRIX64)
		}
		case 16:
		{
			FETCH(__uint128_t)
			FLIP(16)
			char buf[50], *b = buf;
			while(s) {
				*(b++) = (char)(s%10)+'0';
				s /= 10;
			}
			*b = 0;
			flip(buf, (NSUInteger)(b-buf));
			return [NSString stringWithFormat:@"%s", buf];
		}
		default: return nil;
	}
}
#undef FETCH
#undef FLIP
#undef FORMAT

static long double ieeeToLD(const void *bytes, unsigned exp, unsigned man) {
	__uint128_t b = 0;
	memcpy(&b, bytes, (1 + exp + man + 7)/8);
	
	__uint128_t m = b << (1+exp) >> (128 - man);
	int64_t e = (int64_t)(b << 1 >> (128 - exp));
	unsigned s = b >> 127;
	
	if(e) {
		if(e ^ (int64_t)((1ULL<<exp)-1)) {
			// normal
			int64_t e2 = e + 1 - (int64_t)(1ULL<<(exp-1));
			long double t = ldexpl(m, (int)(e2-man)) + ldexpl(1, (int)e2);
			return s ? -t : t;
		} else {
			if(m) {
				// nan
				return __builtin_nanl(""); // No attempt to translate codes.
			} {
				// infinity
				return s ? __builtin_infl() : -__builtin_infl();
			}
		}
	} else {
		if(m) {
			// subnormal
			int64_t e2 = 2 - (int64_t)(1ULL<<(exp-1));
			long double t = ldexpl(m, (int)(e2-man));
			return s ? -t : t;
		} else {
			// zero
			return s ? -0.0L : 0.0L;
		}
	}
}

static id floatingPointDescription(const unsigned char *bytes, NSUInteger length, enum Endianness_t endianness) {
	switch (length) {
		case sizeof(float):
		{
			union {
				uint32_t i;
				float f;
			} temp;
			_Static_assert(sizeof temp.f == sizeof temp.i, "sizeof(float) is not 4!");
			temp.i = *(const uint32_t *)(const void *)bytes;
			if (endianness != eNativeEndianness) temp.i = (uint32_t)reverse(temp.i, sizeof(float));
			return [NSString stringWithFormat:@"%.15g", (double)temp.f];
		}
		case sizeof(double):
		{
			union {
				uint64_t i;
				double f;
			} temp;
			_Static_assert(sizeof temp.f == sizeof temp.i, "sizeof(double) is not 8!");
			temp.i = *(const uint64_t *)(const void *)bytes;
			if (endianness != eNativeEndianness) temp.i = reverse(temp.i, sizeof(double));
			return [NSString stringWithFormat:@"%.15g", temp.f];
		}
#ifndef __arm64__ // TODO
		case 10:
		{
			typedef float __attribute__((mode(XF))) float80;
			union {
				uint8_t i[10];
				float80 f;
			} temp;
			if (endianness == eNativeEndianness) {
				memcpy(temp.i, bytes, 10);
			} else {
				for(unsigned i = 0; i < 10; i++) {
					temp.i[9 - i] = bytes[i];
				}
			}
			return [NSString stringWithFormat:@"%.15Lg", (long double)temp.f];
		}
#endif
		case 16:
		{
			//typedef float __attribute__((mode(TF))) float128; // Here's to hoping clang support comes one day.
			uint64_t temp[2];
			temp[0] = ((const uint64_t*)(const void *)bytes)[0];
			temp[1] = ((const uint64_t*)(const void *)bytes)[1];
			if (endianness != eNativeEndianness) {
				uint64_t t = temp[0];
				temp[0] = reverse(temp[1], 8);
				temp[1] = reverse(t, 8);
			}
			return [NSString stringWithFormat:@"%.15Lg", ieeeToLD(temp, 15, 112)];
		}
		default: return nil;
	}
}

static NSString * const InspectionErrorNoDataKey =  @"noData";
static NSString * const InspectionErrorTooMuchKey = @"tooMuchData";
static NSString * const InspectionErrorTooLittleKey = @"tooLittleData";
static NSString * const InspectionErrorInvalidUTF8BytesKey = @"invalidUTF8Bytes";
static NSString * const InspectionErrorNonPwr2Key = @"badByteCount";
static NSString * const InspectionErrorInternalKey = @"internalError";

static NSAttributedString *inspectionError(NSString *s) {
	NSMutableParagraphStyle *paragraphStyle = [[NSParagraphStyle defaultParagraphStyle] mutableCopy];
	[paragraphStyle setMinimumLineHeight:(CGFloat)16.];
	NSAttributedString *result = [[NSAttributedString alloc] initWithString:s attributes:@{NSForegroundColorAttributeName: [NSColor disabledControlTextColor], NSFontAttributeName: [NSFont controlContentFontOfSize:11], NSParagraphStyleAttributeName: paragraphStyle}];
	return result;
}

- (id)valueForController:(HFController *)controller ranges:(NSArray *)ranges isError:(BOOL *)outIsError {
	/* Just do a rough cut on length before going to valueForData. */
	
	if ([ranges count] != 1) {
		if(outIsError) *outIsError = YES;
		return inspectionError(NSLocalizedStringFromTable(@"contiguousRange", ZGDataInspectorLocalizationTable, nil));
	}
	HFRange range = [(HFRangeWrapper *)ranges[0] HFRange];
	
	if(range.length == 0) {
		if(outIsError) *outIsError = YES;
		return inspectionError(NSLocalizedStringFromTable(InspectionErrorNoDataKey, ZGDataInspectorLocalizationTable, nil));
	}
	
	if(range.length > MAX_EDITABLE_BYTE_COUNT) {
		if(outIsError) *outIsError = YES;
		return inspectionError(NSLocalizedStringFromTable(InspectionErrorTooMuchKey, ZGDataInspectorLocalizationTable, nil));
	}
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wcovered-switch-default"
	switch ([self type]) {
		case eInspectorTypeUnsignedInteger:
		case eInspectorTypeSignedInteger:
		case eInspectorTypeFloatingPoint:
			if(range.length > 16) {
				if(outIsError) *outIsError = YES;
				return inspectionError(NSLocalizedStringFromTable(InspectionErrorTooMuchKey, ZGDataInspectorLocalizationTable, nil));
			}
			break;
		case eInspectorTypeUTF8Text:
			// MAX_EDITABLE_BYTE_COUNT already checked above
			break;
		case eInspectorTypeSLEB128:
		case eInspectorTypeULEB128:
		case eInspectorTypeBinary:
			if(range.length > 24) {
				if(outIsError) *outIsError = YES;
				return inspectionError(NSLocalizedStringFromTable(InspectionErrorTooMuchKey, ZGDataInspectorLocalizationTable, nil));
			}
			break;
		case eInspectorTypeCount:
		default:
			if(outIsError) *outIsError = YES;
			return inspectionError(NSLocalizedStringFromTable(InspectionErrorInternalKey, ZGDataInspectorLocalizationTable, nil));
	}
#pragma clang diagnostic pop
	
	return [self valueForData:[controller dataForRange:range] isError:outIsError];
}

- (id)valueForData:(NSData *)data isError:(BOOL *)outIsError {
	return [self valueForBytes:[data bytes] length:[data length] isError:outIsError];
}

- (id)valueForBytes:(const unsigned char *)bytes length:(NSUInteger)length isError:(BOOL *)outIsError {
	if(outIsError) *outIsError = YES;
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wcovered-switch-default"
	switch ([self type]) {
		case eInspectorTypeUnsignedInteger:
		case eInspectorTypeSignedInteger:
			/* Only allow powers of 2 up to 8 */
			switch (length) {
				case 0: return inspectionError(NSLocalizedStringFromTable(InspectionErrorNoDataKey, ZGDataInspectorLocalizationTable, nil));
				case 1: case 2: case 4: case 8:
					if(outIsError) *outIsError = NO;
					if(inspectorType == eInspectorTypeSignedInteger)
						return signedIntegerDescription(bytes, length, endianness, numberBase);
					else
						return unsignedIntegerDescription(bytes, length, endianness, numberBase);
				default:
					return length > 8 ? inspectionError(NSLocalizedStringFromTable(InspectionErrorTooMuchKey, ZGDataInspectorLocalizationTable, nil)) : inspectionError(NSLocalizedStringFromTable(InspectionErrorNonPwr2Key, ZGDataInspectorLocalizationTable, nil));
			}
		
		case eInspectorTypeFloatingPoint:
			switch (length) {
				case 0:
					return inspectionError(NSLocalizedStringFromTable(InspectionErrorNoDataKey, ZGDataInspectorLocalizationTable, nil));
				case 1: case 2: case 3:
					return inspectionError(NSLocalizedStringFromTable(InspectionErrorTooLittleKey, ZGDataInspectorLocalizationTable, nil));
				case 4: case 8: case 10: case 16:
					if(outIsError) *outIsError = NO;
					return floatingPointDescription(bytes, length, endianness);
				default:
					return length > 16 ? inspectionError(NSLocalizedStringFromTable(InspectionErrorTooMuchKey, ZGDataInspectorLocalizationTable, nil)) : inspectionError(NSLocalizedStringFromTable(InspectionErrorNonPwr2Key, ZGDataInspectorLocalizationTable, nil));
			}
				
		case eInspectorTypeUTF8Text: {
			if(length == 0) return inspectionError(NSLocalizedStringFromTable(InspectionErrorNoDataKey, ZGDataInspectorLocalizationTable, nil));
			if(length > MAX_EDITABLE_BYTE_COUNT) return inspectionError(NSLocalizedStringFromTable(InspectionErrorTooMuchKey, ZGDataInspectorLocalizationTable, nil));
			NSString *ret = [[NSString alloc] initWithBytes:bytes length:length encoding:NSUTF8StringEncoding];
			if(ret == nil) return inspectionError(NSLocalizedStringFromTable(InspectionErrorInvalidUTF8BytesKey, ZGDataInspectorLocalizationTable, nil));
			if(outIsError) *outIsError = NO;
			return ret;
		}
		case eInspectorTypeBinary: {
			if(outIsError) *outIsError = NO;
			NSString* ret = @"";
			
			for (NSUInteger i = 0; i < length; ++i) {
				unsigned char input = bytes[i];

				char binary[] = "00000000";
				
				if ( input & 0x80 )
					binary[0] = '1';
				
				if ( input & 0x40 )
					binary[1] = '1';
				
				if ( input & 0x20 )
					binary[2] = '1';
				
				if ( input & 0x10 )
					binary[3] = '1';
				
				if ( input & 0x08 )
					binary[4] = '1';
				
				if ( input & 0x04 )
					binary[5] = '1';
				
				if ( input & 0x02 )
					binary[6] = '1';
				
				if ( input & 0x01 )
					binary[7] = '1';

				ret = [ret stringByAppendingFormat:@"%s ", binary ];
			}
			
			return  ret;
		}
		
		case eInspectorTypeSLEB128: {
			int64_t result = 0;
			int shift = 0;
			for (size_t i = 0; i < length; i++) {
				result |= ((bytes[i] & 0x7F) << shift);
				shift += 7;
				
				if ((bytes[i] & 0x80) == 0) {
					if (shift < 64 && (bytes[i] & 0x40)) {
						result |= -(1 << shift);
					}
					return [NSString stringWithFormat:@"%lld (%ld bytes)", result, i + 1];
				}
			}
			
			return inspectionError(NSLocalizedStringFromTable(InspectionErrorTooLittleKey, ZGDataInspectorLocalizationTable, nil));
		}
		
		case eInspectorTypeULEB128: {
			uint64_t result = 0;
			int shift = 0;
			for (size_t i = 0; i < length; i++) {
				result |= (uint64_t)((bytes[i] & 0x7F) << shift);
				shift += 7;
				
				if ((bytes[i] & 0x80) == 0) {
					return [NSString stringWithFormat:@"%llu (%ld bytes)", result, i + 1];
				}
			}
			
			return inspectionError(NSLocalizedStringFromTable(InspectionErrorTooLittleKey, ZGDataInspectorLocalizationTable, nil));
		}
		
		case eInspectorTypeCount:
		default:
			return inspectionError(NSLocalizedStringFromTable(InspectionErrorInternalKey, ZGDataInspectorLocalizationTable, nil));
	}
#pragma clang diagnostic pop
}

static BOOL valueCanFitInByteCount(unsigned long long unsignedValue, NSUInteger count) {
	long long signedValue = (long long)unsignedValue;
	switch (count) {
	case 1:
		return unsignedValue <= UINT8_MAX || (signedValue <= INT8_MAX && signedValue >= INT8_MIN);
	case 2:
		return unsignedValue <= UINT16_MAX || (signedValue <= INT16_MAX && signedValue >= INT16_MIN);
	case 4:
		return unsignedValue <= UINT32_MAX || (signedValue <= INT32_MAX && signedValue >= INT32_MIN);
	case 8:
		return unsignedValue <= UINT64_MAX || (signedValue <= INT64_MAX && signedValue >= INT64_MIN);
	default:
		return NO;
	}
}

static BOOL stringRangeIsNullBytes(NSString *string, NSRange range) {
	static const int bufferChars = 256;
	static const unichar zeroBuf[bufferChars] = {0}; //unicode null bytes
	unichar buffer[bufferChars];
	
	NSRange r = NSMakeRange(range.location, bufferChars);
	
	if(range.length > bufferChars) { // No underflow please.
		NSUInteger lastBlock = range.location + range.length - bufferChars;
		for(; r.location < lastBlock; r.location += bufferChars) {
			[string getCharacters:buffer range:r];
			if(memcmp(buffer, zeroBuf, bufferChars)) return NO;
		}
	}

	// Handle the uneven bytes at the end.
	r.length = range.location + range.length - r.location;
	[string getCharacters:buffer range:r];
	if(memcmp(buffer, zeroBuf, r.length)) return NO;

	return YES;
}

- (BOOL)acceptStringValue:(NSString *)value replacingByteCount:(NSUInteger)count intoData:(unsigned char *)outData {
	if (inspectorType == eInspectorTypeUnsignedInteger || inspectorType == eInspectorTypeSignedInteger) {
		if (numberBase == eNumberBaseHexadecimal) {
			NSScanner *scanner = [NSScanner scannerWithString:value];
			unsigned long long unsignedHexValue = 0;
			if (![scanner scanHexLongLong:&unsignedHexValue]) {
				NSLog(@"Invalid hex value %@", value);
				return NO;
			}
			value = [NSString stringWithFormat:@"%llu", unsignedHexValue];
		}
		
		char buffer[256];
		BOOL success = [value getCString:buffer maxLength:sizeof buffer encoding:NSASCIIStringEncoding];
		if (! success) return NO;

		if (! (count == 1 || count == 2 || count == 4 || count == 8)) return NO;
	
		errno = 0;
		char *endPtr = NULL;
		/* note that strtoull handles negative values */
		unsigned long long unsignedValue = strtoull(buffer, &endPtr, 0);
		int resultError = errno;
		
		/* Make sure we consumed some of the string */
		if (endPtr == buffer) return NO;
		
		/* Check for conversion errors (overflow, etc.) */
		if (resultError != 0) return NO;
		
		/* Now check to make sure we fit */
		if (! valueCanFitInByteCount(unsignedValue, count)) return NO;
		
		if (outData == NULL) return YES; // No need to continue if we're not outputting

		/* Get all 8 bytes in big-endian form */
		unsigned long long consumableValue = unsignedValue;
		unsigned char bytes[8];
		unsigned i = 8;
		while (i--) {
			bytes[i] = consumableValue & 0xFF;
			consumableValue >>= 8;
		}
	
		/* Now copy the last (least significant) 'count' bytes to outData in the requested endianness */
		for (i=0; i < count; i++) {
			unsigned char byte = bytes[(8 - count + i)];
			if (endianness == eEndianBig) {
				outData[i] = byte;
			}
			else {
				outData[count - i - 1] = byte;
			}
		}
	
		/* Victory */
		return YES;
	}
	else if (inspectorType == eInspectorTypeFloatingPoint) {
		char buffer[256];
		BOOL success = [value getCString:buffer maxLength:sizeof buffer encoding:NSASCIIStringEncoding];
		if (! success) return NO;

		union {
			float  f;
			double d;
#ifndef __arm64__ // TODO
			float __attribute__((mode(XF))) x;
#endif
			__uint128_t t; // Maybe clang will support mode(TF) one day.
		} val;

		char *endPtr = NULL;
		errno = 0;
		
		switch(count) {
			case 4: val.f = strtof(buffer, &endPtr); break;
			case 8: val.d = strtod(buffer, &endPtr); break;
#ifndef __arm64__ // TODO
			case 10: val.x = strtold(buffer, &endPtr); break;
			case 16: {
				val.x = strtold(buffer, &endPtr);
				val.t = (val.t >> 64 << 112) | (val.t << 48 << 17 >> 16);
				break;
			}
#endif
			default: return NO;
		}
		
		if (errno != 0) return NO; // Check for conversion errors (overflow, etc.)
		if (endPtr == buffer) return NO; // Make sure we consumed some of the string

		if (outData == NULL) return YES; // No need to continue if we're not outputting
		
		unsigned char bytes[sizeof(val)];
		memcpy(bytes, &val, count);
		
		/* Now copy the first 'count' bytes to outData in the requested endianness.  This is different from the integer case - there we always work big-endian because we support more different byteCounts, but here we work in the native endianness because there's no simple way to convert a float or double to big endian form */
		for (NSUInteger i = 0; i < count; i++) {
			if (endianness == eNativeEndianness) {
				outData[i] = bytes[i];
			} else {
				outData[count - i - 1] = bytes[i];
			}
		}
		
		/* Return triumphantly! */
		return YES;
	}
	else if (inspectorType == eInspectorTypeUTF8Text) {
		/*
		 * If count is longer than the UTF-8 encoded value, succeed and zero fill
		 * the rest of outbuf. It's obvious behavior and probably more useful than
		 * only allowing an exact length UTF-8 replacement.
		 *
		 * By the same token, allow ending zero bytes to be dropped, so re-editing
		 * the same text doesn't fail due to the null bytes we added at the end.
		 */
		
		unsigned char buffer_[256];
		unsigned char *buffer = buffer_;
		NSUInteger used;
		BOOL ret;
		NSRange fullRange = NSMakeRange(0, [value length]);
		NSRange leftover;
		
		// Speculate that 256 chars is enough.
		ret = [value getBytes:buffer maxLength:count < sizeof(buffer_) ? count : sizeof(buffer_) usedLength:&used
					 encoding:NSUTF8StringEncoding options:0 range:fullRange remainingRange:&leftover];
		
		if(!ret) return NO;
		if(leftover.length == 0 || stringRangeIsNullBytes(value, leftover)) {
			// Buffer was large enough, yay!
			if(outData) {
				memcpy(outData, buffer, used);
				memset(outData+used, 0, count-used);
			}
			return YES;
		}
		
		// Buffer wasn't large enough.
		// Don't bother trying to reuse previous conversion, it's small beans anyways.
		
		if(!outData) return count <= [value lengthOfBytesUsingEncoding:NSUTF8StringEncoding];
		
		buffer = malloc(count);
		ret = [value getBytes:buffer maxLength:count usedLength:&used encoding:NSUTF8StringEncoding
					  options:0 range:fullRange remainingRange:&leftover];
		ret = ret && (leftover.length == 0 || stringRangeIsNullBytes(value, leftover)) && used <= count;
		if(ret) {
			memcpy(outData, buffer, used);
			memset(outData+used, 0, count-used);
		}
		free(buffer);
		return ret;
	}
	else if (inspectorType == eInspectorTypeBinary) {
		if (value.length != (count * 8)) {
			return NO;
		}
		for (NSUInteger i = 0; i < value.length; i++) {
			const unichar ch = [value characterAtIndex:i];
			if (ch != '0' && ch != '1') {
				return NO;
			}
		}
		if (outData) {
			for (NSUInteger byteIndex = 0; byteIndex < count; byteIndex++) {
				NSString *bitsStr = [value substringWithRange:NSMakeRange(byteIndex * 8, 8)];
				outData[byteIndex] = bitStringToValue(bitsStr);
			}
		}
		return YES;
	}
	else {
		/* Unknown inspector type */
		return NO;
	}
}

static uint8_t bitStringToValue(NSString *value) {
	HFASSERT(value.length == 8);
	uint8_t byte = 0;
	NSRange range = NSMakeRange(0, 1);
	for (NSUInteger stringIndex = 0; stringIndex < value.length; stringIndex++, range.location++) {
		const uint8_t bitValue = (uint8_t)[value substringWithRange:range].intValue;
		byte |= bitValue << ((value.length - 1) - stringIndex);
	}
	return byte;
}

- (id)propertyListRepresentation {
	return @{
		@"InspectorType": @(inspectorType),
		@"Endianness": @(endianness),
		@"NumberBase": @(numberBase),
	};
}

- (void)setPropertyListRepresentation:(id)plist {
	inspectorType = (enum InspectorType_t)[(NSNumber *)plist[@"InspectorType"] intValue];
	endianness = (enum Endianness_t)[(NSNumber *)plist[@"Endianness"] intValue];
	numberBase = (enum NumberBase_t)[(NSNumber *)plist[@"NumberBase"] intValue];
}

@end
