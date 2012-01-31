
#import <servers/netname.h>
#import <libc.h>

#include "../client/client.h"

double	snd_basetime;
port_t devPort;

extern	port_t	task_self_;
#define	task_self()	task_self_

//========================================================================

#ifndef	_ntsoundNTSound
#define	_ntsoundNTSound

/* Module NTSound */

#include <mach/kern_return.h>
#include <mach/port.h>
#include <mach/message.h>

#ifndef	mig_external
#define mig_external extern
#endif

#include <mach/std_types.h>
#include <mach/mach_types.h>
typedef short *sound_data_t;

#define NTSOUNDNAME "NEXTIME_Sound"

/* Routine ntsoundAcquire */
mig_external kern_return_t ntsoundAcquire (
        port_t kern_serv_port,
        port_t owner_port,
        vm_offset_t *dmaAddress,
        int *dmaSize,
        int *success);

/* Routine ntsoundRelease */
mig_external kern_return_t ntsoundRelease (
        port_t kern_serv_port,
        port_t owner_port);

/* Routine ntsoundStart */
mig_external kern_return_t ntsoundStart (
        port_t kern_serv_port,
        port_t owner_port);

/* Routine ntsoundStop */
mig_external kern_return_t ntsoundStop (
        port_t kern_serv_port,
        port_t owner_port);

/* Routine ntsoundConfig */
mig_external kern_return_t ntsoundConfig (
        port_t kern_serv_port,
        port_t owner_port,
        int channelCount,
        int samplingRate,
        int encoding,
        int useInterrupts);

/* Routine ntsoundBytesProcessed */
mig_external kern_return_t ntsoundBytesProcessed (
        port_t kern_serv_port,
        port_t owner_port,
        int *byte_count);

/* Routine ntsoundDMACount */
mig_external kern_return_t ntsoundDMACount (
        port_t kern_serv_port,
        port_t owner_port,
        int *dma_count);

/* Routine ntsoundInterruptCount */
mig_external kern_return_t ntsoundInterruptCount (
        port_t kern_serv_port,
        port_t owner_port,
        int *irq_count);

/* Routine ntsoundWrite */
mig_external kern_return_t ntsoundWrite (
        port_t kern_serv_port,
        port_t owner_port,
        sound_data_t data,
        unsigned int dataCnt,
        int *actual_count);

/* Routine ntsoundSetVolume */
mig_external kern_return_t ntsoundSetVolume (
        port_t kern_serv_port,
        port_t owner_port,
        int value);

/* Routine ntsoundWireRange */
mig_external kern_return_t ntsoundWireRange (
        port_t device_port,
        port_t token,
        port_t task,
        vm_offset_t addr,
        vm_size_t size,
        boolean_t wire);

#endif	_ntsoundNTSound

//========================================================================

extern	port_t	name_server_port;

#define NX_SoundDeviceParameterKeyBase		0
#define NX_SoundDeviceParameterValueBase	200
#define NX_SoundStreamParameterKeyBase		400
#define NX_SoundStreamParameterValueBase	600
#define NX_SoundParameterTagMax			799

typedef enum _NXSoundParameterTag {
   NX_SoundDeviceBufferSize = NX_SoundDeviceParameterKeyBase,
   NX_SoundDeviceBufferCount,
   NX_SoundDeviceDetectPeaks,
   NX_SoundDeviceRampUp,
   NX_SoundDeviceRampDown,
   NX_SoundDeviceInsertZeros,
   NX_SoundDeviceDeemphasize,
   NX_SoundDeviceMuteSpeaker,
   NX_SoundDeviceMuteHeadphone,
   NX_SoundDeviceMuteLineOut,
   NX_SoundDeviceOutputLoudness,
   NX_SoundDeviceOutputAttenuationStereo,
   NX_SoundDeviceOutputAttenuationLeft,
   NX_SoundDeviceOutputAttenuationRight,
   NX_SoundDeviceAnalogInputSource,
   NX_SoundDeviceMonitorAttenuation,
   NX_SoundDeviceInputGainStereo,
   NX_SoundDeviceInputGainLeft,
   NX_SoundDeviceInputGainRight,

   NX_SoundDeviceAnalogInputSource_Microphone
       = NX_SoundDeviceParameterValueBase,
   NX_SoundDeviceAnalogInputSource_LineIn,

   NX_SoundStreamDataEncoding = NX_SoundStreamParameterKeyBase,
   NX_SoundStreamSamplingRate,
   NX_SoundStreamChannelCount,
   NX_SoundStreamHighWaterMark,
   NX_SoundStreamLowWaterMark,
   NX_SoundStreamSource,
   NX_SoundStreamSink,
   NX_SoundStreamDetectPeaks,
   NX_SoundStreamGainStereo,
   NX_SoundStreamGainLeft,
   NX_SoundStreamGainRight,

   NX_SoundStreamDataEncoding_Linear16 = NX_SoundStreamParameterValueBase,
   NX_SoundStreamDataEncoding_Linear8,
   NX_SoundStreamDataEncoding_Mulaw8,
   NX_SoundStreamDataEncoding_Alaw8,
   NX_SoundStreamDataEncoding_AES,
   NX_SoundStreamSource_Analog,
   NX_SoundStreamSource_AES,
   NX_SoundStreamSink_Analog,
   NX_SoundStreamSink_AES
} NXSoundParameterTag;

//========================================================================

//#include "NTSound.h"
#include <mach/mach_types.h>
#include <mach/message.h>
#include <mach/mig_errors.h>
#include <mach/msg_type.h>
#if	!defined(KERNEL) && !defined(MIG_NO_STRINGS)
#include <strings.h>
#endif
/* LINTLIBRARY */

extern port_t mig_get_reply_port();
extern void mig_dealloc_reply_port();

#ifndef	mig_internal
#define	mig_internal	static
#endif

#ifndef	TypeCheck
#define	TypeCheck 1
#endif

#ifndef	UseExternRCSId
#ifdef	hc
#define	UseExternRCSId		1
#endif
#endif

#ifndef	UseStaticMsgType
#if	!defined(hc) || defined(__STDC__)
#define	UseStaticMsgType	1
#endif
#endif

#define msg_request_port	msg_remote_port
#define msg_reply_port		msg_local_port


/* Routine Acquire */
mig_external kern_return_t ntsoundAcquire (
        port_t kern_serv_port,
        port_t owner_port,
        vm_offset_t *dmaAddress,
        int *dmaSize,
        int *success)
{
        typedef struct {
                msg_header_t Head;
                msg_type_t owner_portType;
                port_t owner_port;
        } Request;

        typedef struct {
                msg_header_t Head;
                msg_type_t RetCodeType;
                kern_return_t RetCode;
                msg_type_t dmaAddressType;
                vm_offset_t dmaAddress;
                msg_type_t dmaSizeType;
                int dmaSize;
                msg_type_t successType;
                int success;
        } Reply;

        union {
                Request In;
                Reply Out;
        } Mess;

        register Request *InP = &Mess.In;
        register Reply *OutP = &Mess.Out;

        msg_return_t msg_result;

#if	TypeCheck
        boolean_t msg_simple;
#endif	TypeCheck

        unsigned int msg_size = 32;

#if	UseStaticMsgType
        static const msg_type_t owner_portType = {
                /* msg_type_name = */		MSG_TYPE_PORT,
                /* msg_type_size = */		32,
                /* msg_type_number = */		1,
                /* msg_type_inline = */		TRUE,
                /* msg_type_longform = */	FALSE,
                /* msg_type_deallocate = */	FALSE,
                /* msg_type_unused = */		0,
        };
#endif	UseStaticMsgType

#if	UseStaticMsgType
        static const msg_type_t RetCodeCheck = {
                /* msg_type_name = */		MSG_TYPE_INTEGER_32,
                /* msg_type_size = */		32,
                /* msg_type_number = */		1,
                /* msg_type_inline = */		TRUE,
                /* msg_type_longform = */	FALSE,
                /* msg_type_deallocate = */	FALSE,
                /* msg_type_unused = */		0
        };
#endif	UseStaticMsgType

#if	UseStaticMsgType
        static const msg_type_t dmaAddressCheck = {
                /* msg_type_name = */		MSG_TYPE_INTEGER_32,
                /* msg_type_size = */		32,
                /* msg_type_number = */		1,
                /* msg_type_inline = */		TRUE,
                /* msg_type_longform = */	FALSE,
                /* msg_type_deallocate = */	FALSE,
                /* msg_type_unused = */		0
        };
#endif	UseStaticMsgType

#if	UseStaticMsgType
        static const msg_type_t dmaSizeCheck = {
                /* msg_type_name = */		MSG_TYPE_INTEGER_32,
                /* msg_type_size = */		32,
                /* msg_type_number = */		1,
                /* msg_type_inline = */		TRUE,
                /* msg_type_longform = */	FALSE,
                /* msg_type_deallocate = */	FALSE,
                /* msg_type_unused = */		0
        };
#endif	UseStaticMsgType

#if	UseStaticMsgType
        static const msg_type_t successCheck = {
                /* msg_type_name = */		MSG_TYPE_INTEGER_32,
                /* msg_type_size = */		32,
                /* msg_type_number = */		1,
                /* msg_type_inline = */		TRUE,
                /* msg_type_longform = */	FALSE,
                /* msg_type_deallocate = */	FALSE,
                /* msg_type_unused = */		0
        };
#endif	UseStaticMsgType

#if	UseStaticMsgType
        InP->owner_portType = owner_portType;
#else	UseStaticMsgType
        InP->owner_portType.msg_type_name = MSG_TYPE_PORT;
        InP->owner_portType.msg_type_size = 32;
        InP->owner_portType.msg_type_number = 1;
        InP->owner_portType.msg_type_inline = TRUE;
        InP->owner_portType.msg_type_longform = FALSE;
        InP->owner_portType.msg_type_deallocate = FALSE;
#endif	UseStaticMsgType

        InP->owner_port /* owner_port */ = /* owner_port */ owner_port;

        InP->Head.msg_simple = FALSE;
        InP->Head.msg_size = msg_size;
        InP->Head.msg_type = MSG_TYPE_NORMAL | MSG_TYPE_RPC;
        InP->Head.msg_request_port = kern_serv_port;
        InP->Head.msg_reply_port = mig_get_reply_port();
        InP->Head.msg_id = 1008;

        msg_result = msg_rpc(&InP->Head, MSG_OPTION_NONE, sizeof(Reply), 0, 0);
        if (msg_result != RPC_SUCCESS) {
                if (msg_result == RCV_INVALID_PORT)
                        mig_dealloc_reply_port();
                return msg_result;
        }

#if	TypeCheck
        msg_size = OutP->Head.msg_size;
        msg_simple = OutP->Head.msg_simple;
#endif	TypeCheck

        if (OutP->Head.msg_id != 1108)
                return MIG_REPLY_MISMATCH;

#if	TypeCheck
        if (((msg_size != 56) || (msg_simple != TRUE)) &&
            ((msg_size != sizeof(death_pill_t)) ||
             (msg_simple != TRUE) ||
             (OutP->RetCode == KERN_SUCCESS)))
                return MIG_TYPE_ERROR;
#endif	TypeCheck

#if	TypeCheck
#if	UseStaticMsgType
        if (* (int *) &OutP->RetCodeType != * (int *) &RetCodeCheck)
#else	UseStaticMsgType
        if ((OutP->RetCodeType.msg_type_inline != TRUE) ||
            (OutP->RetCodeType.msg_type_longform != FALSE) ||
            (OutP->RetCodeType.msg_type_name != MSG_TYPE_INTEGER_32) ||
            (OutP->RetCodeType.msg_type_number != 1) ||
            (OutP->RetCodeType.msg_type_size != 32))
#endif	UseStaticMsgType
                return MIG_TYPE_ERROR;
#endif	TypeCheck

        if (OutP->RetCode != KERN_SUCCESS)
                return OutP->RetCode;

#if	TypeCheck
#if	UseStaticMsgType
        if (* (int *) &OutP->dmaAddressType != * (int *) &dmaAddressCheck)
#else	UseStaticMsgType
        if ((OutP->dmaAddressType.msg_type_inline != TRUE) ||
            (OutP->dmaAddressType.msg_type_longform != FALSE) ||
            (OutP->dmaAddressType.msg_type_name != MSG_TYPE_INTEGER_32) ||
            (OutP->dmaAddressType.msg_type_number != 1) ||
            (OutP->dmaAddressType.msg_type_size != 32))
#endif	UseStaticMsgType
                return MIG_TYPE_ERROR;
#endif	TypeCheck

        *dmaAddress /* dmaAddress */ = /* *dmaAddress */ OutP->dmaAddress;

#if	TypeCheck
#if	UseStaticMsgType
        if (* (int *) &OutP->dmaSizeType != * (int *) &dmaSizeCheck)
#else	UseStaticMsgType
        if ((OutP->dmaSizeType.msg_type_inline != TRUE) ||
            (OutP->dmaSizeType.msg_type_longform != FALSE) ||
            (OutP->dmaSizeType.msg_type_name != MSG_TYPE_INTEGER_32) ||
            (OutP->dmaSizeType.msg_type_number != 1) ||
            (OutP->dmaSizeType.msg_type_size != 32))
#endif	UseStaticMsgType
                return MIG_TYPE_ERROR;
#endif	TypeCheck

        *dmaSize /* dmaSize */ = /* *dmaSize */ OutP->dmaSize;

#if	TypeCheck
#if	UseStaticMsgType
        if (* (int *) &OutP->successType != * (int *) &successCheck)
#else	UseStaticMsgType
        if ((OutP->successType.msg_type_inline != TRUE) ||
            (OutP->successType.msg_type_longform != FALSE) ||
            (OutP->successType.msg_type_name != MSG_TYPE_INTEGER_32) ||
            (OutP->successType.msg_type_number != 1) ||
            (OutP->successType.msg_type_size != 32))
#endif	UseStaticMsgType
                return MIG_TYPE_ERROR;
#endif	TypeCheck

        *success /* success */ = /* *success */ OutP->success;

        return OutP->RetCode;
}

/* Routine Release */
mig_external kern_return_t ntsoundRelease (
        port_t kern_serv_port,
        port_t owner_port)
{
        typedef struct {
                msg_header_t Head;
                msg_type_t owner_portType;
                port_t owner_port;
        } Request;

        typedef struct {
                msg_header_t Head;
                msg_type_t RetCodeType;
                kern_return_t RetCode;
        } Reply;

        union {
                Request In;
                Reply Out;
        } Mess;

        register Request *InP = &Mess.In;
        register Reply *OutP = &Mess.Out;

        msg_return_t msg_result;

#if	TypeCheck
        boolean_t msg_simple;
#endif	TypeCheck

        unsigned int msg_size = 32;

#if	UseStaticMsgType
        static const msg_type_t owner_portType = {
                /* msg_type_name = */		MSG_TYPE_PORT,
                /* msg_type_size = */		32,
                /* msg_type_number = */		1,
                /* msg_type_inline = */		TRUE,
                /* msg_type_longform = */	FALSE,
                /* msg_type_deallocate = */	FALSE,
                /* msg_type_unused = */		0,
        };
#endif	UseStaticMsgType

#if	UseStaticMsgType
        static const msg_type_t RetCodeCheck = {
                /* msg_type_name = */		MSG_TYPE_INTEGER_32,
                /* msg_type_size = */		32,
                /* msg_type_number = */		1,
                /* msg_type_inline = */		TRUE,
                /* msg_type_longform = */	FALSE,
                /* msg_type_deallocate = */	FALSE,
                /* msg_type_unused = */		0
        };
#endif	UseStaticMsgType

#if	UseStaticMsgType
        InP->owner_portType = owner_portType;
#else	UseStaticMsgType
        InP->owner_portType.msg_type_name = MSG_TYPE_PORT;
        InP->owner_portType.msg_type_size = 32;
        InP->owner_portType.msg_type_number = 1;
        InP->owner_portType.msg_type_inline = TRUE;
        InP->owner_portType.msg_type_longform = FALSE;
        InP->owner_portType.msg_type_deallocate = FALSE;
#endif	UseStaticMsgType

        InP->owner_port /* owner_port */ = /* owner_port */ owner_port;

        InP->Head.msg_simple = FALSE;
        InP->Head.msg_size = msg_size;
        InP->Head.msg_type = MSG_TYPE_NORMAL | MSG_TYPE_RPC;
        InP->Head.msg_request_port = kern_serv_port;
        InP->Head.msg_reply_port = mig_get_reply_port();
        InP->Head.msg_id = 1009;

        msg_result = msg_rpc(&InP->Head, MSG_OPTION_NONE, sizeof(Reply), 0, 0);
        if (msg_result != RPC_SUCCESS) {
                if (msg_result == RCV_INVALID_PORT)
                        mig_dealloc_reply_port();
                return msg_result;
        }

#if	TypeCheck
        msg_size = OutP->Head.msg_size;
        msg_simple = OutP->Head.msg_simple;
#endif	TypeCheck

        if (OutP->Head.msg_id != 1109)
                return MIG_REPLY_MISMATCH;

#if	TypeCheck
        if (((msg_size != 32) || (msg_simple != TRUE)) &&
            ((msg_size != sizeof(death_pill_t)) ||
             (msg_simple != TRUE) ||
             (OutP->RetCode == KERN_SUCCESS)))
                return MIG_TYPE_ERROR;
#endif	TypeCheck

#if	TypeCheck
#if	UseStaticMsgType
        if (* (int *) &OutP->RetCodeType != * (int *) &RetCodeCheck)
#else	UseStaticMsgType
        if ((OutP->RetCodeType.msg_type_inline != TRUE) ||
            (OutP->RetCodeType.msg_type_longform != FALSE) ||
            (OutP->RetCodeType.msg_type_name != MSG_TYPE_INTEGER_32) ||
            (OutP->RetCodeType.msg_type_number != 1) ||
            (OutP->RetCodeType.msg_type_size != 32))
#endif	UseStaticMsgType
                return MIG_TYPE_ERROR;
#endif	TypeCheck

        if (OutP->RetCode != KERN_SUCCESS)
                return OutP->RetCode;

        return OutP->RetCode;
}

/* Routine Start */
mig_external kern_return_t ntsoundStart (
        port_t kern_serv_port,
        port_t owner_port)
{
        typedef struct {
                msg_header_t Head;
                msg_type_t owner_portType;
                port_t owner_port;
        } Request;

        typedef struct {
                msg_header_t Head;
                msg_type_t RetCodeType;
                kern_return_t RetCode;
        } Reply;

        union {
                Request In;
                Reply Out;
        } Mess;

        register Request *InP = &Mess.In;
        register Reply *OutP = &Mess.Out;

        msg_return_t msg_result;

#if	TypeCheck
        boolean_t msg_simple;
#endif	TypeCheck

        unsigned int msg_size = 32;

#if	UseStaticMsgType
        static const msg_type_t owner_portType = {
                /* msg_type_name = */		MSG_TYPE_PORT,
                /* msg_type_size = */		32,
                /* msg_type_number = */		1,
                /* msg_type_inline = */		TRUE,
                /* msg_type_longform = */	FALSE,
                /* msg_type_deallocate = */	FALSE,
                /* msg_type_unused = */		0,
        };
#endif	UseStaticMsgType

#if	UseStaticMsgType
        static const msg_type_t RetCodeCheck = {
                /* msg_type_name = */		MSG_TYPE_INTEGER_32,
                /* msg_type_size = */		32,
                /* msg_type_number = */		1,
                /* msg_type_inline = */		TRUE,
                /* msg_type_longform = */	FALSE,
                /* msg_type_deallocate = */	FALSE,
                /* msg_type_unused = */		0
        };
#endif	UseStaticMsgType

#if	UseStaticMsgType
        InP->owner_portType = owner_portType;
#else	UseStaticMsgType
        InP->owner_portType.msg_type_name = MSG_TYPE_PORT;
        InP->owner_portType.msg_type_size = 32;
        InP->owner_portType.msg_type_number = 1;
        InP->owner_portType.msg_type_inline = TRUE;
        InP->owner_portType.msg_type_longform = FALSE;
        InP->owner_portType.msg_type_deallocate = FALSE;
#endif	UseStaticMsgType

        InP->owner_port /* owner_port */ = /* owner_port */ owner_port;

        InP->Head.msg_simple = FALSE;
        InP->Head.msg_size = msg_size;
        InP->Head.msg_type = MSG_TYPE_NORMAL | MSG_TYPE_RPC;
        InP->Head.msg_request_port = kern_serv_port;
        InP->Head.msg_reply_port = mig_get_reply_port();
        InP->Head.msg_id = 1010;

        msg_result = msg_rpc(&InP->Head, MSG_OPTION_NONE, sizeof(Reply), 0, 0);
        if (msg_result != RPC_SUCCESS) {
                if (msg_result == RCV_INVALID_PORT)
                        mig_dealloc_reply_port();
                return msg_result;
        }

#if	TypeCheck
        msg_size = OutP->Head.msg_size;
        msg_simple = OutP->Head.msg_simple;
#endif	TypeCheck

        if (OutP->Head.msg_id != 1110)
                return MIG_REPLY_MISMATCH;

#if	TypeCheck
        if (((msg_size != 32) || (msg_simple != TRUE)) &&
            ((msg_size != sizeof(death_pill_t)) ||
             (msg_simple != TRUE) ||
             (OutP->RetCode == KERN_SUCCESS)))
                return MIG_TYPE_ERROR;
#endif	TypeCheck

#if	TypeCheck
#if	UseStaticMsgType
        if (* (int *) &OutP->RetCodeType != * (int *) &RetCodeCheck)
#else	UseStaticMsgType
        if ((OutP->RetCodeType.msg_type_inline != TRUE) ||
            (OutP->RetCodeType.msg_type_longform != FALSE) ||
            (OutP->RetCodeType.msg_type_name != MSG_TYPE_INTEGER_32) ||
            (OutP->RetCodeType.msg_type_number != 1) ||
            (OutP->RetCodeType.msg_type_size != 32))
#endif	UseStaticMsgType
                return MIG_TYPE_ERROR;
#endif	TypeCheck

        if (OutP->RetCode != KERN_SUCCESS)
                return OutP->RetCode;

        return OutP->RetCode;
}

/* Routine Stop */
mig_external kern_return_t ntsoundStop (
        port_t kern_serv_port,
        port_t owner_port)
{
        typedef struct {
                msg_header_t Head;
                msg_type_t owner_portType;
                port_t owner_port;
        } Request;

        typedef struct {
                msg_header_t Head;
                msg_type_t RetCodeType;
                kern_return_t RetCode;
        } Reply;

        union {
                Request In;
                Reply Out;
        } Mess;

        register Request *InP = &Mess.In;
        register Reply *OutP = &Mess.Out;

        msg_return_t msg_result;

#if	TypeCheck
        boolean_t msg_simple;
#endif	TypeCheck

        unsigned int msg_size = 32;

#if	UseStaticMsgType
        static const msg_type_t owner_portType = {
                /* msg_type_name = */		MSG_TYPE_PORT,
                /* msg_type_size = */		32,
                /* msg_type_number = */		1,
                /* msg_type_inline = */		TRUE,
                /* msg_type_longform = */	FALSE,
                /* msg_type_deallocate = */	FALSE,
                /* msg_type_unused = */		0,
        };
#endif	UseStaticMsgType

#if	UseStaticMsgType
        static const msg_type_t RetCodeCheck = {
                /* msg_type_name = */		MSG_TYPE_INTEGER_32,
                /* msg_type_size = */		32,
                /* msg_type_number = */		1,
                /* msg_type_inline = */		TRUE,
                /* msg_type_longform = */	FALSE,
                /* msg_type_deallocate = */	FALSE,
                /* msg_type_unused = */		0
        };
#endif	UseStaticMsgType

#if	UseStaticMsgType
        InP->owner_portType = owner_portType;
#else	UseStaticMsgType
        InP->owner_portType.msg_type_name = MSG_TYPE_PORT;
        InP->owner_portType.msg_type_size = 32;
        InP->owner_portType.msg_type_number = 1;
        InP->owner_portType.msg_type_inline = TRUE;
        InP->owner_portType.msg_type_longform = FALSE;
        InP->owner_portType.msg_type_deallocate = FALSE;
#endif	UseStaticMsgType

        InP->owner_port /* owner_port */ = /* owner_port */ owner_port;

        InP->Head.msg_simple = FALSE;
        InP->Head.msg_size = msg_size;
        InP->Head.msg_type = MSG_TYPE_NORMAL | MSG_TYPE_RPC;
        InP->Head.msg_request_port = kern_serv_port;
        InP->Head.msg_reply_port = mig_get_reply_port();
        InP->Head.msg_id = 1011;

        msg_result = msg_rpc(&InP->Head, MSG_OPTION_NONE, sizeof(Reply), 0, 0);
        if (msg_result != RPC_SUCCESS) {
                if (msg_result == RCV_INVALID_PORT)
                        mig_dealloc_reply_port();
                return msg_result;
        }

#if	TypeCheck
        msg_size = OutP->Head.msg_size;
        msg_simple = OutP->Head.msg_simple;
#endif	TypeCheck

        if (OutP->Head.msg_id != 1111)
                return MIG_REPLY_MISMATCH;

#if	TypeCheck
        if (((msg_size != 32) || (msg_simple != TRUE)) &&
            ((msg_size != sizeof(death_pill_t)) ||
             (msg_simple != TRUE) ||
             (OutP->RetCode == KERN_SUCCESS)))
                return MIG_TYPE_ERROR;
#endif	TypeCheck

#if	TypeCheck
#if	UseStaticMsgType
        if (* (int *) &OutP->RetCodeType != * (int *) &RetCodeCheck)
#else	UseStaticMsgType
        if ((OutP->RetCodeType.msg_type_inline != TRUE) ||
            (OutP->RetCodeType.msg_type_longform != FALSE) ||
            (OutP->RetCodeType.msg_type_name != MSG_TYPE_INTEGER_32) ||
            (OutP->RetCodeType.msg_type_number != 1) ||
            (OutP->RetCodeType.msg_type_size != 32))
#endif	UseStaticMsgType
                return MIG_TYPE_ERROR;
#endif	TypeCheck

        if (OutP->RetCode != KERN_SUCCESS)
                return OutP->RetCode;

        return OutP->RetCode;
}

/* Routine Config */
mig_external kern_return_t ntsoundConfig (
        port_t kern_serv_port,
        port_t owner_port,
        int channelCount,
        int samplingRate,
        int encoding,
        int useInterrupts)
{
        typedef struct {
                msg_header_t Head;
                msg_type_t owner_portType;
                port_t owner_port;
                msg_type_t channelCountType;
                int channelCount;
                msg_type_t samplingRateType;
                int samplingRate;
                msg_type_t encodingType;
                int encoding;
                msg_type_t useInterruptsType;
                int useInterrupts;
        } Request;

        typedef struct {
                msg_header_t Head;
                msg_type_t RetCodeType;
                kern_return_t RetCode;
        } Reply;

        union {
                Request In;
                Reply Out;
        } Mess;

        register Request *InP = &Mess.In;
        register Reply *OutP = &Mess.Out;

        msg_return_t msg_result;

#if	TypeCheck
        boolean_t msg_simple;
#endif	TypeCheck

        unsigned int msg_size = 64;

#if	UseStaticMsgType
        static const msg_type_t owner_portType = {
                /* msg_type_name = */		MSG_TYPE_PORT,
                /* msg_type_size = */		32,
                /* msg_type_number = */		1,
                /* msg_type_inline = */		TRUE,
                /* msg_type_longform = */	FALSE,
                /* msg_type_deallocate = */	FALSE,
                /* msg_type_unused = */		0,
        };
#endif	UseStaticMsgType

#if	UseStaticMsgType
        static const msg_type_t channelCountType = {
                /* msg_type_name = */		MSG_TYPE_INTEGER_32,
                /* msg_type_size = */		32,
                /* msg_type_number = */		1,
                /* msg_type_inline = */		TRUE,
                /* msg_type_longform = */	FALSE,
                /* msg_type_deallocate = */	FALSE,
                /* msg_type_unused = */		0,
        };
#endif	UseStaticMsgType

#if	UseStaticMsgType
        static const msg_type_t samplingRateType = {
                /* msg_type_name = */		MSG_TYPE_INTEGER_32,
                /* msg_type_size = */		32,
                /* msg_type_number = */		1,
                /* msg_type_inline = */		TRUE,
                /* msg_type_longform = */	FALSE,
                /* msg_type_deallocate = */	FALSE,
                /* msg_type_unused = */		0,
        };
#endif	UseStaticMsgType

#if	UseStaticMsgType
        static const msg_type_t encodingType = {
                /* msg_type_name = */		MSG_TYPE_INTEGER_32,
                /* msg_type_size = */		32,
                /* msg_type_number = */		1,
                /* msg_type_inline = */		TRUE,
                /* msg_type_longform = */	FALSE,
                /* msg_type_deallocate = */	FALSE,
                /* msg_type_unused = */		0,
        };
#endif	UseStaticMsgType

#if	UseStaticMsgType
        static const msg_type_t useInterruptsType = {
                /* msg_type_name = */		MSG_TYPE_INTEGER_32,
                /* msg_type_size = */		32,
                /* msg_type_number = */		1,
                /* msg_type_inline = */		TRUE,
                /* msg_type_longform = */	FALSE,
                /* msg_type_deallocate = */	FALSE,
                /* msg_type_unused = */		0,
        };
#endif	UseStaticMsgType

#if	UseStaticMsgType
        static const msg_type_t RetCodeCheck = {
                /* msg_type_name = */		MSG_TYPE_INTEGER_32,
                /* msg_type_size = */		32,
                /* msg_type_number = */		1,
                /* msg_type_inline = */		TRUE,
                /* msg_type_longform = */	FALSE,
                /* msg_type_deallocate = */	FALSE,
                /* msg_type_unused = */		0
        };
#endif	UseStaticMsgType

#if	UseStaticMsgType
        InP->owner_portType = owner_portType;
#else	UseStaticMsgType
        InP->owner_portType.msg_type_name = MSG_TYPE_PORT;
        InP->owner_portType.msg_type_size = 32;
        InP->owner_portType.msg_type_number = 1;
        InP->owner_portType.msg_type_inline = TRUE;
        InP->owner_portType.msg_type_longform = FALSE;
        InP->owner_portType.msg_type_deallocate = FALSE;
#endif	UseStaticMsgType

        InP->owner_port /* owner_port */ = /* owner_port */ owner_port;

#if	UseStaticMsgType
        InP->channelCountType = channelCountType;
#else	UseStaticMsgType
        InP->channelCountType.msg_type_name = MSG_TYPE_INTEGER_32;
        InP->channelCountType.msg_type_size = 32;
        InP->channelCountType.msg_type_number = 1;
        InP->channelCountType.msg_type_inline = TRUE;
        InP->channelCountType.msg_type_longform = FALSE;
        InP->channelCountType.msg_type_deallocate = FALSE;
#endif	UseStaticMsgType

        InP->channelCount /* channelCount */ = /* channelCount */ channelCount;

#if	UseStaticMsgType
        InP->samplingRateType = samplingRateType;
#else	UseStaticMsgType
        InP->samplingRateType.msg_type_name = MSG_TYPE_INTEGER_32;
        InP->samplingRateType.msg_type_size = 32;
        InP->samplingRateType.msg_type_number = 1;
        InP->samplingRateType.msg_type_inline = TRUE;
        InP->samplingRateType.msg_type_longform = FALSE;
        InP->samplingRateType.msg_type_deallocate = FALSE;
#endif	UseStaticMsgType

        InP->samplingRate /* samplingRate */ = /* samplingRate */ samplingRate;

#if	UseStaticMsgType
        InP->encodingType = encodingType;
#else	UseStaticMsgType
        InP->encodingType.msg_type_name = MSG_TYPE_INTEGER_32;
        InP->encodingType.msg_type_size = 32;
        InP->encodingType.msg_type_number = 1;
        InP->encodingType.msg_type_inline = TRUE;
        InP->encodingType.msg_type_longform = FALSE;
        InP->encodingType.msg_type_deallocate = FALSE;
#endif	UseStaticMsgType

        InP->encoding /* encoding */ = /* encoding */ encoding;

#if	UseStaticMsgType
        InP->useInterruptsType = useInterruptsType;
#else	UseStaticMsgType
        InP->useInterruptsType.msg_type_name = MSG_TYPE_INTEGER_32;
        InP->useInterruptsType.msg_type_size = 32;
        InP->useInterruptsType.msg_type_number = 1;
        InP->useInterruptsType.msg_type_inline = TRUE;
        InP->useInterruptsType.msg_type_longform = FALSE;
        InP->useInterruptsType.msg_type_deallocate = FALSE;
#endif	UseStaticMsgType

        InP->useInterrupts /* useInterrupts */ = /* useInterrupts */ useInterrupts;

        InP->Head.msg_simple = FALSE;
        InP->Head.msg_size = msg_size;
        InP->Head.msg_type = MSG_TYPE_NORMAL | MSG_TYPE_RPC;
        InP->Head.msg_request_port = kern_serv_port;
        InP->Head.msg_reply_port = mig_get_reply_port();
        InP->Head.msg_id = 1012;

        msg_result = msg_rpc(&InP->Head, MSG_OPTION_NONE, sizeof(Reply), 0, 0);
        if (msg_result != RPC_SUCCESS) {
                if (msg_result == RCV_INVALID_PORT)
                        mig_dealloc_reply_port();
                return msg_result;
        }

#if	TypeCheck
        msg_size = OutP->Head.msg_size;
        msg_simple = OutP->Head.msg_simple;
#endif	TypeCheck

        if (OutP->Head.msg_id != 1112)
                return MIG_REPLY_MISMATCH;

#if	TypeCheck
        if (((msg_size != 32) || (msg_simple != TRUE)) &&
            ((msg_size != sizeof(death_pill_t)) ||
             (msg_simple != TRUE) ||
             (OutP->RetCode == KERN_SUCCESS)))
                return MIG_TYPE_ERROR;
#endif	TypeCheck

#if	TypeCheck
#if	UseStaticMsgType
        if (* (int *) &OutP->RetCodeType != * (int *) &RetCodeCheck)
#else	UseStaticMsgType
        if ((OutP->RetCodeType.msg_type_inline != TRUE) ||
            (OutP->RetCodeType.msg_type_longform != FALSE) ||
            (OutP->RetCodeType.msg_type_name != MSG_TYPE_INTEGER_32) ||
            (OutP->RetCodeType.msg_type_number != 1) ||
            (OutP->RetCodeType.msg_type_size != 32))
#endif	UseStaticMsgType
                return MIG_TYPE_ERROR;
#endif	TypeCheck

        if (OutP->RetCode != KERN_SUCCESS)
                return OutP->RetCode;

        return OutP->RetCode;
}

/* Routine BytesProcessed */
mig_external kern_return_t ntsoundBytesProcessed (
        port_t kern_serv_port,
        port_t owner_port,
        int *byte_count)
{
        typedef struct {
                msg_header_t Head;
                msg_type_t owner_portType;
                port_t owner_port;
        } Request;

        typedef struct {
                msg_header_t Head;
                msg_type_t RetCodeType;
                kern_return_t RetCode;
                msg_type_t byte_countType;
                int byte_count;
        } Reply;

        union {
                Request In;
                Reply Out;
        } Mess;

        register Request *InP = &Mess.In;
        register Reply *OutP = &Mess.Out;

        msg_return_t msg_result;

#if	TypeCheck
        boolean_t msg_simple;
#endif	TypeCheck

        unsigned int msg_size = 32;

#if	UseStaticMsgType
        static const msg_type_t owner_portType = {
                /* msg_type_name = */		MSG_TYPE_PORT,
                /* msg_type_size = */		32,
                /* msg_type_number = */		1,
                /* msg_type_inline = */		TRUE,
                /* msg_type_longform = */	FALSE,
                /* msg_type_deallocate = */	FALSE,
                /* msg_type_unused = */		0,
        };
#endif	UseStaticMsgType

#if	UseStaticMsgType
        static const msg_type_t RetCodeCheck = {
                /* msg_type_name = */		MSG_TYPE_INTEGER_32,
                /* msg_type_size = */		32,
                /* msg_type_number = */		1,
                /* msg_type_inline = */		TRUE,
                /* msg_type_longform = */	FALSE,
                /* msg_type_deallocate = */	FALSE,
                /* msg_type_unused = */		0
        };
#endif	UseStaticMsgType

#if	UseStaticMsgType
        static const msg_type_t byte_countCheck = {
                /* msg_type_name = */		MSG_TYPE_INTEGER_32,
                /* msg_type_size = */		32,
                /* msg_type_number = */		1,
                /* msg_type_inline = */		TRUE,
                /* msg_type_longform = */	FALSE,
                /* msg_type_deallocate = */	FALSE,
                /* msg_type_unused = */		0
        };
#endif	UseStaticMsgType

#if	UseStaticMsgType
        InP->owner_portType = owner_portType;
#else	UseStaticMsgType
        InP->owner_portType.msg_type_name = MSG_TYPE_PORT;
        InP->owner_portType.msg_type_size = 32;
        InP->owner_portType.msg_type_number = 1;
        InP->owner_portType.msg_type_inline = TRUE;
        InP->owner_portType.msg_type_longform = FALSE;
        InP->owner_portType.msg_type_deallocate = FALSE;
#endif	UseStaticMsgType

        InP->owner_port /* owner_port */ = /* owner_port */ owner_port;

        InP->Head.msg_simple = FALSE;
        InP->Head.msg_size = msg_size;
        InP->Head.msg_type = MSG_TYPE_NORMAL | MSG_TYPE_RPC;
        InP->Head.msg_request_port = kern_serv_port;
        InP->Head.msg_reply_port = mig_get_reply_port();
        InP->Head.msg_id = 1013;

        msg_result = msg_rpc(&InP->Head, MSG_OPTION_NONE, sizeof(Reply), 0, 0);
        if (msg_result != RPC_SUCCESS) {
                if (msg_result == RCV_INVALID_PORT)
                        mig_dealloc_reply_port();
                return msg_result;
        }

#if	TypeCheck
        msg_size = OutP->Head.msg_size;
        msg_simple = OutP->Head.msg_simple;
#endif	TypeCheck

        if (OutP->Head.msg_id != 1113)
                return MIG_REPLY_MISMATCH;

#if	TypeCheck
        if (((msg_size != 40) || (msg_simple != TRUE)) &&
            ((msg_size != sizeof(death_pill_t)) ||
             (msg_simple != TRUE) ||
             (OutP->RetCode == KERN_SUCCESS)))
                return MIG_TYPE_ERROR;
#endif	TypeCheck

#if	TypeCheck
#if	UseStaticMsgType
        if (* (int *) &OutP->RetCodeType != * (int *) &RetCodeCheck)
#else	UseStaticMsgType
        if ((OutP->RetCodeType.msg_type_inline != TRUE) ||
            (OutP->RetCodeType.msg_type_longform != FALSE) ||
            (OutP->RetCodeType.msg_type_name != MSG_TYPE_INTEGER_32) ||
            (OutP->RetCodeType.msg_type_number != 1) ||
            (OutP->RetCodeType.msg_type_size != 32))
#endif	UseStaticMsgType
                return MIG_TYPE_ERROR;
#endif	TypeCheck

        if (OutP->RetCode != KERN_SUCCESS)
                return OutP->RetCode;

#if	TypeCheck
#if	UseStaticMsgType
        if (* (int *) &OutP->byte_countType != * (int *) &byte_countCheck)
#else	UseStaticMsgType
        if ((OutP->byte_countType.msg_type_inline != TRUE) ||
            (OutP->byte_countType.msg_type_longform != FALSE) ||
            (OutP->byte_countType.msg_type_name != MSG_TYPE_INTEGER_32) ||
            (OutP->byte_countType.msg_type_number != 1) ||
            (OutP->byte_countType.msg_type_size != 32))
#endif	UseStaticMsgType
                return MIG_TYPE_ERROR;
#endif	TypeCheck

        *byte_count /* byte_count */ = /* *byte_count */ OutP->byte_count;

        return OutP->RetCode;
}

/* Routine DMACount */
mig_external kern_return_t ntsoundDMACount (
        port_t kern_serv_port,
        port_t owner_port,
        int *dma_count)
{
        typedef struct {
                msg_header_t Head;
                msg_type_t owner_portType;
                port_t owner_port;
        } Request;

        typedef struct {
                msg_header_t Head;
                msg_type_t RetCodeType;
                kern_return_t RetCode;
                msg_type_t dma_countType;
                int dma_count;
        } Reply;

        union {
                Request In;
                Reply Out;
        } Mess;

        register Request *InP = &Mess.In;
        register Reply *OutP = &Mess.Out;

        msg_return_t msg_result;

#if	TypeCheck
        boolean_t msg_simple;
#endif	TypeCheck

        unsigned int msg_size = 32;

#if	UseStaticMsgType
        static const msg_type_t owner_portType = {
                /* msg_type_name = */		MSG_TYPE_PORT,
                /* msg_type_size = */		32,
                /* msg_type_number = */		1,
                /* msg_type_inline = */		TRUE,
                /* msg_type_longform = */	FALSE,
                /* msg_type_deallocate = */	FALSE,
                /* msg_type_unused = */		0,
        };
#endif	UseStaticMsgType

#if	UseStaticMsgType
        static const msg_type_t RetCodeCheck = {
                /* msg_type_name = */		MSG_TYPE_INTEGER_32,
                /* msg_type_size = */		32,
                /* msg_type_number = */		1,
                /* msg_type_inline = */		TRUE,
                /* msg_type_longform = */	FALSE,
                /* msg_type_deallocate = */	FALSE,
                /* msg_type_unused = */		0
        };
#endif	UseStaticMsgType

#if	UseStaticMsgType
        static const msg_type_t dma_countCheck = {
                /* msg_type_name = */		MSG_TYPE_INTEGER_32,
                /* msg_type_size = */		32,
                /* msg_type_number = */		1,
                /* msg_type_inline = */		TRUE,
                /* msg_type_longform = */	FALSE,
                /* msg_type_deallocate = */	FALSE,
                /* msg_type_unused = */		0
        };
#endif	UseStaticMsgType

#if	UseStaticMsgType
        InP->owner_portType = owner_portType;
#else	UseStaticMsgType
        InP->owner_portType.msg_type_name = MSG_TYPE_PORT;
        InP->owner_portType.msg_type_size = 32;
        InP->owner_portType.msg_type_number = 1;
        InP->owner_portType.msg_type_inline = TRUE;
        InP->owner_portType.msg_type_longform = FALSE;
        InP->owner_portType.msg_type_deallocate = FALSE;
#endif	UseStaticMsgType

        InP->owner_port /* owner_port */ = /* owner_port */ owner_port;

        InP->Head.msg_simple = FALSE;
        InP->Head.msg_size = msg_size;
        InP->Head.msg_type = MSG_TYPE_NORMAL | MSG_TYPE_RPC;
        InP->Head.msg_request_port = kern_serv_port;
        InP->Head.msg_reply_port = mig_get_reply_port();
        InP->Head.msg_id = 1014;

        msg_result = msg_rpc(&InP->Head, MSG_OPTION_NONE, sizeof(Reply), 0, 0);
        if (msg_result != RPC_SUCCESS) {
                if (msg_result == RCV_INVALID_PORT)
                        mig_dealloc_reply_port();
                return msg_result;
        }

#if	TypeCheck
        msg_size = OutP->Head.msg_size;
        msg_simple = OutP->Head.msg_simple;
#endif	TypeCheck

        if (OutP->Head.msg_id != 1114)
                return MIG_REPLY_MISMATCH;

#if	TypeCheck
        if (((msg_size != 40) || (msg_simple != TRUE)) &&
            ((msg_size != sizeof(death_pill_t)) ||
             (msg_simple != TRUE) ||
             (OutP->RetCode == KERN_SUCCESS)))
                return MIG_TYPE_ERROR;
#endif	TypeCheck

#if	TypeCheck
#if	UseStaticMsgType
        if (* (int *) &OutP->RetCodeType != * (int *) &RetCodeCheck)
#else	UseStaticMsgType
        if ((OutP->RetCodeType.msg_type_inline != TRUE) ||
            (OutP->RetCodeType.msg_type_longform != FALSE) ||
            (OutP->RetCodeType.msg_type_name != MSG_TYPE_INTEGER_32) ||
            (OutP->RetCodeType.msg_type_number != 1) ||
            (OutP->RetCodeType.msg_type_size != 32))
#endif	UseStaticMsgType
                return MIG_TYPE_ERROR;
#endif	TypeCheck

        if (OutP->RetCode != KERN_SUCCESS)
                return OutP->RetCode;

#if	TypeCheck
#if	UseStaticMsgType
        if (* (int *) &OutP->dma_countType != * (int *) &dma_countCheck)
#else	UseStaticMsgType
        if ((OutP->dma_countType.msg_type_inline != TRUE) ||
            (OutP->dma_countType.msg_type_longform != FALSE) ||
            (OutP->dma_countType.msg_type_name != MSG_TYPE_INTEGER_32) ||
            (OutP->dma_countType.msg_type_number != 1) ||
            (OutP->dma_countType.msg_type_size != 32))
#endif	UseStaticMsgType
                return MIG_TYPE_ERROR;
#endif	TypeCheck

        *dma_count /* dma_count */ = /* *dma_count */ OutP->dma_count;

        return OutP->RetCode;
}

/* Routine InterruptCount */
mig_external kern_return_t ntsoundInterruptCount (
        port_t kern_serv_port,
        port_t owner_port,
        int *irq_count)
{
        typedef struct {
                msg_header_t Head;
                msg_type_t owner_portType;
                port_t owner_port;
        } Request;

        typedef struct {
                msg_header_t Head;
                msg_type_t RetCodeType;
                kern_return_t RetCode;
                msg_type_t irq_countType;
                int irq_count;
        } Reply;

        union {
                Request In;
                Reply Out;
        } Mess;

        register Request *InP = &Mess.In;
        register Reply *OutP = &Mess.Out;

        msg_return_t msg_result;

#if	TypeCheck
        boolean_t msg_simple;
#endif	TypeCheck

        unsigned int msg_size = 32;

#if	UseStaticMsgType
        static const msg_type_t owner_portType = {
                /* msg_type_name = */		MSG_TYPE_PORT,
                /* msg_type_size = */		32,
                /* msg_type_number = */		1,
                /* msg_type_inline = */		TRUE,
                /* msg_type_longform = */	FALSE,
                /* msg_type_deallocate = */	FALSE,
                /* msg_type_unused = */		0,
        };
#endif	UseStaticMsgType

#if	UseStaticMsgType
        static const msg_type_t RetCodeCheck = {
                /* msg_type_name = */		MSG_TYPE_INTEGER_32,
                /* msg_type_size = */		32,
                /* msg_type_number = */		1,
                /* msg_type_inline = */		TRUE,
                /* msg_type_longform = */	FALSE,
                /* msg_type_deallocate = */	FALSE,
                /* msg_type_unused = */		0
        };
#endif	UseStaticMsgType

#if	UseStaticMsgType
        static const msg_type_t irq_countCheck = {
                /* msg_type_name = */		MSG_TYPE_INTEGER_32,
                /* msg_type_size = */		32,
                /* msg_type_number = */		1,
                /* msg_type_inline = */		TRUE,
                /* msg_type_longform = */	FALSE,
                /* msg_type_deallocate = */	FALSE,
                /* msg_type_unused = */		0
        };
#endif	UseStaticMsgType

#if	UseStaticMsgType
        InP->owner_portType = owner_portType;
#else	UseStaticMsgType
        InP->owner_portType.msg_type_name = MSG_TYPE_PORT;
        InP->owner_portType.msg_type_size = 32;
        InP->owner_portType.msg_type_number = 1;
        InP->owner_portType.msg_type_inline = TRUE;
        InP->owner_portType.msg_type_longform = FALSE;
        InP->owner_portType.msg_type_deallocate = FALSE;
#endif	UseStaticMsgType

        InP->owner_port /* owner_port */ = /* owner_port */ owner_port;

        InP->Head.msg_simple = FALSE;
        InP->Head.msg_size = msg_size;
        InP->Head.msg_type = MSG_TYPE_NORMAL | MSG_TYPE_RPC;
        InP->Head.msg_request_port = kern_serv_port;
        InP->Head.msg_reply_port = mig_get_reply_port();
        InP->Head.msg_id = 1015;

        msg_result = msg_rpc(&InP->Head, MSG_OPTION_NONE, sizeof(Reply), 0, 0);
        if (msg_result != RPC_SUCCESS) {
                if (msg_result == RCV_INVALID_PORT)
                        mig_dealloc_reply_port();
                return msg_result;
        }

#if	TypeCheck
        msg_size = OutP->Head.msg_size;
        msg_simple = OutP->Head.msg_simple;
#endif	TypeCheck

        if (OutP->Head.msg_id != 1115)
                return MIG_REPLY_MISMATCH;

#if	TypeCheck
        if (((msg_size != 40) || (msg_simple != TRUE)) &&
            ((msg_size != sizeof(death_pill_t)) ||
             (msg_simple != TRUE) ||
             (OutP->RetCode == KERN_SUCCESS)))
                return MIG_TYPE_ERROR;
#endif	TypeCheck

#if	TypeCheck
#if	UseStaticMsgType
        if (* (int *) &OutP->RetCodeType != * (int *) &RetCodeCheck)
#else	UseStaticMsgType
        if ((OutP->RetCodeType.msg_type_inline != TRUE) ||
            (OutP->RetCodeType.msg_type_longform != FALSE) ||
            (OutP->RetCodeType.msg_type_name != MSG_TYPE_INTEGER_32) ||
            (OutP->RetCodeType.msg_type_number != 1) ||
            (OutP->RetCodeType.msg_type_size != 32))
#endif	UseStaticMsgType
                return MIG_TYPE_ERROR;
#endif	TypeCheck

        if (OutP->RetCode != KERN_SUCCESS)
                return OutP->RetCode;

#if	TypeCheck
#if	UseStaticMsgType
        if (* (int *) &OutP->irq_countType != * (int *) &irq_countCheck)
#else	UseStaticMsgType
        if ((OutP->irq_countType.msg_type_inline != TRUE) ||
            (OutP->irq_countType.msg_type_longform != FALSE) ||
            (OutP->irq_countType.msg_type_name != MSG_TYPE_INTEGER_32) ||
            (OutP->irq_countType.msg_type_number != 1) ||
            (OutP->irq_countType.msg_type_size != 32))
#endif	UseStaticMsgType
                return MIG_TYPE_ERROR;
#endif	TypeCheck

        *irq_count /* irq_count */ = /* *irq_count */ OutP->irq_count;

        return OutP->RetCode;
}

/* Routine Write */
mig_external kern_return_t ntsoundWrite (
        port_t kern_serv_port,
        port_t owner_port,
        sound_data_t data,
        unsigned int dataCnt,
        int *actual_count)
{
        typedef struct {
                msg_header_t Head;
                msg_type_t owner_portType;
                port_t owner_port;
                msg_type_long_t dataType;
                short data[7000];
        } Request;

        typedef struct {
                msg_header_t Head;
                msg_type_t RetCodeType;
                kern_return_t RetCode;
                msg_type_t actual_countType;
                int actual_count;
        } Reply;

        union {
                Request In;
                Reply Out;
        } Mess;

        register Request *InP = &Mess.In;
        register Reply *OutP = &Mess.Out;

        msg_return_t msg_result;

#if	TypeCheck
        boolean_t msg_simple;
#endif	TypeCheck

        unsigned int msg_size = 44;
        /* Maximum request size 14044 */
        unsigned int msg_size_delta;

#if	UseStaticMsgType
        static const msg_type_t owner_portType = {
                /* msg_type_name = */		MSG_TYPE_PORT,
                /* msg_type_size = */		32,
                /* msg_type_number = */		1,
                /* msg_type_inline = */		TRUE,
                /* msg_type_longform = */	FALSE,
                /* msg_type_deallocate = */	FALSE,
                /* msg_type_unused = */		0,
        };
#endif	UseStaticMsgType

#if	UseStaticMsgType
        static const msg_type_long_t dataType = {
        {
                /* msg_type_name = */		0,
                /* msg_type_size = */		0,
                /* msg_type_number = */		0,
                /* msg_type_inline = */		TRUE,
                /* msg_type_longform = */	TRUE,
                /* msg_type_deallocate = */	FALSE,
        },
                /* msg_type_long_name = */	MSG_TYPE_INTEGER_16,
                /* msg_type_long_size = */	16,
                /* msg_type_long_number = */	7000,
        };
#endif	UseStaticMsgType

#if	UseStaticMsgType
        static const msg_type_t RetCodeCheck = {
                /* msg_type_name = */		MSG_TYPE_INTEGER_32,
                /* msg_type_size = */		32,
                /* msg_type_number = */		1,
                /* msg_type_inline = */		TRUE,
                /* msg_type_longform = */	FALSE,
                /* msg_type_deallocate = */	FALSE,
                /* msg_type_unused = */		0
        };
#endif	UseStaticMsgType

#if	UseStaticMsgType
        static const msg_type_t actual_countCheck = {
                /* msg_type_name = */		MSG_TYPE_INTEGER_32,
                /* msg_type_size = */		32,
                /* msg_type_number = */		1,
                /* msg_type_inline = */		TRUE,
                /* msg_type_longform = */	FALSE,
                /* msg_type_deallocate = */	FALSE,
                /* msg_type_unused = */		0
        };
#endif	UseStaticMsgType

#if	UseStaticMsgType
        InP->owner_portType = owner_portType;
#else	UseStaticMsgType
        InP->owner_portType.msg_type_name = MSG_TYPE_PORT;
        InP->owner_portType.msg_type_size = 32;
        InP->owner_portType.msg_type_number = 1;
        InP->owner_portType.msg_type_inline = TRUE;
        InP->owner_portType.msg_type_longform = FALSE;
        InP->owner_portType.msg_type_deallocate = FALSE;
#endif	UseStaticMsgType

        InP->owner_port /* owner_port */ = /* owner_port */ owner_port;

#if	UseStaticMsgType
        InP->dataType = dataType;
#else	UseStaticMsgType
        InP->dataType.msg_type_long_name = MSG_TYPE_INTEGER_16;
        InP->dataType.msg_type_long_size = 16;
        InP->dataType.msg_type_header.msg_type_inline = TRUE;
        InP->dataType.msg_type_header.msg_type_longform = TRUE;
        InP->dataType.msg_type_header.msg_type_deallocate = FALSE;
#endif	UseStaticMsgType

        if (dataCnt > 7000)
                return MIG_ARRAY_TOO_LARGE;
        bcopy((char *) data, (char *) InP->data, 2 * dataCnt);

        InP->dataType.msg_type_long_number /* dataCnt */ = /* dataType.msg_type_long_number */ dataCnt;

        msg_size_delta = (2 * dataCnt + 3) & ~3;
        msg_size += msg_size_delta;

        InP->Head.msg_simple = FALSE;
        InP->Head.msg_size = msg_size;
        InP->Head.msg_type = MSG_TYPE_NORMAL | MSG_TYPE_RPC;
        InP->Head.msg_request_port = kern_serv_port;
        InP->Head.msg_reply_port = mig_get_reply_port();
        InP->Head.msg_id = 1016;

        msg_result = msg_rpc(&InP->Head, MSG_OPTION_NONE, sizeof(Reply), 0, 0);
        if (msg_result != RPC_SUCCESS) {
                if (msg_result == RCV_INVALID_PORT)
                        mig_dealloc_reply_port();
                return msg_result;
        }

#if	TypeCheck
        msg_size = OutP->Head.msg_size;
        msg_simple = OutP->Head.msg_simple;
#endif	TypeCheck

        if (OutP->Head.msg_id != 1116)
                return MIG_REPLY_MISMATCH;

#if	TypeCheck
        if (((msg_size != 40) || (msg_simple != TRUE)) &&
            ((msg_size != sizeof(death_pill_t)) ||
             (msg_simple != TRUE) ||
             (OutP->RetCode == KERN_SUCCESS)))
                return MIG_TYPE_ERROR;
#endif	TypeCheck

#if	TypeCheck
#if	UseStaticMsgType
        if (* (int *) &OutP->RetCodeType != * (int *) &RetCodeCheck)
#else	UseStaticMsgType
        if ((OutP->RetCodeType.msg_type_inline != TRUE) ||
            (OutP->RetCodeType.msg_type_longform != FALSE) ||
            (OutP->RetCodeType.msg_type_name != MSG_TYPE_INTEGER_32) ||
            (OutP->RetCodeType.msg_type_number != 1) ||
            (OutP->RetCodeType.msg_type_size != 32))
#endif	UseStaticMsgType
                return MIG_TYPE_ERROR;
#endif	TypeCheck

        if (OutP->RetCode != KERN_SUCCESS)
                return OutP->RetCode;

#if	TypeCheck
#if	UseStaticMsgType
        if (* (int *) &OutP->actual_countType != * (int *) &actual_countCheck)
#else	UseStaticMsgType
        if ((OutP->actual_countType.msg_type_inline != TRUE) ||
            (OutP->actual_countType.msg_type_longform != FALSE) ||
            (OutP->actual_countType.msg_type_name != MSG_TYPE_INTEGER_32) ||
            (OutP->actual_countType.msg_type_number != 1) ||
            (OutP->actual_countType.msg_type_size != 32))
#endif	UseStaticMsgType
                return MIG_TYPE_ERROR;
#endif	TypeCheck

        *actual_count /* actual_count */ = /* *actual_count */ OutP->actual_count;

        return OutP->RetCode;
}

/* Routine SetVolume */
mig_external kern_return_t ntsoundSetVolume (
        port_t kern_serv_port,
        port_t owner_port,
        int value)
{
        typedef struct {
                msg_header_t Head;
                msg_type_t owner_portType;
                port_t owner_port;
                msg_type_t valueType;
                int value;
        } Request;

        typedef struct {
                msg_header_t Head;
                msg_type_t RetCodeType;
                kern_return_t RetCode;
        } Reply;

        union {
                Request In;
                Reply Out;
        } Mess;

        register Request *InP = &Mess.In;
        register Reply *OutP = &Mess.Out;

        msg_return_t msg_result;

#if	TypeCheck
        boolean_t msg_simple;
#endif	TypeCheck

        unsigned int msg_size = 40;

#if	UseStaticMsgType
        static const msg_type_t owner_portType = {
                /* msg_type_name = */		MSG_TYPE_PORT,
                /* msg_type_size = */		32,
                /* msg_type_number = */		1,
                /* msg_type_inline = */		TRUE,
                /* msg_type_longform = */	FALSE,
                /* msg_type_deallocate = */	FALSE,
                /* msg_type_unused = */		0,
        };
#endif	UseStaticMsgType

#if	UseStaticMsgType
        static const msg_type_t valueType = {
                /* msg_type_name = */		MSG_TYPE_INTEGER_32,
                /* msg_type_size = */		32,
                /* msg_type_number = */		1,
                /* msg_type_inline = */		TRUE,
                /* msg_type_longform = */	FALSE,
                /* msg_type_deallocate = */	FALSE,
                /* msg_type_unused = */		0,
        };
#endif	UseStaticMsgType

#if	UseStaticMsgType
        static const msg_type_t RetCodeCheck = {
                /* msg_type_name = */		MSG_TYPE_INTEGER_32,
                /* msg_type_size = */		32,
                /* msg_type_number = */		1,
                /* msg_type_inline = */		TRUE,
                /* msg_type_longform = */	FALSE,
                /* msg_type_deallocate = */	FALSE,
                /* msg_type_unused = */		0
        };
#endif	UseStaticMsgType

#if	UseStaticMsgType
        InP->owner_portType = owner_portType;
#else	UseStaticMsgType
        InP->owner_portType.msg_type_name = MSG_TYPE_PORT;
        InP->owner_portType.msg_type_size = 32;
        InP->owner_portType.msg_type_number = 1;
        InP->owner_portType.msg_type_inline = TRUE;
        InP->owner_portType.msg_type_longform = FALSE;
        InP->owner_portType.msg_type_deallocate = FALSE;
#endif	UseStaticMsgType

        InP->owner_port /* owner_port */ = /* owner_port */ owner_port;

#if	UseStaticMsgType
        InP->valueType = valueType;
#else	UseStaticMsgType
        InP->valueType.msg_type_name = MSG_TYPE_INTEGER_32;
        InP->valueType.msg_type_size = 32;
        InP->valueType.msg_type_number = 1;
        InP->valueType.msg_type_inline = TRUE;
        InP->valueType.msg_type_longform = FALSE;
        InP->valueType.msg_type_deallocate = FALSE;
#endif	UseStaticMsgType

        InP->value /* value */ = /* value */ value;

        InP->Head.msg_simple = FALSE;
        InP->Head.msg_size = msg_size;
        InP->Head.msg_type = MSG_TYPE_NORMAL | MSG_TYPE_RPC;
        InP->Head.msg_request_port = kern_serv_port;
        InP->Head.msg_reply_port = mig_get_reply_port();
        InP->Head.msg_id = 1017;

        msg_result = msg_rpc(&InP->Head, MSG_OPTION_NONE, sizeof(Reply), 0, 0);
        if (msg_result != RPC_SUCCESS) {
                if (msg_result == RCV_INVALID_PORT)
                        mig_dealloc_reply_port();
                return msg_result;
        }

#if	TypeCheck
        msg_size = OutP->Head.msg_size;
        msg_simple = OutP->Head.msg_simple;
#endif	TypeCheck

        if (OutP->Head.msg_id != 1117)
                return MIG_REPLY_MISMATCH;

#if	TypeCheck
        if (((msg_size != 32) || (msg_simple != TRUE)) &&
            ((msg_size != sizeof(death_pill_t)) ||
             (msg_simple != TRUE) ||
             (OutP->RetCode == KERN_SUCCESS)))
                return MIG_TYPE_ERROR;
#endif	TypeCheck

#if	TypeCheck
#if	UseStaticMsgType
        if (* (int *) &OutP->RetCodeType != * (int *) &RetCodeCheck)
#else	UseStaticMsgType
        if ((OutP->RetCodeType.msg_type_inline != TRUE) ||
            (OutP->RetCodeType.msg_type_longform != FALSE) ||
            (OutP->RetCodeType.msg_type_name != MSG_TYPE_INTEGER_32) ||
            (OutP->RetCodeType.msg_type_number != 1) ||
            (OutP->RetCodeType.msg_type_size != 32))
#endif	UseStaticMsgType
                return MIG_TYPE_ERROR;
#endif	TypeCheck

        if (OutP->RetCode != KERN_SUCCESS)
                return OutP->RetCode;

        return OutP->RetCode;
}

/* Routine WireRange */
mig_external kern_return_t ntsoundWireRange (
        port_t device_port,
        port_t token,
        port_t task,
        vm_offset_t addr,
        vm_size_t size,
        boolean_t wire)
{
        typedef struct {
                msg_header_t Head;
                msg_type_t tokenType;
                port_t token;
                msg_type_t taskType;
                port_t task;
                msg_type_t addrType;
                vm_offset_t addr;
                msg_type_t sizeType;
                vm_size_t size;
                msg_type_t wireType;
                boolean_t wire;
        } Request;

        typedef struct {
                msg_header_t Head;
                msg_type_t RetCodeType;
                kern_return_t RetCode;
        } Reply;

        union {
                Request In;
                Reply Out;
        } Mess;

        register Request *InP = &Mess.In;
        register Reply *OutP = &Mess.Out;

        msg_return_t msg_result;

#if	TypeCheck
        boolean_t msg_simple;
#endif	TypeCheck

        unsigned int msg_size = 64;

#if	UseStaticMsgType
        static const msg_type_t tokenType = {
                /* msg_type_name = */		MSG_TYPE_PORT,
                /* msg_type_size = */		32,
                /* msg_type_number = */		1,
                /* msg_type_inline = */		TRUE,
                /* msg_type_longform = */	FALSE,
                /* msg_type_deallocate = */	FALSE,
                /* msg_type_unused = */		0,
        };
#endif	UseStaticMsgType

#if	UseStaticMsgType
        static const msg_type_t taskType = {
                /* msg_type_name = */		MSG_TYPE_PORT,
                /* msg_type_size = */		32,
                /* msg_type_number = */		1,
                /* msg_type_inline = */		TRUE,
                /* msg_type_longform = */	FALSE,
                /* msg_type_deallocate = */	FALSE,
                /* msg_type_unused = */		0,
        };
#endif	UseStaticMsgType

#if	UseStaticMsgType
        static const msg_type_t addrType = {
                /* msg_type_name = */		MSG_TYPE_INTEGER_32,
                /* msg_type_size = */		32,
                /* msg_type_number = */		1,
                /* msg_type_inline = */		TRUE,
                /* msg_type_longform = */	FALSE,
                /* msg_type_deallocate = */	FALSE,
                /* msg_type_unused = */		0,
        };
#endif	UseStaticMsgType

#if	UseStaticMsgType
        static const msg_type_t sizeType = {
                /* msg_type_name = */		MSG_TYPE_INTEGER_32,
                /* msg_type_size = */		32,
                /* msg_type_number = */		1,
                /* msg_type_inline = */		TRUE,
                /* msg_type_longform = */	FALSE,
                /* msg_type_deallocate = */	FALSE,
                /* msg_type_unused = */		0,
        };
#endif	UseStaticMsgType

#if	UseStaticMsgType
        static const msg_type_t wireType = {
                /* msg_type_name = */		MSG_TYPE_BOOLEAN,
                /* msg_type_size = */		32,
                /* msg_type_number = */		1,
                /* msg_type_inline = */		TRUE,
                /* msg_type_longform = */	FALSE,
                /* msg_type_deallocate = */	FALSE,
                /* msg_type_unused = */		0,
        };
#endif	UseStaticMsgType

#if	UseStaticMsgType
        static const msg_type_t RetCodeCheck = {
                /* msg_type_name = */		MSG_TYPE_INTEGER_32,
                /* msg_type_size = */		32,
                /* msg_type_number = */		1,
                /* msg_type_inline = */		TRUE,
                /* msg_type_longform = */	FALSE,
                /* msg_type_deallocate = */	FALSE,
                /* msg_type_unused = */		0
        };
#endif	UseStaticMsgType

#if	UseStaticMsgType
        InP->tokenType = tokenType;
#else	UseStaticMsgType
        InP->tokenType.msg_type_name = MSG_TYPE_PORT;
        InP->tokenType.msg_type_size = 32;
        InP->tokenType.msg_type_number = 1;
        InP->tokenType.msg_type_inline = TRUE;
        InP->tokenType.msg_type_longform = FALSE;
        InP->tokenType.msg_type_deallocate = FALSE;
#endif	UseStaticMsgType

        InP->token /* token */ = /* token */ token;

#if	UseStaticMsgType
        InP->taskType = taskType;
#else	UseStaticMsgType
        InP->taskType.msg_type_name = MSG_TYPE_PORT;
        InP->taskType.msg_type_size = 32;
        InP->taskType.msg_type_number = 1;
        InP->taskType.msg_type_inline = TRUE;
        InP->taskType.msg_type_longform = FALSE;
        InP->taskType.msg_type_deallocate = FALSE;
#endif	UseStaticMsgType

        InP->task /* task */ = /* task */ task;

#if	UseStaticMsgType
        InP->addrType = addrType;
#else	UseStaticMsgType
        InP->addrType.msg_type_name = MSG_TYPE_INTEGER_32;
        InP->addrType.msg_type_size = 32;
        InP->addrType.msg_type_number = 1;
        InP->addrType.msg_type_inline = TRUE;
        InP->addrType.msg_type_longform = FALSE;
        InP->addrType.msg_type_deallocate = FALSE;
#endif	UseStaticMsgType

        InP->addr /* addr */ = /* addr */ addr;

#if	UseStaticMsgType
        InP->sizeType = sizeType;
#else	UseStaticMsgType
        InP->sizeType.msg_type_name = MSG_TYPE_INTEGER_32;
        InP->sizeType.msg_type_size = 32;
        InP->sizeType.msg_type_number = 1;
        InP->sizeType.msg_type_inline = TRUE;
        InP->sizeType.msg_type_longform = FALSE;
        InP->sizeType.msg_type_deallocate = FALSE;
#endif	UseStaticMsgType

        InP->size /* size */ = /* size */ size;

#if	UseStaticMsgType
        InP->wireType = wireType;
#else	UseStaticMsgType
        InP->wireType.msg_type_name = MSG_TYPE_BOOLEAN;
        InP->wireType.msg_type_size = 32;
        InP->wireType.msg_type_number = 1;
        InP->wireType.msg_type_inline = TRUE;
        InP->wireType.msg_type_longform = FALSE;
        InP->wireType.msg_type_deallocate = FALSE;
#endif	UseStaticMsgType

        InP->wire /* wire */ = /* wire */ wire;

        InP->Head.msg_simple = FALSE;
        InP->Head.msg_size = msg_size;
        InP->Head.msg_type = MSG_TYPE_NORMAL | MSG_TYPE_RPC;
        InP->Head.msg_request_port = device_port;
        InP->Head.msg_reply_port = mig_get_reply_port();
        InP->Head.msg_id = 1018;

        msg_result = msg_rpc(&InP->Head, MSG_OPTION_NONE, sizeof(Reply), 0, 0);
        if (msg_result != RPC_SUCCESS) {
                if (msg_result == RCV_INVALID_PORT)
                        mig_dealloc_reply_port();
                return msg_result;
        }

#if	TypeCheck
        msg_size = OutP->Head.msg_size;
        msg_simple = OutP->Head.msg_simple;
#endif	TypeCheck

        if (OutP->Head.msg_id != 1118)
                return MIG_REPLY_MISMATCH;

#if	TypeCheck
        if (((msg_size != 32) || (msg_simple != TRUE)) &&
            ((msg_size != sizeof(death_pill_t)) ||
             (msg_simple != TRUE) ||
             (OutP->RetCode == KERN_SUCCESS)))
                return MIG_TYPE_ERROR;
#endif	TypeCheck

#if	TypeCheck
#if	UseStaticMsgType
        if (* (int *) &OutP->RetCodeType != * (int *) &RetCodeCheck)
#else	UseStaticMsgType
        if ((OutP->RetCodeType.msg_type_inline != TRUE) ||
            (OutP->RetCodeType.msg_type_longform != FALSE) ||
            (OutP->RetCodeType.msg_type_name != MSG_TYPE_INTEGER_32) ||
            (OutP->RetCodeType.msg_type_number != 1) ||
            (OutP->RetCodeType.msg_type_size != 32))
#endif	UseStaticMsgType
                return MIG_TYPE_ERROR;
#endif	TypeCheck

        if (OutP->RetCode != KERN_SUCCESS)
                return OutP->RetCode;

        return OutP->RetCode;
}


//========================================================================

/*
==================
SNDDMA_Init

Try to find a sound device to mix for.
Returns false if nothing is found.
==================
*/
qboolean SNDDMA_Init(void)
{
    int		err;
    int		i;
	byte	*buf;
        int	bufsize;
  	int	progress, oldprogress;
        
    shm = &sn;
    shm->channels = 2;
    shm->samplebits = 16;
    shm->speed = 11025;

    err = netname_look_up(name_server_port,"", NTSOUNDNAME,&devPort);
    if (err)
    {
        Com_Printf("SNDDMA_Init: Cannot access theater driver\n");
        return false;
    }

    err = ntsoundAcquire(devPort,task_self(),(vm_offset_t *)&buf,&bufsize,&i);
    if (err || !i)
    {
        Com_Printf("SNDDMA_Init: Sound driver is busy or messed up\n");
        return false;
    }

    err = ntsoundConfig(devPort,task_self(),shm->channels,(int)shm->speed,
                        NX_SoundStreamDataEncoding_Linear16, 1);
    if (err)
    {
        Com_Printf("SNDDMA_Init: ntsoundConfig error: %d\n",err);
        return false;
    }
    else
        Com_Printf("SNDDMA_Init: Configured for %d Hz, %d channels\n"
                   ,(int)shm->speed,shm->channels);
 //   printf ("buf: 0x%x\n", buf);
 //   printf ("bufsize: %d\n", bufsize);

    bzero(buf,bufsize);

//   ntsoundSetVolume(devPort,task_self(),5);
   ntsoundStart(devPort,task_self());

   shm->soundalive = true;
   shm->splitbuffer = false;
   shm->samples = bufsize/(shm->samplebits/8);
   shm->samplepos = 0;
   shm->submission_chunk = 1;
   shm->buffer = buf;

   //
   // find a buffer crossing point for pos testing
   //
   
   ntsoundBytesProcessed(devPort,task_self(),&oldprogress);
   do
       {
       ntsoundBytesProcessed(devPort,task_self(),&progress);
     } while (progress == oldprogress);
   snd_basetime = Sys_DoubleTime() - progress/(11025*2);
 
   return true;
}

/*
==============
SNDDMA_GetDMAPos

return the current sample position (in mono samples read)
inside the recirculating dma buffer, so the mixing code will know
how many sample are required to fill it up.
===============
*/
int SNDDMA_GetDMAPos(void)
{
    int		progress;

#if 0
    ntsoundBytesProcessed(devPort,task_self(),&progress);
//    ntsoundDMACount(devPort,task_self(),&progress);

//printf ("(%i / %f) ", progress, (float)(Sys_DoubleTime ()));
    progress += 2048;
    progress >>= 1;
#else
    
 progress = (Sys_DoubleTime() - snd_basetime)*11025*2;
 progress += 8192;
 progress &= ~1;
#endif
 
    progress &= (shm->samples-1);

    return progress;
}


/*
==============
SNDDMA_Submit

Reset the sound device for exiting
===============
*/
void SNDDMA_Submit(void)
{
}

/*
==============
SNDDMA_Shutdown

Reset the sound device for exiting
===============
*/
void SNDDMA_Shutdown(void)
{
    ntsoundStop(devPort,task_self());
    ntsoundRelease(devPort,task_self());
}

