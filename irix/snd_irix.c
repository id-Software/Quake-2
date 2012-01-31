#include <dmedia/dmedia.h>
#include <dmedia/audio.h>

#include "../client/client.h"
#include "../client/snd_loc.h"

/*
==================
SNDDM_Init

Try to find a sound device to mix for.
Returns false if nothing is found.
Returns true and fills in the "dma" structure with information for the mixer.
==================
*/

// must be power of two!
#define QSND_SKID	    2
#define QSND_BUFFER_FRAMES  8192
#define QSND_BUFFER_SIZE    (QSND_BUFFER_FRAMES*2)

#define UST_TO_BUFFPOS(ust) ((int)((ust) & (QSND_BUFFER_FRAMES - 1)) << 1)

cvar_t *s_loadas8bit;
cvar_t *s_khz;
cvar_t *sndchannels;

short int dma_buffer[QSND_BUFFER_SIZE];
ALport sgisnd_aport = NULL;
long long sgisnd_startframe;
double sgisnd_frames_per_ns;
long long sgisnd_lastframewritten = 0;

qboolean SNDDMA_Init(void)
{
    ALconfig	ac = NULL;
    ALpv	pvbuf[2];

    s_loadas8bit = Cvar_Get("s_loadas8bit", "16", CVAR_ARCHIVE);
    if ((int)s_loadas8bit->value)
	dma.samplebits = 8;
    else
	dma.samplebits = 16;

    if (dma.samplebits != 16) {
	Com_Printf("Don't currently support %i-bit data.  Forcing 16-bit.\n",
		   dma.samplebits);
	dma.samplebits = 16;
	Cvar_SetValue( "s_loadas8bit", false );
    }

    s_khz = Cvar_Get("s_khz", "0", CVAR_ARCHIVE);
    switch ((int)s_khz->value) {
    case 48:
	dma.speed = AL_RATE_48000;
	break;
    case 44:
	dma.speed = AL_RATE_44100;
	break;
    case 32:
	dma.speed = AL_RATE_32000;
	break;
    case 22:
	dma.speed = AL_RATE_22050;
	break;
    case 16:
	dma.speed = AL_RATE_16000;
	break;
    case 11:
	dma.speed = AL_RATE_11025;
	break;
    case 8:
	dma.speed = AL_RATE_8000;
	break;
    default:
	dma.speed = AL_RATE_22050;
	Com_Printf("Don't currently support %i kHz sample rate.  Using %i.\n",
		   (int)s_khz->value, (int)(dma.speed/1000));
    }
    
    sndchannels = Cvar_Get("sndchannels", "2", CVAR_ARCHIVE);
    dma.channels = (int)sndchannels->value;
    if (dma.channels != 2)
	Com_Printf("Don't currently support %i sound channels.  Try 2.\n",
		   sndchannels);

    /***********************/

    ac = alNewConfig();
    alSetChannels( ac, AL_STEREO );
    alSetSampFmt( ac, AL_SAMPFMT_TWOSCOMP );
    alSetQueueSize( ac, QSND_BUFFER_FRAMES );
    if (dma.samplebits == 8)
	alSetWidth( ac, AL_SAMPLE_8 );
    else
	alSetWidth( ac, AL_SAMPLE_16 );

    sgisnd_aport = alOpenPort( "Quake", "w", ac );
    if (!sgisnd_aport)
    {
	printf( "failed to open audio port!\n" );
    }

    // set desired sample rate
    pvbuf[0].param = AL_MASTER_CLOCK;
    pvbuf[0].value.i = AL_CRYSTAL_MCLK_TYPE;
    pvbuf[1].param = AL_RATE;
    pvbuf[1].value.ll = alIntToFixed( dma.speed );
    alSetParams( alGetResource( sgisnd_aport ), pvbuf, 2 );
    if (pvbuf[1].sizeOut < 0)
	printf( "illegal sample rate %d\n", dma.speed );

    sgisnd_frames_per_ns = dma.speed * 1.0e-9;

    dma.samples = sizeof(dma_buffer)/(dma.samplebits/8);
    dma.submission_chunk = 1;

    dma.buffer = (unsigned char *)dma_buffer;

    dma.samplepos = 0;

    alFreeConfig( ac );
    return true;
}


/*
==============
SNDDMA_GetDMAPos

return the current sample position (in mono samples, not stereo)
inside the recirculating dma buffer, so the mixing code will know
how many sample are required to fill it up.
===============
*/
int SNDDMA_GetDMAPos(void)
{
    long long ustFuture, ustNow;
    if (!sgisnd_aport) return( 0 );
    alGetFrameTime( sgisnd_aport, &sgisnd_startframe, &ustFuture );
    dmGetUST( (unsigned long long *)&ustNow );
    sgisnd_startframe -= (long long)((ustFuture - ustNow) * sgisnd_frames_per_ns);
    sgisnd_startframe += 100;
//printf( "frame %ld pos %d\n", frame, UST_TO_BUFFPOS( sgisnd_startframe ) );
    return( UST_TO_BUFFPOS( sgisnd_startframe ) );
}

/*
==============
SNDDMA_Shutdown

Reset the sound device for exiting
===============
*/
void SNDDMA_Shutdown(void)
{
    if (sgisnd_aport) alClosePort( sgisnd_aport ), sgisnd_aport = NULL;
    return;
}

/*
==============
SNDDMA_Submit

Send sound to device if buffer isn't really the dma buffer
===============
*/

extern int soundtime;

void SNDDMA_Submit(void)
{
    int nFillable, nFilled, nPos;
    int nFrames, nFramesLeft;
    unsigned endtime;

    if (!sgisnd_aport) return;

    nFillable = alGetFillable( sgisnd_aport );
    nFilled = QSND_BUFFER_FRAMES - nFillable;

    nFrames = dma.samples >> (dma.channels - 1);

    if (paintedtime - soundtime < nFrames)
	nFrames = paintedtime - soundtime;

    if (nFrames <= QSND_SKID) return;

    nPos = UST_TO_BUFFPOS( sgisnd_startframe );

    // dump re-written contents of the buffer
    if (sgisnd_lastframewritten > sgisnd_startframe)
    {
	alDiscardFrames( sgisnd_aport, sgisnd_lastframewritten - sgisnd_startframe );
    }
    else if ((int)(sgisnd_startframe - sgisnd_lastframewritten) >= QSND_BUFFER_FRAMES)
    {
	// blow away everything if we've underflowed
	alDiscardFrames( sgisnd_aport, QSND_BUFFER_FRAMES );
    }

    // don't block
    if (nFrames > nFillable) nFrames = nFillable;

    // account for stereo
    nFramesLeft = nFrames;
    if (nPos + nFrames * dma.channels > QSND_BUFFER_SIZE)
    {
	int nFramesAtEnd = (QSND_BUFFER_SIZE - nPos) >> (dma.channels - 1);
	
	alWriteFrames( sgisnd_aport, &dma_buffer[nPos], nFramesAtEnd );
	nPos = 0;
	nFramesLeft -= nFramesAtEnd;
    }
    alWriteFrames( sgisnd_aport, &dma_buffer[nPos], nFramesLeft );

    sgisnd_lastframewritten = sgisnd_startframe + nFrames;
}

void SNDDMA_BeginPainting (void)
{
}
