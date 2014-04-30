/*
   Copyright (C) 1996, 1997, 1998, 1999, 2000 Florian Schintke

   This is free software; you can redistribute it and/or modify it under
   the terms of the GNU General Public License as published by the Free
   Software Foundation; either version 2, or (at your option) any later
   version.

   This is distributed in the hope that it will be useful, but WITHOUT
   ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or
   FITNESS FOR A PARTICULAR PURPOSE.  See the GNU General Public License
   for more details.

   You should have received a copy of the GNU General Public License with
   the c2html, java2html, pas2html or perl2html source package as the
   file COPYING. If not, write to the Free Software Foundation, Inc.,
   59 Temple Place - Suite 330, Boston, MA
   02111-1307, USA.
*/

#ifndef WILDCARDS_H
#define WILDCARDS_H

extern int wildcardfit (char *wildcard, char *test);
/* this function implements the UN*X wildcards and returns  */
/* 0  if *wildcard does not match *test                     */
/* 1  if *wildcard matches *test                            */

#endif