/*
Copyright (C) 1997-2001 Id Software, Inc.

This program is free software; you can redistribute it and/or
modify it under the terms of the GNU General Public License
as published by the Free Software Foundation; either version 2
of the License, or (at your option) any later version.

This program is distributed in the hope that it will be useful,
but WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  

See the GNU General Public License for more details.

You should have received a copy of the GNU General Public License
along with this program; if not, write to the Free Software
Foundation, Inc., 59 Temple Place - Suite 330, Boston, MA  02111-1307, USA.

*/

#include "qcommon.h"

// define this to dissalow any data but the demo pak file
//#define	NO_ADDONS

// enables faster binary pak searck, still experimental
#define BINARY_PACK_SEARCH

// if a packfile directory differs from this, it is assumed to be hacked
// Full version
#define	PAK0_CHECKSUM	0x40e614e0
// Demo
//#define	PAK0_CHECKSUM	0xb2c6d7ea
// OEM
//#define	PAK0_CHECKSUM	0x78e135c

/*
=============================================================================

QUAKE FILESYSTEM

=============================================================================
*/


//
// in memory
//

typedef struct
{
	char	name[MAX_QPATH];
	long	hash;		// Knightmare added- To speed up searching
	int		filepos, filelen;
	qboolean		ignore;		// Knightmare added- whether this file should be ignored
} packfile_t;

typedef struct pack_s
{
	char	filename[MAX_OSPATH];
	FILE	*handle;
	int		numfiles;
	packfile_t	*files;
	unsigned int	contentFlags;	// Knightmare added- to skip cetain paks
} pack_t;

char	fs_gamedir[MAX_OSPATH];
cvar_t	*fs_basedir;
cvar_t	*fs_cddir;
cvar_t	*fs_gamedirvar;

typedef struct filelink_s
{
	struct filelink_s	*next;
	char	*from;
	int		fromlength;
	char	*to;
} filelink_t;

filelink_t	*fs_links;

typedef struct searchpath_s
{
	char	filename[MAX_OSPATH];
	pack_t	*pack;		// only one of filename / pack will be used
	struct searchpath_s *next;
} searchpath_t;

searchpath_t	*fs_searchpaths;
searchpath_t	*fs_base_searchpaths;	// without gamedirs

char *COM_FileExtension (char *in);

/*

All of Quake's data access is through a hierchal file system, but the contents of the file system can be transparently merged from several sources.

The "base directory" is the path to the directory holding the quake.exe and all game directories.  The sys_* files pass this to host_init in quakeparms_t->basedir.  This can be overridden with the "-basedir" command line parm to allow code debugging in a different directory.  The base directory is
only used during filesystem initialization.

The "game directory" is the first tree on the search path and directory that all generated files (savegames, screenshots, demos, config files) will be saved to.  This can be overridden with the "-game" command line parameter.  The game directory can never be changed while quake is executing.  This is a precacution against having a malicious server instruct clients to write files over areas they shouldn't.

*/

// Knightmare added
char *type_extensions[] =
{
	"bsp",
	"md2",
	"sp2",
	"dm2",
	"cin",
	"wav",
	"ogg",
	"pcx",
	"wal",
	"tga",
//	"jpg",
//	"png",
	"cfg",
	"txt",
	"def",
	"alias",
	0
};

/*
=================
FS_TypeFlagForPakItem
Returns bit flag based on pak item's extension.
=================
*/
unsigned int FS_TypeFlagForPakItem (char *itemName)
{
	int		i;	
	char	*tmp, extension[8];

	tmp = COM_FileExtension (itemName);
	strncpy(extension, tmp, sizeof(extension));
	for (i=0; type_extensions[i]; i++) {
		if ( !Q_stricmp(extension, type_extensions[i]) )
			return (1<<i);
	}
	return 0;
}
// end Knightmare

/*
================
FS_filelength
================
*/
int FS_filelength (FILE *f)
{
	int		pos;
	int		end;

	pos = ftell (f);
	fseek (f, 0, SEEK_END);
	end = ftell (f);
	fseek (f, pos, SEEK_SET);

	return end;
}


/*
============
FS_CreatePath

Creates any directories needed to store the given filename
============
*/
void	FS_CreatePath (char *path)
{
	char	*ofs;

	// Knightmare added
	if (strstr(path, "..") || strstr(path, "::") || strstr(path, "\\\\") || strstr(path, "//"))
	{
		Com_Printf("WARNING: refusing to create relative path '%s'\n", path);
		return;
	}
	
	for (ofs = path+1 ; *ofs ; ofs++)
	{
		if (*ofs == '/')
		{	// create the directory
			*ofs = 0;
			Sys_Mkdir (path);
			*ofs = '/';
		}
	}
}

// Knightmare- Psychospaz's mod detector
qboolean FS_ModType (char *name)
{
	searchpath_t	*search;

	for (search = fs_searchpaths ; search ; search = search->next)
	{
		if (strstr (search->filename, name))
			return true;
	}
	return (0);
}


/*
==============
FS_FCloseFile

For some reason, other dll's can't just cal fclose()
on files returned by FS_FOpenFile...
==============
*/
void FS_FCloseFile (FILE *f)
{
	fclose (f);
}


// RAFAEL
/*
	Developer_searchpath
*/
int	Developer_searchpath (int who)
{
	
	int		ch;
	// PMM - warning removal
//	char	*start;
	searchpath_t	*search;
	
	if (who == 1) // xatrix
		ch = 'x';
	else if (who == 2)
		ch = 'r';

	for (search = fs_searchpaths ; search ; search = search->next)
	{
		if (strstr (search->filename, "xatrix"))
			return 1;

		if (strstr (search->filename, "rogue"))
			return 2;
/*
		start = strchr (search->filename, ch);

		if (start == NULL)
			continue;

		if (strcmp (start ,"xatrix") == 0)
			return (1);
*/
	}
	return (0);

}

// Knightmare added
#ifdef BINARY_PACK_SEARCH
/*
=================
FS_FindPackItem

Performs a binary search by hashed filename
to find pack items in a sorted pack
=================
*/
int FS_FindPackItem (pack_t *pack, char *itemName, long itemHash)
{
	int		smax, smin, smidpt;	//, counter = 0;
	int		i;

	// catch null pointers
	if ( !pack || !itemName )
		return -1;

	smin = 0;	smax = pack->numfiles;
	while ( (smax - smin) > 5 )	//&& counter < pack->numFiles )
	{
		smidpt = (smax + smin) / 2;
		if (pack->files[smidpt].hash > itemHash)	// before midpoint
			smax = smidpt;
		else if (pack->files[smidpt].hash < itemHash)	// after midpoint
			smin = smidpt;
		else	// pack->files[smidpt].hash == itemHash
			break;
	//	counter++;
	}
	for (i=smin; i<smax; i++)
	{	// make sure this entry is not blacklisted & compare filenames
		if ( pack->files[i].hash == itemHash && !pack->files[i].ignore
			&& !Q_stricmp(pack->files[i].name, itemName) )
			return i;
	}
	return -1;
}
#endif	// BINARY_PACK_SEARCH


/*
===========
FS_FOpenFile

Finds the file in the search path.
returns filesize and an open FILE *
Used for streaming data out of either a pak file or
a seperate file.
===========
*/
int file_from_pak = 0;
#ifndef NO_ADDONS
int FS_FOpenFile (char *filename, FILE **file)
{
	searchpath_t	*search;
	char			netpath[MAX_OSPATH];
	pack_t			*pak;
	int				i;
	filelink_t		*link;
	// Knightmare added
	long			hash;
	unsigned int	typeFlag;

	file_from_pak = 0;
	// Knightmare added
	hash = Com_HashFileName(filename, 0, false);
	typeFlag = FS_TypeFlagForPakItem(filename);

	// check for links first
	for (link = fs_links ; link ; link=link->next)
	{
		if (!strncmp (filename, link->from, link->fromlength))
		{
			Com_sprintf (netpath, sizeof(netpath), "%s%s",link->to, filename+link->fromlength);
			*file = fopen (netpath, "rb");
			if (*file)
			{		
				Com_DPrintf ("link file: %s\n",netpath);
				return FS_filelength (*file);
			}
			return -1;
		}
	}

//
// search through the path, one element at a time
//
	for (search = fs_searchpaths ; search ; search = search->next)
	{
	// is the element a pak file?
		if (search->pack)
		{
		// look through all the pak file elements
			pak = search->pack;

			// Knightmare- skip if pack doesn't contain this type of file
			if ((typeFlag != 0)) {
				if (!(pak->contentFlags & typeFlag))
					continue;
			}
#ifdef BINARY_PACK_SEARCH	// Knightmare- use new binary algorithm
			// find index of pack item
			i = FS_FindPackItem (pak, filename, hash);
			// found it!
			if ( i != -1 && i >= 0 && i < pak->numfiles )
			{
#else
			for (i=0 ; i<pak->numfiles ; i++)
			{
				if (pak->files[i].ignore)	// Knightmare- skip blacklisted files
					continue;
				if (hash != pak->files[i].hash)	// Knightmare- compare hash first
					continue;
#endif	// 	BINARY_PACK_SEARCH
				if (!Q_strcasecmp (pak->files[i].name, filename))
				{	// found it!
					file_from_pak = 1;
					Com_DPrintf ("PackFile: %s : %s\n",pak->filename, filename);
				// open a new file on the pakfile
					*file = fopen (pak->filename, "rb");
					if (!*file)
						Com_Error (ERR_FATAL, "Couldn't reopen %s", pak->filename);	
					fseek (*file, pak->files[i].filepos, SEEK_SET);
					return pak->files[i].filelen;
				}
			}
		}
		else
		{		
	// check a file in the directory tree
			
			Com_sprintf (netpath, sizeof(netpath), "%s/%s",search->filename, filename);
			
			*file = fopen (netpath, "rb");
			if (!*file)
				continue;
			
			Com_DPrintf ("FindFile: %s\n",netpath);

			return FS_filelength (*file);
		}
		
	}
	
	Com_DPrintf ("FindFile: can't find %s\n", filename);
	
	*file = NULL;
	return -1;
}

#else

// this is just for demos to prevent add on hacking

int FS_FOpenFile (char *filename, FILE **file)
{
	searchpath_t	*search;
	char			netpath[MAX_OSPATH];
	pack_t			*pak;
	int				i;
	// Knightmare added
	long			hash;

	file_from_pak = 0;
	// Knightmare added
	hash = Com_HashFileName(filename, 0, false);

	// get config from directory, everything else from pak
	if (!strcmp(filename, "config.cfg") || !strncmp(filename, "players/", 8))
	{
		Com_sprintf (netpath, sizeof(netpath), "%s/%s",FS_Gamedir(), filename);
		
		*file = fopen (netpath, "rb");
		if (!*file)
			return -1;
		
		Com_DPrintf ("FindFile: %s\n",netpath);

		return FS_filelength (*file);
	}

	for (search = fs_searchpaths ; search ; search = search->next)
		if (search->pack)
			break;
	if (!search)
	{
		*file = NULL;
		return -1;
	}

	pak = search->pack;
	for (i=0 ; i<pak->numfiles ; i++)
	{
		if (pak->files[i].ignore)	// Knightmare- skip blacklisted files
			continue;
		if (hash != pak->files[i].hash)	// Knightmare- compare hash first
			continue;
		if (!Q_strcasecmp (pak->files[i].name, filename))
		{	// found it!
			file_from_pak = 1;
			Com_DPrintf ("PackFile: %s : %s\n",pak->filename, filename);
		// open a new file on the pakfile
			*file = fopen (pak->filename, "rb");
			if (!*file)
				Com_Error (ERR_FATAL, "Couldn't reopen %s", pak->filename);	
			fseek (*file, pak->files[i].filepos, SEEK_SET);
			return pak->files[i].filelen;
		}
	}
	
	Com_DPrintf ("FindFile: can't find %s\n", filename);
	
	*file = NULL;
	return -1;
}

#endif


/*
=================
FS_Read

Properly handles partial reads
=================
*/
void CDAudio_Stop(void);
#define	MAX_READ	0x10000		// read in blocks of 64k
void FS_Read (void *buffer, int len, FILE *f)
{
	int		block, remaining;
	int		read;
	byte	*buf;
	int		tries;

	buf = (byte *)buffer;

	// read in chunks for progress bar
	remaining = len;
	tries = 0;
	while (remaining)
	{
		block = remaining;
		if (block > MAX_READ)
			block = MAX_READ;
		read = fread (buf, 1, block, f);
		if (read == 0)
		{
			// we might have been trying to read from a CD
			if (!tries)
			{
				tries = 1;
				CDAudio_Stop();
			}
			else
				Com_Error (ERR_FATAL, "FS_Read: 0 bytes read");
		}

		if (read == -1)
			Com_Error (ERR_FATAL, "FS_Read: -1 bytes read");

		// do some progress bar thing here...

		remaining -= read;
		buf += read;
	}
}


// Knightmare added
#if 0
/*
=================
FS_FRead

Properly handles partial reads of size up to count times
No error if it can't read
=================
*/
int FS_FRead (void *buffer, int size, int count, FILE *f)
{
	int			loops, remaining, r;
	byte		*buf;
	qboolean	tried = false;

	// Read
	loops = count;
	//remaining = size;
	buf = (byte *)buffer;

	while (loops)
	{	// Read in chunks
		remaining = size;
		while (remaining)
		{
			r = fread(buf, 1, remaining, f);

			if (r == 0)
			{
				if (!tried)
				{	// We might have been trying to read from a CD
					CDAudio_Stop();
					tried = true;
				}
				else {
				//	Com_Printf("FS_FRead: 0 bytes read\n");
					return size - remaining;
				}
			}
			else if (r == -1)
				Com_Error(ERR_FATAL, "FS_FRead: -1 bytes read");

			remaining -= r;
			buf += r;
		}
		loops--;
	}
	return size;
}


/*
=================
FS_Seek
=================
*/
void FS_Seek (FILE *f, int offset, fsOrigin_t origin)
{
	switch (origin)
	{
	case FS_SEEK_SET:
		fseek(f, offset, SEEK_SET);
		break;
	case FS_SEEK_CUR:
		fseek(f, offset, SEEK_CUR);
		break;
	case FS_SEEK_END:
		fseek(f, offset, SEEK_END);
		break;
	default:
		Com_Error(ERR_FATAL, "FS_Seek: bad origin (%i)", origin);
	}
}


/*
=================
FS_Tell

Returns -1 if an error occurs
=================
*/
int FS_Tell (FILE *f)
{
	return ftell(f);
}
#endif
// end Knightmare


/*
============
FS_LoadFile

Filename are reletive to the quake search path
a null buffer will just return the file length without loading
============
*/
int FS_LoadFile (char *path, void **buffer)
{
	FILE	*h;
	byte	*buf;
	int		len;

	buf = NULL;	// quiet compiler warning

// look for it in the filesystem or pack files
	len = FS_FOpenFile (path, &h);
	if (!h)
	{
		if (buffer)
			*buffer = NULL;
		return -1;
	}
	
	if (!buffer)
	{
		fclose (h);
		return len;
	}

	buf = Z_Malloc(len);
	*buffer = buf;

	FS_Read (buf, len, h);

	fclose (h);

	return len;
}


/*
=============
FS_FreeFile
=============
*/
void FS_FreeFile (void *buffer)
{
	Z_Free (buffer);
}


// Some incompetently packaged mods have these files in their paks!
char *pakfile_ignore_names[] =
{
	"save/",
	"scrnshot/",
	"autoexec.cfg",
	"config.cfg",
	0
};

/*
=================
FS_FileInPakBlacklist

Checks against a blacklist to see if a file
should not be loaded from a pak.
=================
*/
qboolean FS_FileInPakBlacklist (char *filename)
{
	int			i;
	char		*compare;
	qboolean	ignore = false;

	compare = filename;
	if (compare[0] == '/')	// remove leading slash
		compare++;

	for (i=0; pakfile_ignore_names[i]; i++) {
		if ( !Q_strncasecmp(compare, pakfile_ignore_names[i], strlen(pakfile_ignore_names[i])) )
			ignore = true;
	}

//	if (ignore)
//		Com_Printf ("FS_LoadPackFile: file %s blacklisted!\n", filename);
//	else if ( !strncmp (filename, "save/", 5) )
//		Com_Printf ("FS_LoadPackFile: file %s not blacklisted.\n", filename);
	return ignore;
}

#ifdef BINARY_PACK_SEARCH
/*
=================
FS_PakFileCompare
 
Used for sorting pak entries by hash
=================
*/
long *nameHashes = NULL;
int FS_PakFileCompare (const void *f1, const void *f2)
{
	if (!nameHashes)
		return 1;

	return (nameHashes[*((int *)(f1))] - nameHashes[*((int *)(f2))]);
}
#endif	// BINARY_PACK_SEARCH

/*
=================
FS_LoadPackFile

Takes an explicit (not game tree related) path to a pak file.

Loads the header and directory, adding the files at the beginning
of the list so they override previous pack files.

Knightmare- added checks for corrupt/malicious paks by Skuller
=================
*/
#ifndef LONG_MAX
#define LONG_MAX	0x7FFFFFFF
#endif
pack_t *FS_LoadPackFile (char *packfile)
{
	dpackheader_t	header;
	int				i;
	packfile_t		*newfiles;
	int				numpackfiles;
	pack_t			*pack;
	FILE			*packhandle;
	dpackfile_t		info[MAX_FILES_IN_PACK];
	unsigned		checksum;
	unsigned		contentFlags = 0;	// Knightmare added
	int				tmpPos, tmpLen;		// Knightmare added
#ifdef BINARY_PACK_SEARCH	//  Knightmare added
	int				*sortIndices;
	long			*sortHashes;
#endif	// BINARY_PACK_SEARCH

	packhandle = fopen(packfile, "rb");
	if (!packhandle)
		return NULL;

	if ( fread (&header, 1, sizeof(header), packhandle) != sizeof(header) ) {	// Knightmare- catch bad header
		Com_Printf ("Failed to read header on %s\n", packfile);
		fclose(packhandle);
		return NULL;
	}
	if (LittleLong(header.ident) != IDPAKHEADER) {	// Knightmare- made this not fatal
	//	Com_Error (ERR_F/*ATAL, "%s is not a packfile", packfile);
		Com_Printf ("%s is not a pak file\n", packfile);
		fclose(packhandle);
		return NULL;
	}
	header.dirofs = LittleLong (header.dirofs);
	header.dirlen = LittleLong (header.dirlen);
	if ( header.dirlen > LONG_MAX )	// || (header.dirlen % sizeof(packfile_t)) != 0 )	// Knightmare- catch bad dirlen
	{
		Com_Printf ("%s has a bad directory length\n", packfile);
		fclose(packhandle);
		return NULL;
	}
	if ( header.dirofs > (LONG_MAX - header.dirlen) )	// Knightmare- catch bad dirofs
	{
		Com_Printf ("%s has a bad directory offset\n", packfile);
		fclose(packhandle);
		return NULL;
	}

	numpackfiles = header.dirlen / sizeof(dpackfile_t);

	if (numpackfiles > MAX_FILES_IN_PACK) {	// Knightmare- made this not fatal
	//	Com_Error (ERR_FATAL, "%s has %i files", packfile, numpackfiles);
		Com_Printf ("%s has too many files: %i > %i\n", packfile, numpackfiles, MAX_FILES_IN_PACK);
		fclose(packhandle);
		return NULL;
	}

//	newfiles = Z_Malloc (numpackfiles * sizeof(packfile_t));

	if ( fseek (packhandle, header.dirofs, SEEK_SET) )	// Knightmare- catch seek failure
	{
		Com_Printf ("Seeking to directory failed on %s\n", packfile);
		fclose(packhandle);
		return NULL;
	}
	if ( fread (info, 1, header.dirlen, packhandle) != header.dirlen )	// Knightmare- catch dir read failure
	{
		Com_Printf ("Reading directory failed on %s\n", packfile);
		fclose(packhandle);
		return NULL;
	}

// crc the directory to check for modifications
	checksum = Com_BlockChecksum ((void *)info, header.dirlen);

#ifdef NO_ADDONS
	if (checksum != PAK0_CHECKSUM)
		return NULL;
#endif

	for (i = 0; i < numpackfiles; i++)	// Knightmare- catch bad filelen / filepos
	{
		tmpPos = LittleLong(info[i].filepos);
		tmpLen = LittleLong(info[i].filelen);
		if ( tmpLen > LONG_MAX || tmpPos > (LONG_MAX - tmpLen) )
		{
			Com_Printf ("%s has a bad directory structure\n", packfile);
			fclose(packhandle);
			return NULL;
		}
	}

	newfiles = Z_Malloc (numpackfiles * sizeof(packfile_t));	// Knightmare- moved newfiles alloc here

#ifdef BINARY_PACK_SEARCH	// Knightmare- sorting of pak contents for binary search
	// create sort table
	sortIndices = Z_Malloc(numpackfiles * sizeof(int));
	sortHashes = Z_Malloc(numpackfiles * sizeof(unsigned));
	nameHashes = sortHashes;
	for (i = 0; i < numpackfiles; i++)
	{
		sortIndices[i] = i;
		sortHashes[i] = Com_HashFileName(info[i].name, 0, false);
	}
	qsort((void *)sortIndices, numpackfiles, sizeof(int), FS_PakFileCompare);

	// Parse the directory
	for (i = 0; i < numpackfiles; i++)
	{
		strcpy(newfiles[i].name, info[sortIndices[i]].name);
		newfiles[i].hash = sortHashes[sortIndices[i]];
		newfiles[i].filepos = LittleLong(info[sortIndices[i]].filepos);
		newfiles[i].filelen = LittleLong(info[sortIndices[i]].filelen);
		newfiles[i].ignore = FS_FileInPakBlacklist(newfiles[i].name);	// check against pak loading blacklist
		if (!newfiles[i].ignore)	// add type flag for this file
			contentFlags |= FS_TypeFlagForPakItem(newfiles[i].name);
	}

	// free sort table
	Z_Free (sortIndices);
	Z_Free (sortHashes);
	nameHashes = NULL;
#else
// parse the directory
	for (i=0 ; i<numpackfiles ; i++)
	{
		strcpy (newfiles[i].name, info[i].name);
		newfiles[i].hash = Com_HashFileName(info[i].name, 0, false);	// Knightmare- added to speed up seaching
		newfiles[i].filepos = LittleLong(info[i].filepos);
		newfiles[i].filelen = LittleLong(info[i].filelen);
		newfiles[i].ignore = FS_FileInPakBlacklist(info[i].name);	// Knightmare- check against pak loading blacklist
		if (!newfiles[i].ignore)	// Knightmare- add type flag for this file
			contentFlags |= FS_TypeFlagForPakItem(newfiles[i].name);
	}
#endif	// BINARY_PACK_SEARCH

	pack = Z_Malloc (sizeof (pack_t));
	strcpy (pack->filename, packfile);
	pack->handle = packhandle;
	pack->numfiles = numpackfiles;
	pack->files = newfiles;
	pack->contentFlags = contentFlags;	// Knightmare added
	
	Com_Printf ("Added packfile %s (%i files)\n", packfile, numpackfiles);
	return pack;
}


/*
================
FS_AddGameDirectory

Sets fs_gamedir, adds the directory to the head of the path,
then loads and adds pak1.pak pak2.pak ... 
================
*/
void FS_AddGameDirectory (char *dir)
{
	int				i;
	searchpath_t	*search;
	pack_t			*pak;
	char			pakfile[MAX_OSPATH];

	strcpy (fs_gamedir, dir);

	//
	// add the directory to the search path
	//
	search = Z_Malloc (sizeof(searchpath_t));
	strcpy (search->filename, dir);
	search->next = fs_searchpaths;
	fs_searchpaths = search;

	//
	// add any pak files in the format pak0.pak pak1.pak, ...
	//
	for (i=0; i<100; i++) // Knightmare- go up to pak99
	{
		Com_sprintf (pakfile, sizeof(pakfile), "%s/pak%i.pak", dir, i);
		pak = FS_LoadPackFile (pakfile);
		if (!pak)
			continue;
		search = Z_Malloc (sizeof(searchpath_t));
		search->pack = pak;
		search->next = fs_searchpaths;
		fs_searchpaths = search;		
	}


}

/*
============
FS_Gamedir

Called to find where to write a file (demos, savegames, etc)
============
*/
char *FS_Gamedir (void)
{
	if (*fs_gamedir)
		return fs_gamedir;
	else
		return BASEDIRNAME;
}

/*
=============
FS_ExecAutoexec
=============
*/
void FS_ExecAutoexec (void)
{
	char *dir;
	char name [MAX_QPATH];

	dir = Cvar_VariableString("gamedir");
	if (*dir)
		Com_sprintf(name, sizeof(name), "%s/%s/autoexec.cfg", fs_basedir->string, dir); 
	else
		Com_sprintf(name, sizeof(name), "%s/%s/autoexec.cfg", fs_basedir->string, BASEDIRNAME); 
	if (Sys_FindFirst(name, 0, SFF_SUBDIR | SFF_HIDDEN | SFF_SYSTEM))
		Cbuf_AddText ("exec autoexec.cfg\n");
	Sys_FindClose();
}


/*
================
FS_SetGamedir

Sets the gamedir and path to a different directory.
================
*/
void FS_SetGamedir (char *dir)
{
	searchpath_t	*next;

	if (strstr(dir, "..") || strstr(dir, "/")
		|| strstr(dir, "\\") || strstr(dir, ":") )
	{
		Com_Printf ("Gamedir should be a single filename, not a path\n");
		return;
	}

	//
	// free up any current game dir info
	//
	while (fs_searchpaths != fs_base_searchpaths)
	{
		if (fs_searchpaths->pack)
		{
			fclose (fs_searchpaths->pack->handle);
			Z_Free (fs_searchpaths->pack->files);
			Z_Free (fs_searchpaths->pack);
		}
		next = fs_searchpaths->next;
		Z_Free (fs_searchpaths);
		fs_searchpaths = next;
	}

	//
	// flush all data, so it will be forced to reload
	//
	if (dedicated && !dedicated->value)
		Cbuf_AddText ("vid_restart\nsnd_restart\n");

	Com_sprintf (fs_gamedir, sizeof(fs_gamedir), "%s/%s", fs_basedir->string, dir);

	if (!strcmp(dir,BASEDIRNAME) || (*dir == 0))
	{
		Cvar_FullSet ("gamedir", "", CVAR_SERVERINFO|CVAR_NOSET);
		Cvar_FullSet ("game", "", CVAR_LATCH|CVAR_SERVERINFO);
	}
	else
	{
		Cvar_FullSet ("gamedir", dir, CVAR_SERVERINFO|CVAR_NOSET);
		if (fs_cddir->string[0])
			FS_AddGameDirectory (va("%s/%s", fs_cddir->string, dir) );
		FS_AddGameDirectory (va("%s/%s", fs_basedir->string, dir) );
	}
}


/*
================
FS_Link_f

Creates a filelink_t
================
*/
void FS_Link_f (void)
{
	filelink_t	*l, **prev;
	char		*to;

	if (Cmd_Argc() != 3)
	{
		Com_Printf ("USAGE: link <from> <to>\n");
		return;
	}

	// r1ch's fix to prevent filesystem browsing
	to = Cmd_Argv(2);
	if (to[0])
	{
		if (strstr(to, "..") || strchr(to, '\\') || *to != '.')
		{
			Com_Printf ("Illegal destination path.\n");
			return;
		}
	}

	// see if the link already exists
	prev = &fs_links;
	for (l=fs_links ; l ; l=l->next)
	{
		if (!strcmp (l->from, Cmd_Argv(1)))
		{
			Z_Free (l->to);
			if (!strlen(Cmd_Argv(2)))
			{	// delete it
				*prev = l->next;
				Z_Free (l->from);
				Z_Free (l);
				return;
			}
			l->to = CopyString (Cmd_Argv(2));
			return;
		}
		prev = &l->next;
	}

	// create a new link
	l = Z_Malloc(sizeof(*l));
	l->next = fs_links;
	fs_links = l;
	l->from = CopyString(Cmd_Argv(1));
	l->fromlength = strlen(l->from);
	l->to = CopyString(Cmd_Argv(2));
}

/*
** FS_ListFiles
*/
char **FS_ListFiles( char *findname, int *numfiles, unsigned musthave, unsigned canthave )
{
	char *s;
	int nfiles = 0;
	char **list = 0;

	s = Sys_FindFirst( findname, musthave, canthave );
	while ( s )
	{
		if ( s[strlen(s)-1] != '.' )
			nfiles++;
		s = Sys_FindNext( musthave, canthave );
	}
	Sys_FindClose ();

	if ( !nfiles ) {
		*numfiles = 0;
		return NULL;
	}

	nfiles++; // add space for a guard
	*numfiles = nfiles;

	list = malloc( sizeof( char * ) * nfiles );
	memset( list, 0, sizeof( char * ) * nfiles );

	s = Sys_FindFirst( findname, musthave, canthave );
	nfiles = 0;
	while ( s )
	{
		if ( s[strlen(s)-1] != '.' )
		{
			list[nfiles] = strdup( s );
#ifdef _WIN32
			strlwr( list[nfiles] );
#endif
			nfiles++;
		}
		s = Sys_FindNext( musthave, canthave );
	}
	Sys_FindClose ();

	return list;
}

/*
** FS_Dir_f
*/
void FS_Dir_f( void )
{
	char	*path = NULL;
	char	findname[1024];
	char	wildcard[1024] = "*.*";
	char	**dirnames;
	int		ndirs;

	if ( Cmd_Argc() != 1 )
	{
		strcpy( wildcard, Cmd_Argv( 1 ) );
	}

	while ( ( path = FS_NextPath( path ) ) != NULL )
	{
		char *tmp = findname;

		Com_sprintf( findname, sizeof(findname), "%s/%s", path, wildcard );

		while ( *tmp != 0 )
		{
			if ( *tmp == '\\' ) 
				*tmp = '/';
			tmp++;
		}
		Com_Printf( "Directory of %s\n", findname );
		Com_Printf( "----\n" );

		if ( ( dirnames = FS_ListFiles( findname, &ndirs, 0, 0 ) ) != 0 )
		{
			int i;

			for ( i = 0; i < ndirs-1; i++ )
			{
				if ( strrchr( dirnames[i], '/' ) )
					Com_Printf( "%s\n", strrchr( dirnames[i], '/' ) + 1 );
				else
					Com_Printf( "%s\n", dirnames[i] );

				free( dirnames[i] );
			}
			free( dirnames );
		}
		Com_Printf( "\n" );
	};
}

/*
============
FS_Path_f

============
*/
void FS_Path_f (void)
{
	searchpath_t	*s;
	filelink_t		*l;

	Com_Printf ("Current search path:\n");
	for (s=fs_searchpaths ; s ; s=s->next)
	{
		if (s == fs_base_searchpaths)
			Com_Printf ("----------\n");
		if (s->pack)
		//	Com_Printf("%s (%i files, content flags: %d)\n", s->pack->filename, s->pack->numfiles, s->pack->contentFlags);
			Com_Printf ("%s (%i files)\n", s->pack->filename, s->pack->numfiles);
		else
			Com_Printf ("%s\n", s->filename);
	}

	Com_Printf ("\nLinks:\n");
	for (l=fs_links ; l ; l=l->next)
		Com_Printf ("%s : %s\n", l->from, l->to);
}

/*
================
FS_NextPath

Allows enumerating all of the directories in the search path
================
*/
char *FS_NextPath (char *prevpath)
{
	searchpath_t	*s;
	char			*prev;

	if (!prevpath)
		return fs_gamedir;

	prev = fs_gamedir;
	for (s=fs_searchpaths ; s ; s=s->next)
	{
		if (s->pack)
			continue;
		if (prevpath == prev)
			return s->filename;
		prev = s->filename;
	}

	return NULL;
}


/*
================
FS_InitFilesystem
================
*/
void FS_InitFilesystem (void)
{
	Cmd_AddCommand ("path", FS_Path_f);
	Cmd_AddCommand ("link", FS_Link_f);
	Cmd_AddCommand ("dir", FS_Dir_f );

	//
	// basedir <path>
	// allows the game to run from outside the data tree
	//
	fs_basedir = Cvar_Get ("basedir", ".", CVAR_NOSET);

	//
	// cddir <path>
	// Logically concatenates the cddir after the basedir for 
	// allows the game to run from outside the data tree
	//
	fs_cddir = Cvar_Get ("cddir", "", CVAR_NOSET);
	if (fs_cddir->string[0])
		FS_AddGameDirectory (va("%s/"BASEDIRNAME, fs_cddir->string) );

	//
	// start up with baseq2 by default
	//
	FS_AddGameDirectory (va("%s/"BASEDIRNAME, fs_basedir->string) );

	// any set gamedirs will be freed up to here
	fs_base_searchpaths = fs_searchpaths;

	// check for game override
	fs_gamedirvar = Cvar_Get ("game", "", CVAR_LATCH|CVAR_SERVERINFO);
	if (fs_gamedirvar->string[0])
		FS_SetGamedir (fs_gamedirvar->string);
}

// Knightmare added
/*
=================
FS_ListPak

Generates a listing of the contents of a pak file
=================
*/
char **FS_ListPak (char *find, int *num)
{
	searchpath_t	*search;
	//char			netpath[MAX_OSPATH];
	pack_t			*pak;

	int nfiles = 0, nfound = 0;
	char **list = 0;
	int i;

	// now check pak files
	for (search = fs_searchpaths; search; search = search->next)
	{
		if (!search->pack)
			continue;

		pak = search->pack;

		// now find and build list
		for (i=0 ; i<pak->numfiles ; i++)
				nfiles++;
	}

	list = malloc( sizeof( char * ) * nfiles );
	memset( list, 0, sizeof( char * ) * nfiles );

	for (search = fs_searchpaths; search; search = search->next)
	{
		if (!search->pack)
			continue;

		pak = search->pack;

		// now find and build list
		for (i=0 ; i<pak->numfiles ; i++)
		{
			if (strstr(pak->files[i].name, find))
			{
				list[nfound] = strdup(pak->files[i].name);
				nfound++;
			}
		}
	}
	
	*num = nfound;

	return list;		
}


/*
=================
FS_FreeFileList
=================
*/
void FS_FreeFileList (char **list, int n)
{
	int i;

	for (i = 0; i < n; i++)
	{
		if (list && list[i])
		{
			free(list[i]);
			list[i] = 0;
		}
	}
	free(list);
}


/*
=================
FS_ItemInList
=================
*/
qboolean FS_ItemInList (char *check, int num, char **list)
{
	int		i;

	if (!check || !list)
		return false;
	for (i=0; i<num; i++)
	{
		if (!list[i])
			continue;
		if (!Q_strcasecmp(check, list[i]))
			return true;
	}
	return false;
}


/*
=================
FS_InsertInList
=================
*/
void FS_InsertInList (char **list, char *insert, int len, int start)
{
	int		i;

	if (!list) return;
	if (len < 1 || start < 0) return;
	if (start >= len) return;

	for (i=start; i<len; i++)
	{
		if (!list[i])
		{
			list[i] = strdup(insert);
			return;
		}
	}
	list[len] = strdup(insert);
}
// end Knightmare