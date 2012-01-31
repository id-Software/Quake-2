
Quake2 3.16 changes:

- Fixed infinite grenade bug
- Fixed autodownloading to actually download sounds and console pics
- Fixed autodownload to not create empty directories for files not on
  the server.
- Added customized client downloading.  cvars are the same as the server side:
    allow_download - global download on/off
    allow_download_players - players download on/off
    allow_download_models - models download on/off
    allow_download_sounds - sounds download on/off
    allow_download_maps - maps download on/off
  They can also be (more easily) set with a new Download Options menu 
  accessible in Multiplayer/Player Setup/Download Options
- Changed checksumming code to be more portable and faster.


Quake2 3.15 changes:

- Added visible weapons support.  This is precached with a special symbol, i.e.
  gi.modelindex("#w_shotgun.md2") which causes the client to autobind it to
  the players current weapon model.  Plug in player models can optionally 
  support the visible weapons.  Any that do not support it will use their
  default weapon.md2 files automatically.
  Visible weapons files for plug in player models are not downloaded
  automatically--only the default weapon.md2 (and skin) is.
- New cvar cl_vwep controls whether visible weapons is enabled on the client.
  If you turn it off, the visible weapons models are not loaded.  This can offer
  a speed up on slow or memory starved machines.
- Rewrote the some of the net code to use optimized network packets for 
  projectiles.  This is transparent to the game code, but improves netplay
  substancially.  The hyperblaster doesn't flood modem players anymore.
- Rewrote the packet checksum code to be more portable and defeat proxy bots
  yet again.
- Autodownload support is in.  The following items will be automatcally
  downloaded as needed:
    - world map (and textures)
    - models
    - sounds (precached ones)
    - plug in player model, skin, skin_i and weapon.md2
  downloads go to a temp file (maps/blah.tmp for example) and get renamed
  when done.  autoresume is supported (if you lose connect during the
  download, just reconnect and resume).  Server has fine control over
  the downloads with the following new cvars:
    allow_download - global download on/off
    allow_download_players - players download on/off
    allow_download_models - models download on/off
    allow_download_sounds - sounds download on/off
    allow_download_maps - maps download on/off
  maps that are in pak files will _not_ autodownload from the server, this
  is for copyright considerations.
  The QuakeWorld bug of the server map changing while download a map has
  been fixed.
- New option in the Multiplayer/Player Setup menu for setting your connection
  speed.  This sets a default rate for the player and can improve net
  performance for modem connections.
- Rewrote some of the save game code to make it more portable.  I wanted to
  completely rewrite the entire save game system and make it portable across
  versions and operating systems, but this would require an enormous amount
  of work.
- Added another 512 configure strings for general usage for mod makers.
  This gives lots of room for general string displays on the HUD and in other
  data.
- Player movement code re-written to be similiar to that of NetQuake and
  later versions of QuakeWorld.  Player has more control in the air and
  gets a boost in vertical speed when jumping off the top of ramps.
- Fixed up serverrecord so that it works correctly with the later versions.
  serverrecord lets the server do a recording of the current game that
  demo editors can use to make demos from any PVS in the level.  Server
  recorded demos are BIG.  Will look at using delta compression in them
  to cut down the size.
- Copy protection CD check has been removed.
- Quake2 3.15 has changed the protocol (so old servers will not run) but
  all existing game dlls can run on the new version (albiet without the
  new features such as visible weapons).
- Added flood protection.  Controlled from the following cvars:
   flood_msgs - maximum number of messages allowed in the time period
                specified by flood_persecond
   flood_persecond - time period that a maximum of flood_msgs messages are
                     permitted
   flood_waitdelay - amount of time a client gets muzzled for flooding
- fixed it so blaster/hyperblaster shots aren't treated as solid when
  predicting--you aren't clipped against them now.
- gender support is now in.  The userinfo cvar "gender" can be set to
  male/female/none (none for neutral messages).  This doesn't affect sounds
  but does affect death messages in the game.  The models male and cyborg
  default to gender male, and female and crackhor default to female.
  Everything else defaults to none, but you can set it by typing
  "gender male" or "gender female" as appropriate.
- IP banning support ala QW.  It's built into the game dll as 'sv' console
  commands.  This list is:
    sv addip <ip-mask>  - adds an ip to the ban list
	sv listip <ip-mask> - removes an ip from the ban list
	sv writeip - writes the ban list to <gamedir>/listip.cfg.  You can
	  exec this on a server load to load the list on subsequent server runs.
	  like so:  quake2 +set dedicated 1 +exec listip.cfg
	sv removeip <ip-mask> - remove an ip from the list
  the ip list is a simple mask system.  Adding 192.168 to the list
  would block out everyone in the 192.168.*.* net block.  You get 1024 bans,
  if you need more, recompile the game dll. :)
  A new cvar is also supported called 'filterban'.  It defaults to one which
  means "allow everyone to connect _except_ those matching in the ban list."
  If you set it to zero, the meaning reverses like so, "don't allow anyone
  to connect unless they are in the list."

Quake2 CTF 1.09a Changes:

- Q2CTF 1.09 requires 3.15 now.
- Competition Match mode added.  Server can be reset into a timed match mode.
  Includes a pregame setup time, countdown until game start, timed match,
  statistics on players, admin functions and a post game time.
- The server command 'gamemap' now works correctly.  On a server, you can
  change maps with two commands:  map and gamemap.  Map will cause all teams
  to reset, gamemap will change maps with the teams intact.
- New console commands:
    yes - vote yes on an election
    no - vote no on an election
    ready - ready oneself for a match
    notready - remove oneself from the ready list (stop the clock)
    ghost - ghost back into a match if connection was lost
    admin - become an admin or access the admin menu
    stats - show statistics on players in a match
    warp - warp to a new level
    boot - kick a player of the server (you must be an admin)
    playerlist - show player list and connect times
- New cvars:
    competition - set to 1 to allow the server to be voted by players into
      competition mode.  Set to 3 for a dedicated competition server.
      The default, 0, disables competition features.
    matchlock - controls whether players are allowed into a match in progress
      in competition mode.  Defaults to on (1).
    electpercentage - the precentage of yes votes needed to win an election.
      Defaults to 66%.
    matchtime - length of a match, defaulting to 20 minutes.  Can be changed
      by admins.
    matchsetuptime - length of time allowed to setup a match (after which
      the server will reset itself back into normal pickup play).  Defaults
      to 10 mins.
    matchstarttime - The countdown after match setup has been completed
      until the match begins.  Defaults to 20 seconds.
    admin_password - Password for admin access (allowing access to the admin
      menu without needing to be elected).
- Minor bug fixes in team selection to help balance the teams better (the
  default option on the menu is now the team with the fewer players).
- Don't get base defenses for telefragging your teammates in base.
- Telefrags at start of game no longer count (to help with game spawning).
- Instant weapon changing is now a server option (and can be changed by
  admin menu).
- New admin menu that allows remote changes of the following items:
    Match length (time)
    Match setup length (time)
    Match start length (time)
    Weapons Stay
    Instant Items
    Quad Drop
    Instant Weapons
- As part of the match code, a new 'ghost' option is included.  When a match
  begins, all players are printed a randomly generated five digit ghost code
  in their consoles.  If the player loses connection for some reason during
  the match, they can reconnect and reenter the game keeping their score
  intact at the time of disconnection.
- Visible weapon support (as with the 3.15 release).
- Some minor changes to the pmenu code to allow more flexability

    
