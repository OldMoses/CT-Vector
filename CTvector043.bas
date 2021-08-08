$CONSOLE
$COLOR:32


'²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²
'² ÉÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ» ²
'² º ÉÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ» º ²
'² º º                     CT-Vector (formerly Star Ruttier)                      º º ²
'² º ÌÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹ º ²
'² º º 2D6 Sci Fi roleplaying utility inspired by Classic Traveller starship      º º ²
'² º º combat tabletop rules.                                                     º º ²
'² º º coding by Richard Wessel using  QB64 v.1.5                                 º º ²
'² º º user must have v.1.5 or later to compile, available at www.qb64.org        º º ²
'² º º                                                                            º º ²
'² º º Made possible with guidance and code contributions by Bplus, Petr,         º º ²
'² º º SMcNeill, SierraKen, FellippeHeitor and many others at QB64.org forum.     º º ²
'² º º Thank you.                                                                 º º ²
'² º º                                                                            º º ²
'² º º Thanks to my son Erik for the idea to include an auto counter thrust,      º º ²
'² º º as well as listening to the endless blather.                               º º ²
'² º º                                                                            º º ²
'² º º Development and beta test version 0.43  uploaded __-__-2021                º º ²
'² º º                                                                            º º ²
'² º º The Traveller game in all forms is owned by Far Future Enterprises.        º º ²
'² º º Copyright 1977 - 2008 Far Future Enterprises.                              º º ²
'² º º see SUB Comments for full fair use text.                                   º º ²
'² º º                                                                            º º ²
'² º ÈÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼ º ²
'² ÈÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼ ²
'²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²

'                                                               USER DEFINED VARIABLES
TYPE V3 '                                                       relative unit placement
    pX AS _INTEGER64 '                                          X coordinate / mem 0-7
    pY AS _INTEGER64 '                                          Y coordinate / mem 8-15
    pZ AS _INTEGER64 '                                          Z coordinate / mem 16-23
END TYPE

TYPE V3U '                                                      converting V3 to unit vectors
    x AS _FLOAT
    y AS _FLOAT
    z AS _FLOAT
END TYPE

TYPE ship '                                                     unit info variable
    id AS _UNSIGNED _BYTE '                                     unit ID / mem 0
    Nam AS STRING * 10 '                                        unit name / mem 1 - 10
    MaxG AS SINGLE '                                            Maximum thrust ship can use / mem 11-14
    op AS V3 '                                                  previous turn x,y,z position op=old position / mem 15-22,23-30,31-38
    OSp AS SINGLE '                                             previous turn velocity / mem 39-42
    OHd AS SINGLE '                                             previous turn heading / mem 43-46
    OIn AS SINGLE '                                             previous turn inclination / mem 47-50
    Ostat AS _BYTE '                                            previous turn status / mem 51
    ap AS V3 '                                                  Absolute x,y,z position ap=absolute position / mem 52-59,60-67,68-75
    Sp AS SINGLE '                                              coasting velocity / mem 76-79
    Hd AS SINGLE '                                              coasting heading / mem 80-83
    In AS SINGLE '                                              coasting inclination / mem 84-87
    status AS _BYTE '                                           0=destroyed 1=in flight 2=landed 3=disabled / mem 88
    '                                                           4=launching
    bogey AS _BYTE '                                            target of intercept/evade/Pfall/Orbit/etc. solution / mem 89
    bstat AS _BYTE '                                            type of solution 0=none 1=evade 2=intercept 3=Planetfall / mem 90
    '                                                               4=Orbit 5=Fleet slaved 6=Station keeping etc., etc.
    bdata AS _INTEGER64 '                                       Orbit flightplan altitude
    mil AS _BYTE '                                              military sensors? true/false / mem 91
END TYPE

TYPE Maneuver '                                                 active thrust/force polar vector
    Azi AS SINGLE '                                             Thrust heading / mem 0-3
    Inc AS SINGLE '                                             Thrust inclination / mem 4-7
    Gs AS SINGLE '                                              Thrust acceleration / mem 8-11
END TYPE

TYPE body '                                                     Celestial bodies
    nam AS STRING * 20 '                                        Name / mem 0-19
    parnt AS STRING * 20 '                                      name of parent body / mem 20-39
    radi AS _INTEGER64 '                                        Size (needs _INTEGER64 in event of large star) / mem 40-47
    orad AS _INTEGER64 '                                        Orbital radius / mem 48-55
    oprd AS SINGLE '                                            Orbital period (years) / mem 56-59
    rota AS SINGLE '                                            Rotational period / mem 60-63
    dens AS SINGLE '                                            Density, basis for grav(Gs) calculation / mem 64-67
    rank AS _BYTE '                                             1=primary, 2=planet/companion, 3=satelite, etc. / mem 68
    star AS _BYTE '                                             -1=star  0=non-stellar body 2=planetoid belt / mem 69
    class AS STRING * 2 '                                       Two digit code, use for stellar class, GG, etc. / mem 70-71
    siz AS STRING * 3 '                                         three digit code, use for stellar size, / mem 72-74
    ps AS V3 '                                                  coordinate position / mem 75-98
END TYPE

TYPE sort '                                                     Large value sorting variable
    index AS INTEGER
    value AS _INTEGER64
END TYPE

'                                                               GLOBAL VARIABLES, ARRAYS AND HANDLES
DIM SHARED ttl AS STRING * 15 '                                 Title bar text
DIM SHARED clr&(0 TO 15) '                                      32 bit equivalent of SCREEN 0 colors
DIM SHARED hvns(x) AS body '                                    System stars and planets
DIM SHARED cmb(x) AS ship '                                     unit info array (Combatants)
DIM SHARED rcs(x) AS V3 '                                       Relative Coordinate Ship- x,y,z relative to vpoint
DIM SHARED rcp(x) AS V3 '                                       Relative Coordinate Planet- "   "   "    "    "
DIM SHARED dcs(x) AS V3 '                                       display Coordinate Ship
DIM SHARED dcp(x) AS V3 '                                       display Coordinate Planet
DIM SHARED ihat AS V3 '                                         x axis identity vector
DIM SHARED jhat AS V3 '                                         y axis identity vector
DIM SHARED khat AS V3 '                                         z axis identity vector
'DIM SHARED xangle AS SINGLE '                                   Andle of rotation on ecliptic
DIM SHARED zangle AS SINGLE '                                   Angle from overhead for Z-pan
DIM SHARED Ozang AS SINGLE '                                    Old 3D angle value for fast toggle
DIM SHARED vpoint AS _UNSIGNED _BYTE '                          active unit pointer
DIM SHARED shipoff AS _UNSIGNED _BYTE '                         display offset for ship data scroll
DIM SHARED units AS _UNSIGNED _BYTE '                           number of combatant units
DIM SHARED collision AS _BYTE '                                 collision check variable
DIM SHARED Thrust(x) AS Maneuver '                              Applied acceleration
DIM SHARED Gwat(x) AS Maneuver '                                Acceleration vector of gravitational influences
DIM SHARED origin AS V3 '                                       vector origin for PyT calls, Vec_Adds, etc.


DIM SHARED Turncount AS INTEGER '                               number of turns of play
DIM SHARED etd AS INTEGER '                                     elapsed time days
DIM SHARED eth AS _BYTE '                                       elapsed time hours
DIM SHARED etm AS _BYTE '                                       elapsed time minutes
DIM SHARED ets AS _BYTE '                                       elapsed time seconds
DIM SHARED t1% '                                                auto-save timer handle
DIM SHARED chr_img(255) AS LONG '                               handle array for resizeable font
DIM SHARED ZoomFac AS SINGLE '                                  display zoom
DIM SHARED orbs AS INTEGER '                                    number of stars/planets/satellites
DIM SHARED oryr AS SINGLE '                                     # of years since 000-0000
DIM SHARED SenMax AS LONG '                                     Maximum target lock range
DIM SHARED SenLocC AS LONG '                                    Minimum civilian sensor target lock range
DIM SHARED SenLocM AS LONG '                                    Minimum military sensor target lock range
DIM SHARED RngCls AS LONG '                                     Close combat range
DIM SHARED RngMed AS LONG '                                     Meduim combat range
DIM SHARED A& '                                                 Main screen handle
DIM SHARED AW& '                                                Azimuth wheel overlay handle
DIM SHARED IW& '                                                Inclinometer wheel overlay handle
DIM SHARED SS& '                                                Sensor screen handle
DIM SHARED ZS& '                                                Z-pan screen handle
DIM SHARED ORI& '                                               Orientation screen handle
DIM SHARED Moon& '                                              landed image handle
REDIM SHARED ship_box(20) AS LONG '                             Ship data display box
DIM SHARED flight& '                                            Flightplan solution buttons
DIM SHARED evade& '                                             Evade solution buttons
DIM SHARED intercept& '                                         Intercept solution buttons
DIM SHARED fleet& '                                             Fleet slave button (proposed)
DIM SHARED break& '                                             Break formation button (proposed)
DIM SHARED XZ& '                                                Zoom extents button
DIM SHARED IZ& '                                                Zoom in button
DIM SHARED OZ& '                                                Zoom out button
DIM SHARED RG& '                                                Ranging button
DIM SHARED OB& '                                                Orbit track button
DIM SHARED GD& '                                                Grid button
DIM SHARED AZ& '                                                Azimuth wheel button
DIM SHARED IN& '                                                Inclinometer button
DIM SHARED JP& '                                                Jump envelope button
DIM SHARED DI& '                                                Jump Diameter button
DIM SHARED DN& '                                                Jump Density button
DIM SHARED QT& '                                                Quit button (program end)
DIM SHARED cancel& '                                            Cancel solution
DIM SHARED strfld AS LONG '                                     Gate_Keeper background
DIM SHARED ShpT AS LONG '                                       Thrusting ship image handle
DIM SHARED ShpO AS LONG '                                       Non-thrusting ship image handle
DIM SHARED TLoc AS LONG '                                       Target lock icon handle
DIM SHARED TLocn AS LONG '                                      Target lock not available handle
DIM SHARED TunLoc AS LONG '                                     Target unlock icon handle
DIM SHARED flag AS LONG '                                       Flag ship- has units slaved to it
DIM SHARED slave AS LONG '                                      fleet locked indicator
DIM SHARED trnon AS LONG '                                      Transponder on image handle
DIM SHARED trnoff AS LONG '                                     Transponder off image handle
DIM SHARED fa12& '                                              FONT HANDLES
DIM SHARED fa10&
DIM SHARED fa14&
DIM SHARED fa32&
DIM SHARED ft16&
DIM SHARED ft14&
DIM SHARED ft12&

DIM SHARED togs AS _UNSIGNED INTEGER '                          Display/Control toggles
'                                                               Undo toggle- prevents more than one turn undo       togs bit=0  ³ AND 1
'                                                               Z-pan toggle (hotkey 3)                             togs bit=1  ³ AND 2
'                                                               Azimuth wheel toggle (hotkey a)                     togs bit=2  ³ AND 4
'                                                               Grid toggle (hotkey g)                              togs bit=3  ³ AND 8
'                                                               Ranging circle toggle (hotkey r)                    togs bit=4  ³ AND 16
'                                                               Inclinometer toggle (hotkey i)                      togs bit=5  ³ AND 32
'                                                               Jump diameter toggle (hotkey j)                     togs bit=6  ³ AND 64
'                                                               Orbit track display toggle (hotkey o)               togs bit=7  ³ AND 128
'                                                               Gravity zone toggle (hotkey z)                      togs bit=8  ³ AND 256
'                                                               Jump diameters or density (hotkey d)                togs bit=9  ³ AND 512
'                                                               Belt/ring display toggle (hotkey b)                 togs bit=10 ³ AND 1024
'                                                               Block move mode (mouse only)                        togs bit=11 ³ AND 2048
'                                                               Collision check mode (mouse only)                   togs bit=12 ³ AND 4096
'                                                               3D mode=1 / 2D mode=0 (initial parameter only)      togs bit=13 ³ AND 8192
'                                                               Rank show TRUE/FALSE (hotkey #)                     togs bit=14 ³ AND 16384
'                                                               bit 15 for future expansions

'                                                               DEBUGGING VARIABLES (if any present for beta testing)


'                                                               INITIAL PARAMETERS
ttl = "CT Vector 0.43" '                                        Title bar string
origin.pX = 0: origin.pY = 0: origin.pZ = 0 '                   zero vector
ihat.pX = 1: ihat.pY = 0: ihat.pZ = 0 '                         x identity unit vector
jhat.pX = 0: jhat.pY = 1: jhat.pZ = 0 '                         y identity unit vector
khat.pX = 0: khat.pY = 0: khat.pZ = 1 '                         z identity unit vector
cmb(0).ap = origin '                                            No ships left active unit at origin (within rank 1 feature)
Turncount = 0 '                                                 game turn number- determines elapsed time in scenario
vpoint = 1 '                                                    active unit pointer
ZoomFac = 1 '                                                   Zoom factor
shipoff = 0 '                                                   ship list scrolling offset value

'the following will be re-initialized in SUB Gate_Keeper if default.ini is present
togs = &B0111010110001101 '                                     set toggle initial state &H758D, dec 30093
SenMax = 900000
SenLocC = 150000
SenLocM = 600000
RngCls = 250000
RngMed = 500000

'                                                               CONSTANTS
CONST KMtoAU = 150000000 '                                      kilometer to Astronomical unit conversion; actual = 149597900
'CONST KMtoPC = 30856780000000 '                                 kilometer to parsec conversion; or 3.085678D13
CONST Degree1 = INT(_D2R(1) * 100000) / 100000 '

REDIM SHARED Thrust(x) AS Maneuver '                            unit accelerations/vector
REDIM SHARED Sensor(x, x) AS _BYTE '                            Sensor ops- element order (active unit, passive unit)
'                                                               bit 0 = Sensor occlusion flag
'                                                               bit 1 = Target lock flag
'                                                               bit 2 = Contact indistinct/Extreme range flag
'                                                               bit 3 = Proximity alert
'                                                               bit 4 = Transponder x=x
'                                                               bit 5
'                                                               bit 6
'                                                               bit 7

RESTORE colors
FOR x = 0 TO 15 '                                               iterate colors 0 thru 15
    READ r% '                                                   get red component
    READ g% '                                                   get green component
    READ b% '                                                   get blue component
    clr&(x) = _RGB32(r%, g%, b%) '                              mix color x into array
NEXT x

'                                                               IMAGES _FONTS AND BUTTONS
FOR Ascii = 0 TO 255 '                                          PETR'S CHARACTER IMAGE LOADER
    chr_img(Ascii) = _NEWIMAGE(8, 16, 32) '                     create image for each ASCII character
    _DEST chr_img(Ascii) '                                      set image _DESTination of ASCII character
    _PRINTMODE _KEEPBACKGROUND '                                transparency for graphics overlays
    COLOR Whitesmoke
    _PRINTSTRING (0, 0), CHR$(Ascii), chr_img(Ascii) '          put ASCII character in image
NEXT Ascii '                                                    now any size ASCII character can be printed

A& = _NEWIMAGE(1250, 700, 32) '                                 Main display
SS& = _NEWIMAGE(620, 620, 32) '                                 Sensor screen display
AW& = _NEWIMAGE(620, 620, 32) '                                 Azimuth wheel overlay                created in Make_Images
IW& = _NEWIMAGE(620, 620, 32) '                                 Inclinometer wheel overlay              "     "   "     "
ZS& = _NEWIMAGE(40, 650, 32) '                                  Z-pan slider display
ORI& = _NEWIMAGE(254, 254, 32) '                                Orientation display
flight& = _NEWIMAGE(80, 16, 32) '                               Flight_Plan solution button------------------------------------------------
evade& = _NEWIMAGE(40, 16, 32) '                                Evade solution button                          |
intercept& = _NEWIMAGE(72, 16, 32) '                            Intercept solution button                      |
fleet& = _NEWIMAGE(40, 16, 32) '                                Fleet slaved button                            |
break& = _NEWIMAGE(40, 16, 32) '                                Break formation button                         |
cancel& = _NEWIMAGE(48, 16, 32) '                               Cancel solution button                         |
XZ& = _NEWIMAGE(64, 32, 32) '                                   Zoom extents button                            |
IZ& = _NEWIMAGE(64, 32, 32) '                                   Zoom In button                                 |
OZ& = _NEWIMAGE(64, 32, 32) '                                   Zoom Out button                      created in Make_Buttons
RG& = _NEWIMAGE(56, 32, 32) '                                   Ranging button                                 |
OB& = _NEWIMAGE(56, 32, 32) '                                   Orbit track button                             |
GD& = _NEWIMAGE(48, 32, 32) '                                   Grid button                                    |
AZ& = _NEWIMAGE(40, 32, 32) '                                   Azimuth button                                 |
IN& = _NEWIMAGE(40, 32, 32) '                                   Inclinometer button                            |
JP& = _NEWIMAGE(48, 32, 32) '                                   Jump envelope button                           |
DI& = _NEWIMAGE(48, 32, 32) '                                   Jump Diameter button                           |
DN& = _NEWIMAGE(48, 32, 32) '                                   Jump Density button                            |
QT& = _NEWIMAGE(48, 32, 32) '                                   Quit button (program end)--------------------------------------------------
IF _DIREXISTS("images") THEN
    strfld = _LOADIMAGE("images\starfield.jpg", 32) '           Gate_Keeper background image
    ShpT = _LOADIMAGE("images\thrust.png", 32) '                ship- thrusting
    ShpO = _LOADIMAGE("images\suleimano.png", 32) '             ship- no thrust
    TLoc = _LOADIMAGE("images\tlock.png", 32) '                 target lock icon
    TLocn = _LOADIMAGE("images\tlockn.png", 32) '               target lock n/a
    TunLoc = _LOADIMAGE("images\tunlock.png", 32) '             target unlock icon
    flag = _LOADIMAGE("images\flag.png", 32) '                  flag ship
    slave = _LOADIMAGE("images\slave.png", 32) '                fleet lock icon
    trnon = _LOADIMAGE("images\trnsp1.png", 32)
    trnoff = _LOADIMAGE("images\trnsp0.png", 32)
    Moon& = _LOADIMAGE("images\moon1.jpg", 32)
ELSE
    Bad_Install "images", -1
END IF

Make_Images '                                                   Create overlays
Make_Buttons '                                                  Create control buttons

IF _FILEEXISTS("C:/windows/fonts/arialbd.ttf") THEN
    fs$ = "arialbd.ttf"
ELSE
    fs$ = "images/arialbd.ttf"
END IF
fa12& = _LOADFONT(fs$, 12) '                                    ship & control fonts
fa10& = _LOADFONT(fs$, 10)
fa14& = _LOADFONT(fs$, 14)
fa32& = _LOADFONT(fs$, 32)

IF _FILEEXISTS("C:/windows/fonts/timesbd.ttf") THEN
    fp$ = "timesbd.ttf"
ELSE
    fp$ = "images/timesbd.ttf"
END IF
ft16& = _LOADFONT(fp$, 16) '                                    planetary fonts
ft14& = _LOADFONT(fp$, 14)
ft12& = _LOADFONT(fp$, 12)

SCREEN A& '                                                     Initiate main screen
DO: LOOP UNTIL _SCREENEXISTS
_TITLE ttl '                                                    "CT-vector 0.4 beta testing"
'_SCREENMOVE 5, 5
_SCREENMOVE _DESKTOPWIDTH - _WIDTH(A&), 5 '                     temporary console debug position

Gate_Keeper '                                                   Splash screen and setup

t1% = _FREETIMER '                                              Autosave timer
ON TIMER(t1%, 60) Save_Scenario 0 '                             save every minute
TIMER(t1%) ON

Main_Loop '                                                      Enter main program loop
Terminus '                                                      Johnny, clean your room and get out!
CLEAR
SYSTEM '                                                        End program and return to OS

'                                                               DATA SECTION
colors:
'                                                               colors 0-4
DATA 0,0,0,0,0,168,0,168,0,0,168,168,168,0,0
'                                                               colors 5-9
DATA 168,0,168,168,84,0,168,168,168,84,84,84,84,84,252
'                                                               colors 10-14
DATA 84,252,84,84,252,252,252,84,84,252,84,252,252,252,84
'                                                               color 15
DATA 252,252,252

ships: '                                                        Sample ships for demo and debugging
'name, MaxG,ap.pX,ap.pY,ap.pZ,Speed,Heading,Inclination,mil
DATA 4
'DATA "Lander",2,-500000,-500000,0,0,0,0,0
DATA "PC vessel",2,-500000,-500000,0,0,0,0,0
DATA "Cruiser",4,-650000,-530000,0,0,0,0,-1
DATA "Raider",2,-700000,230000,0,0,0,0,0
DATA "SDB-1978",6,-670000,231000,0,0,0,0,-1


'                                                               END DATA SECTION
'                                                               END MAIN MODULE
'**********************************************************************************
'                                                               BEGIN SUB/FUNCTION SECTION


'±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
SUB Add_Ship

    'called from: Main_Loop, MouseOps
    'Appends new ship to list- reconfigures sensor array
    Panel_Blank 420, 578, 64, 32
    Con_Blok 420, 578, 64, 32, "Adding", 0, &H508C5B4C
    _DISPLAY

    IF units > 0 THEN
        DIM ts(units, units) AS _BYTE '                         define a temp sensor holder
        FOR x = 1 TO units '                                    save state of Sensor & TLock
            FOR y = 1 TO units
                ts(x, y) = Sensor(x, y)
        NEXT y, x

        units = units + 1 '                                     increment ship counter
        REDIM Sensor(units, units)
        FOR x = 1 TO units - 1 '                                reload Sensor & TLock
            FOR y = 1 TO units - 1
                Sensor(x, y) = ts(x, y)
        NEXT y, x
    ELSE
        units = units + 1
        REDIM Sensor(units, units)
    END IF

    REDIM _PRESERVE cmb(units) AS ship
    REDIM _PRESERVE Thrust(units) AS Maneuver
    REDIM _PRESERVE Gwat(units) AS Maneuver
    REDIM _PRESERVE ship_box(units)
    ship_box(units) = _NEWIMAGE(290, 96, 32)
    cmb(units).id = cmb(units - 1).id + 1
    cmb(units).status = 1
    cmb(units).ap.pX = cmb(vpoint).ap.pX + 100000 '             start near active unit
    cmb(units).ap.pY = cmb(vpoint).ap.pY + 100000 '             edit call can change this
    cmb(units).ap.pZ = 0
    FOR x = 1 TO orbs '                                         check planets for interference
        IF PyT(3, cmb(units).ap, hvns(x).ps) > hvns(x).radi THEN _CONTINUE 'if outside planet then skip
        DO
            cmb(units).ap.pX = cmb(units).ap.pX + 100000 '      move ship until beyond planet radius
        LOOP UNTIL PyT(3, cmb(units).ap, hvns(x).ps) > hvns(x).radi
    NEXT x
    vpoint = units '                                            set as active
    Sensor(vpoint, vpoint) = _SETBIT(Sensor(vpoint, vpoint), 4) 'transponder on
    Edit_Ship -1

END SUB 'Add_Ship


'±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
SUB Auto_Move (tar AS INTEGER, sol AS INTEGER, mode AS INTEGER)

    'called from: Move_Turn
    ' Calculate and issue automated maneuvers to return to Move_Turn
    ' tar = target unit: tar is also carried in cmb(sol).bogey
    '       it may be another ship or a planet depending upon the mode.
    ' sol = solution unit: i.e. unit executing the nav order
    ' mode = type of maneuver order, carried in cmb(sol).bstat
    '        1=evade
    '        2=intercept
    '        3=planetfall/land
    '        4=orbit
    '        6=hold station
    '        7=safe jump point (nearest)
    'typical syntax: Auto_Move cmb(x).bogey, unit x, [0 - 4, 6]
    'using .bogey to hold planet/ship target index.

    'We cannot know the future, so we must use the present to predict it.
    DIM tarpos AS V3 '                                          target unit position
    DIM solpos AS V3 '                                          solution unit position
    DIM tarmov AS V3 '                                          last target movement vector
    DIM solmov AS V3 '                                          last solution movement vector
    DIM tarfut AS V3 '                                          projected future target position
    DIM solfut AS V3 '                                          projected future solution position
    DIM difmov AS V3 '                                          difference vector between sol & tar
    DIM clsmov AS V3 '                                          vector to command thrust orders
    DIM tmp AS V3 '                                             temporary vector container
    DIM uclsmov AS V3U '                                        closing unit vector
    DIM usolmov AS V3U '                                        sol's moving unit vector
    solpos = cmb(sol).ap

    'position & movement of target entity: planet or ship depending upon AI mode
    IF mode < 3 OR mode = 5 THEN
        tarpos = cmb(tar).ap
        tarmov = cmb(tar).ap: Vec_Add tarmov, cmb(tar).op, -1 'compute last target movement vector (target velocity)
        solmov = cmb(sol).ap: Vec_Add solmov, cmb(sol).op, -1 'compute last solution movement vector (solution velocity)
    ELSE
        tarpos = hvns(tar).ps 'is there a turnundo/redo bug affecting this???
        Get_Body_Vec tar, tarmov
        solmov = cmb(sol).ap: Vec_Add solmov, cmb(sol).op, -1 'compute last solution movement vector (solution velocity)
    END IF
    'now solpos, tarpos, solmov, tarmov are set for this call

    SELECT CASE mode '                                          what mode of automove are we executing?
        CASE IS = 1
            'ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
            '³ EVADE            ³ {sol} seeks to avoid target lock range with selected unit {tar} WORKING
            'ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
            tarfut = tarpos: Vec_Add tarfut, tarmov, 1 '        compute projected future target position
            solfut = solpos: Vec_Add solfut, solmov, 1 '        compute projected future solution position
            clsmov = tarfut: Vec_Add clsmov, solfut, -1 '       vector between future positions
            Vec_Mult clsmov, -1 '                               invert for escape vector
            Vec_2_Thrust sol, clsmov '                          initiate evading thrust
        CASE IS = 2
            'ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
            '³ INTERCEPT        ³ {sol} seek to close to target lock range with selected unit {tar} WORKING
            'ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
            IF NOT Sensor(sol, tar) AND 1 THEN '                if sensors are not occluded
                Vec_Add tarpos, solpos, -1: solpos = origin '   we'll set relative positions
                ds## = PyT(3, solpos, tarpos)
                T2c! = SQR(2000 * ds## / (cmb(sol).MaxG * 10)) / 1000 'turns to close range
                tarfut = tarmov: Vec_Mult tarfut, T2c!: Vec_Add tarfut, tarpos, 1 'tar position in T2c turns
                solfut = solmov: Vec_Mult solfut, T2c!: Vec_Add solfut, solpos, 1 'sol position in T2c turns
                clsmov = tarfut: Vec_Add clsmov, solfut, -1 '   clsmov accelerates toward tar's future position
                difmov = solmov: Vec_Add difmov, tarmov, -1 '   difmov is difference between velocity of sol and tar
                T2m! = SQR(2000 * PyT(3, origin, difmov) / (cmb(sol).MaxG * 10)) / 1000 'turns to match vector
                IF T2c! > T2m! THEN
                    Vec_Mult clsmov, 1 '                        accelerate toward clsmov
                ELSE
                    IF Vec_Dot(tarpos, clsmov) < 0 THEN
                        Vec_Mult clsmov, 1
                    ELSE
                        Vec_Mult clsmov, -1 '                   accelerate away from clsmov (decelerate)
                    END IF
                END IF
                Vec_Mult clsmov, (PyT(3, origin, clsmov) / (cmb(sol).MaxG * 5000)) 'throttle back when necessary
                IF cmb(sol).mil THEN tr&& = SenLocM ELSE tr&& = SenLocC
                IF PyT(3, cmb(sol).ap, cmb(tar).ap) < _SHR(tr&&, 1) THEN 'if we're within target range stay with the target
                    clsmov = tarmov: Vec_Add clsmov, solmov, -1 'match vector
                END IF
                Vec_2_Thrust sol, clsmov '                      enable maneuver order
            ELSE '                                              if sensors ARE occluded
                cmb(sol).bstat = 0: cmb(sol).bogey = 0 '        contact lost, cancel the order
                'ortho thrust to avoid a planet
                tmp = solmov: Vec_Mult tmp, -1
                'clsmov.pX = -tmp.pY
                'clsmov.pY = tmp.pX
                Vec_2_Thrust sol, clsmov
            END IF '                                            end: sensor occlusion test
        CASE IS = 3
            'ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
            '³ PLANETFALL       ³ {sol} conducts a landing operation on selected world {tar} WORKING
            'ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
            'DIM AS V3 Gcomp
            DIM AS V3U offrad
            Vec_Add tarpos, solpos, -1: solpos = origin '       we'll set relative positions
            ds## = PyT(3, solpos, tarpos) - hvns(tar).radi '    distance to planetary surface
            IF ds## < 0 THEN ds## = 1 '                         head off the error caused by suare root of negative number
            T2c! = SQR(2000 * ds## / (cmb(sol).MaxG * 10)) / 1000 'turns to close range
            tarfut = tarmov: Vec_Mult tarfut, T2c!: Vec_Add tarfut, tarpos, 1 'tar position in T2c! turns
            solfut = solmov: Vec_Mult solfut, T2c!: Vec_Add solfut, solpos, 1 'sol position in T2c! turns

            'offset the tarfut by radius magnitude toward solfut so we're not aiming for the center of the planet
            tmp = solfut: Vec_Add tmp, tarfut, -1
            Vec_2_UVec tmp, offrad: Vec_Mult_Unit tmp, offrad, hvns(tar).radi
            Vec_Add tarfut, tmp, 1

            clsmov = tarfut: Vec_Add clsmov, solfut, -1 '       clsmov accelerates toward tar's future position
            difmov = solmov: Vec_Add difmov, tarmov, -1 '       difmov is difference between velocity of sol and tar

            IF ds## < cmb(sol).MaxG * 5000 THEN ' less than full thrust potential and close enough for one turn landing then
                'we'll assume landing
                cmb(sol).status = 2: cmb(sol).bogey = tar '     set landed status and body
                cmb(sol).bstat = 0: Thrust(sol).Gs = 0 '        shut 'er down
            ELSE '                                              we'll continue with approach maneuvers
                Vec_Mult clsmov, (PyT(3, origin, clsmov) / (cmb(sol).MaxG * 5000)) 'throttle back when necessary

                IF PyT(3, cmb(sol).ap, hvns(tar).ps) < hvns(tar).radi * 1.3 THEN 'if we're within 20% of planet radius
                    clsmov = tarmov: Vec_Add clsmov, solmov, -1 'match vector
                END IF
                Vec_2_Thrust sol, clsmov '                      enable maneuver order
            END IF
        CASE IS = 4
            'ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
            '³ ORBIT            ³ {sol} maintains an orbit around selected world {tar}, works erratically
            'ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
            'What's coming in
            '   cmb(sol).bogey = Closest_Rank_Body(sol, 2)
            '   cmb(sol).bstat = 4  'obviously, or we wouldn't be in case #4
            '   cmb(vpoint).bdata = PyT(3, cmb(sol).ap, hvns(cmb(sol).bogey).ps) 'distance when orbit order issued
            '       so we have the body to orbit and the distance from it at the orders issuance
            '
            'What are we to make of this?
            '   are we in 2D mode? We can limit to the ecliptic
            '       direction to planet and direction of travel
            '   are we in 3D mode? We need an orbital plane unit normal from direction to planet and direction of travel
            '       direction of planet, direction of travel and plane of orbit
            DIM AS V3U dt, d2p, un, dwm
            tmp = tarpos: Vec_Add tmp, solpos, -1: Vec_2_UVec tmp, d2p 'direction vector to planet {d2p}
            Vec_2_UVec solmov, dt '                             direction vector of travel {dt}
            Vec_Cross_Unit un, dt, d2p '                        un defines insertion crossed with planet direction

            'from here we cross d2p X un result is direction we must go {dwm}
            'but it has to follow a circular path, not sure how to do that...jus dunno
            Vec_Cross_Unit dwm, d2p, un

            'now grow dwm by a proportion of gwat
            Vec_Mult_Unit tmp, dwm, 5

            ''first attempt
            'DIM d AS V3 '
            'DIM dv AS V3U '                                     direction vector cmb(sol) to bogey
            'd = solpos: Vec_Add d, tarpos, -1: Vec_2_UVec d, dv 'dv now has unit vector out to ship
            'ds&& = PyT(3, solpos, tarpos) '                     actual distance from planet
            'dmv&& = cmb(sol).bdata - ds&& '                     vector move to maintain orbit distance
            'Vec_Mult_Unit d, dv, dmv&&
            'Vec_2_Thrust sol, d

            ''second attempt
            ''DIM strt, nd, nrm AS V3
            'Get_Body_Vec tar, tarmov
            'solmov = cmb(sol).ap: Vec_Add solmov, cmb(sol).op, -1
            ''drct = Vec_Dot(tarmov, solmov) 'chicken or chase
            'IF togs AND 8192 THEN '2d mode
            '    '   ecliptic plane orbit defined already by khat
            'ELSE '3d mode
            '    '   calculate the orbital plane in nrm
            'END IF

        CASE IS = 5
            'ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
            '³ FLEET FORMATION  ³ {sol} follows thrust orders of a selected flagship {tar) WORKING
            'ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
            Thrust(sol).Azi = Thrust(tar).Azi '                 sol duplicates thrust orders of tar
            Thrust(sol).Inc = Thrust(tar).Inc
            'accelerate with tar, but only to unit's own drive limits
            Thrust(sol).Gs = Thrust(tar).Gs + ((Thrust(tar).Gs - cmb(sol).MaxG) * (Thrust(tar).Gs > cmb(sol).MaxG))
        CASE IS = 6
            'ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
            '³ STATION KEEPING  ³ {sol} maintains a position relative to a selected body {tar} WORKING
            'ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
            Vec_Add clsmov, tarmov, 1
            Vec_Add clsmov, solmov, -1
            IF PyT(3, cmb(sol).ap, hvns(cmb(sol).bogey).ps) <> cmb(sol).bdata THEN 'if station distance changes
                DIM adjust AS V3, adu AS V3U, df AS V3
                adjust = solpos: Vec_Add adjust, tarpos, -1
                Vec_2_UVec adjust, adu '                        adu is the unit vector direction
                ch&& = PyT(3, origin, adjust) - cmb(sol).bdata
                Vec_Mult_Unit df, adu, ch&&
                Vec_Add clsmov, df, -1
            END IF
            Vec_2_Thrust sol, clsmov
        CASE IS = 7
            'ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
            '³ SAFE JUMP POINT  ³ {sol} maneuvers to the nearest safe jump distance
            'ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
            'based on diameter/density
            DIM AS V3 s2t, s2p, lvt, lvp
            redoo:
            tr = hvns(tar).rank
            IF togs AND 512 THEN '                              density or diameter jump zone
                l! = hvns(tar).dens
                IF tr > 1 THEN lp! = hvns(Find_Parent(tar)).dens
            ELSE
                l! = 1: lp! = 1
            END IF
            _ECHO "P=" + STR$(tar) + " " + hvns(tar).nam
            IF tr > 1 THEN
                tp&& = PyT(3, hvns(Find_Parent(tar)).ps, solpos) '  tar parent to unit distance
                jp&& = hvns(Find_Parent(tar)).radi * 200 * lp! '     parent's jump shadow distance
            END IF
            t&& = PyT(3, tarpos, solpos) '                      tar to unit distance
            j&& = hvns(tar).radi * 200 * l! '                   tar's jump shadow distance

            'p2p&& = PyT(3, hvns(Find_Parent(tar)).ps, tarpos) ' tar to parent distance
            's2t = solpos: Vec_Add s2t, tarpos, -1 '                     vector to target
            's2p = solpos: Vec_Add s2p, hvns(Find_Parent(tar)).ps, -1 '  vector to parent
            s2t = tarpos: Vec_Add s2t, solpos, -1
            IF tr > 1 THEN s2p = hvns(Find_Parent(tar)).ps: Vec_Add s2p, solpos, -1

            IF t&& > j&& THEN '                                 if we're beyond target shadow
                IF tr > 1 THEN
                    IF tp&& > jp&& THEN '                       if we're beyond parent shadow
                        cmb(sol).bstat = 0: cmb(sol).bogey = 0: Thrust(sol).Gs = 0 'safe to jump
                        _ECHO "JUMP!"
                    ELSE
                        cmb(sol).bogey = Find_Parent(tar) '     switch to parent, if not already, for next turn
                        tar = cmb(sol).bogey
                        GOTO redoo
                    END IF
                ELSE
                    cmb(sol).bstat = 0: cmb(sol).bogey = 0: Thrust(sol).Gs = 0 'safe to jump
                    _ECHO "JUMP!"
                END IF
            ELSE
                'we need to leave the target and/or the parent
                IF hvns(tar).orad + j&& < jp&& THEN '           tar shadow is fully in parent shadow
                    'we leave the parent
                    cmb(sol).bogey = Find_Parent(tar)
                    Vec_2_UVec s2p, uclsmov '                   most direct course away from parent
                    Vec_Mult_Unit clsmov, uclsmov, cmb(sol).MaxG * 5000 'multiply uclsmov by full thrust
                ELSE
                    'check for partial overlap
                    IF hvns(tar).orad - j&& < jp&& THEN '       tar shadow overlaps parent shadow
                        'we plot a course that avoids both
                        IF tp&& > jp&& THEN '                   if we're beyond parent shadow, but in an overlapping tar shadow
                            'concentrate on tar
                            Vec_2_UVec s2t, uclsmov '           most direct course away from target
                            Vec_Mult_Unit clsmov, uclsmov, cmb(sol).MaxG * 5000 'multiply uclsmov by full thrust
                        ELSE
                            'we have to find nearest exit from both
                            Vec_2_UVec s2p, uclsmov '                   most direct course away from parent
                            Vec_Mult_Unit lvp, uclsmov, cmb(sol).MaxG * 5000
                            Vec_2_UVec s2t, uclsmov '           most direct course away from target
                            Vec_Mult_Unit lvt, uclsmov, cmb(sol).MaxG * 5000
                            clsmov = lvp: Vec_Add lvp, lvt, 1
                        END IF
                    ELSE '                                      tar shadow is beyond parent shadow
                        'we leave the target
                        Vec_2_UVec s2t, uclsmov '           most direct course away from target
                        Vec_Mult_Unit clsmov, uclsmov, cmb(sol).MaxG * 5000 'multiply uclsmov by full thrust
                    END IF
                END IF
            END IF

            Vec_Mult clsmov, -1 '                               invert for escape vector
            Vec_2_Thrust sol, clsmov '                          initiate evading thrust

    END SELECT

END SUB 'Auto_Move


'±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
FUNCTION Az_From_Parent (var AS INTEGER)

    'called from: various
    DIM t AS V3 '                                               target planet (x,y) position
    DIM c AS V3 '                                               target planet's parent body (x,y) position
    c = hvns(Find_Parent(var)).ps: t = hvns(var).ps '           position vectors and distance
    Az_From_Parent = Azimuth!(t.pX - c.pX, t.pY - c.pY) '       azimuth between body and parent

END FUNCTION 'Az_From_Parent


'±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
FUNCTION Azimuth! (x AS _INTEGER64, y AS _INTEGER64)

    'called from: various
    'Returns the azimuth bearing of a relative (x,y) offset
    'adjusts for modified screen coordinate system
    IF x < 0 AND y >= 0 THEN
        Azimuth! = 7.853981 - ABS(_ATAN2(y, x))
    ELSE
        Azimuth! = 1.570796 - _ATAN2(y, x)
    END IF

END FUNCTION 'Azimuth!


'±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
SUB Azimuth_Wheel

    'called from: New_Vector_Graph, Sensor_Screen
    'Draw Azimuth wheel display
    IF ABS(zangle) < 1.48353 THEN '                             if not too tilted to lose all detail
        jz = COS(zangle) '                                      trig Y axis squish factor
        j = 1000 * COS(cmb(vpoint).Hd) * jz
        jp = 950 * COS(cmb(vpoint).Hd + Degree1) * jz
        jm = 950 * COS(cmb(vpoint).Hd - Degree1) * jz
        i = 1000 * SIN(cmb(vpoint).Hd)
        im = 950 * SIN(cmb(vpoint).Hd - Degree1)
        ip = 950 * SIN(cmb(vpoint).Hd + Degree1)

        _PUTIMAGE (-1000, 1000 * jz)-(1000, -1000 * jz), AW& '  Draw azimuth wheel image with Y axis squish

        'Direction to Primary indicator- draw yellow primary azimuth indicator along azimuth wheel
        FCirc 990 * SIN(Azimuth!(-cmb(vpoint).ap.pX, -cmb(vpoint).ap.pY)), (990 * COS(Azimuth!(-cmb(vpoint).ap.pX, -cmb(vpoint).ap.pY))) * jz, 10, clr&(14)

        'Heading indicator
        LINE (im, jm)-(i, j), _RGBA32(168, 0, 168, 200) '       draw heading arrow anticlock tail to point
        LINE (i, j)-(ip, jp), _RGBA32(168, 0, 168, 200) '       draw heading arrow point to clock tail
        LINE (0, 0)-(i, j), _RGBA32(168, 0, 168, 40) '          heading leader line
    END IF

END SUB 'Azimuth_Wheel


'±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
SUB Bad_Install (var AS STRING, var2 AS _BYTE)

    'called from: various
    SCREEN A&
    CLS
    Dialog_Box "WARNING!", 400, 400, 25, Red, Red
    LOCATE 8, 56
    PRINT "The "; var; " directory could not be found."
    LOCATE 9, 56
    PRINT "Please check for proper installation"
    LOCATE 11, 56
    PRINT "Left click or press any key."
    _DISPLAY
    Press_Click
    IF var2 THEN '                                              if fatal error then end
        END
    END IF

END SUB 'Bad_Install


'±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
FUNCTION Bearing (unit AS INTEGER)

    'called from: Disp_Data
    'determine azimuth bearing on ecliptic plane of 'unit' from viewpoint
    'and check for possible collision/docking
    collision = (rcs(unit).pX = 0) * (rcs(unit).pY = 0) * (rcs(unit).pZ = 0)
    Bearing = Azimuth!(rcs(unit).pX, rcs(unit).pY)

END FUNCTION 'Bearing


'±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
SUB Bevel_Button (xsiz AS INTEGER, ysiz AS INTEGER, col AS _UNSIGNED LONG)

    'called from: Con_Blok, Make_Buttons
    'Create control button bevels for 3D effect - called from Con_Blok & Make_Buttons
    'Inspiration and basic algorithm by SierraKen
    brdr = ABS(INT(ysiz / 4) * (ysiz <= xsiz) + INT(xsiz / 4) * (ysiz > xsiz))
    FOR bb = 0 TO brdr
        c = c + 100 / brdr
        LINE (0 + bb, 0 + bb)-(xsiz - 1 - bb, ysiz - 1 - bb), _RGBA32(_RED32(col) - 100 + c, _GREEN32(col) - 100 + c, _BLUE32(col) - 100 + c, _ALPHA(col)), B
    NEXT bb

END SUB 'Bevel_Button


'±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
SUB Button_Block

    'called from: Refresh
    'MANEUVER AND PROGRAM CONTROLS under data blocks and orientation screen

    'First tier buttons: start at (0, 578) advance 70/
    Con_Blok 0, 578, 64, 32, "Vector", 1, &HFF2C9B2C
    IF cmb(vpoint).bstat = 5 OR cmb(vpoint).status = 3 THEN '   if active in fleet or disabled
        Panel_Blank 0, 578, 64, 32
    END IF
    'Con_Blok 70, 578, 64, 32, "n/a", 0, &HFF2C9B2C '           future button place keeper
    'Con_Blok 140, 578, 64, 32, "n/a", 0, &HFF2C9B2C '          future button place keeper
    Con_Blok 210, 578, 64, 32, "Turn", 1, &HFF2C9B2C
    Con_Blok 280, 578, 64, 32, "EditShp", 1, &HFFA6A188
    Con_Blok 350, 578, 64, 32, "Delete", 0, &HFFC80000
    Con_Blok 420, 578, 64, 32, "LoadAll", 0, &HFF2C9B2C
    Con_Blok 490, 578, 64, 32, "SaveAll", 1, &HFF8C5B4C

    'Second tier buttons: start at (0, 614) advance 70/
    Con_Blok 0, 614, 64, 32, "Gs= 0", 0, &HFF2C9B2C
    IF cmb(vpoint).bstat = 5 OR cmb(vpoint).status = 3 THEN '   if active in fleet or disabled
        Panel_Blank 0, 614, 64, 32
    END IF
    Con_Blok 70, 614, 64, 32, "Trnspndr", 0, &HFF2C9B2C
    IF NOT Sensor(vpoint, vpoint) AND 16 THEN
        Panel_Blank 70, 614, 64, 32
    END IF
    Con_Blok 140, 614, 64, 32, "Details", 0, &HFF2C9B2C
    IF togs AND 1 THEN c& = &HFF3F3F3F ELSE c& = &HFF2C9B2C '   if undo unavailable else available
    Con_Blok 210, 614, 64, 32, "Undo", 1, c&
    Con_Blok 280, 614, 64, 32, "AddShip", 0, &HFFA6A188
    Con_Blok 350, 614, 64, 32, "Purge", 0, &HFFC80000
    Con_Blok 420, 614, 64, 32, "LoadSys", 0, &HFF2C9B2C
    Con_Blok 490, 614, 64, 32, "SaveSys", 0, &HFF8C5B4C

    'Third tier buttons: start at (0, 650) advance 70/
    Con_Blok 0, 650, 64, 32, "Brake", 0, &HFF2C9B2C
    IF cmb(vpoint).bstat = 5 OR cmb(vpoint).status = 3 THEN '   if active in fleet or disabled
        Panel_Blank 0, 650, 64, 32
    END IF
    Con_Blok 70, 650, 64, 32, "Options", 0, &HFF2C9B2C
    Con_Blok 140, 650, 64, 32, "Col/Chk", 0, &HFF2C9B2C
    IF NOT togs AND 4096 THEN Panel_Blank 140, 650, 64, 32 '     if Col/Chk off
    Con_Blok 210, 650, 64, 32, "Help", 1, &HFF4CCB9C
    IF togs AND 2048 THEN c& = &HFFDFDFDF ELSE c& = &HFF3F3F3F 'if MovAll enabled else disabled
    Con_Blok 280, 650, 64, 32, "MovAll", 0, c&
    IF cmb(vpoint).status = 3 THEN s$ = "Repair" ELSE s$ = "Adrift"
    Con_Blok 350, 650, 64, 32, s$, 0, &HFFC80000
    Con_Blok 420, 650, 64, 32, "LoadShp", 0, &HFF2C9B2C
    Con_Blok 490, 650, 64, 32, "SaveShp", 0, &HFF8C5B4C

    '_DISPLAY CONTROL TOGGLES - permanent images under sensor screen
    _PUTIMAGE (560, 660), XZ&, A& '                             Zoom Extents
    _PUTIMAGE (626, 660), IZ&, A& '                             Zoom In
    _PUTIMAGE (692, 660), OZ&, A& '                             Zoom Out
    COLOR clr&(7)
    _PRINTSTRING (560, 641), "Zoom Factor: " + STR$(ZoomFac), A&
    _PUTIMAGE (762, 660), RG&, A& '                             Ranging Band toggle
    IF NOT togs AND 16 THEN Off_Button RG&, 762, 660
    _PUTIMAGE (820, 660), OB&, A& '                             Orbit track toggle
    IF NOT togs AND 128 THEN Off_Button OB&, 820, 660
    _PUTIMAGE (878, 660), GD&, A& '                             Grid toggle
    IF NOT togs AND 8 THEN Off_Button GD&, 878, 660
    _PUTIMAGE (928, 660), AZ&, A& '                             Azimuth Wheel toggle
    IF NOT togs AND 4 THEN Off_Button AZ&, 928, 660
    IF togs AND 8192 THEN '                                     if 3D mode then
        _PUTIMAGE (970, 660), IN&, A& '                         Inclinometer toggle
        IF NOT togs AND 32 THEN Off_Button IN&, 970, 660
    END IF
    _PUTIMAGE (1012, 660), JP&, A& '                            Jump Envelope toggle
    IF togs AND 64 THEN
        IF togs AND 512 THEN
            _PUTIMAGE (1062, 660), DI&, A& '                    Jump Diameter toggle
        ELSE
            _PUTIMAGE (1062, 660), DN&, A& '                    Jump Density toggle
        END IF
    ELSE
        Off_Button JP&, 1012, 660
    END IF
    _PUTIMAGE (1132, 660), QT&, A& '                            Quit (program) button
    IF togs AND 8192 THEN
        IF togs AND 2 THEN
            Con_Blok 1204, 660, 40, 32, "3D", 0, &HFFB5651D
        ELSE
            Con_Blok 1204, 660, 40, 32, "2D", 0, &HFFB5651D
        END IF
    END IF

END SUB 'Button_Block


'±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
SUB Cancel_AI (var AS _BYTE, var2 AS INTEGER)

    'called from: Col_Check, Delete_Ship
    FOR sp = 1 TO units '                   cancel all orders targeting the destroyed unit
        IF sp = var THEN _CONTINUE
        IF cmb(sp).bogey = var THEN
            SELECT CASE cmb(sp).bstat
                CASE 1, 2, 5
                    IF var2 <> 0 THEN '                         hold station pending further orders
                        cmb(sp).bstat = 6: cmb(sp).bogey = p
                        cmb(sp).bdata = PyT(3, cmb(sp).ap, hvns(p).ps)
                    ELSE
                        cmb(sp).bstat = 0: cmb(sp).bogey = 0
                    END IF
            END SELECT
        END IF
    NEXT sp

END SUB 'Cancel_AI


'±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
FUNCTION Choose_World% (header AS STRING, mode AS _BYTE)

    'Display world list, click on desired world and its index number is returned
    'called from: Flight_Plan
    tm% = INT((_HEIGHT(A&) - 95) / 16) '                        compute available planet slots
    IF tm% > orbs THEN tm% = orbs '                             limit to # of planets
    po% = 0 '                                                   initialize mousewheel offset to 0
    backimage& = _COPYIMAGE(0) '                                copy screen background
    DO
        _PUTIMAGE , backimage&, A& '                            display screen background
        Dialog_Box header, _WIDTH(A&) / 3, _HEIGHT(A&), 0, &HFF00FF00, &HFFFFFFFF
        ms = MBS
        hvr% = INT((_MOUSEY - 47) / 16) '                       index mouse x hover
        IF ms AND 1 THEN '                                      left mouse click
            IF hvr% > 0 AND hvr% <= tm% THEN '                  are we hovering in the available slots?
                IF mode THEN '                                  action/landing{-1} or information{0}
                    IF hvns(hvr% + po%).star <> 2 THEN '        ring/belts are regions not a destination
                        in = -1: bdy = hvr% + po% '             set loop exit & target body index
                    END IF
                ELSE
                    in = -1: bdy = hvr% + po%
                END IF '                                        end: mode test
            END IF
            Clear_MB 1
        END IF
        IF ms AND 512 THEN po% = po% + 1 + (po% = orbs - tm%) ' increment offset
        IF ms AND 1024 THEN po% = po% - 1 - (po% < 1) '         decrement offset
        FOR x = 1 TO tm%
            xpos% = _WIDTH(A&) / 2 - 80 + (32 * (hvns(x + po%).rank - 1)) 'indent satellites
            ypos% = 63 + ((x - 1) * 16) '                       assign slot
            IF x = hvr% THEN COLOR &HFFFF0000 ELSE COLOR &HFFFFFFFF 'red on mouseover
            _PRINTSTRING (xpos%, ypos%), hvns(x + po%).nam '    display planet name
        NEXT x
        _LIMIT 30
        _DISPLAY
    LOOP UNTIL in '                                             exit loop on valid input
    COLOR &HFFFFFFFF
    _FREEIMAGE backimage&
    Choose_World% = bdy

END FUNCTION 'Choose_World


'±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
SUB Clear_MB (var AS INTEGER)

    DO UNTIL NOT _MOUSEBUTTON(var)
        WHILE _MOUSEINPUT: WEND
    LOOP

END SUB 'Clear_MB


'±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
FUNCTION Closest_Rank_Body (var AS INTEGER, var2 AS INTEGER)

    'called from: various
    'Find closest body of rank var2 to unit var
    'Syntax: Closest_Rank_Body <unit index>, <rank, 0=all>
    FOR n = 1 TO orbs '                                         find all rank var2 non-belt bodies
        IF var2 = 0 THEN
            IF hvns(n).star <> 2 THEN p2 = p2 + 1 '             include all but belts/rings
        ELSE
            IF hvns(n).rank = var2 AND hvns(n).star <> 2 THEN p2 = p2 + 1 'include ony those of rank var2
        END IF
    NEXT n
    DIM tmp(p2) AS sort
    FOR x = 1 TO orbs '                                         pick out rank var2s and assign index and distance to tmp
        IF var2 = 0 THEN
            IF hvns(x).star = 2 THEN _CONTINUE
        ELSE
            IF hvns(x).rank <> var2 OR hvns(x).star = 2 THEN _CONTINUE
        END IF
        y = y + 1
        tmp(y).index = x
        tmp(y).value = PyT(3, rcs(var), rcp(x))
    NEXT x
    FOR s = 1 TO p2 '                                           sort by closest to farthest
        FOR T = 1 TO p2 - 1
            IF tmp(T).value > tmp(s).value THEN SWAP tmp(T), tmp(s)
    NEXT T, s
    Closest_Rank_Body = tmp(1).index '                          tmp(1).index now is the closest rank var2 body

END FUNCTION 'Closest_Rank_Body


'±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
SUB Col_Check (var AS INTEGER)

    'Called from: Move_Turn when 'togs' bit 12 set
    'Check for collision between unit 'var' and any planetary bodies
    IF cmb(var).status MOD 2 <> 0 THEN '                        unit not landed or destroyed
        DIM movp AS V3 '                                        movement vector of planet

        FOR p = 1 TO orbs
            IF hvns(p).star = 2 THEN _CONTINUE '                skip belts/rings
            dist&& = PyT(3, cmb(var).ap, hvns(p).ps) '          distance between unit 'var' and planet 'p'
            IF dist&& - hvns(p).radi > 300000000 THEN _CONTINUE 'skip distances beyond 2 AU from surface
            Get_Body_Vec p, movp '                              establish movement of planet
            prch&& = PyT(3, movp, origin) + hvns(p).radi '      movement radius + radius of planet (danger space)
            srch&& = PyT(3, cmb(var).op, cmb(var).ap) '         movement radius of unit
            IF dist&& <= prch&& + srch&& AND cmb(var).Ostat <> 2 THEN 'if those radii overlap then check for collision
                DIM f AS V3 '                                   end turn planet position
                f = movp: Vec_Add f, hvns(p).ps, 1 '            f has end of turn planet position
                c = 0
                DO '                                            iterate the seconds in the turn
                    c = c + 1
                    IF Intra_Turn_Vec_Map&&(c, cmb(var).op, cmb(var).ap, hvns(p).ps, f) <= hvns(p).radi THEN 'is ship within planet radius on second c?
                        cmb(var).status = 0 '                   unit has been destroyed
                        cmb(var).bogey = p '                    in collision with 'p'
                        cmb(var).Sp = 0 '                       set all vectors to zero
                        Thrust(var).Azi = 0
                        Thrust(var).Inc = 0
                        Thrust(var).Gs = 0
                        Sensor(var, var) = _RESETBIT(Sensor(var, var), 4) 'transponder silenced

                        Cancel_AI var, p '                      end all maneuver orders targeting var

                        IF var = vpoint THEN '                  if crashed unit is vpoint then choose another
                            ct% = 0
                            DO '                                find next available unit to be active
                                IF vpoint = units THEN vpoint = 1 ELSE vpoint = vpoint + 1
                                IF cmb(vpoint).status > 0 THEN EXIT DO
                                ct% = ct% + 1
                            LOOP UNTIL ct% = units
                            IF ct% = units THEN '               if all units destroyed center on primary
                                vpoint = 0
                            END IF
                        END IF
                        EXIT DO '                               var crashed on second c no need to check further
                    END IF '                                    end within radius check
                LOOP UNTIL c = 1000 '                           when 1000 seconds we're done checking for this turn
            END IF
        NEXT p
    END IF

END SUB 'Col_Check


'±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
SUB Col_Check_Ship (var AS INTEGER)

    'Check for proximity to other vessels
    FOR s = 1 TO units '                                        check for unit collisions
        IF s = var THEN _CONTINUE
        Sensor(var, s) = _RESETBIT(Sensor(var, s), 3) '         reset collision flag before checking
        dist&& = PyT(3, cmb(var).ap, cmb(s).ap)
        IF dist&& > 300000000 THEN _CONTINUE '                  skip distances beyond 2 AU from unit s
        IF dist&& <= PyT(3, cmb(s).op, cmb(s).ap) + PyT(3, cmb(var).op, cmb(var).ap) THEN 'if movement radii exceed distance
            c = 0
            DO
                c = c + 1
                IF Intra_Turn_Vec_Map&&(c, cmb(var).op, cmb(var).ap, cmb(s).op, cmb(s).ap) < 5 THEN
                    Sensor(var, s) = _SETBIT(Sensor(var, s), 3) 'Proximity alert, collision is possible
                END IF
            LOOP UNTIL c = 1000
        END IF
    NEXT s

END SUB 'Col_Check_Ship


'±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
SUB Coming

    _PRINTSTRING (300, 560), "Coming soon...maybe", A&
    _DISPLAY
    SLEEP 2

END SUB 'Coming


'±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
SUB Comments

    'FAIR USE STATEMENT:
    'The Traveller game in all forms is owned by Far Future Enterprises.
    'Copyright 1977 - 2008 Far Future Enterprises. Traveller is a registered
    'trademark of Far Future Enterprises. Far Future permits web sites and
    'fanzines for this game, provided it contains this notice, that Far Future
    'is notified, and subject to a withdrawal of permission on 90 days notice.
    'The contents of this site are for personal, non-commercial use only.
    'Any use of Far Future Enterprises's copyrighted material or trademarks
    'anywhere on this web site and its files should not be viewed as a challenge
    'to those copyrights or trademarks. In addition, any program/articles/file
    'on this site cannot be republished or distributed without the consent of
    'the author who contributed it.


    'VERSION COMMENTS
    'Basic algorithm for rewrite of STARRUTR.BAS
    'starship vector movement handler for Classic Traveller RPG
    '
    '
    'HISTORIC COMMENTS
    '              STARRUTR.BAS (8.3 short for Star Ruttier)
    '   The ruttier being an archaic term for the charts and directions
    'that a sailing ships pilot would use to navigate, Star Ruttier is
    'a QBasic based program for tracking 3 dimensional space craft
    'maneuvers in an interplanetary setting.
    '   Conceived as a ship to ship combat game aid for the Traveller
    'Role Playing system, Star Ruttier displays graphic position and numeric
    'data for vector maneuvers in a turn based 3D cartesian (X,Y,Z) system.
    'It's primary purpose is to remove the scaling and time constraints of
    'plotting vectors on paper.
    '   On the left each ship unit is displayed with Unit index, Name, Azimuth
    'Heading, Inclination, and Speed with one ship highlighted as the active
    'unit.  All inactive units are additionally displayed with Azimuth Bearing,
    'Inclination, and Distance from the active unit. On the right of the screen
    'a graphics window is displayed showing the relative positions of each
    'indexed unit.  The active unit is displayed in the center of the graphics
    'window, with the other units positioned relative to the active unit. The
    'active unit can be chosen by using the up and down arrows.
    '   The display is dynamically resized to include all units displayed
    'regardless of distance from the active unit. The display is viewed from
    'the Galactic zenith with the top edge being Coreward. Other viewpoints
    'may be offered in subsequent versions. In this release units above or
    'below the active unit are displayed Blue shift and Red shift
    'respectively.
    '   The 'chose' menu in the lower left corner displays the menu options
    'which can be accessed by typing the highlighted letter of each choice.
    'Type 'V' for vector to input new thrust, Azimuth, and Inclination
    'headings for the active unit. If no new values are entered the active
    'unit will default to the last entered values. The unit will continue
    'to thrust until the power is cut by entering zero values for thrust,
    'though the unit will continue to coast at the current vector.
    '   Type 'T' for turn after all desired vectors have been entered and
    'the new vectors will be applied for the current turn. All unit positions
    'will be updated and displayed and new vectors can be entered.
    '   Type 'Q' to quit program

    'CT Vector.bas comments

    'HOT KEYS       accessible in main loop
    '[up arrow]     increments active unit pointer
    '[down arrow]   decrements active unit pointer
    '[Delete]       delete the active unit
    '[Insert]       Add new unit and make active
    ' "+"           zoom in
    ' "-"           zoom out
    ' "X"           zoom extents (default zoom factor 1)
    ' "A"           toggle azimuth wheel....................... [default=on]
    ' "B"           toggle planetoid belt/ring display......... [default=on]
    ' "G"           toggle grid................................ [default=on]
    ' "I"           toggle inclinometer........................ [default=off]
    ' "R"           toggle ranging bands....................... [default=off]
    ' "J"           toggle jump diameters...................... [default=off]
    ' "D"           toggle density based jump diameters........ [default=off]
    ' "O"           toggle orbit tracks........................ [default=on]
    ' "Z"           toggle gravity zones....................... [default=on]
    ' "3"           toggle 3D panning.......................... [default=off]
    ' "#"           toggle planet rank # display............... [default=on]
    ' "V"           enter new vector for active unit. Enter azimuth "c" to counter vector
    ' "S"           save scenario dialog box
    ' "T"           apply vectors to game turn
    ' "U"           undo previous turn
    ' "E"           edit active unit data
    ' "Q"           end program

    'MOUSE OPERATIONS
    'control        hover over
    '{no click}     Orientation:        display thrust, yaw & pitch
    'left button:   Astrogator:         choose active unit
    '               Ship Data Display:  choose active unit
    'right button:  Astrogator:         move active unit to click
    '               Ship Data Display:  show detailed information on chosen unit
    'middle button: Astrogator:         reset zoom to factor=1
    'mouse wheel:   Astrogator:         zoom in/out

    'CT Vector has updated displays to 32 bit images. Mouse support has been added.
    'Navigation aids of azimuth wheel, inclinometer, scale grid as well as jump
    'diameter and combat range bands have been added. All may be toggled on and off
    'as needed. Planetary bodies will now occlude sensors of active ship.
    'Right mouse click will reposition active unit, in x,y, to anywhere on the visible
    'sensor screen limits. Z-pan slider rotates view 180 deg. around X axis. Systems,
    'ships and scenarios may be saved and recalled. Ships may be moved in groups and
    'arranged into fleets/squadrons. Fonts added to controls screen ship labels.
    'Fast mouse wheel zooming added to ver. 0.4 Added transponders, cleaned up
    'file mess for scenario saves and rewrote ship data display for ver. 0.43.
    'Improved automatic moves of landing and interception

    'The program will zoom out to distances of many parsecs, but has difficulty
    'zooming in tightly under several circumstances. Turn off belt/ring displays,
    'orbit tracks, and/or use Z-panning sparingly to improve speed.

    'FILE STRUCTURE: these must be present for proper function, autosave functions will
    'create ..\scenarios\autosave as necessary automatically
    'user responsible for keeping track of additional subdirectories.
    '
    'FILE TYPES
    'System files:   <file_name>.tss
    'Ship files:     <file_name>.tvg
    'Scenario files: <file_name>.tfs
    '
    '<root>\applications
    '      ÃÄ images\various
    '      ÃÄ scenarios\*.tfs
    '      ³           ÀÄ autosave\auto.tfs
    '      ÃÄ ships\*.tvg
    '      ÀÄ systems\*.tss

    'ALGORITHMIC STRUCTURE
    'Initial entry occurs at SUB Gate_Keeper and SUB Set_Up
    'Execution is then passed to SUB Main_Loop, from which all subsequent
    'calls are routed. Main_Loop consists of two nested do loops, the inner
    'loop handling collection of input commands, animation of the orientation
    'screen and ship data display. The outer loop resets the input flag, and
    'loops to update all displays. Mouse input is conditioned by Steve McNeill's
    'FUNCTION MBS%. Mr. McNeill's SUB fcirc also gets the credit for the rendering of
    'planetary orbs in the sensor display. Three coordinate systems are defined.
    'Absolute coordinates are referenced from the primary system star. Relative
    'coordinates are referenced relative to the active unit. Finally, Display
    'coordinates are 2D projections relative to the active unit and any rotations of
    'the display.

    'DISPLAY SCHEME for ship_box(x) {290,96} w/ red bounding box
    '  0           <0------36 columns------289>
    '  Â    line 1 (0,0)  ID (31,0)Name/no signal (119,0)PROX # (241,0)trans icon  (273,0)flag icon
    '  ³    line 2 (0,16) X:######### Y:######## Z:########
    '  ³    line 3 (0,32) Spd:#####.##kps (128,32)Hdg:###.## (216,32)Z:##.##
    '  ³    line 4 (0,48) Brng: (40,48)###.# (88,48)Z:-##.## (160,48)Dist:
    '  ³    line 5 (0,64) [EVADE] (49,64)[INTERCEPT] (130,64)[FLEET/BREAK] (234,64)flag#  (252,64)slave icon  (273,64)tlock icons
    '  Á    line 6 (0,80) targeting/targeted by/destroyed messages
    ' 95

    'TRAVEL FORMULAE (from Traveller Book)
    'Time[s] = 2 * ((Distance[m] / Acceleration[m/s^2])^.5)
    'Distance[m] = Acceleration[m/s^2] * Time[s]^2 / 4
    'Acceleration[m/s^2] = 4 * Distance[m] / Time[s]^2


    'GRAVITY FORMULAE (from Traveller Book)
    'Radius[100km] = 8 * Diameter[UPP]
    'Mass[earth mass] = K[earth densities] * (diameter[UPP] / 8)^3
    'Gs = K[earth densities] * (Diameter[UPP] / 8)
    'L = 64 * (Mass / G)^.5

    'OTHER USEFUL THINGS
    'from http://braeunig.us/space/vectors.htm
    'longitude=l=azimuth, latitude=b=inclination, and radial distance, r.
    'x = r cos b cos l   it must be noted that x & y are transposed with respect to
    'y = r cos b sin l   this application.
    'z = r sin b
    'Given XYZ coordinates, longitude and latitude are derived as follows:
    '    l = arctan[ y / x ]
    '    b = _ATAN2(z, (x ^ 2 + y ^ 2) ^ .5)  = asin[ z / r ]
    'where r is simply the vector magnitude. It is important that special care be taken to place l in the correct quadrant.

    'Proj a onto b: Vec_Mult b, Vec_Dot(a, b) / PyT( 3, origin, b) ^ 2
    'Proj b onto a: Vec_Mult a, Vec_Dot(a, b) / PyT( 3, origin, a) ^ 2

    'color legend- for clr&(x) assignments
    '0=black,1=blue,2=green,3=aqua,4=red,5=purple,6=brown,7=white
    '8=gray, +8=bright color, except 14=yellow,

    'Mean Density of Earth = 5.514

    'LINKS
    'http://www.batesville.k12.in.us/Physics/PhyNet/Mechanics/Gravity/lab/excel_orbits.htm

    'USEFUL ALGORITHMS that are faster implemented outside of FUNCTION
    'find the x coordinate of a magnitude and azimuth: x = magnitude * SIN(Azimuth)
    'find the y coordinate of a magnitude and azimuth: y = magnitude * COS(Azimuth)

    'Deceleration = v^2 - u^2 / 2s
    'Where,
    'v = The Final Velocity
    'u = The Initial Velocity
    's = Distance

    'pmap

    'BUG LIST
    'Somebody please shoot me...

END SUB 'Comments


'±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
SUB Con_Blok (xpos AS INTEGER, ypos AS INTEGER, xsiz AS INTEGER, ysiz AS INTEGER, label AS STRING, high AS INTEGER, col AS _UNSIGNED LONG)

    'called from: Button_Block, et. al.
    'Create control block
    CN& = _NEWIMAGE(xsiz, ysiz, 32)
    _DEST CN&
    COLOR , col
    CLS
    Bevel_Button xsiz, ysiz, col
    _PRINTMODE _KEEPBACKGROUND
    x = LEN(label)
    IF fa12& > 0 THEN '                                            if font is available
        sx = _SHR(xsiz, 1) - _SHR(_PRINTWIDTH(_TRIM$(label)), 1)
        sy = _SHR(ysiz, 1) - _SHR(_FONTHEIGHT(fa12&), 1)
        _FONT fa12&
    ELSE '                                                      if not
        sx = _SHR(xsiz, 1) - _SHL(x, 2): sy = _SHR(ysiz, 1) - 8
    END IF
    FOR p = 1 TO x '                                            iterate through label characters
        IF p = high THEN COLOR clr&(4) ELSE COLOR clr&(0) '     print hotkey highlight color (red) else (black)
        IF col = &HFFC80000 THEN COLOR clr&(15)
        'IF _RED32(col) > 127 THEN COLOR clr&(15)
        _PRINTSTRING (sx, sy), MID$(label, p, 1) '             still worth tweaking IMO
        sx = sx + _PRINTWIDTH(MID$(label, p, 1))
    NEXT p
    _FONT 16
    _PUTIMAGE (xpos, ypos), CN&, A&
    _FREEIMAGE CN&

END SUB 'Con_Blok


'±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
SUB Coord_Update (var AS INTEGER)

    'called from: Move_Turn if var1 not landed, landed units treated as radius satellites
    'updates cmb(var).ap
    DIM AS V3 CoastD, ThrstD, TotalD
    Polar_2_Vec CoastD, cmb(var).Sp, cmb(var).In, cmb(var).Hd 'Determine coasting deltaXYZ; initial speed

    dist = Thrust(var).Gs * 5000 '                              Determine thrusting delta XYZ for Move_Turn
    Polar_2_Vec ThrstD, dist, Thrust(var).Inc, Thrust(var).Azi 'Determine thrusting delta XYZ for Move_Turn

    TotalD = CoastD: Vec_Add TotalD, ThrstD, 1 '                Sum Cumulative Coordinates

    'Update unit coordinates
    cmb(var).op = cmb(var).ap '                                 move present to old
    Vec_Add cmb(var).ap, TotalD, 1 '                            update present
    Grav_Well var, -1 '                                         apply gravity influences

END SUB 'Coord_Update


'±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
SUB Delete_Ship '

    'called from: Main_Loop, Mouse_Button_Left
    IF units > 0 THEN
        Dialog_Box "You're about to delete " + RTRIM$(cmb(vpoint).Nam) + ". continue?", 400, 200, 100, clr&(4), clr&(15)
        Con_Blok 450, 225, 120, 32, "Yes [enter]", 0, clr&(4)
        Con_Blok 630, 225, 120, 32, "No [Esc]", 0, clr&(4)
        _DISPLAY
        Cancel_AI vpoint, 0

        DO
            x$ = UCASE$(INKEY$)
            ms = MBS
            IF ms AND 1 THEN
                SELECT CASE _MOUSEY
                    CASE 225 TO 257
                        SELECT CASE _MOUSEX
                            CASE 450 TO 570 '                   delete with mouseclick on "Yes"
                                dl% = -1
                            CASE 630 TO 750 '                   abort delete with mouseclick on "No"
                                EXIT SUB
                        END SELECT
                END SELECT
                Clear_MB 1
            END IF
            IF x$ = CHR$(13) THEN dl% = -1 '                    delete with ENTER
            IF x$ = CHR$(27) THEN EXIT SUB '                    abort delete with ESC keypress
            _LIMIT 30
        LOOP UNTIL dl%
        n% = units - 1 '                                        dim sufficient temp variables
        DIM tmpshp(n%) AS ship
        DIM tmpthrs(n%) AS Maneuver
        DIM tmpsens(n%, n%) AS _BYTE
        y% = 0
        FOR x = 1 TO units '                                    move existing data to temp variables
            IF x = vpoint THEN _CONTINUE '                      active is being deleted, skip it
            y% = y% + 1
            tmpshp(y%) = cmb(x)
            tmpthrs(y%) = Thrust(x)
            z% = 0
            FOR q = 1 TO units '                                preserve sensor matrix
                IF q = vpoint THEN _CONTINUE '                  active is being deleted, skip it
                z% = z% + 1
                tmpsens(y%, z%) = Sensor(x, q)
        NEXT q, x
        units = n% '                                            decrement unit counter
        REDIM cmb(units) AS ship
        REDIM Thrust(units) AS Maneuver
        REDIM Gwat(units) AS Maneuver
        REDIM Sensor(units, units) AS _BYTE
        FOR x = 1 TO units '                                    Move temps back into primary variables
            cmb(x) = tmpshp(x)
            Thrust(x) = tmpthrs(x)
            FOR y = 1 TO units
                Sensor(x, y) = tmpsens(x, y)
        NEXT y, x
        _FREEIMAGE ship_box(units + 1) '                        free data box memory
        vpoint = vpoint + (vpoint > units) '                    decrement the active counter if over units
    ELSE
        'Dialog_Box "There are no further units to be deleted", 400, 200, 100, clr&(4), clr&(15)
        'SLEEP 4
    END IF

END SUB 'Delete_Ship


'±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
SUB Dialog_Box (heading AS STRING, xsiz AS INTEGER, ysiz AS INTEGER, ypos AS INTEGER, bcol AS _UNSIGNED LONG, tcol AS _UNSIGNED LONG)

    'called from: various
    'superimpose a screen centered input box for various input routines
    T& = _NEWIMAGE(xsiz, ysiz, 32) '                            define box
    _DEST T&
    COLOR tcol, &HFF282828 '                                    set text color with grey background
    CLS
    FOR x = 0 TO 5 '                                            draw bounding box 6 pixels thick
        IF x < 2 THEN
            LINE (0 + x, 0 + x)-(_WIDTH(T&) - 1 - x, _HEIGHT(T&) - 1 - x), clr&(0), B
        ELSE
            LINE (0 + x, 0 + x)-(_WIDTH(T&) - 1 - x, _HEIGHT(T&) - 1 - x), bcol, B
        END IF
    NEXT x
    l = _SHR(_WIDTH(T&), 1) - _SHL(LEN(heading), 2) '           set heading position
    _PRINTSTRING (l, 31), heading, T& '                         print heading two rows below top
    _PUTIMAGE (_SHR(_WIDTH(A&), 1) - _SHR(_WIDTH(T&), 1), ypos), T&, A& ' display box
    _DEST A&
    _FREEIMAGE T&

END SUB 'Dialog_Box


'±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
SUB Disp_Data

    'CREATE DATA DISPLAYS
    DIM vpt, dst, lan, far, ovr, flt, occ, stl AS _BYTE
    IF cmb(vpoint).mil THEN s&& = SenLocM / 2 ELSE s&& = SenLocC / 2 'moved outside of unit loop

    FOR x = 1 TO units

        vpt = (x = vpoint) '                                    Is x the active unit?
        dst = (cmb(x).status = 0) '                             Is x destroyed?
        lan = (cmb(x).status = 2) '                             Is x landed?
        far = (PyT(3, cmb(vpoint).ap, cmb(x).ap) > 1500000000) 'Is x greater than 10 AU distant?
        ovr = (Thrust(x).Gs > cmb(x).MaxG) '                    Is x overloading its drives?
        flt = (cmb(x).bstat = 5) '                              Is x slaved to a fleet maneuver?
        occ = _READBIT(Sensor(vpoint, x), 0) '                  Is x sensor occluded from the active unit?
        stl = ((NOT (Sensor(x, x) AND 16)) AND (PyT(3, cmb(vpoint).ap, cmb(x).ap) > s&&)) 'Is x running silent? {transponder OFF}
        IF Sensor(vpoint, x) AND 2 THEN stl = 0

        _DEST ship_box(x) '                                     Set ship box x
        IF fa14& > 0 THEN _FONT fa14&
        IF vpt THEN '                                           Clear with correct colors for x
            COLOR clr&(15), clr&(8)
        ELSE
            IF (Sensor(vpoint, x) AND 1) OR dst THEN '          Occluded or destroyed
                COLOR clr&(8), clr&(0)
            ELSE
                COLOR clr&(3), clr&(0)
            END IF
        END IF
        CLS

        'Create unit 'x' data display line by line----------------------------------------------- line 1  (x,0)
        PRINT cmb(x).id; " ";
        IF vpt THEN
            PRINT cmb(x).Nam;
        ELSE
            IF Sensor(x, x) AND 16 THEN PRINT cmb(x).Nam; ELSE PRINT "no signal"
        END IF
        IF Sensor(x, x) AND 16 THEN _PUTIMAGE (241, 0), trnon, ship_box(x) ELSE _PUTIMAGE (241, 0), trnoff, ship_box(x)
        FOR o = 1 TO units 'If any other units are slaved to unit x, display flagship icon
            IF o = x THEN _CONTINUE
            IF Sensor(x, o) AND 8 THEN '      Proximity with Sensor bit 3 test
                _PRINTSTRING (119, 0), "PROX " + _TRIM$(STR$(o))
            END IF
            IF cmb(o).bstat = 5 AND cmb(o).bogey = x THEN
                _PUTIMAGE (273, 0), flag, ship_box(x)
            END IF
        NEXT o
        '---------------------------------------------------------------------------------------- line 2  (x,16)
        IF (NOT far) AND (NOT stl) AND (NOT occ) THEN
            LOCATE 2, 1
            PRINT "X:";: Trunc_Coord cmb(x).ap.pX: PRINT " "; ' Absolute coordinate position
            PRINT "Y:";: Trunc_Coord cmb(x).ap.pY: PRINT " ";
            PRINT "Z:";: Trunc_Coord cmb(x).ap.pZ: PRINT
        END IF
        '---------------------------------------------------------------------------------------- line 3  (x,32)
        IF NOT stl THEN
            IF far THEN
                COLOR clr&(3), clr&(0)
                _PRINTSTRING (0, 32), "Extreme Range"
            ELSE
                IF occ THEN
                    _PRINTSTRING (0, 32), "Sensor Occluded"
                ELSE '                                              speed/heading/inclination
                    _PRINTSTRING (0, 32), "Spd:"
                    IF ovr THEN presclr& = _DEFAULTCOLOR: COLOR clr&(12)
                    'if speed exceeds 99,999kps then
                    '   print speed as #.###c
                    'else
                    '_PRINTSTRING (32, 32), _TRIM$(STR$(INT((cmb(x).Sp / 1000) * 100) / 100)) + "kps"
                    _PRINTSTRING (32, 32), Fix_Float$(cmb(x).Sp / 1000, 2) + "kps"
                    'end if
                    IF ovr THEN COLOR presclr&
                    _PRINTSTRING (128, 32), "Hdg: " + Fix_Float$(_R2D(cmb(x).Hd), 1)
                    _PRINTSTRING (216, 32), "Z:" + Fix_Float$(_R2D(cmb(x).In), 1)
                END IF
            END IF
        ELSE
            COLOR clr&(3), clr&(0)
            _PRINTSTRING (0, 32), "Contact Indistinct"
        END IF
        '---------------------------------------------------------------------------------------- line 4  (x,48)
        IF (NOT far) AND (NOT stl) AND (NOT vpt) AND (NOT occ) THEN
            'Bearing Z-angle Dist from active
            _PRINTSTRING (0, 48), "Brng:" '                     unit bearing
            br = Bearing(x)
            IF collision THEN presclr& = _DEFAULTCOLOR: COLOR clr&(12)
            _PRINTSTRING (40, 48), Fix_Float$(_R2D(br), 1)
            slp = _R2D(Slope!(cmb(x).ap, cmb(vpoint).ap)) 'Z-angle
            _PRINTSTRING (88, 48), "Z: " + Fix_Float$(slp, 2) ' + _TRIM$(STR$(slp))
            'Distance
            d## = PyT(3, cmb(vpoint).ap, cmb(x).ap)
            IF d## < 10000000 THEN
                d$ = "km: " + STR$(INT(d##))
            ELSE
                d$ = "AU: " + Fix_Float$(d## / KMtoAU, 3)
            END IF
            _PRINTSTRING (160, 48), d$
            IF collision THEN COLOR presclr&
            collision = NOT collision
        END IF
        '---------------------------------------------------------------------------------------- line 5  (x,64)
        IF vpt THEN
            IF flt THEN
                _PUTIMAGE (0, 64), break&, ship_box(x) '        Break instead of flight
                GOSUB fleet_icons
            ELSE
                _PUTIMAGE (0, 64), flight&, ship_box(x) '       Flightplan image
            END IF
        ELSE
            IF (NOT dst) AND (NOT far) AND (NOT stl) AND (NOT occ) THEN
                IF cmb(vpoint).status <> 2 THEN '               if vpoint not landed
                    IF x = cmb(vpoint).bogey AND cmb(vpoint).bstat < 3 THEN 'cancel image
                        _PUTIMAGE (0, 64), cancel&, ship_box(x)
                    ELSE '                                          Automove images
                        _PUTIMAGE (0, 64), evade&, ship_box(x)
                        _PUTIMAGE (49, 64), intercept&, ship_box(x)
                        IF flt THEN
                            _PUTIMAGE (130, 64), break&, ship_box(x) 'w/break
                            GOSUB fleet_icons
                        ELSE
                            IF NOT lan THEN
                                _PUTIMAGE (130, 64), fleet&, ship_box(x) 'w/fleet
                            END IF
                        END IF
                    END IF
                END IF '                                        end: landed skip
                IF cmb(vpoint).mil THEN b&& = SenLocM ELSE b&& = SenLocC 'target lock state
                IF Sensor(vpoint, x) AND 2 THEN
                    _PUTIMAGE (273, 64), TunLoc, ship_box(x) '  break target lock
                ELSE
                    IF PyT(3, cmb(vpoint).ap, cmb(x).ap) <= b&& THEN
                        _PUTIMAGE (273, 64), TLoc, ship_box(x) 'target possible
                    ELSE
                        _PUTIMAGE (273, 64), TLocn, ship_box(x) 'target impossible
                    END IF
                END IF '                                        end targeting test
            END IF '                                            end obscuration tests
        END IF '                                                end vpoint test
        '---------------------------------------------------------------------------------------- line 6  (x,80)
        IF (NOT far) AND (NOT occ) THEN
            SELECT CASE cmb(x).status
                CASE IS = 0
                    _PRINTSTRING (0, 80), "destroyed: crashed on " + hvns(cmb(x).bogey).nam, ship_box(x)
                CASE IS = 1 '                                   in flight targeting/targeted by
                    IF vpt THEN
                        tl = 0: c = 0 '                         "targeted by x... "
                        COLOR clr&(12)
                        FOR o = 1 TO units
                            IF NOT Sensor(o, vpoint) AND 2 THEN _CONTINUE
                            IF tl THEN
                                c = c + LEN(_TRIM$(STR$(cmb(o).id))) + 16
                                tb$ = _TRIM$(STR$(cmb(o).id)) + ", "
                                _PRINTSTRING (104 + c, 80), tb$, ship_box(x)
                            ELSE
                                _PRINTSTRING (3, 80), "Targeted by:", ship_box(x)
                                tl = -1
                                c = c + LEN(_TRIM$(STR$(cmb(o).id)))
                                tb$ = _TRIM$(STR$(cmb(o).id)) + ", "
                                _PRINTSTRING (104 + c, 80), tb$, ship_box(x)
                            END IF
                        NEXT o
                    ELSE
                        IF Sensor(x, vpoint) AND 2 THEN '       Is x targeting active?
                            COLOR clr&(12)
                            _PRINTSTRING (0, 80), "Targeting active", ship_box(x)
                        END IF
                        IF Sensor(vpoint, x) AND 2 THEN ' check for target lock
                            COLOR clr&(12)
                            _PRINTSTRING (0, 80), ">>Target Locked<<", ship_box(x)
                        END IF
                    END IF
                CASE IS = 2
                    _PRINTSTRING (0, 80), "landed on " + hvns(cmb(x).bogey).nam, ship_box(x)
            END SELECT
        END IF
        LINE (0, 0)-(289, 95), clr&(4), B '                     bounding box & we're done
        _FONT 16

    NEXT x

    'PLACE SHIP_BOX DATA DISPLAY IMAGES:                        6 display slots available
    lim% = 6 - ((units - 6) * (units < 7)) '                    limit to 6 or 'units' whichever is lower
    shipoff = -shipoff * (units > 6) '                          shipoff (if any) applied only if more than 6 units else 0
    FOR y = 1 TO lim%
        _PUTIMAGE (0, 96 * (y - 1)), ship_box(y + shipoff), A& ' display ship info- adding any offset if more than 6 units
    NEXT y
    _DEST A&
    COLOR clr&(15)
    EXIT SUB

    fleet_icons: '                                              Fleet icon gosub for both active & inactive units
    _PRINTSTRING (234, 64), STR$(cmb(x).bogey)
    _PUTIMAGE (252, 64), slave, ship_box(x)
    RETURN

END SUB 'Disp_Data


'±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
SUB Draw_Ring_Belt (cntr AS V3, rng AS _INTEGER64, in AS _INTEGER64, rat AS SINGLE)

    DIM cen AS V3
    cen.pX = cntr.pX * rat
    rin% = in * rat
    stp& = 5 / rat
    aster& = &H2F7F7FFF '                                       belt/ring color  previous &H087F7F7F too thin for pb stepping
    IF togs AND 2 THEN
        cen.pY = (cntr.pY * (COS(zangle)) + (cntr.pZ * SIN(zangle))) * rat
        asp! = COS(zangle)
        FOR pb = 0 TO rng STEP stp&
            CIRCLE (cen.pX, cen.pY), rin% + (pb * rat), aster&, , , asp!
        NEXT pb
    ELSE
        cen.pY = cntr.pY * rat
        FOR pb = 0 TO rng STEP stp&
            frm = Frame_Sect%(cntr, (in + pb), rat) '       are we in the frame?
            IF frm > 0 THEN '                                   if yes then
                IF PyT(2, origin, cntr) > (1415 / rat) * 25 THEN 'if orad is 25 x visual screen then draw line
                    DIM drct AS V3 '                            direction vector
                    DIM PT AS V3 '                              Point Tangent
                    Vec_Cross drct, cntr, khat '                 get orthogonal of vertical and orbit track radius
                    d2a## = PyT(2, cntr, origin) '              distance from orbit track center to active unit
                    PT = cntr: Vec_Mult PT, -1 * ((in + pb) / d2a##): Vec_Add PT, cntr, 1 'find tangent point on orbit track
                    Vec_Mult PT, rat
                    Vec_Mult drct, rat
                    LINE (PT.pX, PT.pY)-(PT.pX + drct.pX, PT.pY + drct.pY), aster&
                    LINE (PT.pX, PT.pY)-(PT.pX + drct.pX * -1, PT.pY + drct.pY * -1), aster&
                ELSE
                    CIRCLE (cen.pX, cen.pY), (in + pb) * rat, aster&
                END IF
            END IF
        NEXT pb
    END IF

END SUB 'Draw_Ring_Belt


'±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
SUB Edit_Ship (var AS _BYTE)

    'called from: Main_Loop, Mouse_Button_Left, Add_Ship
    IF var THEN
        u$ = "Editing new vessel"
    ELSE
        Panel_Blank 280, 578, 64, 32
        Con_Blok 280, 578, 64, 32, "Editing", 1, &H508C5B4C
        u$ = "Editing " + _TRIM$(cmb(vpoint).Nam)
    END IF

    t% = 400: r% = 5
    Dialog_Box u$, t%, 250, 100, &HFF8C5B4C, clr&(15)
    in1$ = "Enter new value or press ENTER to default"
    l = _SHR(_WIDTH(A&), 1) - _SHL(LEN(in1$), 2) '                 l = _WIDTH(A&) / 2 - (LEN(in1$) * 8) / 2
    _PRINTSTRING (l, 320), in1$, A&
    _DISPLAY
    col% = _SHR((_SHR(_WIDTH(A&), 1) - _SHR(t%, 1)), 3) + 4
    IF var = 0 THEN
        LOCATE 6 + r%, col%
        INPUT "new name:"; n$
        IF n$ <> "" THEN cmb(vpoint).Nam = n$
        LOCATE 7 + r%, col%
        INPUT "Max Gs:"; mg$
        IF mg$ <> "" THEN cmb(vpoint).MaxG = VAL(mg$)
        LOCATE 8 + r%, col%
        INPUT "X pos:"; xp$
        IF xp$ <> "" THEN cmb(vpoint).ap.pX = VAL(xp$)
        LOCATE 9 + r%, col%
        INPUT "Y pos:"; yp$
        IF yp$ <> "" THEN cmb(vpoint).ap.pY = VAL(yp$)
        IF togs AND 8192 THEN '                                 2D mode exclusion here
            LOCATE 10 + r%, col%
            INPUT "Z pos:"; zp$
            IF zp$ <> "" THEN cmb(vpoint).ap.pZ = VAL(zp$)
        ELSE
            LOCATE 10 + r%, col%
            PRINT "Z pos: 0": cmb(vpoint).ap.pZ = 0
        END IF '                                                end 2D exclusion
        LOCATE 11 + r%, col%
        INPUT "Speed (kps):"; sp$
        IF sp$ <> "" THEN cmb(vpoint).Sp = VAL(sp$) * 1000
        LOCATE 12 + r%, col%
        INPUT "Heading:"; hd$
        IF hd$ <> "" THEN cmb(vpoint).Hd = _D2R(VAL(hd$))
        LOCATE 13 + r%, col%
        INPUT "Inclination:"; in$
        IF in$ <> "" THEN cmb(vpoint).In = _D2R(VAL(in$))
        DO
            b = 0
            LOCATE 14 + r%, col%
            PRINT "                                         "
            LOCATE 14 + r%, col%
            INPUT "Scout/military sensors? y/n ", mil$
            SELECT CASE UCASE$(mil$)
                CASE IS = "Y"
                    cmb(vpoint).mil = -1: b = -1
                CASE IS = "N"
                    cmb(vpoint).mil = 0: b = -1
                CASE IS = ""
                    b = -1
                CASE ELSE
            END SELECT
        LOOP UNTIL b
    ELSE
        LOCATE 7 + r%, col%
        INPUT "Max Gs:"; mg$
        IF mg$ <> "" THEN cmb(vpoint).MaxG = VAL(mg$)
    END IF

END SUB 'Edit_Ship


'±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
SUB FCirc (CX AS _INTEGER64, CY AS _INTEGER64, RR AS _INTEGER64, C AS _UNSIGNED LONG)

    'called from: various
    'Steve's circle draw
    DIM R AS _INTEGER64, RError AS _INTEGER64
    DIM X AS _INTEGER64, Y AS _INTEGER64
    R = ABS(RR) '                                               radius value along positive x
    RError = -R '                                               opposite side of circle? negative x
    X = R '                                                     point along positive x position
    Y = 0 '                                                     starting at the equator
    IF R = 0 THEN PSET (CX, CY), C: EXIT SUB '                  zero radius is point, not circle
    LINE (CX - X, CY)-(CX + X, CY), C, BF '                     draw equatorial line
    WHILE X > Y
        RError = RError + Y * 2 + 1
        IF RError >= 0 THEN
            IF X <> Y + 1 THEN
                LINE (CX - Y, CY - X)-(CX + Y, CY - X), C, BF ' draw line above equator
                LINE (CX - Y, CY + X)-(CX + Y, CY + X), C, BF ' draw line below equator
            END IF
            X = X - 1
            RError = RError - X * 2
        END IF
        Y = Y + 1
        LINE (CX - X, CY - Y)-(CX + X, CY - Y), C, BF '         draw line north latitudes
        LINE (CX - X, CY + Y)-(CX + X, CY + Y), C, BF '         draw line south latitudes
    WEND

END SUB 'FCirc


'±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
FUNCTION Find_Parent (var AS INTEGER)

    'called from: various
    'Accepts a planetary body index (var) and finds the parent body it orbits
    FOR x = 1 TO orbs
        IF hvns(var).parnt = hvns(x).nam THEN Find_Parent = x: EXIT FOR
    NEXT x

END FUNCTION 'Find_Parent


'±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
FUNCTION Fix_Float$ (x##, dec AS INTEGER)

    'called from Disp_Data
    bs$ = STR$(x##) '                                           string of input number x##
    ex = INSTR(bs$, "D") + INSTR(bs$, "E")
    IF ex <> 0 THEN '                                           an exponential has been thrown
        pwr = VAL(MID$(bs$, ex + 3))
        'use pwr to loop pwr-1 0's after a "." then use left$(bs,1)
        n$ = "0."
        FOR z = 1 TO pwr - 1
            n$ = n$ + "0"
        NEXT z
        Fix_Float$ = n$ + LEFT$(_TRIM$(bs$), 1)
    ELSE '                                                      a decimal number has been thrown
        pnt = INSTR(bs$, ".")
        IF pnt = 0 THEN Fix_Float$ = bs$
        Fix_Float$ = LEFT$(bs$, pnt + dec)
    END IF

END FUNCTION 'FixFloat##


'±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
SUB Flight_Plan

    'called from: Main_Loop, Mouse_Button_Left
    'Conduct an automated flight orders input - orders interpreted by Auto_Move
    Dialog_Box "Flight Plan", 400, 500, 25, _RGBA32(22, 166, 211, 255), &HFFFFFFFF
    IF cmb(vpoint).status = 2 THEN
        Con_Blok 545, 100, 160, 48, "Launch", 0, _RGBA32(22, 166, 211, 255)
        Con_Blok 545, 164, 160, 48, "Goto & Land", 0, _RGBA32(22, 166, 211, 255)
    ELSE
        Con_Blok 545, 100, 160, 48, "Jump in Matching", 0, _RGBA32(22, 166, 211, 255)
        Con_Blok 545, 164, 160, 48, "Goto & Land", 0, _RGBA32(22, 166, 211, 255)
        Con_Blok 545, 228, 160, 48, "Orbit", 0, _RGBA32(22, 166, 211, 255)
        Con_Blok 545, 292, 160, 48, "Hold station", 0, _RGBA32(22, 166, 211, 255)
        Con_Blok 545, 356, 160, 48, "Safe Jump", 0, _RGBA32(22, 166, 211, 255)
        Con_Blok 545, 420, 160, 48, "Abort [Esc]", 0, _RGBA32(22, 166, 211, 255)
    END IF
    _DISPLAY

    'Mouse and keyboard picking of Flight_Plan mode- setting choice%
    DO
        x$ = UCASE$(INKEY$)
        ms = MBS
        IF ms AND 1 THEN
            SELECT CASE _MOUSEX
                CASE 545 TO 705
                    SELECT CASE _MOUSEY
                        CASE 100 TO 148 '                       planet matching
                            choice% = 1: dl% = -1
                            Panel_Blank 545, 100, 160, 48
                        CASE 164 TO 212 '                       planet fall
                            choice% = 2: dl% = -1
                            Panel_Blank 545, 164, 160, 48
                        CASE 228 TO 276 '                       orbit
                            choice% = 3: dl% = -1
                            Panel_Blank 545, 228, 160, 48
                        CASE 292 TO 340 '                       station keeping
                            choice% = 4: dl% = -1
                            Panel_Blank 545, 292, 160, 48
                        CASE 356 TO 404 '                       nearest safe jump point
                            choice% = 5: dl% = -1
                            Panel_Blank 545, 356, 160, 48
                        CASE 420 TO 468 '                       abort
                            Panel_Blank 545, 420, 160, 48
                            EXIT DO
                    END SELECT
            END SELECT
            Clear_MB 1
        END IF
        IF x$ = CHR$(27) THEN EXIT SUB '                        abort delete with ESC keypress
        _LIMIT 30
    LOOP UNTIL dl%

    SELECT CASE choice%
        CASE IS = 1 'JUMP IN MATCHING/LAUNCH IF LANDED: first Flight_Plan algorithm is to match nearby planet vector
            IF cmb(vpoint).status = 2 THEN '                    launch if already landed on a body, manual launch
                New_Vector_Graph
            ELSE
                'A GM edit; not a maneuver
                DIM nw AS V3 '                                       target planet's cartesian turn displacement
                Get_Body_Vec Closest_Rank_Body(vpoint, 2), nw 'change 2 to 0 to see if combined vectors work
                cmb(vpoint).Hd = Azimuth(nw.pX, nw.pY)
                cmb(vpoint).Sp = PyT(2, nw, origin)
                cmb(vpoint).In = 0
            END IF
        CASE IS = 2 'PLANETFALL  bstat=3  bogey=target body
            IF cmb(vpoint).status = 2 THEN cmb(vpoint).status = 4 'launch if already landed on a body, direct to automatic
            cmb(vpoint).bstat = 3: cmb(vpoint).bogey = Choose_World%("Land On...", -1)
        CASE IS = 3 'ORBIT  bstat=4    bogey=target body
            IF cmb(vpoint).status = 2 THEN EXIT SELECT '        skip landed unit
            'Coming
            'EXIT SELECT
            'STILL TRYING TO FIGURE THIS ONE OUT
            'use gwat (AS maneuver) to configure acceleration.
            cmb(vpoint).bogey = Closest_Rank_Body(vpoint, 2)
            cmb(vpoint).bstat = 4
            'we should establish altitude (aka cmb(vpoint).bdata) here
            'after wards handing the computations to Auto_Move
            cmb(vpoint).bdata = PyT(3, cmb(vpoint).ap, hvns(cmb(vpoint).bogey).ps)
        CASE IS = 4 'STATION KEEPING bstat=6
            IF cmb(vpoint).status = 2 THEN EXIT SELECT '        skip landed unit
            cmb(vpoint).bstat = 6
            Refresh
            Dialog_Box "Nearest Station Keeping", 400, 200, 25, _RGBA32(22, 211, 166, 255), &HFFFFFFFF
            Con_Blok 480, 100, 70, 48, "System", 0, _RGBA32(22, 211, 166, 255)
            Con_Blok 580, 100, 70, 48, "Planet", 0, _RGBA32(22, 211, 166, 255)
            Con_Blok 680, 100, 70, 48, "Moon", 0, _RGBA32(22, 211, 166, 255)
            _DISPLAY
            dl% = 0
            DO
                x$ = UCASE$(INKEY$)
                ms1 = MBS
                IF ms1 AND 1 THEN
                    SELECT CASE _MOUSEY
                        CASE 100 TO 148
                            SELECT CASE _MOUSEX
                                CASE 480 TO 550 '               system stationary
                                    ch% = 1: dl% = -1
                                    Panel_Blank 480, 100, 70, 48
                                CASE 580 TO 650 '               planet stations
                                    ch% = 2: dl% = -1
                                    Panel_Blank 580, 100, 70, 48
                                CASE 680 TO 750 '               satellite stations
                                    ch% = 3: dl% = -1
                                    Panel_Blank 680, 100, 70, 48
                            END SELECT
                    END SELECT
                    Clear_MB 1
                END IF
                IF x$ = CHR$(27) THEN EXIT SUB '                abort delete with ESC keypress
                _LIMIT 30
            LOOP UNTIL dl%
            IF ch% = 1 THEN '                                   rank one is primary star aka system stationary
                cmb(vpoint).bogey = 1 '                         set target to primary star (or system barycenter)
            ELSE
                cmb(vpoint).bogey = Closest_Rank_Body(vpoint, ch%) 'choose the closest body, of rank ch%, to station by
            END IF
            cmb(vpoint).bdata = PyT(3, cmb(vpoint).ap, hvns(cmb(vpoint).bogey).ps) ' set the station distance
        CASE IS = 5 'PROCEED TO SAFE JUMP POINT bstat=7
            IF cmb(vpoint).status = 2 THEN EXIT SELECT
            cmb(vpoint).bstat = 7
            cmb(vpoint).bogey = Closest_Rank_Body(vpoint, 0)

            'x = Closest_Rank_Body(vpoint, 0)
            'FOR js = hvns(x).rank TO 1 STEP -1
            '    IF togs AND 512 THEN l! = hvns(x).dens ELSE l! = 1
            '
            'NEXT js
        CASE ELSE
            EXIT SUB
    END SELECT

END SUB 'Flight_Plan


'±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
FUNCTION Frame_Sect% (feature AS V3, radius AS _INTEGER64, ratio AS SINGLE)

    'called from: Draw_Ring_Belt, System_Map
    'Determine feature's relation to active's {origin} viewport using relative or display coordinates
    'Purpose: determine whether and/or how to draw feature
    'SYNTAX: Frame_Sect%(feature center V3, feature radius, result of Prop! call)
    Sact = 1415 / ratio '                                       Active unit's visibility radius: 1415=circumscribed display
    dist## = PyT(2, origin, feature) '                          distance between active unit and feature center point

    IF dist## > Sact + radius THEN Frame_Sect% = 0 '            feature's radius is beyond display - no draw if 0
    IF dist## < radius - Sact THEN Frame_Sect% = 1 '            feature's radius encompasses entire display - if fill then fill only screen
    IF dist## < Sact - radius THEN Frame_Sect% = 2 '            feature is encompassed by display - draw entire
    IF dist## < Sact + radius AND dist## > radius - Sact THEN Frame_Sect% = 3 ' feature intersects display - draw partial if possible

END FUNCTION 'Frame_Sect%


'±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
SUB Gate_Keeper

    'called from: Main Module
    IF _FILEEXISTS("default.ini") THEN
        OPEN "default.ini" FOR BINARY AS #1
        GET #1, , togs
        GET #1, , SenMax
        GET #1, , SenLocC
        GET #1, , SenLocM
        GET #1, , RngCls
        GET #1, , RngMed
        CLOSE #1
    END IF
    SCREEN A&
    _DEST A&
    COLOR , clr&(0)
    CLS
    _PUTIMAGE (0, 0), strfld, A&
    fa96& = _LOADFONT("arialbd.ttf", 96)
    IF fa96& > 0 THEN '                                           Print _TITLE
        _FONT fa96&
        COLOR &HFF5050A0
        _PRINTMODE _KEEPBACKGROUND
        _PRINTSTRING (_WIDTH(A&) / 2 - _PRINTWIDTH(ttl) / 2, 100), ttl
        _FONT 16
        _FREEFONT fa96&
        COLOR clr&(15)
    ELSE '                                                      use Prnt if font not available
        Prnt _TRIM$(ttl), 6, -6, 250, 100, 48, 0, &HFF5050A0
    END IF
    subtitle$ = "Classic Traveller starship maneuvers"
    IF fa32& > 0 THEN
        _FONT fa32&
        COLOR &HFF707060
        _PRINTMODE _KEEPBACKGROUND
        _PRINTSTRING (_WIDTH(A&) / 2 - _PRINTWIDTH(subtitle$) / 2, 200), subtitle$
        _FONT 16
        COLOR clr&(15)
    ELSE
        Prnt subtitle$, 2, -2, 320, 200, 16, 0, &HFF505040
    END IF
    COLOR clr&(7)
    splash1$ = "Ditch the paper, compasses and protractors! CT-Vector will handle the starship maneuvers, and even do it in 3D."
    _PRINTSTRING (_WIDTH(A&) / 2 - _PRINTWIDTH(splash1$) / 2, 250), splash1$, A&
    splash2$ = "If you know a star system/scenario name and path you may load it now, or press [enter] to default to Sol"
    _PRINTSTRING (_WIDTH(A&) / 2 - _PRINTWIDTH(splash2$) / 2, 270), splash2$, A&
    DO
        T& = _NEWIMAGE(950, 200, 32)
        _DEST T&
        CLS
        FOR x = 0 TO 2
            LINE (0 + x, 0 + x)-(949 - x, 199 - x), &HFF5050A0, B
        NEXT x
        _PUTIMAGE (150, 290), T&, A&
        _DEST A&
        LOCATE 20, 25
        INPUT "Input system/scenario name or [ENTER] to default to Sol :", sys$
        IF sys$ = "" THEN
            sys$ = "systems/Sol.tss" '                          load default Sol
            IF _FILEEXISTS(sys$) THEN lookup = 1 ELSE lookup = 3
        ELSE
            sys$ = _TRIM$(sys$)
            lng% = LEN(sys$)
            ext1% = INSTR(1, sys$, ".tss")
            ext2% = INSTR(1, sys$, ".tfs")
            bod1% = INSTR(1, sys$, "systems")
            bod2% = INSTR(1, sys$, "scenarios")
            IF ext1% <> 0 OR bod1% <> 0 THEN '                  if system inputs
                IF ext1% = 0 THEN tmp$ = sys$ + ".tss"
                IF bod1% = 0 THEN tmp$ = "systems/" + sys$
                IF _FILEEXISTS(tmp$) THEN
                    sys$ = tmp$
                    lookup = 1 '                                system present
                ELSE
                    lookup = 3 '                                file not found
                END IF
            ELSEIF ext2% <> 0 OR bod2% <> 0 THEN '              if scenario inputs
                IF ext2% = 0 THEN tmp$ = sys$ + ".tfs"
                IF bod2% = 0 THEN tmp$ = "scenarios/" + sys$
                IF _FILEEXISTS(tmp$) THEN
                    sys$ = tmp$
                    lookup = 2 '                                scenario present
                ELSE
                    lookup = 3 '                                file not found
                END IF
            ELSE
                tmp1$ = "systems/" + sys$ + ".tss"
                tmp2$ = "scenarios/" + sys$ + ".tfs"
                IF _FILEEXISTS(tmp1$) THEN
                    sys$ = tmp1$: lookup = 1 '                  system
                ELSEIF _FILEEXISTS(tmp2$) THEN
                    sys$ = tmp2$: lookup = 2 '                  scenario
                ELSE
                    lookup = 3 '                                file not found
                END IF
            END IF
        END IF
        SELECT CASE lookup
            CASE IS = 1 '                                       system file into hvns() array
                OPEN sys$ FOR BINARY AS #1
                orbs = LOF(1) / LEN(hvns(0))
                REDIM hvns(orbs) AS body
                FOR x = 1 TO orbs '                             Load data array
                    GET #1, , hvns(x)
                NEXT x
                CLOSE #1
                LOCATE 22, 25: INPUT "Input year: ", yr '       get ephemeris info
                LOCATE 23, 25: INPUT "Input day (0-365): ", dy
                IF dy = 0 THEN
                    oryr = yr
                ELSE
                    oryr = yr + (dy / 365)
                END IF
                LOCATE 25, 25: INPUT "2D/3D mode (enter '2' for 2D, default 3D):", md$
                IF md$ = "2" THEN
                    togs = _RESETBIT(togs, 13) '                set 2D mode
                END IF
                _FREEIMAGE T&
                Set_Up '                                        Re_Calc included in Set_Up
                EXIT DO
            CASE IS = 2 '                                       load the binary scenario file
                OPEN sys$ FOR BINARY AS #1
                GET #1, , units '                               Load environment
                GET #1, , orbs
                GET #1, , Turncount
                GET #1, , oryr
                GET #1, , vpoint
                GET #1, , shipoff
                GET #1, , togs
                GET #1, , zangle
                GET #1, , Ozang
                REDIM hvns(orbs) AS body '                      Create required variable and image states
                REDIM cmb(units) AS ship
                REDIM ship_box(units)
                FOR x = 1 TO units
                    ship_box(x) = _NEWIMAGE(290, 96, 32)
                NEXT x
                REDIM Thrust(units) AS Maneuver
                REDIM Gwat(units) AS Maneuver
                REDIM Sensor(units, units) AS _BYTE
                FOR h = 1 TO orbs '                             Load system details
                    GET #1, , hvns(h)
                NEXT h
                FOR s = 1 TO units '                            Load ships and sensor states
                    GET #1, , cmb(s)
                    GET #1, , Thrust(s)
                    FOR sm = 1 TO units
                        GET #1, , Sensor(s, sm)
                    NEXT sm
                NEXT s
                CLOSE #1
                Turn_2_Clock Turncount
                Re_Calc
                EXIT DO
            CASE IS = 3
                LOCATE 22, 25: PRINT "File does not exist. Please check your path and file name."
                SLEEP 3
        END SELECT
    LOOP
    t$ = ttl + " " + sys$ '                                     add system id to _TITLE bar
    _TITLE t$
    _FREEIMAGE strfld

END SUB 'Gate_Keeper


'±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
SUB Get_Body_Vec (var AS INTEGER, var2 AS V3)

    'called from: various
    'Compute the vector of planet var, returning in var2 | <var2.pX, var2.pY, var2.pZ>
    DIM i AS V3 '                                               relative start position
    DIM j AS V3 '                                               relative end position
    r% = hvns(var).rank
    u% = var
    IF r% > 1 THEN
        DO
            az! = Az_From_Parent(u%)
            i.pX = hvns(u%).orad * SIN(az!) '                   starting position relative to parent
            i.pY = hvns(u%).orad * COS(az!)
            daz! = az! + (_PI * 2) / (hvns(u%).oprd * 31557.6) 'future azimuth
            j.pX = hvns(u%).orad * SIN(daz!) '                  ending position relative to parent
            j.pY = hvns(u%).orad * COS(daz!)
            Vec_Add j, i, -1 '                                  subtract past from future position vector
            Vec_Add var2, j, 1 '                                add to combined tally
            u% = Find_Parent(u%) '                              set unit to parent
            r% = r% - 1 '                                       decrement rank
        LOOP UNTIL r% < 2 '                                     stop at primary body, it doesn't move in absolute coordinates
    ELSE
        var2 = origin '                                         primary star is both stationary and at origin
    END IF

END SUB 'Get_Body_Vec


'±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
SUB Grav_Force_Vec (gravvec AS V3, gravtarg AS V3, var AS INTEGER)

    'called from: Grav_Well
    'Returns a gravity acceleration vector {gravvec} applied by a planet {var} upon a position vector {gravtarg}
    DIM unv AS V3U '                                            gravitational unit vector
    radius## = hvns(var).radi
    ds## = PyT(3, hvns(var).ps, gravtarg)
    ds## = ds## + ((ds## - radius##) * (ds## < radius##)) '     no less than radius
    grav! = ((hvns(var).dens * ((4 / 3) * _PI * (radius## * radius## * radius##))) / 26687) / (ds## * ds##)
    tc = grav! * 5000 '                                         Scalar magnitude of pull / turn
    gravvec = hvns(var).ps: Vec_Add gravvec, gravtarg, -1
    Vec_2_UVec gravvec, unv '                                   unv=direction of pull
    Vec_Mult_Unit gravvec, unv, tc

END SUB 'Grav_Force_Vec


'±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
SUB Grav_Well (var AS INTEGER, var2 AS _BYTE)

    'called from: Coord_Update, Load_Ships
    'Determine gravity perturbations of nearby massive bodies, apply if var2 TRUE
    IF cmb(var).status > 0 THEN '                               if unit (var) is destroyed there's no point in doing this
        DIM mdpnt AS V3 '                                       midpoint of ship's vector
        DIM Pull AS V3 '                                        G-force of an individual body
        DIM xu AS V3 '                                          total vectors of all bodies checked
        xu = origin

        'locate var's turn midpoint position vector
        mdpnt = cmb(var).ap: Vec_Add mdpnt, cmb(var).op, -1 '   mdpnt now = movement for the turn
        Vec_Mult mdpnt, 0.5: Vec_Add mdpnt, cmb(var).op, 1 '    add half of movement to start point

        'Iterate all bodies in system
        FOR x = 1 TO orbs
            IF hvns(x).star = 2 THEN _CONTINUE '                skip ring/belt systems
            Grav_Force_Vec Pull, mdpnt, x '                     get G force vector <Pull> exterted by each planet x
            Vec_Add xu, Pull, 1 '                               and tally them up in <xu>
        NEXT x

        'apply the combined vector to unit if called from CoordUpdateII
        IF var2 THEN Vec_Add cmb(var).ap, xu, 1

        'extrapolate out the grav force Maneuver data displayed for active unit
        Gwat(var).Gs = _HYPOT(_HYPOT(xu.pX, xu.pY), xu.pZ) / 5000
        Gwat(var).Azi = Azimuth!(xu.pX, xu.pY)
        Gwat(var).Inc = Slope!(xu, cmb(var).ap)
    END IF '                                                    end unit not destroyed test

END SUB 'Grav_Well


'±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
SUB Help

    'called from: Main_Loop, Mouse_Button_Left
    Dialog_Box "HELP", 1200, 650, 25, &HFF4CCB9C, clr&(15)

    'temporary grid positions- remove when finished
    FOR g = 0 TO 1200
        IF g MOD 10 = 0 THEN
            IF g MOD 100 = 0 THEN g1 = 10 ELSE g1 = 0
            LINE (g + 25, 26)-(g + 25, 50 + g1)
        END IF
    NEXT g

    x% = 40
    x$ = INKEY$
    _PRINTSTRING (x%, 80), "HOTKEYS", A&
    _PRINTSTRING (x%, 96), "[A] Azimuth wheel on/off->", A&
    _PUTIMAGE (250, 80), AZ&, A&
    _PRINTSTRING (x%, 112), "[B] Belts/Rings on/off", A&
    _PRINTSTRING (x%, 128), "[D] Jump zone mode (Density/Diameter)---->", A&
    _PUTIMAGE (380, 112), DN&, A&
    _PUTIMAGE (433, 112), DI&, A&
    _PRINTSTRING (x%, 144), "[E] Edit Active Ship", A&
    _PRINTSTRING (x%, 160), "[F] Flightplan", A&
    _PRINTSTRING (x%, 176), "[G] Scale Grid on/off---->", A&
    _PUTIMAGE (250, 160), GD&, A&
    _PRINTSTRING (x%, 192), "[H] Help Menu------------------->", A&
    Con_Blok 305, 176, 64, 32, "Help", 1, &HFF4CCB9C
    _PRINTSTRING (x%, 208), "[I] Inclinometer on/off------------------>", A&
    _PUTIMAGE (380, 192), IN&, A&
    _PRINTSTRING (x%, 224), "[J] Jump Zones on/off-------------------------->", A&
    _PUTIMAGE (425, 208), JP&, A&
    _PRINTSTRING (x%, 240), "[O] Orbit tracks on/off------------------------------->", A&
    _PUTIMAGE (480, 224), OB&, A&
    _PRINTSTRING (x%, 256), "[Q] Autosave & Quit", A&
    _PRINTSTRING (x%, 272), "[R] Range bands---------->", A&
    _PUTIMAGE (250, 256), RG&, A&
    _PRINTSTRING (x%, 288), "[T] Execute Turn------------------>", A&
    Con_Blok 320, 272, 64, 32, "Turn", 1, &HFF2C9B2C
    _PRINTSTRING (x%, 304), "[U] Undo Turn------------------------------>", A&
    Con_Blok 390, 288, 64, 32, "Undo", 1, &HFF2C9B2C
    _PRINTSTRING (x%, 320), "[V] Vector input (textual)", A&
    _PRINTSTRING (x%, 336), "[X] Zoom Extents (all units)->", A&
    _PUTIMAGE (280, 320), XZ&, A&
    _PRINTSTRING (x%, 352), "[Z] Gravity Zones on/off", A&
    _PRINTSTRING (x%, 368), "[-] Zoom Out-------------------------->", A&
    _PUTIMAGE (350, 352), OZ&, A&
    _PRINTSTRING (x%, 384), "[+] Zoom In----------------------------------->", A&
    _PUTIMAGE (420, 368), IZ&, A&
    _PRINTSTRING (x%, 400), "[up] Activate previous unit", A&
    _PRINTSTRING (x%, 416), "[down] Activate next unit", A&
    _PRINTSTRING (x%, 432), "[insert] Add new unit", A&
    _PRINTSTRING (x%, 448), "[delete] Delete active unit", A&
    _PRINTSTRING (x%, 464), "[3] 2D/3D toggle--------------->", A&
    Con_Blok 300, 448, 40, 32, "2D", 0, &HFFB5651D
    _PRINTSTRING (x%, 496), "MOUSE OPS", A&
    _PRINTSTRING (x%, 639), "Press any key to continue...", A&
    _DISPLAY
    Clear_MB 1
    Press_Click

END SUB 'Help


'±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
SUB HelpII

    'called from: Main_Loop, Mouse_Button_Left
    Dialog_Box "HELP", 1200, 650, 25, &HFF4CCB9C, clr&(15)

    DO


        'temporary grid positions- remove when finished
        FOR g = 0 TO 1200
            IF g MOD 10 = 0 THEN
                IF g MOD 100 = 0 THEN g1 = 10 ELSE g1 = 0
                LINE (g + 25, 26)-(g + 25, 50 + g1)
            END IF
        NEXT g

        x% = 60: y% = 80
        x$ = INKEY$
        _PRINTSTRING (x%, y%), "HOTKEYS", A&
        _PRINTSTRING (x%, y% + 16), "[A] Azimuth wheel on/off->", A&
        '_PUTIMAGE (250, 80), AZ&, A&
        _PRINTSTRING (x%, y% + 32), "[B] Belts/Rings on/off", A&
        _PRINTSTRING (x%, y% + 48), "[D] Jump zone mode (Density/Diameter)---->", A&
        '_PUTIMAGE (380, 112), DN&, A&
        '_PUTIMAGE (433, 112), DI&, A&
        _PRINTSTRING (x%, 144), "[E] Edit Active Ship", A&
        _PRINTSTRING (x%, 160), "[F] Flightplan", A&
        _PRINTSTRING (x%, 176), "[G] Scale Grid on/off---->", A&
        '_PUTIMAGE (250, 160), GD&, A&
        _PRINTSTRING (x%, 192), "[H] Help Menu------------------->", A&
        Con_Blok 305, 176, 64, 32, "Help", 1, &HFF4CCB9C
        _PRINTSTRING (x%, 208), "[I] Inclinometer on/off------------------>", A&
        '_PUTIMAGE (380, 192), IN&, A&
        _PRINTSTRING (x%, 224), "[J] Jump Zones on/off-------------------------->", A&
        '_PUTIMAGE (425, 208), JP&, A&
        _PRINTSTRING (x%, 240), "[O] Orbit tracks on/off------------------------------->", A&
        '_PUTIMAGE (480, 224), OB&, A&
        _PRINTSTRING (x%, 256), "[Q] Autosave & Quit", A&
        _PRINTSTRING (x%, 272), "[R] Range bands---------->", A&
        '_PUTIMAGE (250, 256), RG&, A&
        _PRINTSTRING (x%, 288), "[T] Execute Turn------------------>", A&
        Con_Blok 320, 272, 64, 32, "Turn", 1, &HFF2C9B2C
        _PRINTSTRING (x%, 304), "[U] Undo Turn------------------------------>", A&
        Con_Blok 390, 288, 64, 32, "Undo", 1, &HFF2C9B2C
        _PRINTSTRING (x%, 320), "[V] Vector input (textual)", A&
        _PRINTSTRING (x%, 336), "[X] Zoom Extents (all units)->", A&
        '_PUTIMAGE (280, 320), XZ&, A&
        _PRINTSTRING (x%, 352), "[Z] Gravity Zones on/off", A&
        _PRINTSTRING (x%, 368), "[-] Zoom Out-------------------------->", A&
        '_PUTIMAGE (350, 352), OZ&, A&
        _PRINTSTRING (x%, 384), "[+] Zoom In----------------------------------->", A&
        '_PUTIMAGE (420, 368), IZ&, A&
        _PRINTSTRING (x%, 400), "[up] Activate previous unit", A&
        _PRINTSTRING (x%, 416), "[down] Activate next unit", A&
        _PRINTSTRING (x%, 432), "[insert] Add new unit", A&
        _PRINTSTRING (x%, 448), "[delete] Delete active unit", A&
        _PRINTSTRING (x%, 464), "[3] 2D/3D toggle--------------->", A&
        Con_Blok 300, 448, 40, 32, "2D", 0, &HFFB5651D
        _PRINTSTRING (x%, 496), "MOUSE OPS", A&
        _PRINTSTRING (x%, 639), "Press any key to continue...", A&

        _DISPLAY

        _LIMIT 30
    LOOP UNTIL INKEY$ <> ""

END SUB 'HelpII


'±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
SUB Inc_Meter

    'called from: Sensor_Screen
    'display inclinometer scale
    IF ABS(zangle) > .08727 THEN
        IF cmb(vpoint).In >= 0 THEN '                       Moving with or toward the zenith of the plane
            IF cmb(vpoint).Hd <= _PI THEN '                 right side
                zdeg! = ABS(cmb(vpoint).In - 1.570796)
            ELSE '                                          left side
                zdeg! = ABS(4.712389 + cmb(vpoint).In)
            END IF
        ELSE '                                              Moving toward the nadir of the plane
            IF cmb(vpoint).Hd > _PI THEN '                  left side
                zdeg! = ABS(4.712389 + cmb(vpoint).In)
            ELSE '                                          right side
                zdeg! = ABS(cmb(vpoint).In - 1.570796)
            END IF
        END IF

        jz = SIN(zangle) '                                      Trig squish component
        j = 900 * COS(zdeg!) * jz '                             direction indicator components (y)
        jm = 850 * COS(zdeg! - Degree1) * jz
        jp = 850 * COS(zdeg! + Degree1) * jz
        i = 900 * SIN(zdeg!) '                                  direction indicator components (x)
        im = 850 * SIN(zdeg! - Degree1)
        ip = 850 * SIN(zdeg! + Degree1)

        _PUTIMAGE (-1000, 1000 * jz)-(1000, -1000 * jz), IW&

        LINE (im, jm)-(i, j), _RGBA32(127, 127, 127, 200)
        LINE (i, j)-(ip, jp), _RGBA32(127, 127, 127, 200)
        LINE (0, 0)-(i, j), _RGBA32(127, 127, 127, 80)
    END IF

END SUB 'Inc_Meter


'±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
SUB Info (u AS INTEGER)

    'called from: Mouse_Button_Left
    'display active unit detailed information box
    IF u = vpoint THEN t$ = "ACTIVE UNIT DETAILS" ELSE t$ = "UNIT DETAILS"
    Dialog_Box t$, 600, 600, 25, &HFF4CCB9C, clr&(15)
    d$ = CHR$(248)
    LOCATE 7, 47: PRINT "ID:"; cmb(u).id; " "; cmb(u).Nam
    LOCATE 7, 67: PRINT "Status: ";
    SELECT CASE cmb(u).status
        CASE IS = 0: PRINT "Crashed on "; hvns(cmb(u).bogey).nam
        CASE IS = 1: PRINT "In flight ";
            SELECT CASE cmb(u).bstat
                CASE IS = 1: PRINT "evade "; cmb(cmb(u).bogey).Nam
                CASE IS = 2: PRINT "intercept "; cmb(cmb(u).bogey).Nam
                CASE IS = 3: PRINT "landing on "; hvns(cmb(u).bogey).nam
                CASE IS = 4: PRINT "orbiting "; hvns(cmb(u).bogey).nam
                CASE IS = 5: PRINT "fleet unit of "; cmb(cmb(u).bogey).Nam
                CASE IS = 6: PRINT "station at "; hvns(cmb(u).bogey).nam
                CASE ELSE
                    FOR x = 1 TO units
                        IF x <> u THEN
                            IF cmb(x).bstat = 5 AND cmb(x).bogey = u THEN
                                PRINT "flagship"
                            END IF
                        END IF
                    NEXT x
            END SELECT
        CASE IS = 2: PRINT "Landed on "; hvns(cmb(u).bogey).nam
        CASE IS = 3: PRINT "disabled/adrift"
        CASE IS = 4: PRINT "Launching"
    END SELECT
    LOCATE 9, 47: PRINT "Absolute Coordinate Position from Primary"
    LOCATE 10, 47: PRINT "X: ";
    PRINT USING "###,###,###,###"; cmb(u).ap.pX;
    PRINT "  Y: ";
    PRINT USING "###,###,###,###"; cmb(u).ap.pY;
    PRINT "  Z: ";
    PRINT USING "###,###,###,###"; cmb(u).ap.pZ

    LOCATE 12, 47: PRINT "Previous Coordinate Position from Primary"
    LOCATE 13, 47: PRINT "X: ";
    PRINT USING "###,###,###,###"; cmb(u).op.pX;
    PRINT "  Y: ";
    PRINT USING "###,###,###,###"; cmb(u).op.pY;
    PRINT "  Z: ";
    PRINT USING "###,###,###,###"; cmb(u).op.pZ


    LOCATE 15, 47
    IF cmb(u).status <> 2 THEN
        PRINT "Yaw: "; _ROUND(_R2D(Thrust(u).Azi) * 100) / 100; d$;
        PRINT "  Pitch: "; _ROUND(_R2D(Thrust(u).Inc) * 100) / 100; d$;
    ELSE
        PRINT "Yaw: ---";
        PRINT "  Pitch: ---";
    END IF
    'PRINT "  Thrust: "; _ROUND(Thrust(u).Gs * 100) / 100; " Gs";
    PRINT "  Thrust: "; Fix_Float$(Thrust(u).Gs, 5); " Gs";
    PRINT "  Max Gs="; cmb(u).MaxG
    LOCATE 17, 47
    PRINT "Heading: "; _ROUND(_R2D(cmb(u).Hd) * 100) / 100; d$;
    PRINT "  Inclin: "; _ROUND(_R2D(cmb(u).In) * 100) / 100; d$;
    PRINT "  Velocity: "; _ROUND(cmb(u).Sp / 10) / 100; " kps"

    'Targeting
    LOCATE 19, 47
    PRINT "Targeting:"
    tg = 0
    FOR x = 1 TO units
        IF NOT Sensor(u, x) AND 2 THEN _CONTINUE
        tg = tg + 1
        LOCATE 20 + tg, 47
        PRINT cmb(x).id; " "; cmb(x).Nam
    NEXT x
    'Targeted by
    LOCATE 19, 80
    PRINT "Targeted by:"
    tb = 0
    FOR x = 1 TO units
        IF NOT Sensor(x, u) AND 2 THEN _CONTINUE
        tb = tb + 1
        LOCATE 20 + tb, 80
        PRINT cmb(x).id; " "; cmb(x).Nam
    NEXT x
    _PUTIMAGE (_SHR(_WIDTH(A&), 1) - _SHR(_WIDTH(ship_box(u)), 1), 490), ship_box(u), A&
    LOCATE 38, 58
    PRINT "Left click or press any key to continue..."
    _DISPLAY
    Press_Click

END SUB 'Info


'±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
FUNCTION Intra_Turn_Vec_Map&& (vl%, stA AS V3, ndA AS V3, stB AS V3, ndB AS V3)

    'called from Col_Check, Col_Check_Ship
    'map distance between two moving vectors at vl% seconds in a turn
    DIM AS V3 chs, rnr
    chs.pX = map64&&(vl%, 1, 1000, stA.pX, ndA.pX)
    chs.pY = map64&&(vl%, 1, 1000, stA.pY, ndA.pY)
    chs.pZ = map64&&(vl%, 1, 1000, stA.pZ, ndA.pZ)
    rnr.pX = map64&&(vl%, 1, 1000, stB.pX, ndB.pX)
    rnr.pY = map64&&(vl%, 1, 1000, stB.pY, ndB.pY)
    rnr.pZ = map64&&(vl%, 1, 1000, stB.pZ, ndB.pZ)
    Intra_Turn_Vec_Map&& = PyT(3, chs, rnr)

END FUNCTION 'Intra_Turn_Vec_map&&


'±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
SUB Load_System

    'called from: Mouse_Button_Left
    'Load star system file
    IF _DIREXISTS("systems") THEN
        Dialog_Box "LOAD NEW STAR SYSTEM", 400, 250, 50, &HFF2C9B2C, clr&(15)
        in1$ = "Enter path and filename of system"
        l = _SHR(_WIDTH(A&), 1) - _SHL(LEN(in1$), 2)
        _PRINTSTRING (l, 113), in1$, A&
        _DISPLAY
        LOCATE 10, 57
        INPUT "systems\+ :", fn$
        IF RIGHT$(fn$, 4) <> ".tss" THEN
            fn$ = "systems\" + fn$ + ".tss"
        ELSE
            fn$ = "systems\" + fn$
        END IF
        IF _FILEEXISTS(fn$) THEN
            OPEN fn$ FOR BINARY AS #1
            orbs = LOF(1) / LEN(hvns(0))
            REDIM hvns(orbs) AS body
            Turncount = 0
            FOR x = 1 TO orbs
                GET #1, , hvns(x)
            NEXT x
            CLOSE #1
            LOCATE 12, 57: INPUT "Input year: ", yr '       get ephemeris info
            LOCATE 13, 57: INPUT "Input day (0-365): ", dy
            IF dy = 0 THEN oryr = yr ELSE oryr = yr + (dy / 365)
            Planet_Move 0 '                                      planets to date positions
        ELSE
            LOCATE 12, 57
            PRINT "File not found, check path and name."
            _DISPLAY
            SLEEP 3
        END IF
    ELSE '                                                      Warn and abort if directory missing
        Bad_Install "systems", 0 '                               autosave calls will likely take care of this
    END IF '                                                    during timer events, but keep it just in case.

END SUB 'Load_System


'±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
SUB Load_Ships

    'called from: Mouse_Button_Left
    IF _DIREXISTS("ships") THEN
        Dialog_Box "LOAD NEW VESSEL GROUP", 400, 250, 50, &HFF2C9B2C, clr&(15)
        in1$ = "Enter filename of ships"
        l = _SHR(_WIDTH(A&), 1) - _SHL(LEN(in1$), 2)
        _PRINTSTRING (l, 113), in1$, A&
        _DISPLAY
        LOCATE 10, 57
        INPUT "ships/+ :", fn$
        IF RIGHT$(fn$, 4) <> ".tvg" THEN
            fn$ = "ships/" + fn$ + ".tvg"
        ELSE
            fn$ = "ships/" + fn$
        END IF
        IF _FILEEXISTS(fn$) THEN
            Refresh
            Dialog_Box "REPLACE EXISTING OR ADD TO EXISTING", 400, 170, 50, &HFF2C9B2C, clr&(15)
            Con_Blok 475, 110, 80, 48, "REPLACE", 0, _RGBA32(22, 211, 166, 255)
            Con_Blok 575, 110, 80, 48, "APPEND", 0, _RGBA32(22, 211, 166, 255)
            Con_Blok 675, 110, 80, 48, "ABORT", 0, _RGBA32(22, 211, 166, 255)
            _PRINTSTRING (500, 180), "...or press R  A or esc"
            _DISPLAY
            dl% = 0
            DO
                x$ = UCASE$(INKEY$)
                ms = MBS
                IF ms AND 1 THEN
                    SELECT CASE _MOUSEY
                        CASE 110 TO 158
                            SELECT CASE _MOUSEX
                                CASE 475 TO 555 '               replace
                                    ch% = 1: dl% = -1
                                    Panel_Blank 475, 110, 80, 48
                                CASE 575 TO 655 '               append
                                    ch% = 2: dl% = -1
                                    Panel_Blank 575, 110, 80, 48
                                CASE 675 TO 755 '               abort
                                    Panel_Blank 675, 110, 80, 48
                                    EXIT SUB
                            END SELECT
                    END SELECT
                    Clear_MB 1
                END IF
                IF x$ = "R" THEN ch% = 1: dl% = -1
                IF x$ = "A" THEN ch% = 2: dl% = -1
                IF x$ = CHR$(27) THEN EXIT SUB '                abort delete with ESC keypress
                _LIMIT 30
            LOOP UNTIL dl%
            _DISPLAY
            OPEN fn$ FOR BINARY AS #1
            ashp% = LOF(1) / LEN(cmb(0))

            SELECT CASE ch%
                CASE IS = 1 '                                   Erase existing ships
                    FOR x = 1 TO units '                        erase old ship data displays
                        _FREEIMAGE ship_box(x)
                    NEXT x
                    units = ashp%
                    REDIM cmb(units) AS ship
                    REDIM Sensor(units, units)
                    REDIM Thrust(units) AS Maneuver
                    REDIM Gwat(units) AS Maneuver
                    REDIM ship_box(units)
                    FOR x = 1 TO units
                        ship_box(x) = _NEWIMAGE(290, 96, 32)
                    NEXT x
                    Turncount = 0: vpoint = 1: shipoff = 0
                    FOR x = 1 TO units
                        GET #1, , cmb(x)
                        Sensor(x, x) = _SETBIT(Sensor(x, x), 4) 'transponders on
                    NEXT x
                    CLOSE #1
                CASE IS = 2 '                                   Append to existing ships
                    REDIM _PRESERVE cmb(units + ashp%) AS ship
                    REDIM _PRESERVE Thrust(units + ashp%) AS Maneuver
                    REDIM _PRESERVE Gwat(units + ashp%) AS Maneuver
                    REDIM _PRESERVE ship_box(units + ashp%)
                    DIM tmpsns(units, units) AS _BYTE '          _PRESERVE older ship's sensor data
                    FOR x = 1 TO units: FOR y = 1 TO units: tmpsns(x, y) = Sensor(x, y): NEXT y, x
                    REDIM Sensor(units + ashp%, units + ashp%)
                    FOR x = 1 TO units: FOR y = 1 TO units: Sensor(x, y) = tmpsns(x, y): NEXT y, x
                    FOR x = 1 TO ashp%: ship_box(units + x) = _NEWIMAGE(290, 96, 32): NEXT x 'allocate databox images
                    FOR x = 1 TO ashp% '                        load appended units
                        GET #1, , cmb(units + x)
                        cmb(units + x).id = cmb(units).id + x
                        Sensor(units + x, units + x) = _SETBIT(Sensor(units + x, units + x), 4) 'transponders on
                    NEXT x
                    CLOSE #1
                    units = units + ashp%: ZoomFac = 1: vpoint = 1: shipoff = 0
            END SELECT
            FOR x = 1 TO units '                                nested loop to avoid planet/star collisions here
                FOR y = 1 TO orbs
                    IF PyT(3, cmb(x).ap, hvns(y).ps) > hvns(y).radi THEN _CONTINUE 'skip if outside radius
                    DO '                                        loop to accomodate large stars/GGs
                        cmb(x).ap.pX = cmb(x).ap.pX + 100000 '  Move ship 100K coreward and trailing
                        cmb(x).ap.pY = cmb(x).ap.pY + 100000
                    LOOP UNTIL PyT(3, cmb(x).ap, hvns(y).ps) > hvns(y).radi 'stop once the unit's clear
                NEXT y
                Grav_Well x, 0 '                                sum gravity perturbations, but don't apply yet
            NEXT x
        ELSE
            LOCATE 12, 57
            PRINT "File not found, check path and name."
            SLEEP 3
        END IF
    ELSE
        Bad_Install "ships", 0
    END IF

END SUB 'Load_Ships


'±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
SUB Load_Scenario

    'called from: Mouse_Button_Left
    IF _DIREXISTS("scenarios") THEN
        t% = 400: r% = 2
        Dialog_Box "LOAD SCENARIO", t%, 250, 50, &HFF8C5B4C, clr&(15)
        _DISPLAY
        LOCATE r% + 5, _SHR((_SHR(_WIDTH(A&), 1) - _SHR(t%, 1)), 3) + 4
        INPUT "Enter a scenario name: ", fl$
        IF _TRIM$(fl$) = "auto" THEN fl$ = "autosave/auto"
        LOCATE r% + 7, _SHR((_SHR(_WIDTH(A&), 1) - 40), 3)
        fx$ = "scenarios/" + _TRIM$(fl$) + ".tfs"
        IF _FILEEXISTS(fx$) THEN
            ERASE hvns, cmb, Thrust, Gwat, Sensor '             reset environment/ remove TLock
            FOR x = 1 TO units '                                erase old ship data displays
                _FREEIMAGE ship_box(x)
            NEXT x
            OPEN fx$ FOR BINARY AS #1
            GET #1, , units '                                   Load environment
            GET #1, , orbs
            GET #1, , Turncount
            GET #1, , oryr
            GET #1, , vpoint
            GET #1, , shipoff
            GET #1, , togs
            GET #1, , zangle
            GET #1, , Ozang
            REDIM hvns(orbs) AS body '                          Create required variable and image states
            REDIM cmb(units) AS ship
            REDIM ship_box(units)
            FOR x = 1 TO units
                ship_box(x) = _NEWIMAGE(290, 96, 32)
            NEXT x
            REDIM Thrust(units) AS Maneuver
            REDIM Gwat(units) AS Maneuver
            REDIM Sensor(units, units) AS _BYTE
            FOR h = 1 TO orbs '                                 Load system details
                GET #1, , hvns(h)
            NEXT h
            FOR s = 1 TO units '                                Load ships and sensor states
                GET #1, , cmb(s)
                GET #1, , Thrust(s)
                FOR sm = 1 TO units
                    GET #1, , Sensor(s, sm)
                NEXT sm
            NEXT s
            CLOSE #1
            Turn_2_Clock Turncount
        ELSE '                                                  Check for prior to ver 0.43 files
            vl$ = "scenarios\" + _TRIM$(fl$) + ".tvg" '         Vessel group #2
            pl$ = "scenarios\" + _TRIM$(fl$) + ".tss" '         Planets #1
            sl$ = "scenarios\" + _TRIM$(fl$) + ".tgn" '         saved state #4
            tl$ = "scenarios\" + _TRIM$(fl$) + ".tvt" '         Thrust keeper (.tvt) #3
            tt$ = "scenarios\" + _TRIM$(fl$) + ".ttl" '         Sensor state keeper #5
            IF _FILEEXISTS(vl$) AND _FILEEXISTS(pl$) THEN '     Is old file system present?
                ERASE hvns, cmb, Thrust, Gwat, Sensor '         reset environment/ remove TLock
                FOR x = 1 TO units '                            erase old ship data displays
                    _FREEIMAGE ship_box(x)
                NEXT x
                OPEN pl$ FOR RANDOM AS #1 LEN = LEN(hvns(0)) '  Load new planetary system
                orbs = LOF(1) / LEN(hvns(0))
                REDIM hvns(orbs) AS body
                FOR x = 1 TO orbs
                    GET #1, x, hvns(x)
                NEXT x
                CLOSE #1
                OPEN vl$ FOR RANDOM AS #2 LEN = LEN(cmb(0))
                units = LOF(2) / LEN(cmb(0))
                REDIM cmb(units) AS ship
                REDIM ship_box(units)
                FOR x = 1 TO units
                    ship_box(x) = _NEWIMAGE(290, 96, 32)
                NEXT x
                FOR x = 1 TO units
                    GET #2, x, cmb(x)
                NEXT x
                CLOSE #2
                IF _FILEEXISTS(tl$) THEN '                           important but not fatal if missing
                    OPEN tl$ FOR RANDOM AS #3 LEN = LEN(Thrust(0))
                    REDIM Thrust(units) AS Maneuver
                    REDIM Gwat(units) AS Maneuver
                    FOR x = 1 TO units
                        GET #3, x, Thrust(x)
                    NEXT x
                    CLOSE #3
                ELSE
                    REDIM Thrust(units) AS Maneuver
                    REDIM Gwat(units) AS Maneuver
                END IF
                IF _FILEEXISTS(sl$) THEN '
                    OPEN sl$ FOR INPUT AS #4
                    INPUT #4, Turncount, oryr, vpoint, shipoff, togs, zangle, Ozang
                    CLOSE #4
                ELSE
                    Turncount = 0: oryr = 0: vpoint = 1: shipoff = 0
                END IF
                IF _FILEEXISTS(tt$) THEN
                    OPEN tt$ FOR RANDOM AS #5 LEN = LEN(Sensor(0, 0))
                    REDIM Sensor(units, units) AS _BYTE
                    FOR x = 1 TO units
                        FOR y = 1 TO units
                            GET #5, ((x - 1) * units) + y, Sensor(x, y)
                        NEXT y
                    NEXT x
                    CLOSE #5
                ELSE
                    REDIM Sensor(units, units) AS _BYTE
                END IF
                Turn_2_Clock Turncount
            ELSE
                'essential file(s) are not present, abort
                LOCATE r% + 9, _SHR((_SHR(_WIDTH(A&), 1) - _SHR(t%, 1)), 3) + 4
                PRINT "Essential files missing, check filename."
                SLEEP 3
            END IF
        END IF
    ELSE
        Bad_Install "scenarios", 0 '                             Warn of missing directory, abort
    END IF

END SUB 'Load_Scenario


'±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
SUB Make_Buttons

    'called from: Main Module
    _DEST flight& '                                              Create Flight_Plan button
    CLS
    COLOR , &HFF16A6D3 ' _RGBA32(22, 166, 211, 255) '&HFF16A6D3'
    _PRINTSTRING (0, 0), "FLIGHTPLAN", flight&

    _DEST evade& '                                               Create evade button
    CLS
    COLOR , &HFFF40B11 ' _RGBA32(244, 11, 17, 255) '&HFFF40B11 '
    _PRINTSTRING (0, 0), "EVADE", evade&

    _DEST intercept& '                                           Create intercept button
    CLS
    COLOR , &HFF118B11 ' _RGBA32(17, 139, 17, 255) '&HFF118B11 '
    _PRINTSTRING (0, 0), "INTERCEPT", intercept&

    _DEST fleet& '                                               Create fleet button
    CLS
    COLOR , &HFF8B118B ' _RGBA32(139, 17, 139, 255) '&HFF8B118B '
    _PRINTSTRING (0, 0), "FLEET", fleet&

    _DEST break& '                                               Create break formation button
    CLS
    COLOR , &HFF8B118B ' _RGBA32(139, 17, 139, 255) '&HFF8B118B '
    _PRINTSTRING (0, 0), "BREAK", break&

    _DEST cancel& '                                              Create cancel button
    CLS
    COLOR , &HFF434396 ' _RGBA32(67, 67, 150, 255) '&HFF434396 '
    _PRINTSTRING (0, 0), "CANCEL", cancel&

    _DEST XZ& ' 64x32                                            Create Zoom extents control
    COLOR clr&(0), &HFF4880DE ' _RGBA32(72, 128, 222, 255) '&HFF4880DE '
    CLS
    Bevel_Button 64, 32, &HFF4880DE ' _RGBA32(72, 128, 222, 255) '&HFF
    _PRINTSTRING (8, 8), "Zoom", XZ&
    COLOR clr&(4)
    _PRINTSTRING (48, 8), "X", XZ&

    _DEST IZ& ' 64x32                                            Create Zoom in control
    COLOR clr&(0), &HFF4880DE ' _RGBA32(72, 128, 222, 255) '&HFF
    CLS
    Bevel_Button 64, 32, &HFF4880DE ' _RGBA32(72, 128, 222, 255) '&HFF
    _PRINTSTRING (8, 8), "Zoom", IZ&
    COLOR clr&(4)
    _PRINTSTRING (48, 8), "+", IZ&

    _DEST OZ& ' 64x32                                            Create Zoom out control
    COLOR clr&(0), &HFF4880DE ' _RGBA32(72, 128, 222, 255)
    CLS
    Bevel_Button 64, 32, &HFF4880DE ' _RGBA32(72, 128, 222, 255)
    _PRINTSTRING (8, 8), "Zoom", OZ&
    COLOR clr&(4)
    _PRINTSTRING (48, 8), "-", OZ&

    _DEST RG& ' 56x32                                            Create Range band toggle
    COLOR clr&(0), &HFF4880DE ' _RGBA32(72, 128, 222, 255)
    CLS
    Bevel_Button 56, 32, &HFF4880DE ' _RGBA32(72, 128, 222, 255)
    FCirc 28, 16, 20, _RGBA(252, 252, 84, 100)
    FCirc 28, 16, 12, _RGBA(252, 84, 84, 200)
    _PRINTMODE _KEEPBACKGROUND
    COLOR clr&(4)
    _PRINTSTRING (8, 8), "R", RG&
    COLOR clr&(0)
    _PRINTSTRING (16, 8), "ange", RG&

    _DEST OB& ' 56x32                                            Create Orbit track toggle
    COLOR clr&(0), &HFF4880DE '_RGBA32(72, 128, 222, 255)
    CLS
    Bevel_Button 56, 32, &HFF4880DE '_RGBA32(72, 128, 222, 255)
    CIRCLE (-15, -5), 58, clr&(1)
    CIRCLE (40, 15), 10, clr&(1)
    _PRINTMODE _KEEPBACKGROUND
    COLOR clr&(4)
    _PRINTSTRING (8, 8), "O", OB&
    COLOR clr&(0)
    _PRINTSTRING (16, 8), "rbit", OB&

    _DEST GD& ' 48x32                                            Create Grid toggle
    COLOR clr&(0), &HFF4880DE '_RGBA32(72, 128, 222, 255)
    CLS
    Bevel_Button 48, 32, &HFF4880DE '_RGBA32(72, 128, 222, 255)
    FOR h = 8 TO 48 STEP 8
        LINE (0, h)-(47, h), clr&(8), BF
        LINE (h, 0)-(h, 31), clr&(8), BF
    NEXT h
    _PRINTMODE _KEEPBACKGROUND
    COLOR clr&(4)
    _PRINTSTRING (8, 8), "G", GD&
    COLOR clr&(0)
    _PRINTSTRING (16, 8), "rid", GD&

    _DEST AZ& ' 40x32                                            Create Azimuth toggle
    COLOR clr&(0), &HFF4880DE '_RGBA32(72, 128, 222, 255)
    CLS
    Bevel_Button 40, 32, &HFF4880DE '_RGBA32(72, 128, 222, 255)
    FOR whl = 0 TO 3375 STEP 225
        outerx = (14 * SIN(_D2R(whl / 10))) + 20
        outery = (14 * COS(_D2R(whl / 10))) + 16
        innerx = (12 * SIN(_D2R(whl / 10))) + 20
        innery = (12 * COS(_D2R(whl / 10))) + 16
        LINE (outerx, outery)-(innerx, innery), clr&(5) '       draw tick
    NEXT whl
    _PRINTMODE _KEEPBACKGROUND
    COLOR clr&(4)
    _PRINTSTRING (8, 8), "A", AZ&
    COLOR clr&(0)
    _PRINTSTRING (16, 8), "zi", AZ&

    _DEST IN& ' 40x32                                            Create Inclinometer toggle
    COLOR clr&(0), &HFF4880DE '_RGBA32(72, 128, 222, 255)
    CLS
    Bevel_Button 40, 32, &HFF4880DE '_RGBA32(72, 128, 222, 255)
    FOR whl = 0 TO 1800 STEP 225
        outerx = (14 * SIN(_D2R(whl / 10))) + 20
        outery = (14 * COS(_D2R(whl / 10))) + 16
        innerx = (12 * SIN(_D2R(whl / 10))) + 20
        innery = (12 * COS(_D2R(whl / 10))) + 16
        LINE (outerx, outery)-(innerx, innery), clr&(8) '       draw tick
    NEXT whl
    LINE (20, 16)-((14 * SIN(_D2R(135))) + 20, (14 * COS(_D2R(135))) + 16), clr&(8)
    _PRINTMODE _KEEPBACKGROUND
    COLOR clr&(4)
    _PRINTSTRING (8, 8), "I", IN&
    COLOR clr&(0)
    _PRINTSTRING (16, 8), "nc", IN&

    _DEST JP& ' 48x32                                            Create Jump envelope toggle
    COLOR clr&(0), &HFF4880DE '_RGBA32(72, 128, 222, 255)
    CLS
    Bevel_Button 48, 32, &HFF4880DE '_RGBA32(72, 128, 222, 255)
    FCirc 24, 16, 12, &HC8967474 '_RGBA(150, 116, 116, 200) '&HC8967474 '
    _PRINTMODE _KEEPBACKGROUND
    COLOR clr&(4)
    _PRINTSTRING (8, 8), "J", JP&
    COLOR clr&(0)
    _PRINTSTRING (16, 8), "ump", JP&

    _DEST DI& ' 48x32                                            Create Jump Diameter button
    COLOR clr&(0), &HFF4880DE '_RGBA32(72, 128, 222, 255)
    CLS
    Bevel_Button 48, 32, &HFF4880DE '_RGBA32(72, 128, 222, 255)
    _PRINTMODE _KEEPBACKGROUND
    COLOR clr&(4)
    _PRINTSTRING (8, 8), "D", DI&
    COLOR clr&(0)
    _PRINTSTRING (16, 8), "iam.", DI&

    _DEST DN& ' 48x32                                            Create Jump Density button
    COLOR clr&(0), &HFF4880DE '_RGBA32(72, 128, 222, 255)
    CLS
    Bevel_Button 48, 32, &HFF4880DE '_RGBA32(72, 128, 222, 255)
    'density graphic
    _PRINTMODE _KEEPBACKGROUND
    COLOR clr&(4)
    _PRINTSTRING (8, 8), "D", DN&
    COLOR clr&(0)
    _PRINTSTRING (16, 8), "ens.", DN&

    _DEST QT& ' 48x32                                            Create Quit (program) button
    COLOR clr&(0), &HFFFF0032 '_RGBA32(255, 0, 50, 255) ' &HFFFF0032 '
    CLS
    Bevel_Button 48, 32, &HFFFF0032 '_RGBA32(255, 0, 50, 255)
    COLOR clr&(11)
    _PRINTSTRING (8, 8), "Q", QT&
    COLOR clr&(0)
    _PRINTSTRING (16, 8), "uit", QT&

END SUB 'Make_Buttons


'±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
SUB Make_Images

    'called from: Main Module
    _DEST AW& '                                                  Azimuth wheel image
    WINDOW (-1000, 1000)-(1000, -1000)
    SCREEN AW&
    CLS
    _CLEARCOLOR _RGB32(0, 0, 0)
    FOR whl = 0 TO 359 '                                        iterate through azimuth wheel
        IF whl MOD 45 = 0 THEN '                                45 degree tick and number
            y = 900
            Prnt STR$(whl), 3.5, 3.5, (y + 20) * SIN(_D2R(whl)) - 60, (y + 20) * COS(_D2R(whl)), 24, 0, &H7FA800A8
        ELSEIF whl MOD 10 = 0 THEN '                            10 degree tick
            y = 950
        ELSEIF whl MOD 5 = 0 THEN '                             5 degree tick
            y = 970
        ELSE '                                                  1 degree tick
            y = 990
        END IF
        'Draw azimuth tick
        LINE (1000 * SIN(_D2R(whl)), 1000 * COS(_D2R(whl)))-(y * SIN(_D2R(whl)), y * COS(_D2R(whl))), &HAFA800A8
    NEXT whl

    _DEST IW& '                                                  Inclinometer wheel image
    WINDOW (-1000, 1000)-(1000, -1000)
    SCREEN IW&
    CLS
    _CLEARCOLOR _RGB32(0, 0, 0)
    FOR whl = 0 TO 359 '                                        iterate through azimuth wheel
        IF whl MOD 45 = 0 THEN '                                45 degree tick and number
            y = 800
            SELECT CASE whl
                CASE 0: in$ = "90"
                CASE 45, 315: in$ = "45"
                CASE 90, 270: in$ = "0"
                CASE 135, 225: in$ = "-45"
                CASE 180: in$ = "-90"
            END SELECT
            Prnt in$, 3.5, 3.5, (y + 20) * SIN(_D2R(whl)) - 60, (y + 20) * COS(_D2R(whl)), 24, 0, &H8F7F7F7F
        ELSEIF whl MOD 10 = 0 THEN '                            10 degree tick
            y = 850
        ELSEIF whl MOD 5 = 0 THEN '                             5 degree tick
            y = 870
        ELSE '                                                  1 degree tick
            y = 890
        END IF
        'Draw inclinometer tick
        LINE (900 * SIN(_D2R(whl)), 900 * COS(_D2R(whl)))-(y * SIN(_D2R(whl)), y * COS(_D2R(whl))), &HAF7F7F7F
    NEXT whl

END SUB 'Make_Images


'±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
SUB Main_Loop

    'called from: Main Module
    DIM in AS _BYTE '                                           input flag
    Refresh '                                                   initial display refresh
    DO '                                                        outer loop running computations when inputs
        DO '                                                    inner loop waiting for inputs while no change
            x$ = INKEY$
            IF x$ <> "" THEN in = -1 '                          If a hotkey has been pressed

            'MOUSE OPS
            ms = MBS '                                          get Steve's mouse button status
            IF ms AND 1 THEN '                                  left mouse picks controls
                Mouse_Button_Left _MOUSEX, _MOUSEY
                IF _MOUSEX < 1200 THEN Clear_MB 1
                in = -1
            END IF
            IF ms AND 2 THEN '                                  right mouse places ships in display {position edit}
                Mouse_Button_Right _MOUSEX, _MOUSEY
                Clear_MB 2
                in = -1
            END IF

            IF ms AND 4 THEN '                                  center mouse button reverts to zoom factor 1
                IF _MOUSEX >= 560 AND _MOUSEX <= 1180 THEN
                    IF _MOUSEY >= 18 AND _MOUSEY <= 638 THEN
                        ZoomFac = 1: in = -1
                    END IF
                END IF
                Clear_MB 3
            END IF
            IF ms AND 512 THEN '                                hover & mousewheel for zoom or ship display offset
                IF _MOUSEX < 290 THEN
                    shipoff = shipoff + 1
                    shipoff = shipoff + (((shipoff - (units - 6))) * (shipoff > (units - 6)))
                    in = -1
                ELSEIF _MOUSEX > 560 AND _MOUSEX < 1180 THEN
                    ZoomFac = ZoomFac * .5: in = (zf <> ZoomFac): zf = ZoomFac 'zoom out
                END IF
            END IF
            IF ms AND 1024 THEN
                IF _MOUSEX < 290 THEN
                    shipoff = shipoff - 1 - (shipoff = 0): in = -1
                ELSEIF _MOUSEX > 560 AND _MOUSEX < 1180 THEN
                    ZoomFac = ZoomFac * 2: in = (zf <> ZoomFac): zf = ZoomFac 'zoom in
                END IF
            END IF

            'HOTKEY OPS
            IF x$ = CHR$(43) THEN '                             "+" Zoom In
                ZoomFac = ZoomFac * 2
                Panel_Blank 626, 660, 64, 32
            END IF
            IF x$ = CHR$(45) THEN '                             "-" Zoom Out
                ZoomFac = ZoomFac * .5
                Panel_Blank 692, 660, 64, 32
            END IF
            IF x$ = CHR$(51) THEN '                             "3" 2D/3D toggle
                IF togs AND 8192 THEN '                         if 3D mode
                    togs = _TOGGLEBIT(togs, 1)
                    IF togs AND 2 THEN
                        zangle = Ozang
                    ELSE
                        Ozang = zangle: zangle = 0
                    END IF
                END IF
            END IF
            IF x$ = CHR$(35) THEN togs = _TOGGLEBIT(togs, 14) '                     "#" Rank show
            IF x$ = CHR$(19) THEN Save_Ships
            IF x$ = CHR$(65) OR x$ = CHR$(97) THEN togs = _TOGGLEBIT(togs, 2) '     "A" Azimuth
            IF x$ = CHR$(66) OR x$ = CHR$(98) THEN togs = _TOGGLEBIT(togs, 10) '    "B" belt/ring
            IF x$ = CHR$(68) OR x$ = CHR$(100) THEN togs = _TOGGLEBIT(togs, 9) '    "D" Diameter/Density
            IF x$ = CHR$(69) OR x$ = CHR$(101) THEN Edit_Ship 0 '                   "E" Edit ship
            IF x$ = CHR$(70) OR x$ = CHR$(102) THEN Flight_Plan '                   "F" Flightplan
            IF x$ = CHR$(71) OR x$ = CHR$(103) THEN togs = _TOGGLEBIT(togs, 3) '    "G" Grid
            IF x$ = CHR$(72) OR x$ = CHR$(104) THEN Help '                          "H" Help
            IF x$ = CHR$(73) OR x$ = CHR$(105) THEN '                               "I" Inclinometer
                IF togs AND 8192 THEN togs = _TOGGLEBIT(togs, 5)
            END IF
            IF x$ = CHR$(74) OR x$ = CHR$(106) THEN togs = _TOGGLEBIT(togs, 6) '    "J" Jump zones
            IF x$ = CHR$(79) OR x$ = CHR$(111) THEN togs = _TOGGLEBIT(togs, 7) '    "O" Orbit track
            IF x$ = CHR$(81) OR x$ = CHR$(113) THEN '                               "Q" Autosave & Quit
                TIMER(t1%) OFF: Save_Scenario 0: EXIT SUB '                                                                                                 1
            END IF
            IF x$ = CHR$(82) OR x$ = CHR$(114) THEN togs = _TOGGLEBIT(togs, 4) '    "R" Range
            IF x$ = CHR$(83) OR x$ = CHR$(115) THEN Save_Scenario -1 '              "S" Save scenario dialog
            IF x$ = CHR$(84) OR x$ = CHR$(116) THEN Move_Turn '                     "T" Execute Turn
            IF x$ = CHR$(85) OR x$ = CHR$(117) THEN M_Turn_Undo '                   "U" Undo turn
            IF x$ = CHR$(86) OR x$ = CHR$(118) THEN New_Vector '                    "V" Vector entry (textual)
            IF x$ = CHR$(88) OR x$ = CHR$(120) THEN '                               "X" Zoom Extents
                ZoomFac = 1
                Panel_Blank 560, 660, 64, 32
            END IF
            IF x$ = CHR$(90) OR x$ = CHR$(122) THEN togs = _TOGGLEBIT(togs, 8) '    "Z" Grav zones
            IF x$ = CHR$(0) + CHR$(82) THEN '                                       "Insert" Add ship
                Add_Ship
                Panel_Blank 280, 614, 64, 32
            END IF
            IF x$ = CHR$(0) + CHR$(83) THEN '                                       "Delete" Delete ship
                Delete_Ship
                Panel_Blank 350, 576, 64, 32
            END IF
            IF x$ = CHR$(0) + CHR$(80) THEN '                                       down arrow  20480
                vpoint = vpoint + 1
                IF vpoint > units THEN vpoint = 1: shipoff = 0
                IF units > 6 AND vpoint > 6 THEN shipoff = vpoint - 6
                DO
                    IF cmb(vpoint).status = 0 THEN vpoint = vpoint + 1
                    IF vpoint > units THEN vpoint = 1
                LOOP UNTIL cmb(vpoint).status > 0
            END IF
            IF x$ = CHR$(0) + CHR$(72) THEN '                                       up arrow  18432
                vpoint = vpoint - 1
                IF vpoint < 1 THEN vpoint = units: shipoff = units - 6
                IF units > 6 AND vpoint <= shipoff THEN shipoff = vpoint - 1
                DO
                    IF cmb(vpoint).status = 0 THEN vpoint = vpoint - 1
                    IF vpoint < 1 THEN vpoint = units
                LOOP UNTIL cmb(vpoint).status > 0
            END IF
            _KEYCLEAR
            IF NOT in THEN Ori_Screen vpoint '                  keep up with ori-screen animation while waiting for inputs
            _DISPLAY
            _LIMIT 30
        LOOP UNTIL in '                                         Wait until an input is received
        in = 0
        Re_Calc '                                               update coordinates and sensor states
        Refresh '                                               Do screen and computation updates after input
        _LIMIT 30
    LOOP

END SUB 'Main_Loop


'±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
FUNCTION map! (value!, minRange!, maxRange!, newMinRange!, newMaxRange!)

    'called from: various
    map! = ((value! - minRange!) / (maxRange! - minRange!)) * (newMaxRange! - newMinRange!) + newMinRange!

END FUNCTION 'map!


'±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
FUNCTION map64&& (value!, minRange!, maxRange!, newMinRange&&, newMaxRange&&)

    map64&& = ((value! - minRange!) / (maxRange! - minRange!)) * (newMaxRange&& - newMinRange&&) + newMinRange&&

END FUNCTION 'map64&&


'±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
FUNCTION MBS% 'Mouse Button Status  by Steve McNeill
    STATIC StartTimer AS _FLOAT
    STATIC ButtonDown AS INTEGER
    'STATIC ClickCount AS INTEGER
    CONST ClickLimit## = .4 'Less than 1/2 of a second to down, up a key to count as a CLICK.
    '                          Down longer counts as a HOLD event.
    SHARED Mouse_StartX, Mouse_StartY, Mouse_EndX, Mouse_EndY
    WHILE _MOUSEINPUT 'Remark out this block, if mouse main input/clear is going to be handled manually in main program.
        SELECT CASE SGN(_MOUSEWHEEL)
            CASE 1: MBS = MBS OR 512
            CASE -1: MBS = MBS OR 1024
        END SELECT
    WEND

    IF _MOUSEBUTTON(1) THEN MBS = MBS OR 1
    IF _MOUSEBUTTON(2) THEN MBS = MBS OR 2
    IF _MOUSEBUTTON(3) THEN MBS = MBS OR 4

    IF StartTimer = 0 THEN
        IF _MOUSEBUTTON(1) THEN 'If a button is pressed, start the timer to see what it does (click or hold)
            ButtonDown = 1: StartTimer = TIMER(0.01)
            Mouse_StartX = _MOUSEX: Mouse_StartY = _MOUSEY
        ELSEIF _MOUSEBUTTON(2) THEN
            ButtonDown = 2: StartTimer = TIMER(0.01)
            Mouse_StartX = _MOUSEX: Mouse_StartY = _MOUSEY
        ELSEIF _MOUSEBUTTON(3) THEN
            ButtonDown = 3: StartTimer = TIMER(0.01)
            Mouse_StartX = _MOUSEX: Mouse_StartY = _MOUSEY
        END IF
    ELSE
        BD = ButtonDown MOD 3
        IF BD = 0 THEN BD = 3
        IF TIMER(0.01) - StartTimer <= ClickLimit THEN 'Button was down, then up, within time limit.  It's a click
            IF _MOUSEBUTTON(BD) = 0 THEN MBS = 4 * 2 ^ ButtonDown: ButtonDown = 0: StartTimer = 0
        ELSE
            IF _MOUSEBUTTON(BD) = 0 THEN 'hold event has now ended
                MBS = 0: ButtonDown = 0: StartTimer = 0
                Mouse_EndX = _MOUSEX: Mouse_EndY = _MOUSEY
            ELSE 'We've now started the hold event
                MBS = MBS OR 32 * 2 ^ ButtonDown
            END IF
        END IF
    END IF
END FUNCTION 'MBS%


'±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
SUB Mouse_Button_Left (xpos AS INTEGER, ypos AS INTEGER)

    'called from: Main_Loop
    SELECT CASE xpos
        CASE 0 TO 559 '                                         ÛÛÛLeft text displayÛÛÛ
            SELECT CASE ypos '                                  Divide left into top and bottom
                CASE 0 TO 575
                    SELECT CASE xpos '                          Divide upper left into ship and center display
                        CASE 0 TO 287
                            y = INT(ypos / 96) + 1 + shipoff '  unit # range - modify by shipoff for proper unit
                            IF y <= units THEN
                                IF cmb(y).status <> 0 THEN '    unit not destroyed
                                    ln% = (INT(ypos / 16) + 1) MOD 6 'line position
                                    SELECT CASE ln%
                                        CASE IS = 1 '           transponder icon
                                            IF xpos > 240 AND xpos < 273 THEN
                                                Sensor(y, y) = _TOGGLEBIT(Sensor(y, y), 4) 'toggle transponder of y
                                            ELSE
                                                vpoint = y
                                            END IF
                                        CASE IS = 5 '           automove buttons
                                            IF y = vpoint THEN 'Flightplan or Cancel
                                                IF cmb(vpoint).bstat = 5 THEN
                                                    IF xpos < 40 THEN cmb(vpoint).bstat = 0: cmb(vpoint).bogey = 0
                                                ELSE
                                                    IF xpos < 80 THEN Flight_Plan
                                                END IF
                                            ELSE '              Evade/Intercept/Fleet or Cancel
                                                IF y = cmb(vpoint).bogey THEN ' Cancel was clicked?
                                                    SELECT CASE xpos
                                                        CASE IS < 48
                                                            cmb(vpoint).bogey = 0: cmb(vpoint).bstat = 0 'unit no longer a solution target
                                                        CASE 48 TO 272
                                                            vpoint = y
                                                        CASE IS > 272
                                                            GOSUB targetlock
                                                    END SELECT
                                                ELSE '          Evade/Intercept/Fleet
                                                    SELECT CASE xpos
                                                        CASE 0 TO 39 'Evade
                                                            IF cmb(vpoint).status = 2 THEN
                                                                vpoint = y
                                                            ELSE
                                                                cmb(vpoint).bogey = y: cmb(vpoint).bstat = 1
                                                            END IF
                                                        CASE 49 TO 120 'Intercept
                                                            IF cmb(vpoint).status = 2 THEN 'must launch before intercept order
                                                                vpoint = y
                                                            ELSE
                                                                cmb(vpoint).bogey = y: cmb(vpoint).bstat = 2
                                                            END IF
                                                        CASE 130 TO 168 'Fleet
                                                            IF cmb(y).bstat = 5 THEN 'break formation
                                                                cmb(y).bstat = 0: cmb(y).bogey = 0
                                                            ELSE '                  join fleet maneuvers
                                                                IF cmb(y).status <> 2 THEN 'can't fleet with a landed unit
                                                                    IF NOT Sensor(vpoint, y) AND 1 THEN 'exclude units that are occluded
                                                                        cmb(y).bstat = 5: cmb(y).bogey = vpoint 'fleet y to active
                                                                    ELSE
                                                                        vpoint = y 'but switch to the occluded unit
                                                                    END IF
                                                                ELSE
                                                                    vpoint = y 'make the landed unit active
                                                                END IF
                                                            END IF
                                                        CASE 169 TO 272
                                                            vpoint = y
                                                        CASE IS > 272 'target lock icon
                                                            GOSUB targetlock
                                                    END SELECT 'end: x position within line 5 test
                                                END IF '        end: unit a target of automoves test
                                            END IF '            end: vpoint test
                                        CASE ELSE
                                            vpoint = y
                                    END SELECT '                end: line position case
                                END IF '                        end: destroyed test
                            END IF '                            end: click within unit field test

                            'center display
                        CASE 288 TO 559
                            SELECT CASE ypos
                                CASE 0 TO 324 '                 Planet distance screen area
                                    'Left click for planet info dialog
                                    Clear_MB 1
                                    Planet_Info Choose_World%("Planet Information", 0)
                                    'Planet_Info pli%
                                CASE 325 TO 573
                                    'Ori_Screen area
                            END SELECT
                    END SELECT
                CASE 576 TO 608
                    ' buttons tier 1
                    SELECT CASE xpos
                        CASE 0 TO 63 '                          Input a graphic vector order
                            New_Vector_Graph
                        CASE 70 TO 133 '                        ²²²TO BE DETERMINED²²²
                            Panel_Blank 70, 576, 64, 32
                            Coming
                        CASE 140 TO 203 '                       ²²²TO BE DETERMINED²²²
                            Panel_Blank 140, 576, 64, 32
                            Coming
                        CASE 210 TO 273 '                       Execute a game turn
                            Move_Turn
                        CASE 280 TO 343 '                       Edit a vessels details
                            Edit_Ship 0
                        CASE 350 TO 413 '                       Delete a vessel
                            Panel_Blank 350, 576, 64, 32
                            Delete_Ship
                        CASE 420 TO 483 '                       Load a scenario
                            Panel_Blank 420, 576, 64, 32
                            Load_Scenario
                        CASE 490 TO 553 '                       Save a scenario
                            Panel_Blank 490, 576, 64, 32
                            TIMER(t1%) OFF '                    Close autosave while saving
                            Save_Scenario -1
                            TIMER(t1%) ON '                     Restart autosave when done
                    END SELECT
                    ' buttons tier 2
                CASE 614 TO 646
                    SELECT CASE xpos
                        CASE 0 TO 63 '                          Cut thrust
                            IF cmb(vpoint).bstat <> 5 THEN
                                Panel_Blank 0, 614, 64, 32
                                Con_Blok 0, 614, 64, 32, "Thrust 0", 0, &H502C9B2C
                                _DISPLAY: _DELAY .5
                                Thrust(vpoint).Gs = 0
                                cmb(vpoint).bstat = 0: cmb(vpoint).bogey = 0
                            END IF
                        CASE 70 TO 133 '                        Transponder of active on/off
                            Sensor(vpoint, vpoint) = _TOGGLEBIT(Sensor(vpoint, vpoint), 4)
                        CASE 140 TO 203 '                       Active unit info display
                            Clear_MB 1
                            Panel_Blank 140, 614, 64, 32
                            Info vpoint
                        CASE 210 TO 273 '                       Undo a game turn
                            M_Turn_Undo
                        CASE 280 TO 343 '                       Add a vessel
                            Panel_Blank 280, 614, 64, 32
                            Add_Ship
                        CASE 350 TO 413 '                       Remove wrecked vessels
                            Panel_Blank 350, 614, 64, 32
                            Purge
                        CASE 420 TO 483 '                       Load a star system
                            Panel_Blank 420, 614, 64, 32
                            Load_System
                        CASE 490 TO 553 '                       Save a star system
                            Panel_Blank 490, 614, 64, 32
                            Save_System
                    END SELECT
                    ' buttons tier 3
                CASE 650 TO 682
                    SELECT CASE xpos
                        CASE 0 TO 63 '                          Apply braking thrust
                            Vector_Brake
                        CASE 70 TO 133 '                        Options menu
                            Panel_Blank 70, 650, 64, 32
                            Options
                        CASE 140 TO 203 '                       Collision Check toggle
                            togs = _TOGGLEBIT(togs, 12)
                        CASE 210 TO 273 '                       Help display
                            Panel_Blank 210, 650, 64, 32
                            Help
                        CASE 280 TO 343 '                       Move single or vessel group
                            togs = _TOGGLEBIT(togs, 11)
                        CASE 350 TO 413 '                       Disable/Repair
                            IF cmb(vpoint).status = 3 THEN
                                cmb(vpoint).status = 1
                                Edit_Ship 1
                            ELSE
                                Thrust(vpoint).Gs = 0
                                cmb(vpoint).MaxG = 0
                                cmb(vpoint).status = 3
                            END IF
                        CASE 420 TO 483 '                       Load vessel group
                            Panel_Blank 420, 650, 64, 32
                            Load_Ships
                        CASE 490 TO 553 '                       Save vessel group
                            Panel_Blank 490, 650, 64, 32
                            Save_Ships
                    END SELECT
            END SELECT
        CASE 560 TO 1179 '                                      Right graphics screen
            SELECT CASE ypos
                CASE 19 TO 639
                    ' find relative sensor screen coordinates of mouse left click
                    DIM clk AS V3
                    q! = Prop!: prox = vpoint '                 get proportion & set proximity unit as active
                    clk.pX = map!(xpos, 560, 1179, -1000, 1000) / q!
                    clk.pY = map!(ypos, 19, 639, 1000, -1000) / q!
                    FOR a = 1 TO units
                        IF a = vpoint THEN _CONTINUE '           skip if active unit
                        IF PyT(2, clk, dcs(a)) < PyT(2, clk, dcs(vpoint)) THEN 'if click is closer to 'a' than active
                            IF PyT(2, clk, dcs(a)) < PyT(2, clk, dcs(prox)) THEN 'if click is closer to 'a' than any other 'a' tested
                                prox = a '                      set proximity unit
                            END IF
                        END IF
                    NEXT a
                    shipoff = -(prox - 6) * (prox > 6)
                    vpoint = prox '                             set active to closest proximity unit
                    '    'vvv remove the following if it doesn't work well or become too complex
                    'CASE 640 TO 659 '                           an azimuth slider here ???
                    '    SELECT CASE xpos
                    '        CASE 560 TO 869 'LEFT HALF
                    '            togs = _SETBIT(togs, 1)
                    '            xangle = map!(xpos, 560, 869, -_PI / 2, 0)
                    '            _PRINTSTRING (300, 560), STR$(xangle), A&
                    '        CASE 870 TO 889 'CENTER
                    '            togs = _RESETBIT(togs, 1)
                    '            xangle = 0
                    '        CASE 890 TO 1179 'RIGHT HALF
                    '            togs = _SETBIT(togs, 1)
                    '            xangle = map!(xpos, 890, 1179, 0, _PI / 2)
                    '            _PRINTSTRING (300, 560), STR$(xangle), A&
                    '    END SELECT
                    '    'remove to here
                CASE 660 TO 691 '                               get bottom button bar clicks
                    SELECT CASE xpos
                        CASE 560 TO 623
                            ZoomFac = 1 '                       Zoom to extents
                            Panel_Blank 560, 660, 64, 32
                        CASE 626 TO 689
                            ZoomFac = ZoomFac / .5 '            Zoom in
                            Panel_Blank 626, 660, 64, 32
                        CASE 692 TO 755
                            ZoomFac = ZoomFac * .5 '            Zoom out
                            Panel_Blank 692, 660, 64, 32
                        CASE 762 TO 817
                            togs = _TOGGLEBIT(togs, 4) '        Range toggle
                        CASE 820 TO 875
                            togs = _TOGGLEBIT(togs, 7) '        Orbit toggle
                        CASE 878 TO 925
                            togs = _TOGGLEBIT(togs, 3) '        Grid toggle
                        CASE 928 TO 967
                            togs = _TOGGLEBIT(togs, 2) '        Azimuth wheel toggle
                        CASE 970 TO 1009
                            IF togs AND 8192 THEN
                                togs = _TOGGLEBIT(togs, 5) '    Inclinometer toggle
                            END IF
                        CASE 1012 TO 1059
                            togs = _TOGGLEBIT(togs, 6) '        Jump zone toggle
                        CASE 1062 TO 1109
                            IF togs AND 64 THEN '               if jump zone then
                                togs = _TOGGLEBIT(togs, 9) '    Diameter/Density toggle
                            END IF
                        CASE 1132 TO 1179
                            TIMER(t1%) OFF
                            Save_Scenario 0: Terminus: SYSTEM
                    END SELECT
            END SELECT
        CASE 1204 TO 1244 '                                     Z-pan slider
            IF togs AND 8192 THEN '                             if in 3D mode
                SELECT CASE ypos
                    CASE 4 TO 321 '                             upper half of Z-panner
                        togs = _SETBIT(togs, 1)
                        zangle = map!(ypos, 321, 4, 0, -_PI / 2)
                    CASE 322 TO 337 '                           0ø overhead block
                        togs = _RESETBIT(togs, 1)
                        zangle = 0
                    CASE 338 TO 653 '                           lower half of Z-panner
                        togs = _SETBIT(togs, 1)
                        zangle = map!(ypos, 338, 653, 0, _PI / 2)
                    CASE 660 TO 691 '                           switch toggle
                        WHILE _MOUSEINPUT: WEND
                        togs = _TOGGLEBIT(togs, 1)
                        IF togs AND 2 THEN
                            zangle = Ozang
                        ELSE
                            Ozang = zangle: zangle = 0
                        END IF
                END SELECT
            END IF
    END SELECT '                                                end xpos case
    EXIT SUB

    targetlock:
    IF Sensor(vpoint, y) AND 2 THEN
        Sensor(vpoint, y) = _RESETBIT(Sensor(vpoint, y), 1) 'sever t-lock
    ELSE
        IF cmb(vpoint).mil THEN b&& = SenLocM ELSE b&& = SenLocC 'military/civilian sensor range
        IF Sensor(y, y) AND 16 THEN b&& = b&& ELSE b&& = b&& / 2
        IF PyT(3, origin, rcs(y)) < b&& THEN
            Sensor(vpoint, y) = _SETBIT(Sensor(vpoint, y), 1) 'establish t-lock
        END IF
    END IF
    RETURN

END SUB 'Mouse_Button_Left


'±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
SUB Mouse_Button_Right (xpos AS INTEGER, ypos AS INTEGER)

    'called from: Main_Loop
    SELECT CASE xpos
        CASE 0 TO 559 '                                         Left graphics screen
            'Right click mouse ops here if any are added
            SELECT CASE ypos
                CASE 0 TO 575
                    SELECT CASE xpos
                        CASE 0 TO 287 '                         ship data fields
                            y = INT(ypos / 96) + 1 + shipoff '  unit # range - modify by shipoff for proper unit
                            IF y <= units THEN
                                Panel_Blank 140, 614, 64, 32
                                Info y
                            END IF
                        CASE 288 TO 559 '                       center displays
                    END SELECT
                CASE 576 TO 608
                    'button block
            END SELECT
        CASE 560 TO 1199 '                                      Right graphics screen
            SELECT CASE ypos
                CASE 19 TO 639
                    'Moves active ship, on right click, to new, tilt plane defined, coordinates on the screen.
                    'moves all units as a group if MovAll button enabled, i.e. if (togs,11) aka AND 2048 = TRUE
                    DIM shipstart AS V3
                    DIM temp AS V3
                    ' find relative sensor screen coordinates of mouse click
                    WindowMouseX = map!(xpos, 560, 1179, -1000, 1000)
                    WindowMouseY = map!(ypos, 19, 639, 1000, -1000)
                    'WindowMouseX & Y both divided by results of Prop! give .Abs offsets from active position
                    q! = Prop!
                    IF cmb(vpoint).status = 2 THEN cmb(vpoint).status = 1: cmb(vpoint).bogey = 0
                    shipstart = cmb(vpoint).ap '                save initial point
                    cmb(vpoint).ap.pX = WindowMouseX / q! + cmb(vpoint).ap.pX ' x-axis stays the same at all times
                    cmb(vpoint).ap.pY = (WindowMouseY * COS(-zangle)) / q! + cmb(vpoint).ap.pY 'transform Y
                    cmb(vpoint).ap.pZ = (WindowMouseY * -SIN(-zangle)) / q! + cmb(vpoint).ap.pZ 'transform Z
                    temp = cmb(vpoint).ap: Vec_Add temp, shipstart, -1 'temp now has move displacement

                    'Do we need to recalculate bdata if the moved ship has AI nav orders  ???

                    IF togs AND 2048 THEN '                     if MovAll enabled
                        Vec_Add cmb(vpoint).op, temp, 1 '        move active unit
                        FOR x = 1 TO units '                    move others relative to active move
                            IF x = vpoint THEN _CONTINUE
                            IF cmb(x).status = 2 THEN _CONTINUE 'don't move non active, landed vessels
                            IF cmb(x).status = 0 THEN _CONTINUE 'ghosts don't ride a group move, Purge those devils, damn it!
                            Vec_Add cmb(x).ap, temp, 1
                            Vec_Add cmb(x).op, temp, 1
                        NEXT x
                    ELSE '                                      else move only active unit
                        Vec_Add cmb(vpoint).op, temp, 1
                    END IF

                    q2! = Prop!
                    ZoomFac = ZoomFac * (q! / q2!) '            reset zoom factor to new limits
                    Refresh
            END SELECT
    END SELECT

END SUB 'Mouse_Button_Right


'±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
SUB Move_Turn

    'called from: Main_Loop, Mouse_Button_Left
    'Apply all unit movements
    Turncount = Turncount + 1
    Turn_2_Clock Turncount
    IF units > 0 THEN
        c = 1: d = 1
        DO '                                                    iterate all units
            IF cmb(c).status > 0 THEN '                         if unit destroyed skip the computations
                IF cmb(c).bstat > 0 THEN '                      execute automated orders if present
                    Auto_Move cmb(c).bogey, c, cmb(c).bstat
                END IF
                IF cmb(c).status <> 2 THEN '                    landed units handled in Planet_Move
                    Coord_Update c '                            Update unit position
                    cmb(c).Ostat = cmb(c).status '              move previous turn info to undo info
                    cmb(c).OSp = cmb(c).Sp
                    cmb(c).OHd = cmb(c).Hd
                    cmb(c).OIn = cmb(c).In
                    IF cmb(c).status <> 4 THEN '                launching ships prone to collision true so skip if launching
                        IF cmb(c).bstat <> 3 THEN '             landing ships shouldn't crash either
                            IF togs AND 4096 THEN Col_Check c ' check for collision with star/planet when enabled
                        END IF
                    END IF
                    IF cmb(c).status = 4 THEN cmb(c).status = 1 'complete launch sequence after skipping col_check once
                    cmb(c).Sp = PyT(3, cmb(c).op, cmb(c).ap) '  Update speed and heading information
                    cmb(c).Hd = Azimuth!(cmb(c).ap.pX - cmb(c).op.pX, cmb(c).ap.pY - cmb(c).op.pY)
                    cmb(c).In = Slope!(cmb(c).ap, cmb(c).op)
                END IF
            END IF '                                            end: skip destroyed test
            c = c + 1
        LOOP UNTIL c = units + 1
        DO '                                                    reiterate after all have moved
            Col_Check_Ship d '                                  check if any were in proximity
            d = d + 1
        LOOP UNTIL d = units + 1
    END IF
    Planet_Move 1 '                                              move planets forward
    togs = _RESETBIT(togs, 0) '                                  clear turn undo flag
    Panel_Blank 210, 578, 64, 32
    Con_Blok 210, 578, 64, 32, "Applied", 0, &H502C9B2C
    _DISPLAY
    _DELAY .2

END SUB 'Move_Turn


'±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
SUB M_Turn_Undo

    'called from: Main_Loop, Mouse_Button_Left
    IF togs AND 1 THEN
        'put "cannot undo" message here, if desired. Otherwise just disallow second consecutive undo
    ELSE
        Planet_Move -1 '                                         back peddle the planets
        Turncount = Turncount - 1
        Turn_2_Clock Turncount
        IF units > 0 THEN
            DIM m AS _MEM '                                      move old ship data block back to current data block
            m = _MEM(cmb())
            c = 1
            DO
                _MEMCOPY m, m.OFFSET + c * m.ELEMENTSIZE + 15, 37 TO m, m.OFFSET + c * m.ELEMENTSIZE + 52
                c = c + 1
            LOOP UNTIL c = units + 1
            _MEMFREE m
        END IF

        togs = _SETBIT(togs, 0) '                                set turn undo flag
        Panel_Blank 210, 614, 64, 32
        Con_Blok 210, 614, 64, 32, "Undone", 0, &H502C9B2C
        _DISPLAY
        _DELAY .2
    END IF

END SUB 'M_Turn_Undo


'±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
SUB New_Vector

    'called from: Main_Loop
    'Text based vector input
    IF cmb(vpoint).bstat = 5 THEN
        'must break formation before maneuvers
    ELSE
        IF cmb(vpoint).status = 2 THEN '                        take off from landing algorithm here
            DIM pvec AS V3
            Get_Body_Vec cmb(vpoint).bogey, pvec
            cmb(vpoint).status = 4
            cmb(vpoint).bogey = 0: cmb(vpoint).Ostat = 2 '      no Obogey puts us in limbo for a turn undo
            cmb(vpoint).Sp = PyT(2, origin, pvec) '             impart planet vector to launching vessel
            cmb(vpoint).Hd = Azimuth!(pvec.pX, pvec.pY)
            cmb(vpoint).In = 0
        END IF
        cmb(vpoint).bstat = 0: cmb(vpoint).bogey = 0 '          taking back control from AI
        Dialog_Box "ENTER NEW VECTOR", 400, 250, 50, &HFF2C9B2C, clr&(15)
        LOCATE 8, 56
        PRINT "c= counterthrust"
        LOCATE 9, 56
        INPUT "New Azimuth (Yaw):"; x$
        IF x$ = "c" OR x$ = "C" THEN
            Vector_Brake
        ELSE
            Thrust(vpoint).Azi = _D2R(VAL(x$))
            IF togs AND 8192 THEN
                LOCATE 10, 56
                INPUT "New Inclination (Pitch):"; I$ '
                Thrust(vpoint).Inc = _D2R(VAL(I$))
            ELSE
                LOCATE 10, 56
                PRINT "Inclination=0"
                Thrust(vpoint).Inc = 0
            END IF
            LOCATE 11, 56
            INPUT "New Acceleration:"; Thrust(vpoint).Gs
            IF Thrust(vpoint).Gs > cmb(vpoint).MaxG THEN
                LOCATE 12, 56
                PRINT "Confirm overdrive"
                _DISPLAY
                SLEEP 1
            END IF
        END IF
    END IF

END SUB 'New_Vector


'±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
SUB New_Vector_Graph

    'called from: Mouse_Button_Left
    IF cmb(vpoint).bstat = 5 OR cmb(vpoint).status = 3 THEN
        'must break formation before maneuvers
    ELSE
        IF cmb(vpoint).status = 2 THEN '                        take off from landing algorithm here
            DIM pvec AS V3
            'DIM rvec AS V3
            Get_Body_Vec cmb(vpoint).bogey, pvec '              vector of launch point body
            cmb(vpoint).status = 4 '                            status to launching
            cmb(vpoint).bogey = 0: cmb(vpoint).Ostat = 2 '      no Obogey puts us in limbo for a turn undo
            cmb(vpoint).Sp = PyT(2, origin, pvec) '             impart planet vector to launching vessel
            cmb(vpoint).Hd = Azimuth!(pvec.pX, pvec.pY)
            cmb(vpoint).In = 0
        END IF
        togsave% = togs '                                       save working state
        zangsave = zangle
        Panel_Blank 0, 578, 64, 32 '                             dim vector button
        _DISPLAY

        togs = _RESETBIT(togs, 1) '                              reset back to overhead view
        zangle = 0
        Re_Calc
        Refresh

        'Conduct graphic based vector input
        SST& = _NEWIMAGE(620, 620, 32) '                         Vector input overlay
        _DEST SST&
        VIEW (0, 0)-(619, 619), clr&(0), clr&(3) '              set graphics port full image SST& w/box
        WINDOW (-1000, 1000)-(1000, -1000) '                    set relative cartesian coords

        DIM mosX: DIM mosY
        cmb(vpoint).bstat = 0: cmb(vpoint).bogey = 0 '          taking back control from AI

        DO
            _LIMIT 60
            CLS
            ms = MBS
            _CLEARCOLOR _RGBA(0, 0, 0, 0)
            Azimuth_Wheel
            FOR x = 200 TO 800 STEP 200
                CIRCLE (0, 0), x, clr&(4) '                     Draw thrust percentage circle
                COLOR clr&(4)
                _PRINTMODE _KEEPBACKGROUND
                _PRINTSTRING (310 + (x / 200) * 62, 294), STR$((x / 800) * cmb(vpoint).MaxG) + "Gs", SST&
            NEXT x

            mosX = map!(_MOUSEX, 560, 1180, -1000, 1000)
            mosY = map!(_MOUSEY, 18, 638, 1000, -1000)
            az = Azimuth!(mosX, mosY)
            ds = _HYPOT(mosX, mosY)
            IF ABS(mosX) < 1000 AND ABS(mosY) < 1000 THEN '     If mouse is in window then draw vector rays
                LINE (0, 0)-(1000 * SIN(az), 1000 * COS(az)), clr&(4) ' direction ray
                LINE (0, 0)-(mosX, mosY), clr&(14) '                    thrust ray
                _PRINTSTRING (3, 3), "Azi. " + STR$(_ROUND(_R2D(az) * 100) / 100) + CHR$(248), SST& 'Echo info in top left corner
                _PRINTSTRING (3, 21), "Acceleration " + STR$(INT((ds * cmb(vpoint).MaxG / 800) * 100) / 100) + " Gs", SST&
            END IF
            IF ms AND 1 THEN
                Thrust(vpoint).Azi = az '                       Set azimuth heading
                Thrust(vpoint).Gs = ds * cmb(vpoint).MaxG / 800 'Apply percentage of 800 radius circle as thrust
                IF Thrust(vpoint).Gs > cmb(vpoint).MaxG * 1.25 THEN Thrust(vpoint).Gs = cmb(vpoint).MaxG * 1.25
                Clear_MB 1
                IF togs AND 8192 THEN '                         2D exclusion here
                    DIM mosZ
                    togs = _SETBIT(togs, 1) '                   set 3D mode
                    togs = _SETBIT(togs, 5) '                   show inclinometer
                    togs = _RESETBIT(togs, 7) '                 don't show orbit tracks
                    zangle = _PI / 2 '                          display angle 90ø
                    Re_Calc
                    Refresh
                    _PUTIMAGE (560, 18), SS&, A&
                    _DEST SST&
                    _DISPLAY
                    DO '                                        Inclination loop
                        _LIMIT 60
                        CLS
                        ms1 = MBS
                        _CLEARCOLOR _RGBA(0, 0, 0, 0)
                        FCirc 0, 0, 100, &H3000FF00 '           display 0ø inclination green zone
                        mosX = map!(_MOUSEX, 560, 1180, -1000, 1000)
                        mosZ = map!(_MOUSEY, 18, 638, 1000, -1000)
                        az = Azimuth!(ABS(mosX), mosZ)
                        azd = Azimuth!(mosX, mosZ)
                        COLOR _RGBA32(127, 127, 127, 255)
                        IF _HYPOT(mosX, mosZ) > 100 THEN
                            LINE (0, 0)-(1000 * SIN(azd), 1000 * COS(azd)), clr&(4)
                            _PRINTSTRING (3, 21), "Inclination= " + STR$(_ROUND((_R2D(az - 1.570796)) * -100) / 100) + CHR$(248), SST&
                        ELSE
                            _PRINTSTRING (3, 21), "Inclination= 0" + CHR$(248), SST&
                        END IF
                        _PRINTSTRING (3, 37), "click center green for 0" + CHR$(248), SST&
                        IF ms1 AND 1 THEN
                            IF _HYPOT(mosX, mosZ) < 100 THEN '  Click is in green zone- no inclination
                                Thrust(vpoint).Inc = 0
                            ELSE
                                Thrust(vpoint).Inc = (az - 1.570796) * -1 'Set inclination
                            END IF
                            EXIT DO
                        END IF
                        _PUTIMAGE (560, 18), SS&, A& '          Erase previous rays
                        _PUTIMAGE (560, 18), SST&, A& '         draw new ray
                        _DISPLAY
                    LOOP
                END IF '                                        end 2D exlusion
                EXIT DO
            END IF
            _PUTIMAGE (560, 18), SS&, A& '                       Erase previous rays
            _PUTIMAGE (560, 18), SST&, A& '                      draw new ray
            _DISPLAY
        LOOP
        togs = togsave% '                                       replace working state
        zangle = zangsave
        _PUTIMAGE (560, 18), SS&, A& '                           return to normal
        Re_Calc
        Refresh
        _DISPLAY
        _FREEIMAGE SST&
        Clear_MB 1
    END IF

END SUB 'New_Vector_Graph


'±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
SUB Off_Button (var AS LONG, xpos AS INTEGER, ypos AS INTEGER)

    'called from: Button_Block
    'Darkens controls that are turned off
    t& = _NEWIMAGE(_WIDTH(var), _HEIGHT(var), 32)
    _DEST t&
    CLS , &H7F000000
    _PUTIMAGE (xpos, ypos), t&, 0
    _DEST 0
    _FREEIMAGE t&

END SUB 'Off_Button


'±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
SUB Options

    'UNDER CONSTRUCTION
    'called from: Mouse_Button_Left
    STATIC mil AS _BYTE
    radar = 0
    DO
        radar = radar + _PI / 60
        CLS
        Dialog_Box "OPTIONS", 1200, 650, 25, &HFF4CCB9C, clr&(15) '"OPTIONS" center justified @ y=56

        _PRINTSTRING (75, 82), "Display Toggles"
        IF togs AND 256 THEN c& = &HFF00B100: c$ = "ON" ELSE c& = &HFF4F4F4F: c$ = "OFF"
        Con_Blok 75, 100, 48, 24, c$, 0, c&
        _PRINTSTRING (125, 104), "Grav Zone Toggle [Z]"
        IF togs AND 1024 THEN c& = &HFF00B100: c$ = "ON" ELSE c& = &HFF4F4F4F: c$ = "OFF"
        Con_Blok 75, 130, 48, 24, c$, 0, c&
        _PRINTSTRING (125, 134), "Belt/Ring Toggle [B]"
        'Range alter
        _PRINTSTRING (75, 164), "Gunnery Ranges"
        IF mil THEN
            Con_Blok 195, 164, 48, 16, "mil", 0, &HFF00FF00
            tl& = SenLocM
        ELSE
            Con_Blok 195, 164, 48, 16, "civ", 0, &HFF0000FF
            tl& = SenLocC
        END IF
        FOR x = 0 TO 90 STEP 30
            Con_Blok 75, 180 + x, 24, 24, "-", 0, &HFF00B100
            Con_Blok 105, 180 + x, 24, 24, "/", 0, &HFF00B100
            Con_Blok 135, 180 + x, 24, 24, "+", 0, &HFF00B100
        NEXT x
        _PRINTSTRING (165, 184), "Target lock =" + STR$(tl&) '  contact lock range
        _PRINTSTRING (165, 214), "Contact lost=" + STR$(SenMax) 'contact lost range
        _PRINTSTRING (165, 244), "Close Range =" + STR$(RngCls) 'close range
        _PRINTSTRING (165, 274), "Medium Range=" + STR$(RngMed) 'medium range

        Con_Blok 75, 610, 144, 48, "Save as Default", 0, &HFF00FF00
        Con_Blok 1135, 610, 60, 48, "Exit", 0, &HFF7F107F

        '
        '
        Op& = _NEWIMAGE(500, 500, 32) '                         create visual example screen
        'Opa& = _COPYIMAGE(Op&)
        xf = 250
        _DEST Op&
        CLS
        LINE (0, 0)-(499, 499), &HFF0000FF, B 'bounding box
        LINE (0, 249)-(499, 249), &H2F00FF00 'east/west line
        LINE (249, 0)-(249, 499), &H2F00FF00 'north/south line
        LINE (xf, xf)-(205 * SIN(radar) + xf, 205 * COS(radar) + xf)
        FOR cc% = 50 TO 200 STEP 50
            CIRCLE (249, 249), cc%, &H1F00FF00
        NEXT cc%
        FOR azw = _PI / 8 TO _PI * 2 STEP _PI / 8
            LINE (48 * SIN(azw) + xf, 48 * COS(azw) + xf)-(52 * SIN(azw) + xf, 52 * COS(azw) + xf), &H1F00FF00
            LINE (97 * SIN(azw) + xf, 97 * COS(azw) + xf)-(103 * SIN(azw) + xf, 103 * COS(azw) + xf), &H1F00FF00
            LINE (146 * SIN(azw) + xf, 146 * COS(azw) + xf)-(154 * SIN(azw) + xf, 154 * COS(azw) + xf), &H1F00FF00
            LINE (195 * SIN(azw) + xf, 195 * COS(azw) + xf)-(205 * SIN(azw) + xf, 205 * COS(azw) + xf), &H1F00FF00
        NEXT azw
        q! = 220 / SenMax
        FCirc 450000 * q! + xf, 450000 * q! + xf, 50000 * q!, &HFF347474
        IF togs AND 256 THEN '                                  draw gravity zones on example
            CIRCLE (450000 * q! + xf, 450000 * q! + xf), 70000 * q!, _RGBA(0, 255, 0, 50)
            CIRCLE (450000 * q! + xf, 450000 * q! + xf), 100000 * q!, _RGBA(0, 255, 0, 50)
        END IF
        IF togs AND 1024 THEN '                                 draw ring system
            FOR x = 1 TO 20
                CIRCLE (450000 * q! + xf, 450000 * q! + xf), 120000 * q! + x, &H157F7F7F
            NEXT x
        END IF
        'draw range bands
        CIRCLE (xf, xf), SenMax * q!, &HFFFF0000 '              Target lost circle
        IF mil THEN '                                           Sensor lock circle
            CIRCLE (xf, xf), SenLocM * q!, &HB0545454
        ELSE
            CIRCLE (xf, xf), SenLocC * q!, &HB0545454
        END IF
        FCirc xf, xf, RngMed * q!, _RGBA(252, 252, 84, 15) '     Medium range band
        FCirc xf, xf, RngCls * q!, _RGBA(252, 84, 84, 30) '     Short range band
        _DEST A&
        _PUTIMAGE (660, 90), Op&, A&
        _FREEIMAGE Op& ': _FREEIMAGE Opa&

        'KEY/MOUSE OPS
        K$ = INKEY$
        IF K$ = CHR$(66) OR K$ = CHR$(98) THEN togs = _TOGGLEBIT(togs, 10) '    "B" belt/ring
        IF K$ = CHR$(90) OR K$ = CHR$(122) THEN togs = _TOGGLEBIT(togs, 8) '    "Z" Grav zones
        ms = MBS
        IF ms AND 1 THEN
            _DELAY .2
            SELECT CASE _MOUSEY
                CASE 100 TO 124
                    IF _MOUSEX > 75 AND _MOUSEX < 123 THEN togs = _TOGGLEBIT(togs, 8)
                CASE 130 TO 154
                    IF _MOUSEX > 75 AND _MOUSEX < 123 THEN togs = _TOGGLEBIT(togs, 10)
                CASE 164 TO 180
                    IF _MOUSEX > 194 AND _MOUSEX < 243 THEN mil = NOT mil
                CASE 180 TO 204 'target acquire
                    rng_id% = 1: GOSUB range_picks
                CASE 210 TO 234 'target lose
                    rng_id% = 2: GOSUB range_picks
                CASE 240 TO 264 'close range
                    rng_id% = 3: GOSUB range_picks
                CASE 270 TO 294 'medium range
                    rng_id% = 4: GOSUB range_picks
                CASE 610 TO 658
                    IF _MOUSEX > 75 AND _MOUSEX < 219 THEN Save_Ini
                    IF _MOUSEX > 1134 AND _MOUSEX < 1196 THEN EXIT SUB
            END SELECT
            Clear_MB 1
        END IF
        _DISPLAY
        _LIMIT 30
    LOOP UNTIL _KEYDOWN(27) ' OR (ms AND 1)
    EXIT SUB '                                                  loop finished, leave before gosub blocks

    range_picks: '                                              was "+" or "-" chosen?
    SELECT CASE _MOUSEX
        CASE 75 TO 99 'minus
            d% = -1: GOSUB range_incdec
        CASE 105 TO 129 'plus
            d% = 0: GOSUB range_incdec
        CASE 135 TO 159
            d% = 1: GOSUB range_incdec
    END SELECT
    RETURN

    range_incdec:
    SELECT CASE rng_id%
        CASE IS = 1 '                                           target acquire
            IF d% = 0 THEN
                IF mil THEN SenLocM = 600000 ELSE SenLocC = 150000
            ELSE
                IF mil THEN
                    SenLocM = SenLocM + 150000 * d%
                    IF SenLocM < 150000 THEN SenLocM = 150000
                ELSE
                    SenLocC = SenLocC + (150000 * d%)
                    IF SenLocC < 150000 THEN SenLocC = 150000
                END IF
            END IF
        CASE IS = 2 '                                           target lose
            IF d% = 0 THEN SenMax = 900000 ELSE SenMax = SenMax + 150000 * d%
        CASE IS = 3 '                                           close range
            IF d% = 0 THEN
                RngCls = 250000
            ELSE
                RngCls = RngCls + 150000 * d%
            END IF
            IF RngMed < RngCls * 2 THEN RngMed = RngCls * 2
            IF SenMax < RngMed * 1.8 THEN SenMax = RngMed * 1.8
        CASE IS = 4 '                                           medium range
            IF d% = 0 THEN
                RngMed = 500000
            ELSE
                RngMed = RngMed + 150000 * d%
            END IF
    END SELECT
    RETURN

END SUB 'Options


'±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
SUB Ori_Screen (var AS _BYTE)

    'called from: Main_Loop, Screen_Limits
    'display orientation graphic and place and move stars according to heading and speed; var=active
    IF cmb(var).status <> 2 THEN '                              unit is in flight
        STATIC starx(12) AS INTEGER ' SINGLE
        STATIC stary(12) AS INTEGER ' SINGLE
        STATIC ovar AS _BYTE
        IF ovar > units THEN ovar = units '                     adjust for a lost unit
        IF ovar <> var THEN '                                   if new active unit
            FOR x = 1 TO 12 '                                   Random star placement
                starx(x) = (INT(RND(1) * 254)) - 127
                stary(x) = (INT(RND(1) * 254)) - 127
            NEXT x
            ovar = var '                                        retain active unit # to keep stars for Main_Loop
        END IF

        _DEST ORI&
        WINDOW (-127, 127)-(127, -127)
        CLS
        starhd! = cmb(var).Hd + _PI + (2 * _PI * (cmb(var).Hd >= _PI)) 'set star heading opposite of active ship's heading
        IF cmb(var).Sp = 0 THEN
            sp = 0
        ELSE
            sp = cmb(var).Sp / 10000
            IF sp < 1 THEN sp = 1
            IF sp > 20 THEN sp = 20
        END IF
        xm = sp * SIN(starhd) '
        ym = sp * COS(starhd)
        FOR x = 1 TO 12 '                                       iterate through stars
            PSET (starx(x), stary(x))
            starx(x) = starx(x) + xm
            stary(x) = stary(x) + ym
            'recycle stars that leave screen to opposite boundaries
            starx(x) = starx(x) + (2 * 127 * (starx(x) > 127)) + (2 * -127 * (starx(x) < -127))
            stary(x) = stary(x) + (2 * 127 * (stary(x) > 127)) + (2 * -127 * (stary(x) < -127))
        NEXT x
    ELSE '                                                      unit is landed display a moon scape
        _DEST ORI&
        CLS
        _PUTIMAGE , Moon&, ORI&
    END IF
    LINE (-127, 127)-(127, -127), clr&(4), B
    _PRINTMODE _KEEPBACKGROUND
    _PRINTSTRING (127 - LEN((_TRIM$(cmb(var).Nam))) * 4, 2), cmb(var).Nam, ORI&
    RotoZoom3 127, 127, ShpO, 1, 1, Thrust(var).Azi
    IF Thrust(var).Gs > 0 THEN RotoZoom3 127, 127, ShpT, 1, 1, Thrust(var).Azi
    _PUTIMAGE (295, 325)-(543, 573), ORI&, A&
    IF _MOUSEX > 295 AND _MOUSEX < 543 AND _MOUSEY > 325 AND _MOUSEY < 573 THEN 'on mouse hover
        _PRINTMODE _KEEPBACKGROUND
        _PRINTSTRING (300, 560), " " + LTRIM$(STR$((INT(Thrust(var).Gs) * 100) / 100)) + "Gs"_
             + " @ " + LTRIM$(STR$((INT(_R2D(Thrust(var).Azi)) * 100) / 100)) + CHR$(248)_
              + " Inc " + LTRIM$(STR$((INT(_R2D(Thrust(var).Inc)) * 100) / 100)), A&
    END IF

END SUB 'Ori_Screen


'±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
SUB Panel_Blank (xpos AS INTEGER, ypos AS INTEGER, xsiz AS INTEGER, ysiz AS INTEGER)

    'Background blank to mark and mask button use and/or changes
    CN& = _NEWIMAGE(xsiz, ysiz, 32) '                            active button overlay
    _DEST CN&
    COLOR , &H7F000000 '                                               set overlay background color
    CLS
    _PUTIMAGE (xpos, ypos), CN&, A& '                            cover button
    _FREEIMAGE CN&

END SUB 'Panel_Blank


'±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
SUB Planet_Dist

    'called from: Refresh
    'Show distances to major system bodies in center top screen
    T& = _NEWIMAGE(248, 315, 32)
    _DEST T&
    CLS
    LINE (0, 0)-(247, 314), clr&(4), B
    _PRINTSTRING (156, 2), "AU", T&
    _PRINTSTRING (202, 2), "Brng", T&
    x = 0: yp = 2
    DO
        x = x + 1
        IF hvns(x).star = 2 THEN _CONTINUE '                     exclude planetoid belts
        IF hvns(x).rank > 2 THEN _CONTINUE '                     exclude satellites
        IF yp MOD 2 = 0 THEN
            bb& = &H1F7F7F7F
        ELSE
            bb& = &HFF000000
        END IF
        COLOR clr&(3), bb&
        ds = INT((PyT(3, cmb(vpoint).ap, hvns(x).ps) / KMtoAU) * 100) / 100
        br = INT(Azimuth!(rcp(x).pX, rcp(x).pY) * 10) / 10
        LOCATE yp, 2
        PRINT _TRIM$(hvns(x).nam); SPC(16 - LEN(_TRIM$(hvns(x).nam)));
        LOCATE , 18
        PRINT USING "###.##"; ds; SPC(2);
        LOCATE , 26
        PRINT USING "###.#"; _R2D(br)
        yp = yp + 1
    LOOP UNTIL x = orbs
    _PUTIMAGE (295, 5)-(543, 320), T&, A&
    _DEST A&
    _FREEIMAGE T&

END SUB 'Planet_Dist


SUB Planet_Info (var AS INTEGER)

    '    nam AS STRING * 20 '                                        Name / mem 0-19
    '    parnt AS STRING * 20 '                                      name of parent body / mem 20-39
    '    radi AS _INTEGER64 '                                        Size (needs _INTEGER64 in event of large star) / mem 40-47
    '    orad AS _INTEGER64 '                                        Orbital radius / mem 48-55
    '    oprd AS SINGLE '                                            Orbital period (years) / mem 56-59
    '    rota AS SINGLE '                                            Rotational period / mem 60-63
    '    dens AS SINGLE '                                            Density, basis for grav(Gs) calculation / mem 64-67
    '    rank AS _BYTE '                                             1=primary, 2=planet/companion, 3=satelite, etc. / mem 68
    '    star AS _BYTE '                                             -1=star  0=non-stellar body 2=planetoid belt / mem 69
    '    class AS STRING * 2 '                                       Two digit code, use for stellar class, GG, etc. / mem 70-71
    '    siz AS STRING * 3 '                                         three digit code, use for stellar size, / mem 72-74
    '    ps AS V3 '                                                  coordinate position / mem 75-98

    DIM plin AS body
    plin = hvns(var)
    Dialog_Box _TRIM$(plin.nam), _WIDTH(A&) / 2.5, _HEIGHT(A&), 0, &HFF00FF00, &HFFFFFFFF
    xp = _WIDTH(A&) / 2 - (_WIDTH(A&) / 5) + 16
    yp = 63
    SELECT CASE plin.star
        CASE IS = -1 '                                          star
            typ$ = plin.class + plin.siz + " " + "Star"
            IF plin.rank = 1 THEN
                ord$ = "Primary"
            ELSE
                ord$ = "Companion of " + plin.parnt '+ hvns(Find_Parent(var)).nam
            END IF
        CASE IS = 0 '                                           planetary body
            ord$ = "satellite of " + plin.parnt ' + hvns(Find_Parent(var)).nam
            IF plin.class = "GG" THEN
                typ$ = "Gas Giant"
            ELSE
                typ$ = "Rocky/Icy body"
            END IF
        CASE IS = 2 '                                           ring/belt
            ord$ = "satellite of " + plin.parnt '+ hvns(Find_Parent(var)).nam
            IF hvns(Find_Parent(var)).star = -1 THEN
                typ$ = "Planetoid Belt"
            ELSE
                typ$ = "Ring system"
            END IF
    END SELECT
    _PRINTSTRING (xp, yp), typ$ + "/ " + ord$: yp = yp + 32
    IF plin.star <> 2 THEN
        DIM tmp AS V3
        _PRINTSTRING (xp, yp), "PHYSICAL DATA": yp = yp + 16
        _PRINTSTRING (xp, yp), "Radius: " + STR$(plin.radi) + " km": yp = yp + 16
        _PRINTSTRING (xp, yp), "Mean Density: " + STR$(plin.dens) + "  " + STR$(plin.dens * 5.514) + " g/cubic cm": yp = yp + 16
        grav! = ((plin.dens * ((4 / 3) * _PI * (plin.radi * plin.radi * plin.radi))) / 26687) / (plin.radi * plin.radi)
        _PRINTSTRING (xp, yp), "Surface Gravity: " + STR$(grav!) + " Gs": yp = yp + 32
        _PRINTSTRING (xp, yp), "ORBITAL DATA": yp = yp + 16
        Get_Body_Vec var, tmp
        _PRINTSTRING (xp, yp), "Orbital Velocity: " + STR$(PyT(3, origin, tmp) / 1000) + " km/s": yp = yp + 16
        _PRINTSTRING (xp, yp), "Orbital Radius: " + STR$(plin.orad) + " km": yp = yp + 32
        _PRINTSTRING (xp, yp), "POSITION/DISTANCE DATA (from active)": yp = yp + 16
        d## = INT(PyT(3, origin, rcp(var)))
        IF cmb(vpoint).status = 2 AND cmb(vpoint).bogey = var THEN
            _PRINTSTRING (xp, yp), "On surface": yp = yp + 16
        ELSE
            _PRINTSTRING (xp, yp), "Distance: " + STR$(d##) + " km": yp = yp + 16
        END IF
        _PRINTSTRING (xp, yp), "Azimuth: " + STR$(INT(_R2D(Azimuth!(rcp(var).pX, rcp(var).pY)) * 10) / 10) + CHR$(248): yp = yp + 16
        'inclination from active
        _PRINTSTRING (xp, yp), "Inclination: " + STR$(_R2D(Slope!(rcp(var), origin))) + CHR$(248): yp = yp + 16

    ELSE
        _PRINTSTRING (xp, yp), "PHYSICAL DATA": yp = yp + 16
        wid = -plin.dens * (plin.dens > 0) + -.3 * (plin.dens <= 0) 'calculate ring/belt width
        _PRINTSTRING (xp, yp), "Mean width: " + STR$(plin.orad * wid) + " km": yp = yp + 32
        _PRINTSTRING (xp, yp), "ORBITAL DATA": yp = yp + 16
        _PRINTSTRING (xp, yp), "Mean Orbital Radius: " + STR$(plin.orad) + " km": yp = yp + 16
    END IF
    '_PRINTSTRING (xp, yp), : yp = yp + 16
    '_PRINTSTRING (xp, yp), : yp = yp + 16

    _DISPLAY
    Press_Click

END SUB 'Planet_Info


'±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
SUB Planet_Move (var AS _BYTE)

    'called from: Set_Up, Load_System, Move_Turn, M_Turn_Undo
    'Apply turn movement to planetary bodies
    'var=turncount (1 for normal turn, -1 for undo)
    DIM p AS V3 '                                               parent position to add
    DIM o AS V3 '                                               old planet position for satellite moves
    FOR x = 2 TO 4 '                                            rank iteration, rank 1 primary doesn't move
        FOR v = 1 TO orbs '                                     iterate all bodies
            IF hvns(v).star = 2 THEN _CONTINUE '                 don't move belt/ring systems except relative to parent
            IF hvns(v).rank <> x THEN _CONTINUE '                don't move before higher ranks
            'compute new x,y,z for body v of x rank relative to primary/parent
            przaz## = Az_From_Parent(v)
            IF Turncount = 0 AND var = 0 THEN '               Initial date setup and not a turn undo to turn 0
                'Divide date by orbital period, apply remainder to planet movement
                rot = oryr / hvns(v).oprd + (INT(oryr / hvns(v).oprd) * ((oryr / hvns(v).oprd) <> INT(oryr / hvns(v).oprd)))
                prdtrnaz## = (rot * _PI * 2) '               multiply remainder by 360 for azimuth change
            ELSE '                                              Not initial setup so compute turn change
                prdtrnaz## = (_PI * 2) / (hvns(v).oprd * 31557.6 * var) 'azimuth change / turn  negative .oprd yields retrograde motion
            END IF
            newaz## = przaz## + prdtrnaz## '                    add azimuth change to present azimuth
            p = hvns(Find_Parent(v)).ps
            o = hvns(v).ps '                                    _PRESERVE old position for baseline satellite calculations
            hvns(v).ps.pX = hvns(v).orad * SIN(newaz##) + p.pX 'update planet position
            hvns(v).ps.pY = hvns(v).orad * COS(newaz##) + p.pY
            'put new planet Z position here if the option for tilted orbits is later added
            FOR s = 1 TO orbs '                                 reiterate to pick out the children to drag along
                DIM tmp AS V3
                IF hvns(s).parnt <> hvns(v).nam THEN _CONTINUE ' don't kidnap other planet's children
                tmp = hvns(v).ps: Vec_Add tmp, o, -1: Vec_Add hvns(s).ps, tmp, 1 'apply parent motion to children
            NEXT s

            FOR u = 1 TO units '                                check for landed vessels on v
                IF cmb(u).status <> 2 THEN _CONTINUE '           status 2 gives control to Planet_Move
                IF cmb(u).bogey <> v THEN _CONTINUE
                DIM lnd AS V3
                cmb(u).op = cmb(u).ap: cmb(u).Ostat = cmb(u).status
                cmb(u).OSp = cmb(u).Sp: cmb(u).Sp = 0
                cmb(u).OHd = cmb(u).Hd: cmb(u).Hd = 0
                cmb(u).OIn = cmb(u).In: cmb(u).In = 0
                lnd = hvns(v).ps: Vec_Add lnd, o, -1: Vec_Add cmb(u).ap, lnd, 1 'move unit with planet before checking azimuths
                shpstaz = Azimuth!(cmb(u).ap.pX - hvns(v).ps.pX, cmb(u).ap.pY - hvns(v).ps.pY) 'start azimuth
                rt = (_PI * 2) / (hvns(v).rota * 86.4 * var) '   radian turn rotation {86.4 day rotation constant}
                shpenaz = shpstaz + rt '                        end azimuth
                cmb(u).ap.pX = hvns(v).radi * SIN(shpenaz) + hvns(v).ps.pX 'update ship position
                cmb(u).ap.pY = hvns(v).radi * COS(shpenaz) + hvns(v).ps.pY
                cmb(u).ap.pZ = 0 '                              landed units assumed on ecliptic for now
            NEXT u
    NEXT v, x

END SUB 'Planet_Move


'±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
SUB Polar_2_Vec (vec AS V3, mag AS _INTEGER64, inc AS SINGLE, azi AS SINGLE)

    'Converts polar dirtection to vector- Note:Trig functions reversed for this application
    vec.pZ = mag * SIN(inc)
    vec.pX = mag * COS(inc) * SIN(azi)
    vec.pY = mag * COS(inc) * COS(azi)

END SUB 'Polar_2_Vec


'±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
SUB Press_Click

    DO
        x$ = INKEY$
        IF x$ <> "" THEN in = -1
        ms = MBS
        IF ms AND 1 THEN in = -1: Clear_MB 1
    LOOP UNTIL in

END SUB 'Press_Click


'±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
SUB Prnt (text AS STRING, wsize AS SINGLE, hsize AS SINGLE, StartX AS _INTEGER64, StartY AS _INTEGER64, Xspace AS INTEGER, Yspace AS INTEGER, col AS _UNSIGNED LONG)

    '------------------------------------------------------------------------------------
    ' SUB: Prnt (adaptation of Petr's excellent approach to text resizing)
    '
    ' Purpose:
    ' display text as resizable and recolorable images that have been previously
    ' defined in the main module. Backup for _LOADFONT failure.
    '
    ' Passed parameters:
    ' text sends string value to be printed
    ' wsize sends width size of text to be displayed: 1=original
    ' hsize sends height size of text to be displayed: 1=original
    ' StartX sends upper left x position for _PUTIMAGE
    ' StartY sends upper left y position for _PUTIMAGE
    ' Xspace sends horizontal spacing
    ' Yspace sends vertical spacing
    ' col sends color of character
    '
    'called from: various, label when within a ring/belt or all when font load failure
    '------------------------------------------------------------------------------------

    x = StartX
    y = StartY
    FOR f = 1 TO LEN(text)
        ch = ASC(text, f)
        x = x + Xspace
        y = y + Yspace
        ColoredChar = swapcolor(chr_img(ch), &HFFF5F5F5, col) ' colorize character:
        _PUTIMAGE (x, y)-(x + (wsize * 8), y - (hsize * 16)), ColoredChar, 0
        _FREEIMAGE ColoredChar
    NEXT

END SUB 'Prnt


'±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
FUNCTION Prop!

    'called from: Screen_Limits, Sensor_Screen, Mouse_Button_Left, Mouse_Button_Right
    'find the relative offsets of all units to the active unit and resize
    'to keep all in 80% of the screen, subject to zoom factor override.
    DIM deltamax AS _INTEGER64 ' carries the widest axial separation of units in km
    IF units > 1 THEN '                                         multiple units present
        deltamax = 1000
        x = 0
        DO
            x = x + 1
            IF cmb(x).status = 0 OR x = vpoint THEN _CONTINUE '  skip if active, destroyed or immobile
            IF PyT(3, origin, rcs(x)) > 300000000 THEN _CONTINUE 'skip if unit at extreme range from active
            deltamax = deltamax + (-(ABS(rcs(x).pX) - deltamax) * (ABS(rcs(x).pX) > deltamax))
            deltamax = deltamax + (-(ABS(rcs(x).pY) - deltamax) * (ABS(rcs(x).pY) > deltamax))
        LOOP UNTIL x = units
    ELSE '                                                      only single unit present
        deltamax = 1000000
    END IF
    Prop! = 800 * (ZoomFac / deltamax) '                        all units on screen; subject to zoom factor

END FUNCTION 'Prop!


'±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
SUB Purge

    'called from: Mouse_Button_Left
    'Remove wrecked vessels from list if not desired
    ct = 0
    I$ = cmb(vpoint).Nam '                                      _PRESERVE an active unit identifier
    FOR x = 1 TO units
        ct = ct - (cmb(x).status = 0) '                         Count number of destroyed units
    NEXT x
    IF ct = 0 THEN '                                            No destroyed units?
        EXIT SUB '                                              leave without unnecessary processing
    ELSE '                                                      Yes we have some destroyed units to remove
        n% = units - ct '                                       dim sufficient temp variables
        DIM tmpshp(units) AS ship
        DIM tmpthrs(units) AS Maneuver
        DIM tmpG(units) AS Maneuver
        DIM tmpsens(n%, n%) AS _BYTE
        y% = 0
        FOR x = 1 TO units '                                    keep all existing units in temps
            IF cmb(x).status = 0 THEN _CONTINUE
            y% = y% + 1
            tmpshp(y%) = cmb(x)
            tmpthrs(y%) = Thrust(x)
            tmpG(y%) = Gwat(x)
            z% = 0
            FOR q = 1 TO units
                IF cmb(q).status = 0 THEN _CONTINUE
                z% = z% + 1
                tmpsens(y%, z%) = Sensor(x, q)
            NEXT q
        NEXT x
        units = n% '                                            redimension primary variables
        REDIM cmb(units) AS ship
        REDIM Thrust(units) AS Maneuver
        REDIM Gwat(units) AS Maneuver
        REDIM Sensor(units, units) AS _BYTE
        FOR x = 1 TO units '                                    Move temps back into primary variables
            cmb(x) = tmpshp(x)
            Thrust(x) = tmpthrs(x)
            Gwat(x) = tmpG(x)
            FOR y = 1 TO units
                Sensor(x, y) = tmpsens(x, y)
            NEXT y
            IF cmb(x).Nam = I$ THEN vpoint = x '                set active to new position
        NEXT x
        a = units + 1: b = n% + ct
        FOR x = a TO b '                                        free abandoned ship display memory handles
            _FREEIMAGE ship_box(x)
        NEXT x
    END IF

END SUB 'Purge


'±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
FUNCTION PyT (var AS _BYTE, var1 AS V3, var2 AS V3)

    'called from: various
    'find distance/magnitude between 2D or 3D points
    SELECT CASE var
        CASE IS = 2
            PyT = _HYPOT(var1.pX - var2.pX, var1.pY - var2.pY)
        CASE IS = 3
            PyT = _HYPOT(_HYPOT(var1.pX - var2.pX, var1.pY - var2.pY), var1.pZ - var2.pZ)
    END SELECT

END FUNCTION 'PyT


'±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
FUNCTION Ray_Trace## (var1 AS V3, var2 AS V3, var3 AS V3, var4 AS _INTEGER64)

    'called from: Sensor_Mask
    'Check for Line Of Sight for sensor occlusion
    'var1= first ship, var2= second ship, var3= planet position, var4= planet radius
    dx## = var2.pX - var1.pX: dy## = var2.pY - var1.pY: dz## = var2.pZ - var1.pZ
    A## = (dx## * dx##) + (dy## * dy##) + (dz## * dz##)
    B## = 2 * dx## * (var1.pX - var3.pX) + 2 * dy## * (var1.pY - var3.pY) + 2 * dz## * (var1.pZ - var3.pZ)
    C## = (var3.pX * var3.pX) + (var3.pY * var3.pY) + (var3.pZ * var3.pZ) + (var1.pX * var1.pX) + (var1.pY * var1.pY) +_
                (var1.pZ * var1.pZ) + -2 * (var3.pX * var1.pX + var3.pY * var1.pY + var3.pZ * var1.pZ) - (var4 * var4)
    disabc## = (B## * B##) - 4 * A## * C## ' if disabc## < 0 then no intersection =0 tangent >0 intersects two points
    Ray_Trace## = disabc##

END FUNCTION 'Ray_Trace##


'±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
SUB Re_Calc

    VCS
    Sensor_Mask

END SUB 'ReCalc


'±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
SUB Refresh

    'called from: various
    Screen_Limits '                                             Open sensor display viewport
    Sensor_Screen '                                             display sensor data
    Disp_Data '                                                 Print unit positions, speeds and headings
    Button_Block '                                              control panel
    Planet_Dist '                                               show main planet bearings and distances

END SUB 'Refresh


'±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
SUB RotoZoom3 (X AS LONG, Y AS LONG, Image AS LONG, xScale AS SINGLE, yScale AS SINGLE, radianRotation AS SINGLE)

    'called from: Ori_Screen, Z_Panner
    'With grateful thanks to Galleon and Bplus for this SUB, wish I was this good...
    DIM px(3) AS SINGLE: DIM py(3) AS SINGLE '                  simple arrays for x, y to hold the 4 corners of image
    DIM W&, H&, sinr!, cosr!, i&, x2&, y2& '                    variables for image manipulation
    W& = _WIDTH(Image&): H& = _HEIGHT(Image&)
    px(0) = -W& / 2: py(0) = -H& / 2 '                          left top corner
    px(1) = -W& / 2: py(1) = H& / 2 '                           left bottom corner
    px(2) = W& / 2: py(2) = H& / 2 '                            right bottom
    px(3) = W& / 2: py(3) = -H& / 2 '                           right top
    sinr! = SIN(-radianRotation): cosr! = COS(-radianRotation) 'rotation helpers
    FOR i& = 0 TO 3 '                                           calc new point locations with rotation and zoom
        x2& = xScale * (px(i&) * cosr! + sinr! * py(i&)) + X: y2& = yScale * (py(i&) * cosr! - px(i&) * sinr!) + Y
        px(i&) = x2&: py(i&) = y2&
    NEXT
    _MAPTRIANGLE _SEAMLESS(0, 0)-(0, H& - 1)-(W& - 1, H& - 1), Image TO(px(0), py(0))-(px(1), py(1))-(px(2), py(2))
    _MAPTRIANGLE _SEAMLESS(0, 0)-(W& - 1, 0)-(W& - 1, H& - 1), Image TO(px(0), py(0))-(px(3), py(3))-(px(2), py(2))

END SUB 'RotoZoom3


'±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
SUB Save_Ini

    f$ = "default.ini"
    IF _FILEEXISTS(f$) THEN KILL f$
    OPEN f$ FOR BINARY AS #1
    PUT #1, , togs
    PUT #1, , SenMax
    PUT #1, , SenLocC
    PUT #1, , SenLocM
    PUT #1, , RngCls
    PUT #1, , RngMed
    CLOSE #1

END SUB 'Save_Ini


'±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
SUB Save_Scenario (var AS _BYTE)

    'called from: Main_Loop, Mouse_Button_Left
    'Save the present scenario
    IF _DIREXISTS("scenarios") THEN '                           if "scenarios\" folder exists
        IF var THEN '                                           if not autosave then get scenario name
            t% = 400: r% = 2
            Dialog_Box "SAVING PRESENT SCENARIO", t%, 250, 50, &HFF8C5B4C, clr&(15)
            _DISPLAY
            LOCATE r% + 5, _SHR((_SHR(_WIDTH(A&), 1) - _SHR(t%, 1)), 3) + 4
            INPUT "Enter a scenario name: ", fl$
            LOCATE r% + 7, _SHR((_SHR(_WIDTH(A&), 1) - 40), 3)
            PRINT "Saving..."
        ELSE
            IF _DIREXISTS("scenarios/autosave") THEN '           set or create autosave path
                fl$ = "autosave/auto"
            ELSE '                                              autosave does not exist, create it
                CHDIR "scenarios"
                MKDIR "autosave"
                CHDIR "..\"
                fl$ = "autosave/auto"
            END IF
        END IF
        fx$ = "scenarios/" + _TRIM$(fl$) + ".tfs"
        IF _FILEEXISTS(fx$) THEN KILL fx$ '                      write system scenario state file
        OPEN fx$ FOR BINARY AS #1
        PUT #1, , units
        PUT #1, , orbs
        PUT #1, , Turncount
        PUT #1, , oryr
        PUT #1, , vpoint
        PUT #1, , shipoff
        PUT #1, , togs
        PUT #1, , zangle
        PUT #1, , Ozang
        FOR h = 1 TO orbs
            PUT #1, , hvns(h)
        NEXT h
        FOR s = 1 TO units
            PUT #1, , cmb(s)
            PUT #1, , Thrust(s)
            FOR sm = 1 TO units
                PUT #1, , Sensor(s, sm)
            NEXT sm
        NEXT s
        CLOSE #1
        'check for and delete old files under same name
        vl$ = "scenarios\" + _TRIM$(fl$) + ".tvg" '         Vessel group #2
        pl$ = "scenarios\" + _TRIM$(fl$) + ".tss" '         Planets #1
        sl$ = "scenarios\" + _TRIM$(fl$) + ".tgn" '         saved state #4
        tl$ = "scenarios\" + _TRIM$(fl$) + ".tvt" '         Thrust keeper (.tvt) #3
        tt$ = "scenarios\" + _TRIM$(fl$) + ".ttl" '         Sensor state keeper #5
        IF _FILEEXISTS(vl$) THEN KILL vl$
        IF _FILEEXISTS(pl$) THEN KILL pl$
        IF _FILEEXISTS(sl$) THEN KILL sl$
        IF _FILEEXISTS(tl$) THEN KILL tl$
        IF _FILEEXISTS(tt$) THEN KILL tt$
    ELSE
        MKDIR "scenarios"
        Dialog_Box "CREATING DIRECTORY", 400, 200, 25, Red, Red
        LOCATE 8, 56
        PRINT "The 'scenarios\' directory could not be found."
        LOCATE 9, 56
        PRINT "creating new directory, please retry save"
        _DISPLAY
        SLEEP 4
    END IF

END SUB 'Save_Scenario


'±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
SUB Save_Ships

    'called from: Main_Loop, Mouse_Button_Left
    'Save the present ship list
    IF _DIREXISTS("ships") THEN
        t% = 400
        Dialog_Box "SAVING PRESENT VESSEL(S) & POSITION(S)", t%, 250, 50, &HFF8C5B4C, clr&(15)
        _DISPLAY
        LOCATE r% + 8, _SHR((_SHR(_WIDTH(A&), 1) - _SHR(t%, 1)), 3) + 4
        INPUT "Enter a vessel group name: ", fl$
        LOCATE r% + 10, _SHR((_SHR(_WIDTH(A&), 1) - 40), 3)
        PRINT "Saving..."
        fl$ = "ships\" + fl$ + ".tvg"
        OPEN fl$ FOR BINARY AS #2
        FOR x = 1 TO units: PUT #2, , cmb(x): NEXT '           Save all ships
        CLOSE #2
    ELSE
        MKDIR "ships"
        Dialog_Box "CREATING DIRECTORY", 400, 200, 25, Red, Red
        LOCATE 8, 56
        PRINT "The 'ships\' directory could not be found."
        LOCATE 9, 56
        PRINT "creating new directory, please retry save"
        _DISPLAY
        SLEEP 4
    END IF

END SUB 'Save_Ships


'±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
SUB Save_System

    'called from: Mouse_Button_Left
    'Save a non-zero year system state
    IF _DIREXISTS("systems") THEN
        t% = 600
        Dialog_Box "SAVING SYSTEM", t%, 250, 50, &HFF8C5B4C, clr&(15)

        in1$ = "Enter system name or press ENTER to default to " + _TRIM$(hvns(1).nam)
        l = _SHR(_WIDTH(A&), 1) - _SHR(LEN(in1$), 2)
        _PRINTSTRING (l, 217), in1$, A&
        col% = _SHR((_SHR(_WIDTH(A&), 1) - _SHR(t%, 1)), 3) + 4
        _DISPLAY
        LOCATE 10, col%
        INPUT "System name:"; n$
        IF n$ <> "" THEN
            n$ = _TRIM$(n$)
        ELSE
            n$ = _TRIM$(hvns(1).nam)
        END IF
        sys$ = "systems/" + n$ + ".tss"
        IF _FILEEXISTS(sys$) THEN '                             so that we don't accidentally overwrite a zero year file
            nfn = 1
            DO
                nfn = nfn + 1
                sys$ = "systems/" + n$ + "(" + _TRIM$(STR$(nfn)) + ")" + ".tss" 'create a numbered copy of filename input
            LOOP UNTIL NOT _FILEEXISTS(sys$)
        END IF
        OPEN sys$ FOR BINARY AS #1
        FOR x = 1 TO orbs: PUT #1, , hvns(x): NEXT '            save all planets
        CLOSE #1
    ELSE
        MKDIR "systems"
        Dialog_Box "CREATING DIRECTORY", 400, 200, 25, Red, Red
        LOCATE 8, 56
        PRINT "The 'systems\' directory could not be found."
        LOCATE 9, 56
        PRINT "creating new directory, please retry save"
        _DISPLAY
        SLEEP 4
    END IF

END SUB 'Save_System


'±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
SUB Screen_Limits

    'called from: Refresh
    'Create screen border info
    _DEST A&
    SCREEN A&
    COLOR , &HFF0F0F0F '_RGBA32(15, 15, 15, 10)
    CLS

    _PRINTSTRING (560, 0), "Turn #" + STR$(Turncount), A& '      Turn and time elapsed
    IF etd THEN tm$ = _TRIM$(STR$(etd)) + "d "
    IF eth OR Turncount > 3 THEN tm$ = tm$ + _TRIM$(STR$(eth)) + "h "
    IF Turncount > 0 THEN tm$ = tm$ + _TRIM$(STR$(etm)) + "m " + _TRIM$(STR$(ets)) + "s"
    _PRINTSTRING (672, 0), tm$, A&

    _PRINTSTRING (1075, 0), STR$(Prop!), A&

    IF togs AND 2 THEN
        SELECT CASE zangle '                                    set galactic orientation strings to rotation angle
            CASE IS < -.7853982
                bt$ = "NADIR facing rimward"
                bb$ = "ZENITH facing rimward"
            CASE -.7853982 TO .7853982 '                        within 45ø of vertical
                bt$ = "COREWARD"
                bb$ = "RIMWARD"
            CASE IS > .7853982
                bt$ = "ZENITH facing coreward"
                bb$ = "NADIR facing coreward"
        END SELECT
    ELSE
        bt$ = "COREWARD"
        bb$ = "RIMWARD"
    END IF

    _PRINTSTRING (839, 0), bt$, A& '                             Galactic orientation screen top
    _PRINTSTRING (839, 639), bb$, A& '                           Galactic orientation screen bottom

    FOR x = 1 TO 8
        _PRINTSTRING (1187, 249 + (x * 16)), MID$("TRAILING", x, 1), A& 'Galactic orientation screen right
        _PRINTSTRING (547, 249 + (x * 16)), MID$("SPINWARD", x, 1), A& 'Galactic orientation screen left
    NEXT
    Ori_Screen vpoint '                                          need Ori_Screen here to display during out of loop operations
    IF togs AND 8192 THEN Z_Panner

END SUB 'Screen_Limits


'±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
SUB Sensor_Mask

    'called from: Refresh
    'Determine which units may be sensor occluded by planetary bodies.
    FOR x = 1 TO units '                                        Active unit iteration  x=active
        FOR y = 1 TO units '                                    Passive unit iteration  y=passive
            Sensor(x, y) = _RESETBIT(Sensor(x, y), 0) '         Assume innocent until proven guilty
            IF x = y THEN _CONTINUE '                           if unit is self then skip and leave at zero
            IF PyT(3, cmb(x).ap, cmb(y).ap) > SenMax THEN Sensor(x, y) = _RESETBIT(Sensor(x, y), 1) 'too far to target
            FOR z = 1 TO orbs '                                 Planetary body iteration
                IF hvns(z).star = 2 THEN _CONTINUE '            Skip belt/ring systems
                IF PyT(3, rcs(x), rcp(z)) < PyT(3, rcs(x), rcs(y)) THEN ' is planet closer to active than passive is?
                    IF PyT(3, rcs(y), rcp(z)) < PyT(3, rcs(x), rcs(y)) THEN ' is planet closer to passive than active is?
                        IF Ray_Trace##(rcs(x), rcs(y), rcp(z), hvns(z).radi) > 0 THEN 'if ray trace indicates no LOS then
                            Sensor(x, y) = _SETBIT(Sensor(x, y), 0) ' Passive is sensor occluded and not visible to Active
                            IF Sensor(x, y) AND 2 THEN Sensor(x, y) = _RESETBIT(Sensor(x, y), 1) 'no target lock if occluded
                        END IF
                    END IF '                                    end: is planet between?
                END IF '                                        end: is planet close?
    NEXT z, y, x '                                              end: iterations planetary body/ passive unit/ active unit

END SUB 'Sensor_Mask


'±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
SUB Sensor_Screen

    'called from: Refresh
    'Graphic navigation screen
    _DEST SS&
    CLS '                                                       clear with opaque image

    c% = 4 '                                                    red border & xhair

    VIEW (1, 1)-(618, 618), clr&(0), clr&(c%) '                 set graphics port full image SS& w/box

    WINDOW (-1000, 1000)-(1000, -1000) '                        set relative cartesian coords
    IF togs AND 32 THEN Inc_Meter
    IF togs AND 4 THEN Azimuth_Wheel

    LINE (0, 50)-(0, 25), clr&(c%) '                            draw active unit reference point xhair
    LINE (0, -25)-(0, -50), clr&(c%)
    LINE (-50, 0)-(-25, 0), clr&(c%)
    LINE (25, 0)-(50, 0), clr&(c%)

    'Dynamic scale grid display
    DIM q!
    q! = Prop!
    IF togs AND 8 THEN '                                        If grid toggle is TRUE
        DIM dynagrid AS SINGLE
        dynagrid = 10 ^ INT(LOG(600 / q!) / LOG(10.#)) '        size grid by powers of 10
        g = 0: dc% = 0: dynaq = q! * dynagrid
        DO UNTIL g > 1000 '                                     Draw grid
            IF dc% MOD 10 = 0 THEN gl& = &H28FFFFFF ELSE gl& = &H0FFFFFFF
            LINE (-1000, g)-(1000, g), gl& '                    horizontal grid lines
            IF g > 0 THEN LINE (-1000, -g)-(1000, -g), gl& '    do negative if not 0 line
            LINE (g, -1000)-(g, 1000), gl& '                    vertical grid lines
            IF g > 0 THEN LINE (-g, -1000)-(-g, 1000), gl& '    do negative if not 0 line
            g = g + dynaq
            dc% = dc% + 1
        LOOP

        SELECT CASE dynagrid
            CASE IS < 1
                scalelegend$ = "grid=" + STR$(dynagrid * 1000) + " meters"
            CASE IS > 15000000
                scalelegend$ = "grid=" + STR$(dynagrid / KMtoAU) + " AU"
                'CASE IS > 30856780000000
                '    scalelegend$ = "grid=" + STR$(dynagrid / KMtoPC) + " pc"
            CASE ELSE
                scalelegend$ = "grid=" + STR$(dynagrid) + " km"
        END SELECT
        IF fa12& > 0 THEN
            _FONT fa12&: COLOR &H48FFFFFF: _PRINTMODE _KEEPBACKGROUND
            _PRINTSTRING (10, 600), scalelegend$, SS&
            _FONT 16
        ELSE
            Prnt scalelegend$, 2.8, 2.8, -990, -950, 24, 0, &H48FFFFFF 'print legend in lower left corner
        END IF
    END IF '                                                    end: grid toggle test

    System_Map q! '                                             Draw system details

    'UNIT PLACEMENTS, VECTORS, RANGES AND ID                    Draw each unit and index number on screen
    DIM UDisp AS V3 '                                           proportional dcs unit placement
    DIM VDisp AS V3 '                                           vector indicator transformation

    shipcl& = clr&(2) '                                         set default ship name color to green (going)
    FOR x = 1 TO units '                                        Iterate through all ships
        UDisp = dcs(x): Vec_Mult UDisp, q! '                    unit positions for display
        rtds% = PyT(2, origin, dcs(x)) * q! '                   relative distance factor {active to x}

        Polar_2_Vec VDisp, cmb(x).Sp, cmb(x).In, cmb(x).Hd '    calculate heading vector tails, returning in VDisp,
        Vec_Add VDisp, rcs(x), 1 '                              add relative unit postion to it,
        Vec_Rota VDisp: Vec_Mult VDisp, q! '                    apply any rotations and scale to display factor

        IF ABS(UDisp.pX) < 1415 OR ABS(UDisp.pY) < 1415 THEN '  skip draw if out of frame
            IF NOT Sensor(vpoint, x) AND 1 THEN '               If ship x is not sensor occluded then draw it
                cp = -9 * (dcs(x).pZ > dcs(vpoint).pZ) + -12 * (dcs(x).pZ < dcs(vpoint).pZ) + -7 * (dcs(x).pZ = dcs(vpoint).pZ) 'nearer or farther colors
                IF PyT(3, origin, rcs(x)) > 300000000 THEN '    extreme distance (grey)
                    cp = 7: tfr% = -1 '
                END IF

                IF cmb(x).status > 0 THEN '                     Draw point box, name & reticle/laser if target locks
                    LINE (UDisp.pX - 5, UDisp.pY + 5)-(UDisp.pX + 5, UDisp.pY - 5), clr&(cp), BF
                    IF x <> vpoint AND (Sensor(vpoint, x) AND 2) THEN 'Draw target lock indicator if targeted by active
                        IF rtds% > 400 THEN rtm = 1 ELSE rtm = rtds% / 400 'resize reticle on zoom in with reticle multiplier
                        IF rtds% > 20 THEN '                    drop reticle if too close to active unit
                            rt30 = rtm * 30: rt120 = rtm * 120
                            LINE (UDisp.pX + rt30, UDisp.pY)-(UDisp.pX + rt120, UDisp.pY), &H5FFC5454
                            LINE (UDisp.pX - rt30, UDisp.pY)-(UDisp.pX - rt120, UDisp.pY), &H5FFC5454
                            LINE (UDisp.pX, UDisp.pY + rt30)-(UDisp.pX, UDisp.pY + rt120), &H5FFC5454
                            LINE (UDisp.pX, UDisp.pY - rt30)-(UDisp.pX, UDisp.pY - rt120), &H5FFC5454
                            CIRCLE (UDisp.pX, UDisp.pY), 100 * rtm, &H5FFC5454
                        END IF
                    END IF
                    IF rtds% > 10 THEN
                        IF x <> vpoint AND (Sensor(x, vpoint) AND 2) THEN 'Draw target laser if inactive targeting active
                            LINE (0, 0)-(UDisp.pX, UDisp.pY), &H7FCD9575, , &B0011001100001111 '  &H5FFC5454original &HFFCD9575AntiqueBrass
                        END IF
                    END IF
                    IF x = vpoint AND cmb(x).status <> 3 THEN ' bright green unless damaged
                        shipcl& = clr&(10)
                        GOSUB shipID
                        shipcl& = clr&(2)
                    ELSE
                        IF tfr% THEN '                          if at extreme range/ more than a light turn
                            shipcl& = clr&(cp)
                            GOSUB shipID
                            shipcl& = clr&(2)
                        ELSE
                            IF cmb(x).status = 3 THEN '         red if damaged and drifting, active or otherwise
                                shipcl& = clr&(4)
                                GOSUB shipID
                                shipcl& = clr&(2)
                            ELSE '                              green undamaged non-active units
                                GOSUB shipID
                                shipcl& = clr&(2)
                            END IF
                        END IF
                    END IF
                    IF cmb(x).status <> 2 THEN '                if unit x isn't landed
                        IF x = vpoint THEN '                    draw active unit's vector indicator yellow
                            LINE (0, 0)-(VDisp.pX, VDisp.pY), _RGB32(222, 188, 17)
                        ELSE '                                  draw inactive units vector indicator bluegreen
                            LINE (UDisp.pX, UDisp.pY)-(VDisp.pX, VDisp.pY), _RGB32(17, 188, 222)
                        END IF
                    END IF
                END IF '                                        end: destroyed test
            END IF '                                            end Sensor(vpoint,x) check
        END IF '                                                end out of frame skip

        ' RANGING BANDS & CIRCLES
        IF NOT togs AND 16 THEN _CONTINUE '                 if range toggle is false then skip the rest
        IF x = vpoint THEN '                                    Draw ranging circles of active unit
            IF RngMed * q! > 20 THEN '                          if large enough to see
                FCirc 0, 0, RngMed * q!, _RGBA(252, 252, 84, 5) 'show medium range band
            END IF
            IF RngCls * q! > 20 THEN '                          if large enough to see
                FCirc 0, 0, RngCls * q!, _RGBA(252, 84, 84, 20) 'show short range band
            END IF
            IF cmb(vpoint).mil THEN '                           if military sensors
                dtct = SenLocM '                                military detection range
            ELSE
                dtct = SenLocC '                                civilian detection range
            END IF
            IF dtct * q! > 20 THEN '                            if large enough to see
                CIRCLE (0, 0), dtct * q!, &HB0545454 '          show minimum detection range .5 or 2 light seconds
            END IF
            IF SenMax * q! > 20 THEN '                          if large enough to see
                CIRCLE (0, 0), SenMax * q!, &H70A80000 '        show maximum detection range 3 light seconds
            END IF
        END IF
    NEXT x

    'Grav watcher- upper right sensor screen
    _PRINTMODE _KEEPBACKGROUND
    COLOR _RGBA(0, 255, 0, 50)
    _PRINTSTRING (550, 5), "G:" + STR$(_ROUND(Gwat(vpoint).Gs * 100) / 100), SS&
    _PRINTSTRING (550, 21), "A:" + STR$(_ROUND(_R2D(Gwat(vpoint).Azi) * 100) / 100), SS&
    _PRINTSTRING (550, 37), "I:" + STR$(_ROUND(_R2D(Gwat(vpoint).Inc) * 100) / 100), SS&

    _DEST A& '                                                   return output to main screen
    _PUTIMAGE (560, 18), SS&, A& '                               update sensor screen to mainscreen
    EXIT SUB

    shipID: '                                                   print ship names in font or image if font failed
    IF rtds% > 100 OR x = vpoint THEN
        IF x = vpoint OR (Sensor(x, x) AND 16) THEN
            trn$ = cmb(x).Nam
        ELSE
            trn$ = "??? (" + _TRIM$(STR$(cmb(x).id)) + ")"
        END IF
        IF fa10& > 0 THEN
            _FONT fa10&: COLOR shipcl&: _PRINTMODE _KEEPBACKGROUND
            _PRINTSTRING ((UDisp.pX / 2000) * 620 + 315, (-UDisp.pY / 2000) * 620 + 315), trn$
            _FONT 16
        ELSE
            Prnt trn$, 2.8, 2.8, UDisp.pX + 10, UDisp.pY - 10, 24, 0, shipcl&
        END IF
    END IF
    RETURN

END SUB 'Sensor_Screen


'±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
SUB Set_Up

    Planet_Move 0 '                                              Initial planet position determined by date
    RANDOMIZE TIMER
    DO '                                                        select a random body for ship cluster
        pl% = INT(RND * orbs) + 1
    LOOP UNTIL hvns(pl%).star <> 2 AND hvns(pl%).radi > 100 '   don't place in belt/ring or near trash
    'pl% = 6 '<<< use this line if desiring a specific body for testing purposes, otherwise remark out

    RESTORE ships
    READ a
    units = a
    REDIM cmb(a) AS ship '                                      set up ships (units)
    REDIM Thrust(units) AS Maneuver '                           unit accelerations/vector
    REDIM Gwat(units) AS Maneuver '                             unit g forces
    REDIM Sensor(units, units) AS _BYTE '                       Sensor ops- planetary obscuration array, who can see who?
    FOR x = 1 TO units '                                        initialize unit data
        ship_box(x) = _NEWIMAGE(290, 96, 32) '                  data box
        cmb(x).id = x: READ cmb(x).Nam: READ cmb(x).MaxG
        READ cmb(x).ap.pX: READ cmb(x).ap.pY: READ cmb(x).ap.pZ
        READ cmb(x).Sp: READ cmb(x).Hd: READ cmb(x).In: READ cmb(x).mil
        cmb(x).op = cmb(x).ap
        AZ = RND * (_PI * 2)
        cmb(x).status = 1
        Thrust(x).Azi = RND * (_PI * 2) '                       random orientation
        ds = RND * 500 + 40 '                                   random distance in radii of body
        dz = RND * 20 - 10
        cmb(x).ap.pX = (hvns(pl%).radi * ds) * SIN(AZ) + hvns(pl%).ps.pX
        cmb(x).ap.pY = (hvns(pl%).radi * ds) * COS(AZ) + hvns(pl%).ps.pY
        IF togs AND 8192 THEN
            cmb(x).ap.pZ = hvns(pl%).radi * dz
        ELSE
            cmb(x).ap.pZ = 0
        END IF
        cmb(x).op = cmb(x).ap '                                 prevent first turn runaway
        Sensor(x, x) = _SETBIT(Sensor(x, x), 4) '               all transponders on by default
    NEXT x
    Re_Calc

END SUB 'Set_Up


'±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
FUNCTION Slope! (var1 AS V3, var2 AS V3)

    'called from: various
    'returns degree declination of var1 point relative to var2
    D&& = _HYPOT(var1.pX - var2.pX, var1.pY - var2.pY) '          distance on X,Y plane
    Slope! = _ATAN2(var1.pZ - var2.pZ, D&&)

END FUNCTION 'Slope!


'±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
FUNCTION swapcolor (handle&, oldcolor~&, newcolor~&)

    'called from: Prnt
    'Petr's character color swapping function, called from SUB Prnt
    DIM m AS _MEM, c AS _UNSIGNED LONG
    swapcolor = _COPYIMAGE(handle&, 32)
    m = _MEMIMAGE(swapcolor)
    DO UNTIL x& = m.SIZE - 4
        x& = x& + 4
        c = _MEMGET(m, m.OFFSET + x&, _UNSIGNED LONG)
        IF c = oldcolor~& THEN _MEMPUT m, m.OFFSET + x&, newcolor~&
    LOOP
    _MEMFREE m

END FUNCTION 'swapcolor


'±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
SUB System_Map (g AS SINGLE)

    'called from: Sensor_Screen
    'displays the star system

    'Results of Frame_Sect% calls
    '0 = feature is beyond display zoom- don't draw it
    '1 = features radius encompasses entire display zoom- fill screen circumscription
    '2 = feature is fully encompassed by display zoom- draw the entire feature
    '3 = portion of feature intersects display zoom- draw entire feature, or portion if feasible

    DIM OTC AS V3 '                                             locates foci of orbit tracks & belt/ring systems

    FOR p = 1 TO orbs '                                         Iterate through all system bodies

        'BARYCENTERS
        IF hvns(p).rank > 1 THEN '                              find orbit track center
            OTC = rcp(Find_Parent(p))
        ELSE
            OTC = rcp(p) '                                      system primary doesn't orbit
        END IF

        'MAIN SKIPPING ALGORITHM- don't draw any feature that is extremely remote
        IF hvns(p).star = 2 THEN '                              process belt/ring differently because it has a hvns(p).radi=0
            wid = -(hvns(p).dens / 2) * (hvns(p).dens > 0) + -.15 * (hvns(p).dens <= 0) 'calculate ring/belt width
            IF togs AND 2 THEN
                infrm% = Frame_Sect%(OTC, hvns(p).orad - (hvns(p).orad * wid), g / 10)
                outfrm% = Frame_Sect%(OTC, hvns(p).orad + (hvns(p).orad * wid), g / 10)
            ELSE
                infrm% = Frame_Sect%(OTC, hvns(p).orad - (hvns(p).orad * wid), g)
                outfrm% = Frame_Sect%(OTC, hvns(p).orad + (hvns(p).orad * wid), g)
            END IF
            IF infrm% = 1 OR outfrm% = 0 THEN _CONTINUE '       None of the ring/belt is in frame so skip to next feature
        ELSE
            IF togs AND 2 THEN
                mfrm% = Frame_Sect%(rcp(p), hvns(p).radi * 1000, g)
                ofrm% = Frame_Sect%(OTC, hvns(p).orad, g)
            ELSE
                mfrm% = Frame_Sect%(rcp(p), hvns(p).radi, g)
                ofrm% = Frame_Sect%(OTC, hvns(p).orad, g)
            END IF
            IF mfrm% = 0 AND ofrm% < 2 THEN _CONTINUE '         neither sphere, nor it's orbit track is in frame, so skip to next
        END IF
        '_ECHO "Draw " + STR$(p) '<<< DEBUG CODE watch console for render speed issues REMOVE WHEN FINISHED

        'ON JUMP TOGGLE TRUE, display jump spheres- rejecting those out of frame
        IF (togs AND 64) AND hvns(p).star <> 2 THEN '           jump zones toggled & not asteroid belt
            IF togs AND 512 THEN l! = hvns(p).dens ELSE l! = 1 'density or diameter jump zone
            '100 diameters/densities
            IF hvns(p).radi * 400 * l! * g > 25 THEN '         only draw if > 25 pixels
                IF Frame_Sect%(rcp(p), hvns(p).radi * 200 * l!, g) > 1 THEN
                    FCirc (dcp(p).pX) * g, (dcp(p).pY) * g, (hvns(p).radi * 200 * l!) * g, _RGBA(150, 116, 116, 10)
                END IF
            END IF '                                            end: > 25 pixel test
            '10 diameters/densities
            IF hvns(p).radi * 40 * l! * g > 25 THEN '          only draw if > 25 pixels
                IF Frame_Sect%(rcp(p), hvns(p).radi * 20 * l!, g) > 1 THEN
                    FCirc (dcp(p).pX) * g, (dcp(p).pY) * g, (hvns(p).radi * 20 * l!) * g, _RGBA(200, 116, 116, 5)
                END IF
            END IF '                                            end: > 25 pixel test
        END IF

        'CORONAS AND COLORS
        IF hvns(p).star = -1 THEN '                             if a star then build star corona
            'DETERMINE ANY STELLAR CLASS/SIZE CONSTANTS HERE- use them in place of 50000
            '
            IF Frame_Sect%(rcp(p), hvns(p).radi + (30 * 50000), g) > 0 THEN 'if no corona band in frame then skip drawing
                FOR x = 1 TO 30 '                               draw corona bands
                    IF Frame_Sect%(rcp(p), hvns(p).radi + (x * 50000), g) > 0 THEN
                        FCirc (dcp(p).pX) * g, (dcp(p).pY) * g, (hvns(p).radi + (x * 50000)) * g, _RGBA32(127, 127, 227, 30 - x)
                    END IF
                NEXT x
            END IF
            SELECT CASE MID$(hvns(p).class, 1, 1) '             source: http://www.vendian.org/mncharity/dir3/starcolor/
                CASE IS = "A": c& = &HFFCAD7FF '                202 215 255  #cad7ff
                CASE IS = "B": c& = &HFFAABFFF '                170 191 255  #aabfff
                CASE IS = "F": c& = &HFFF8F7FF '                248 247 255  #f8f7ff
                CASE IS = "G": c& = &HFFFFF4EA '                255 244 234  #fff4ea
                CASE IS = "K": c& = &HFFFFD2A1 '                255 210 161  #ffd2a1
                CASE IS = "M": c& = &HFFFFCC6F '                255 204 111  #ffcc6f
                CASE IS = "O": c& = &HFF9BB0FF '                155 176 255  #9bb0ff  Spectral class colors
            END SELECT '                                        old star color c& = &HFFFC5454
        ELSE
            IF hvns(p).class = "GG" THEN '                      planet color
                c& = &HFF545454 '                               gas giant
            ELSE
                c& = &HFF347474 '                               rocky/icy body
            END IF
        END IF

        IF hvns(p).star < 2 THEN '******************************BODY IS A MASSIVE PLANETARY FEATURE, NOT A RING
            IF togs AND 128 THEN '                              if orbit toggle is true then display orbit tracks
                IF _SHL(hvns(p).orad, 1) * g > 50 THEN '        if large enough to see on screen
                    IF togs AND 2 THEN '                        if Z-pan toggle is true
                        frm = Frame_Sect%(OTC, hvns(p).orad, g / 10) 'exclude insystem OTs
                        IF frm > 1 THEN
                            Vec_Rota OTC
                            CIRCLE (OTC.pX * g, OTC.pY * g), hvns(p).orad * g, _RGBA32(111, 72, 233, 70), , , COS(zangle)
                        END IF
                    ELSE
                        IF Frame_Sect%(OTC, hvns(p).orad, g) = 3 THEN 'if track intersects viewport frame
                            IF hvns(p).orad > (1415 / g) * 2000 THEN 'if orad is 2000x visual screen then draw line instead of circle
                                DIM drct AS V3 '                direction vector
                                DIM PT AS V3 '                  Point Tangent
                                Vec_Cross drct, OTC, khat '     get orthogonal of vertical and orbit track radius
                                d2a## = PyT(2, OTC, origin) '   distance from orbit track center to active unit
                                PT = OTC: Vec_Mult PT, -1 * (hvns(p).orad / d2a##): Vec_Add PT, OTC, 1 'find tangent point on orbit track
                                Vec_Mult PT, g
                                Vec_Mult drct, g
                                'dashed orbit track indicates not a true curve
                                LINE (PT.pX, PT.pY)-(PT.pX + drct.pX, PT.pY + drct.pY), _RGBA32(111, 72, 233, 70), , &B0000000011111111
                                LINE (PT.pX, PT.pY)-(PT.pX + drct.pX * -1, PT.pY + drct.pY * -1), _RGBA32(111, 72, 233, 70), , &B1111111100000000
                            ELSE
                                CIRCLE (OTC.pX * g, OTC.pY * g), hvns(p).orad * g, _RGBA32(111, 72, 233, 70)
                            END IF '                            end: tight angle line/wide angle circle
                        END IF '                                end: out of frame test
                    END IF '                                    end: Z-pan test
                END IF '                                        end: size test
            END IF '                                            end: orbit toggle test

            'display gravity zones
            IF togs AND 256 THEN '                              if grav zone toggle is true
                IF hvns(p).star <> 2 THEN '                     and not a belt/ring system
                    grv! = 0
                    radius## = hvns(p).radi
                    dsx## = hvns(p).dens * ((4 / 3) * _PI * (radius## * radius## * radius##)) / 26687
                    DO
                        grv! = grv! + .25 '                     zones drawn in 1/4G increments
                        IF grv! > cmb(vpoint).MaxG THEN '       indicate danger bands of active unit
                            esc& = _RGBA(0, 255, 0, 70) '       dense green = heavier Gs than active's Max G
                        ELSE
                            esc& = _RGBA(0, 255, 0, 25) '       light green = lighter Gs than active's Max G
                        END IF
                        ds## = (dsx## / grv!) ^ .5 '            set grav zone radius
                        IF ds## * g < 50 THEN _CONTINUE '      if too small to see then skip
                        IF Frame_Sect%(rcp(p), ds##, g) = 3 THEN
                            CIRCLE (dcp(p).pX * g, dcp(p).pY * g), ds## * g, esc&
                        END IF
                    LOOP UNTIL ds## < hvns(p).radi
                END IF '                                        end: belt/ring test
            END IF '                                            end: grav zone toggled test

            'display star/planet body, rejecting those that are out of frame
            IF Frame_Sect%(dcp(p), hvns(p).radi, g) > 0 THEN '  is the feature within the frame
                IF _SHL(hvns(p).radi, 1) * g > 2 THEN '         if large enough to see
                    frm = Frame_Sect%(dcp(p), hvns(p).radi, g)
                    IF frm = 1 THEN '                           planetary body fills screen
                        FCirc 0, 0, 1415, c& '                  fill screen only
                    ELSE
                        FCirc dcp(p).pX * g, dcp(p).pY * g, hvns(p).radi * g, c& 'display planet orb
                        CIRCLE (dcp(p).pX * g, dcp(p).pY * g), hvns(p).radi * g, c& 'and outline it
                    END IF
                ELSE '                                          if not, draw placekeeping point
                    PSET (dcp(p).pX * g, dcp(p).pY * g), c&
                END IF '                                        end: size test

                'display name if there's room
                dsp&& = PyT(2, dcp(Find_Parent(p)), dcp(p)) * g 'display distance to parent planet
                dss&& = PyT(2, dcp(p), origin) * g '            display distance to active unit
                IF (dsp&& > 100 AND dss&& > 50) OR hvns(p).rank = 1 THEN GOSUB print_name 'print name if not too close on screen
            END IF '                                            end planet out of frame reject

        ELSE '**************************************************BODY IS A BELT/RING SYSTEM
            IF togs AND 1024 THEN '                             If belt/ring toggle on
                IF ABS(zangle) <> _PI / 2 THEN '                view point is not on ecliptic plane
                    IF _SHL(hvns(p).orad, 1) * g < 100 THEN _CONTINUE 'skip if belt/ring too small to see
                    wid = -(hvns(p).dens / 2) * (hvns(p).dens > 0) + -.15 * (hvns(p).dens <= 0)
                    outbnd&& = hvns(p).orad + hvns(p).orad * wid 'outer limit of planetoid/ring belt wid% orbital radius
                    SELECT CASE Frame_Sect%(OTC, outbnd&&, g / 10)
                        CASE IS = 0 '                           skip draw as no part of feature is in display
                            EXIT SELECT
                        CASE IS = 1 '                           Outer boundary is beyond display limits
                            inbnd&& = hvns(p).orad - hvns(p).orad * wid 'inner limit of planetoid/ring belt wid% orbital radius
                            frmin = Frame_Sect%(OTC, inbnd&&, g)
                            IF frmin = 0 THEN '                 Display limits are beyond inner boundary
                                FCirc 0, 0, 1415, &H127F7F7F
                                IF ft16& > 0 THEN
                                    COLOR &H5F7F7F7F
                                    _PRINTSTRING ((_WIDTH(SS&) / 2) - (_PRINTWIDTH(_TRIM$(hvns(p).nam)) / 2), _HEIGHT(SS&) / 3), "Within " + _TRIM$(hvns(p).nam)
                                END IF
                            ELSEIF frmin >= 2 THEN Draw_Ring_Belt OTC, outbnd&& - inbnd&&, inbnd&&, g
                            END IF
                        CASE IS = 2 '                           outer limit is fully in display
                            inbnd&& = hvns(p).orad - hvns(p).orad * wid 'inner limit of planetoid/ring belt wid% orbital radius
                            IF Frame_Sect%(OTC, inbnd&&, g) = 2 THEN Draw_Ring_Belt OTC, outbnd&& - inbnd&&, inbnd&&, g
                        CASE IS = 3 '                           outer limit intersects display
                            inbnd&& = hvns(p).orad - hvns(p).orad * wid 'inner limit of planetoid/ring belt wid% orbital radius
                            IF Frame_Sect%(OTC, inbnd&&, g) <> 1 THEN Draw_Ring_Belt OTC, outbnd&& - inbnd&&, inbnd&&, g
                    END SELECT
                END IF '                                        end view parallel to ecliptic test
            END IF '                                            end belt/ring toggle
        END IF '                                                end planetary or belt display
    NEXT p
    EXIT SUB '                                                  iterations done, leave before gosub block

    print_name:
    fl$ = ""
    IF zangle < 0 THEN
        fl = -1
        FOR n = LEN(_TRIM$(hvns(p).nam)) TO 1 STEP -1
            fl$ = fl$ + MID$(hvns(p).nam, n, 1)
        NEXT n
    ELSE
        fl = 1
        fl$ = hvns(p).nam
    END IF
    sz! = 3.6 - hvns(p).rank / 4
    IF ft16& > 0 AND ft14& > 0 AND ft12& > 0 THEN
        SELECT CASE hvns(p).rank
            CASE IS = 1: _FONT ft16&
            CASE IS = 2: _FONT ft14&
            CASE IS >= 3: _FONT ft12&
        END SELECT
        COLOR _RGBA32(200, 67, 55, 170)
        pnx% = map!(dcp(p).pX * g, -1000, 1000, 0, 620) + (hvns(p).radi * g * .3)
        pny% = map!(dcp(p).pY * g, 1000, -1000, 0, 620) + (hvns(p).radi * g * .3)
        nr$ = _TRIM$(hvns(p).nam)
        IF togs AND 16384 THEN nr$ = nr$ + " (" + _TRIM$(STR$(hvns(p).rank)) + ")" 'If show rank set
        _PRINTMODE _KEEPBACKGROUND
        _PRINTSTRING (pnx%, pny%), nr$
        IF zangle < 0 THEN
            ul$ = "___"
            _PRINTSTRING (pnx%, pny% - 16), ul$
        END IF
        _FONT 16
    ELSE
        Prnt fl$, sz! * fl, sz! * fl, (dcp(p).pX * g) + (hvns(p).radi * g * .7), (dcp(p).pY * g) - (hvns(p).radi * g * .7),_
         28, 0,_RGBA32(255 - (hvns(p).rank - 1) * 50, 67, 55, 170)
    END IF
    RETURN

END SUB 'System_Map


'±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
SUB Terminus

    'Free all images on exit
    FOR x = 0 TO 255: _FREEIMAGE chr_img(x): NEXT x
    _FREEIMAGE SS&: _FREEIMAGE AW&: _FREEIMAGE ZS&: _FREEIMAGE ORI&
    _FREEIMAGE flight&: _FREEIMAGE evade&: _FREEIMAGE intercept&
    _FREEIMAGE cancel&: _FREEIMAGE XZ&: _FREEIMAGE IZ&
    _FREEIMAGE OZ&: _FREEIMAGE RG&: _FREEIMAGE OB&: _FREEIMAGE GD&
    _FREEIMAGE AZ&: _FREEIMAGE IN&: _FREEIMAGE JP&: _FREEIMAGE DI&
    _FREEIMAGE DN&: _FREEIMAGE QT&: _FREEIMAGE ShpT: _FREEIMAGE ShpO
    _FREEIMAGE TLoc: _FREEIMAGE TLocn: _FREEIMAGE TunLoc
    _FREEIMAGE flag: _FREEIMAGE slave: _FREEIMAGE trnon: _FREEIMAGE trnoff
    IF fa12& > 0 THEN _FREEFONT (fa12&)
    IF fa10& > 0 THEN _FREEFONT (fa10&)
    IF fa32& > 0 THEN _FREEFONT (fa32&)
    IF fa14& > 0 THEN _FREEFONT (fa14&)
    IF ft16& > 0 THEN _FREEFONT (ft16&)
    IF ft14& > 0 THEN _FREEFONT (ft14&)
    IF ft12& > 0 THEN _FREEFONT (ft12&):

END SUB 'Terminus


'±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
SUB Turn_2_Clock (var AS INTEGER)

    'called from: Load_Scenario, Move_Turn, M_Turn_Undo
    s = var * 1000 '                                            convert turns to seconds
    etd = INT(s / 86400) '                                      elapsed time days
    eth = INT((s - etd * 86400) / 3600) '                       elapsed time hours
    etm = INT((s - (etd * 86400 + eth * 3600)) / 60) '          elapsed time minutes
    ets = s - (etd * 86400 + eth * 3600 + etm * 60) '           elapsed time seconds

END SUB 'Turn_2_Clock


'±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
SUB Trunc_Coord (var AS _INTEGER64)

    'called from: Disp_Data
    IF ABS(var) >= 100000000 THEN '                             convert long coordinates
        x$ = STR$(INT(var / 1000000)) + "M" '                   to abbreviated versions
    ELSEIF ABS(var) >= 100000000000 THEN
        x$ = STR$(INT(var / 1000000000)) + "G"
    ELSE
        x$ = STR$(var)
    END IF
    PRINT x$;

END SUB 'Trunc_Coord


'±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
SUB VCS

    'called from: Refresh
    'Relative/Display Vector Coordinate System
    REDIM rcs(units) AS V3 '                                    Relative Coordinate / Ship
    REDIM rcp(orbs) AS V3 '                                     Relative Coordinate / Planet
    REDIM dcs(units) AS V3 '                                    display Coordinate / Ship
    REDIM dcp(orbs) AS V3 '                                     display Coordinate / Planet
    IF units = 0 THEN vpoint = 0: d = 0 ELSE d = 1

    c = d
    DO '                                                        ITERATE THROUGH SHIPS, setting coordinates for unit c
        rcs(c) = cmb(c).ap: Vec_Add rcs(c), cmb(vpoint).ap, -1 'Set relative ship coordinate system from active unit
        dcs(c) = rcs(c) '                                       initialize display coordinate
        IF togs AND 2 THEN Vec_Rota dcs(c) '                    adjust display coordinates for rotation
        c = c + 1
    LOOP UNTIL c > units

    c = 1 'was c = d, but would make a 0 planet if no ships
    DO '                                                        ITERATE THROUGH PLANETS
        IF hvns(c).star <> 2 THEN '                             Belts and rings have parent centers and orbit radii instead of coordinates
            rcp(c) = hvns(c).ps: Vec_Add rcp(c), cmb(vpoint).ap, -1 'Set relative planet coordinate point from active unit
            dcp(c) = rcp(c)
            IF togs AND 2 THEN Vec_Rota dcp(c)
        END IF
        c = c + 1
    LOOP UNTIL c > orbs

END SUB 'VCS


'±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
SUB Vec_Add (var AS V3, var2 AS V3, var3 AS INTEGER)

    'Add two vectors
    var.pX = var.pX + (var2.pX * var3) '                        add (or subtract) two vectors defined by V3
    var.pY = var.pY + (var2.pY * var3) '                        var= base vector, var2= vector to add
    var.pZ = var.pZ + (var2.pZ * var3) '                        var3 multiple of var2 to add (-sign to subtract)

END SUB 'Vec_Add


'±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
SUB Vec_Cross (var AS V3, var2 AS V3, var3 AS V3)

    'Obtain cross product vector of vectors var2 and var3
    'var is returned as perpendicular plane defining vector
    var.pX = var2.pY * var3.pZ - var2.pZ * var3.pY
    var.pY = -(var2.pX * var3.pZ - var2.pZ * var3.pX)
    var.pZ = var2.pX * var3.pY - var2.pY * var3.pX

END SUB 'Vec_Cross


'±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
SUB Vec_Cross_Unit (var AS V3U, var2 AS V3U, var3 AS V3U)

    'Obtain cross product vector of vectors var2 and var3
    'var is returned as perpendicular plane defining vector
    var.x = var2.y * var3.z - var2.z * var3.y
    var.y = -(var2.x * var3.z - var2.z * var3.x)
    var.z = var2.x * var3.y - var2.y * var3.x

END SUB 'Vec_Cross



'±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
FUNCTION Vec_Dot (var AS V3, var2 AS V3)

    'Obtain scalar dot product between two V3 vectors
    Vec_Dot = var.pX * var2.pX + var.pY * var2.pY + var.pZ * var2.pZ

END FUNCTION 'Vec_Dot


'±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
FUNCTION Vec_Dot_Unit (var AS V3U, var2 AS V3U)

    Vec_Dot_Unit = var.x * var2.x + var.y * var2.y + var.z * var2.z

END FUNCTION 'Vec_Dot_Unit


'±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
SUB Vec_Mult (vec AS V3, multiplier AS SINGLE)

    'multiply vector by scalar value
    vec.pX = vec.pX * multiplier
    vec.pY = vec.pY * multiplier
    vec.pZ = vec.pZ * multiplier

END SUB 'Vec_Mult


'±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
SUB Vec_Mult_Unit (vec AS V3, vecu AS V3U, multiplier AS _INTEGER64)

    'multiply a unit vector (vecu) & return as a V3 (vec)
    vec.pX = vecu.x * multiplier
    vec.pY = vecu.y * multiplier
    vec.pZ = vecu.z * multiplier

END SUB 'Vec_Mult_Unit


'±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
SUB Vec_Rota (var AS V3)

    ''rotate around Z axis
    'x&& = var.pX: y&& = var.pY
    ''xangle equations
    'var.pX = x&& * COS(xangle) + y&& * SIN(xangle)
    'var.pY = x&& * -SIN(xangle) + y&& * COS(xangle)

    'rotate around X axis
    y&& = var.pY: z&& = var.pZ
    var.pY = y&& * COS(zangle) + z&& * SIN(zangle)
    var.pZ = y&& * -SIN(zangle) + z&& * COS(zangle)

END SUB 'Vec_Rota


'±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
SUB Vec_2_Thrust (var AS INTEGER, var2 AS V3)

    'Change an input vector to a polar thrust for unit var
    ds&& = PyT(3, origin, var2)
    Thrust(var).Gs = ds&& / 5000
    IF Thrust(var).Gs > cmb(var).MaxG THEN Thrust(var).Gs = cmb(var).MaxG
    Thrust(var).Azi = Azimuth!(var2.pX, var2.pY)
    Thrust(var).Inc = Slope!(var2, origin)

END SUB 'Vec_2_Thrust


'±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
SUB Vec_2_UVec (var AS V3, var2 AS V3U)

    'convert a V3 to V3U, return in var2
    DIM AS _FLOAT x, y, z, m
    x = var.pX: y = var.pY: z = var.pZ
    m = SQR(x * x + y * y + z * z)
    IF m = 0 THEN
        var2.x = 0
        var2.y = 0
        var2.z = 0
    ELSE
        var2.x = x / m
        var2.y = y / m
        var2.z = z / m
    END IF

END SUB 'Vec_2_UVec


'±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
SUB Vector_Brake

    'Called from: Mouse_Button_Left, New_Vector
    IF cmb(vpoint).bstat = 5 OR cmb(vpoint).status = 3 THEN
    ELSE
        Panel_Blank 0, 650, 64, 32
        Con_Blok 0, 650, 64, 32, "Applied", 0, &H502C9B2C
        _DISPLAY
        _DELAY .5
        Thrust(vpoint).Azi = cmb(vpoint).Hd + _PI
        Thrust(vpoint).Inc = -1 * cmb(vpoint).In
        IF cmb(vpoint).Sp / 5000 < Thrust(vpoint).Gs THEN
            Thrust(vpoint).Gs = cmb(vpoint).Sp / 5000
        END IF
        IF Thrust(vpoint).Gs > cmb(vpoint).MaxG THEN
            Thrust(vpoint).Gs = cmb(vpoint).MaxG
        END IF
    END IF

END SUB 'Vector_Brake


'±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
SUB Z_Panner

    'called from: Screen_Limits
    'Draw Z-pan label
    dfp$ = "display angle from     ecliptic plane   "
    IF fa32& > 0 THEN '                                         if font loaded
        T& = _NEWIMAGE(640, 32, 32)
        _DEST T&
        CLS
        COLOR _RGBA32(127, 127, 127, 50) '                      print in light grey
        _FONT fa32&
        _PRINTSTRING (0, 0), dfp$, T&
        _FONT 16
        _DEST ZS&
        CLS
        RotoZoom3 20, 333, T&, 1, 1, _PI / 2 '                  turn label vertical
    ELSE '                                                      if _LOADFONT failed
        T& = _NEWIMAGE(320, 16, 32)
        _DEST T&
        CLS
        COLOR _RGBA32(127, 127, 127, 50) '                      print in light grey
        _PRINTSTRING (0, 0), dfp$, T&
        _DEST ZS&
        CLS
        RotoZoom3 20, 333, T&, 2, 2, _PI / 2 '                  turn label vertical
    END IF
    _FREEIMAGE T&

    'Draw Z-pan scrollbar
    LINE (0, 0)-(39, 649), clr&(4), B '                         red border
    IF togs AND 2 THEN c& = &HFF7F7F7F ELSE c& = &HFFFF7F7F
    LINE (2, 317)-(37, 332), c&, BF '                           centering button
    IF togs AND 2 THEN '                                        if Z-pan toggle is true
        SELECT CASE zangle
            CASE IS < 0
                yp = map!(zangle, -_PI / 2, 0, 0, 316)
            CASE IS = 0: yp = 324
            CASE IS > 0
                yp = map!(zangle, 0, _PI / 2, 333, 649)
        END SELECT
        LINE (1, yp)-(6, yp - 5), clr&(12) '                    arrow indicator
        LINE (1, yp)-(6, yp + 5), clr&(12)
        COLOR clr&(12)
        _PRINTMODE _KEEPBACKGROUND
        _PRINTSTRING (10, yp - 8), _TRIM$(STR$(INT(_R2D(_PI / 2 - zangle)))) + CHR$(248) 'degree value and degree symbol
    END IF
    _PUTIMAGE (1204, 4), ZS&, A&

END SUB 'Z_Panner


'±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±

