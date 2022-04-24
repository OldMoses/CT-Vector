'$CONSOLE
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
'² º º SMcNeill, SierraKen, FellippeHeitor, SpriggsySpriggs, et.al. at QB64       º º ²
'² º º forum.                                                                     º º ²
'² º º Thank you.                                                                 º º ²
'² º º                                                                            º º ²
'² º º Thanks to my son Erik for the idea to include an auto counter thrust,      º º ²
'² º º as well as listening to the endless blather.                               º º ²
'² º º                                                                            º º ²
'² º º Development and beta test version 0.52  uploaded __-__-2021                º º ²
'² º º                                                                            º º ²
'² º º The Traveller game in all forms is owned by Far Future Enterprises.        º º ²
'² º º Copyright 1977 - 2008 Far Future Enterprises.                              º º ²
'² º º see SUB Comments for full fair use text and development notes.             º º ²
'² º º                                                                            º º ²
'² º ÈÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼ º ²
'² ÈÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼ ²
'²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²

'                                                               USER DEFINED VARIABLES
TYPE V3 '                                                       R3 ship/planet vector movement or position
    pX AS _INTEGER64 '                                          X coordinate / mem 0-7
    pY AS _INTEGER64 '                                          Y coordinate / mem 8-15
    pZ AS _INTEGER64 '                                          Z coordinate / mem 16-23
END TYPE

TYPE V3U '                                                      float precision for converting V3 to unit vectors
    x AS _FLOAT '                                               X coordinate / mem 0-31
    y AS _FLOAT '                                               Y coordinate / mem 32-63
    z AS _FLOAT '                                               Z coordinate / mem 64-95
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

TYPE Odata
    oip AS V3 '                                                 orbital insertion point
    nrm AS V3U '                                                orbit plane normal unit vector
    alt AS _INTEGER64 '                                         orbital altitude
END TYPE

TYPE sort '                                                     Large value sorting variable
    index AS INTEGER
    value AS _INTEGER64
END TYPE

'                                                               GLOBAL VARIABLES, ARRAYS AND HANDLES
DIM SHARED VerA AS _BYTE '                                      Version A.#.#
DIM SHARED VerB AS _BYTE '                                      Version #.B.#
DIM SHARED VerC AS _BYTE '                                      Version #.#.C
DIM SHARED ttl AS STRING * 15 '                                 Title bar text
DIM SHARED clr&(0 TO 15) '                                      32 bit equivalent of SCREEN 0 colors
DIM SHARED hvns(x) AS body '                                    System stars and planets data array
DIM SHARED cmb(x) AS ship '                                     unit data array (Combatants)
DIM SHARED rcs(x) AS V3 '                                       Relative Coordinate Ship-   x,y,z relative to vpoint
DIM SHARED rcp(x) AS V3 '                                       Relative Coordinate Planet-   "   "   "    "    "
DIM SHARED dcs(x) AS V3 '                                       display Coordinate Ship-      "   "   "    "    "
DIM SHARED dcp(x) AS V3 '                                       display Coordinate Planet-    "   "   "    "    "
'DIM SHARED ihat AS V3 '                                         x axis identity vector
'DIM SHARED jhat AS V3 '                                         y axis identity vector
DIM SHARED khat AS V3 '                                         z axis identity vector
'DIM SHARED xangle AS SINGLE '                                   Andle of rotation on ecliptic
DIM SHARED zangle AS SINGLE '                                   Angle from overhead for Z-pan
DIM SHARED Ozang AS SINGLE '                                    Old 3D angle value for fast toggle
DIM SHARED vpoint AS _UNSIGNED _BYTE '                          active unit pointer
DIM SHARED shipoff AS _UNSIGNED _BYTE '                         display offset for ship data scroll
DIM SHARED units AS _UNSIGNED _BYTE '                           number of combatant units
DIM SHARED exists AS _UNSIGNED _BYTE '                          number of units undestroyed
DIM SHARED collision AS _BYTE '                                 collision check variable
DIM SHARED Thrust(x) AS Maneuver '                              Applied acceleration
DIM SHARED Gwat(x) AS Maneuver '                                Acceleration vector of gravitational influences
DIM SHARED OrbDat(x) AS Odata '                                 unit indexed orbit data
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
DIM SHARED oryr AS _FLOAT '                                     # of years since 000-0000 1 turn= 10/864 of a day .00003171 oryr
DIM SHARED SenMax AS LONG '                                     Maximum target lock range
DIM SHARED SenLocC AS LONG '                                    Minimum civilian sensor target lock range
DIM SHARED SenLocM AS LONG '                                    Minimum military sensor target lock range
DIM SHARED RngCls AS LONG '                                     Close combat range
DIM SHARED RngMed AS LONG '                                     Medium combat range
DIM SHARED A& '                                                 Main screen handle
DIM SHARED AW& '                                                Azimuth wheel overlay handle
DIM SHARED IW& '                                                Inclinometer wheel overlay handle
DIM SHARED SS& '                                                Sensor screen handle
DIM SHARED ZS& '                                                Z-pan screen handle
DIM SHARED ORI& '                                               Orientation screen handle
DIM SHARED Moon& '                                              landed image handle
REDIM SHARED ship_box(20) AS LONG '                             Ship data display box
DIM SHARED ship_hlpA AS LONG '                                  Ship data help image active
DIM SHARED ship_hlpB AS LONG '                                  Ship data help image inactive
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
DIM SHARED ShpOT AS LONG '                                      Overthrusting ship image handle
DIM SHARED ShpO AS LONG '                                       Non-thrusting ship image handle
DIM SHARED TLoc AS LONG '                                       Target lock icon handle
DIM SHARED TLocn AS LONG '                                      Target lock not available handle
DIM SHARED TunLoc AS LONG '                                     Target unlock icon handle
DIM SHARED flag AS LONG '                                       Flag ship- has units slaved to it
DIM SHARED slave AS LONG '                                      fleet locked indicator
DIM SHARED trnon AS LONG '                                      Transponder on image handle
DIM SHARED trnoff AS LONG '                                     Transponder off image handle
DIM SHARED dsabl AS LONG '                                      disable shatter image
DIM SHARED fa12& '                                              FONT HANDLES
DIM SHARED fa10&
DIM SHARED fa14&
DIM SHARED fa32&
DIM SHARED ft16&
DIM SHARED ft14&
DIM SHARED ft12&

DIM SHARED togs AS _UNSIGNED LONG '                             Display/Control toggles
'                                                               Undo toggle- prevents more than one turn undo       togs bit=0  ³ AND 1
'                                                               Z-pan toggle (hotkey 3).............................togs bit=1  ³ AND 2
'                                                               Azimuth wheel toggle (hotkey a)                     togs bit=2  ³ AND 4
'                                                               Grid toggle (hotkey g)..............................togs bit=3  ³ AND 8
'                                                               Ranging circle toggle (hotkey r)                    togs bit=4  ³ AND 16
'                                                               Inclinometer toggle (hotkey i)......................togs bit=5  ³ AND 32
'                                                               Jump diameter toggle (hotkey j)                     togs bit=6  ³ AND 64
'                                                               Orbit track display toggle (hotkey o)...............togs bit=7  ³ AND 128
'                                                               Gravity zone toggle (hotkey z)                      togs bit=8  ³ AND 256
'                                                               Jump diameters or density (hotkey d)................togs bit=9  ³ AND 512
'                                                               Belt/ring display toggle (hotkey b)                 togs bit=10 ³ AND 1024
'                                                               Block move mode (mouse only)........................togs bit=11 ³ AND 2048
'                                                               Collision check mode (mouse only)                   togs bit=12 ³ AND 4096
'                                                               3D mode=1 / 2D mode=0 (initial parameter only)......togs bit=13 ³ AND 8192
'                                                               Rank show TRUE/FALSE (hotkey #)                     togs bit=14 ³ AND 16384
'                                                               bit 15-31 for future expansions

'                                                               DEBUGGING VARIABLES (if any present for beta testing)


'                                                               INITIAL PARAMETERS
VerA = 0: VerB = 5: VerC = 2 '                                  version tags
ttl = "CT Vector 0.52" '                                        Title bar string
origin.pX = 0: origin.pY = 0: origin.pZ = 0 '                   zero vector
'ihat.pX = 1: ihat.pY = 0: ihat.pZ = 0 '                         x identity unit vector
'jhat.pX = 0: jhat.pY = 1: jhat.pZ = 0 '                         y identity unit vector
khat.pX = 0: khat.pY = 0: khat.pZ = 1 '                         z identity unit vector
cmb(0).ap = origin '                                            No ships left active unit at origin (within rank 1 feature)
Turncount = 0 '                                                 game turn number- determines elapsed time in scenario
vpoint = 1 '                                                    active unit pointer
ZoomFac = 1 '                                                   Zoom factor
shipoff = 0 '                                                   ship list scrolling offset value

'the following will be re-initialized in SUB Gate_Keeper if default.ini is present
togs = &B00000000000000000111010110001101 '                     set toggle initial state &H758D, dec 30093
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
'                                                               bit 5 = unused
'                                                               bit 6 = unused
'                                                               bit 7 = unused

RESTORE colors
FOR x% = 0 TO 15 '                                              iterate colors 0 thru 15
    READ r% '                                                   get red component
    READ g% '                                                   get green component
    READ b% '                                                   get blue component
    clr&(x%) = _RGB32(r%, g%, b%) '                             mix color x into array
NEXT x%

'                                                               IMAGES _FONTS AND BUTTONS
FOR Ascii% = 0 TO 255 '                                         PETR'S CHARACTER IMAGE LOADER
    chr_img(Ascii%) = _NEWIMAGE(8, 16, 32) '                    create image for each ASCII character
    _DEST chr_img(Ascii%) '                                     set image _DESTination of ASCII character
    _PRINTMODE _KEEPBACKGROUND '                                transparency for graphics overlays
    COLOR Whitesmoke
    _PRINTSTRING (0, 0), CHR$(Ascii%), chr_img(Ascii%) '        put ASCII character in image
NEXT Ascii% '                                                   now any size ASCII character can be printed

A& = _NEWIMAGE(1250, 700, 32) '                                 Main display
SS& = _NEWIMAGE(620, 620, 32) '                                 Sensor screen display
AW& = _NEWIMAGE(620, 620, 32) '                                 Azimuth wheel overlay                created in Make_Images
IW& = _NEWIMAGE(620, 620, 32) '                                 Inclinometer wheel overlay              "     "   "     "
ship_hlpA = _NEWIMAGE(290, 96, 32) '                            Active ship data help image             "     "   "     "
ship_hlpB = _NEWIMAGE(290, 96, 32) '                            Inactive ship data help image           "     "   "     "
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
    ShpOT = _LOADIMAGE("images\ovrthrust.png", 32) '            ship- overthrusting
    ShpO = _LOADIMAGE("images\suleimano.png", 32) '             ship- no thrust
    TLoc = _LOADIMAGE("images\tlock.png", 32) '                 target lock icon
    TLocn = _LOADIMAGE("images\tlockn.png", 32) '               target lock n/a
    TunLoc = _LOADIMAGE("images\tunlock.png", 32) '             target unlock icon
    flag = _LOADIMAGE("images\flag.png", 32) '                  flag ship
    slave = _LOADIMAGE("images\slave.png", 32) '                fleet lock icon
    trnon = _LOADIMAGE("images\trnsp1.png", 32)
    trnoff = _LOADIMAGE("images\trnsp0.png", 32)
    Moon& = _LOADIMAGE("images\moon1.jpg", 32)
    dsabl = _LOADIMAGE("images\disabled.png", 32)
ELSE
    Bad_Install "images", -1
END IF

Make_Buttons '                                                  Create control buttons
Make_Images '                                                   Create overlays

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

$IF WIN THEN
    _SCREENMOVE 5, 5
    '_SCREENMOVE _DESKTOPWIDTH - _WIDTH(A&), 5 '                     temporary console debug position
$END IF

Gate_Keeper '                                                   Splash screen and setup

t1% = _FREETIMER '                                              Autosave timer
ON TIMER(t1%, 60) Save_Scenario 0 '                             save every minute
TIMER(t1%) ON

Main_Loop '                                                      Enter main program loop
END

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
DATA "PC vessel",2,-500000,-500000,0,0,0,0,0
DATA "Cruiser",4,-650000,-530000,0,0,0,0,-1
DATA "Raider",2,-700000,230000,0,0,0,0,0
DATA "SysDefBoat",6,-670000,231000,0,0,0,0,-1

'                                                               END DATA SECTION
'                                                               END MAIN MODULE
'**********************************************************************************
'                                                               BEGIN SUB/FUNCTION SECTION


'±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
SUB Add_Ship

    'Appends new ship to list- reconfigures sensor array
    'called from: Main_Loop, MouseOps
    Panel_Blank 420, 578, 64, 32
    Con_Blok 420, 578, 64, 32, "Adding", 0, &H508C5B4C
    _DISPLAY

    IF units > 0 THEN
        DIM ts(units, units) AS _BYTE '                         define a temp sensor holder
        FOR x% = 1 TO units '                                   save state of Sensor & TLock
            FOR y% = 1 TO units
                ts(x%, y%) = Sensor(x%, y%)
        NEXT y%, x%

        units = units + 1 '                                     increment ship counter
        REDIM Sensor(units, units)
        FOR x% = 1 TO units - 1 '                               reload Sensor & TLock
            FOR y% = 1 TO units - 1
                Sensor(x%, y%) = ts(x%, y%)
        NEXT y%, x%
    ELSE
        units = units + 1
        REDIM Sensor(units, units)
    END IF

    Index_Ship units, -1
    ship_box(units) = _NEWIMAGE(290, 96, 32) '                  define data image for new vessel
    cmb(units).id = cmb(units - 1).id + 1 '                     use next consecutive id number
    cmb(units).status = 1
    cmb(units).ap.pX = cmb(vpoint).ap.pX + 100000 '             start near active unit
    cmb(units).ap.pY = cmb(vpoint).ap.pY + 100000 '             edit call can change this
    cmb(units).ap.pZ = 0
    FOR x% = 1 TO orbs '                                         check planets for interference
        IF PyT(3, cmb(units).ap, hvns(x%).ps) > hvns(x%).radi THEN _CONTINUE 'if outside planet then skip
        DO
            cmb(units).ap.pX = cmb(units).ap.pX + 100000 '      move ship until beyond planet radius
        LOOP UNTIL PyT(3, cmb(units).ap, hvns(x%).ps) > hvns(x%).radi
    NEXT x%
    vpoint = units '                                            set as active
    Sensor(vpoint, vpoint) = _SETBIT(Sensor(vpoint, vpoint), 4) 'transponder on
    Edit_Ship -1

END SUB 'Add_Ship


'±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
SUB Auto_Move (tar AS INTEGER, sol AS INTEGER, mode AS INTEGER)

    ' Calculate and issue automated maneuvers to return to Move_Turn
    ' Auto_Move only calculates the closing vector for each turn, and assigns
    ' that vector to the {sol} indexed Thrust array variable. Move_Turn and its
    ' Coord_Update call actually execute the maneuver.
    ' called from: Move_Turn {prior to Coord_Update}
    ' tar = target unit: tar is carried in cmb(sol).bogey
    '       it may be another ship or a planet depending upon the mode.
    ' sol = solution unit: i.e. unit executing the nav order, always a ship
    ' mode = type of maneuver order, carried in cmb(sol).bstat
    '        0=no order.....................Auto_Move will not be called
    '        1=evade........................relative to a ship
    '        2=intercept....................relative to a ship
    '        3=planetfall/land..............relative to a planet
    '        4=orbit........................relative to a planet
    '        5=fleet........................relative to a ship
    '        6=hold station.................relative to a planet
    '        7=safe jump point (nearest)....relative to a planet
    'typical syntax: Auto_Move cmb(x).bogey, unit x, [0 - 7]

    IF cmb(sol).status = 3 THEN EXIT SUB '                      disabled unit is incapable of a maneuver

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
    'DIM usolmov AS V3U '                                        sol's moving unit vector
    solpos = cmb(sol).ap

    'position & movement of target entity: planet or ship depending upon AI mode
    IF mode < 3 OR mode = 5 THEN
        tarpos = cmb(tar).ap
        tarmov = cmb(tar).ap: Vec_Add tarmov, cmb(tar).op, -1 'compute last target movement vector (target velocity)
        solmov = cmb(sol).ap: Vec_Add solmov, cmb(sol).op, -1 'compute last solution movement vector (solution velocity)
    ELSE
        tarpos = hvns(tar).ps 'is there a turnundo/redo bug affecting this???                                           POSSIBLE BUG?
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
            Vec_2_Thrust Thrust(sol), clsmov, cmb(sol).MaxG '   initiate evading thrust
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
                Vec_2_Thrust Thrust(sol), clsmov, cmb(sol).MaxG
            ELSE '                                              if sensors ARE occluded
                cmb(sol).bstat = 0: cmb(sol).bogey = 0 '        contact lost, cancel the order
                'ortho thrust to avoid a planet
                tmp = solmov: Vec_Mult tmp, -1
                'clsmov.pX = -tmp.pY
                'clsmov.pY = tmp.pX
                Vec_2_Thrust Thrust(sol), clsmov, cmb(sol).MaxG
            END IF '                                            end: sensor occlusion test
        CASE IS = 3
            'ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
            '³ PLANETFALL       ³ {sol} conducts a landing operation on selected world {tar} WORKING
            'ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
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
                'we'll assume landing quick and dirty
                cmb(sol).status = 2: cmb(sol).bogey = tar '     set landed status and body
                cmb(sol).bstat = 0: Thrust(sol).Gs = 0 '        shut 'er down
            ELSE '                                              we'll continue with approach maneuvers
                Vec_Mult clsmov, (PyT(3, origin, clsmov) / (cmb(sol).MaxG * 5000)) 'throttle back when necessary

                IF PyT(3, cmb(sol).ap, hvns(tar).ps) < hvns(tar).radi * 1.3 THEN 'if we're within 20% of planet radius
                    clsmov = tarmov: Vec_Add clsmov, solmov, -1 'match vector
                END IF
                Vec_2_Thrust Thrust(sol), clsmov, cmb(sol).MaxG
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
            'This in Main Module- if we use this approach
            'TYPE Odata
            '    oip AS V3 'orbital insertion point  relative to tarpos
            '    in AS _BYTE 'orbit entered  we can put this in sol's bdata since alt already contains this
            '    nrm AS V3U 'orbit plane normal unit vector
            '    alt AS _INTEGER64 'orbital altitude
            'END TYPE
            'DIM SHARED OrbDat(units) as Odata
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

            ''see orbit problem.txt for code history
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
            Vec_2_Thrust Thrust(sol), clsmov, cmb(sol).MaxG
        CASE IS = 7
            'ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
            '³ SAFE JUMP POINT  ³ {sol} maneuvers to the nearest safe jump distance
            'ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
            DIM AS V3 s2t, s2p, lvt, lvp
            redoo:
            tr = hvns(tar).rank
            IF togs AND 512 THEN '                              density or diameter jump zone
                l! = hvns(tar).dens
                IF tr > 1 THEN lp! = hvns(Find_Parent(tar)).dens
            ELSE
                l! = 1: lp! = 1
            END IF
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
                    ELSE
                        cmb(sol).bogey = Find_Parent(tar) '     switch to parent, if not already, for next turn
                        tar = cmb(sol).bogey
                        GOTO redoo
                    END IF
                ELSE
                    cmb(sol).bstat = 0: cmb(sol).bogey = 0: Thrust(sol).Gs = 0 'safe to jump
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
            Vec_2_Thrust Thrust(sol), clsmov, cmb(sol).MaxG
    END SELECT

END SUB 'Auto_Move


'±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
FUNCTION Az_From_Parent (var AS INTEGER)

    'called from: various
    DIM AS V3 t, c '                                            target planet & planet's parent (x,y) position
    c = hvns(Find_Parent(var)).ps: t = hvns(var).ps '           position vectors and distance
    Az_From_Parent = Azimuth!(t.pX - c.pX, t.pY - c.pY) '       azimuth between body and parent

END FUNCTION 'Az_From_Parent


'±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
FUNCTION Azimuth! (x AS _INTEGER64, y AS _INTEGER64)

    'Returns the azimuth bearing of a relative (x,y) offset
    'adjusts for modified screen coordinate system
    'called from: various
    IF x < 0 AND y >= 0 THEN
        Azimuth! = 7.853981 - ABS(_ATAN2(y, x)) '               _pi * 2.5 = 7.853981
    ELSE
        Azimuth! = 1.570796 - _ATAN2(y, x) '                    _pi / 2 = 1.570796
    END IF

END FUNCTION 'Azimuth!


'±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
SUB Azimuth_Wheel

    'Draw Azimuth wheel display
    'called from: New_Vector_Graph, Sensor_Screen
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

    'determine azimuth bearing on ecliptic plane of 'unit' from viewpoint
    'and check for possible collision/docking
    'called from: Ship_Display
    collision = (rcs(unit).pX = 0) * (rcs(unit).pY = 0) * (rcs(unit).pZ = 0)
    Bearing = Azimuth!(rcs(unit).pX, rcs(unit).pY)

END FUNCTION 'Bearing


'±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
SUB Bevel_Button (xsiz AS INTEGER, ysiz AS INTEGER, col AS _UNSIGNED LONG)

    'Create control button bevels for 3D effect - called from Con_Blok & Make_Buttons
    'Inspiration and basic algorithm by SierraKen
    'called from: Con_Blok, Make_Buttons
    brdr% = ABS(_SHR(ysiz, 2) * (ysiz <= xsiz) + _SHR(xsiz, 2) * (ysiz > xsiz)) '{branchless}
    FOR b% = 0 TO brdr%
        c = c + 100 / brdr%: r% = -(b% <> 0)
        LINE (0 + b%, 0 + b%)-(xsiz - 1 - b%, ysiz - 1 - b%), _RGBA32((_RED32(col) - 100 + c) * r%,_
         (_GREEN32(col) - 100 + c) * r%, (_BLUE32(col) - 100 + c) * r%, _ALPHA(col)), B
    NEXT b%

END SUB 'Bevel_Button


'±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
SUB Build_Str (main AS STRING, allow AS STRING, kp AS STRING)

    'Build a string out of allowable characters, return in 'main'
    'called from: New_Vector_Graph
    IF kp = CHR$(8) THEN
        IF LEN(main) > 0 THEN main = LEFT$(main, LEN(main) - 1)
    ELSE
        IF INSTR(allow, kp) <> 0 THEN main = main + _TRIM$(kp)
    END IF
    kp = ""

END SUB 'Build_Str


'±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
SUB Button_Block

    'MANEUVER AND PROGRAM CONTROLS under data blocks and orientation screen
    'called from: Refresh
    Astat% = cmb(vpoint).status
    'First tier buttons: start at (0, 578) advance 70/
    Con_Blok 0, 578, 64, 32, "Vector", 1, &HFF2C9B2C
    IF cmb(vpoint).bstat = 5 OR Astat% = 3 THEN '   if active in fleet or disabled
        Panel_Blank 0, 578, 64, 32
    END IF
    'Con_Blok 70, 578, 64, 32, "n/a", 0, &HFF2C9B2C '           future button place keeper
    'Con_Blok 140, 578, 64, 32, "n/a", 0, &HFF2C9B2C '          future button place keeper
    Con_Blok 210, 578, 64, 32, "Turn", 1, &HFF2C9B2C
    Con_Blok 280, 578, 64, 32, "EditShp", 1, &HFFA6A188
    Con_Blok 350, 578, 64, 32, "Delete", 0, &HFFC80000
    Con_Blok 420, 578, 64, 32, "LoadAll", 1, &HFF2C9B2C
    Con_Blok 490, 578, 64, 32, "SaveAll", 1, &HFF8C5B4C

    'Second tier buttons: start at (0, 614) advance 70/
    Con_Blok 0, 614, 64, 32, "Gs= 0", 0, &HFF2C9B2C
    IF cmb(vpoint).bstat = 5 OR Astat% <> 1 THEN '              if active in fleet, disabled or landed
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
    Con_Blok 420, 614, 64, 32, "LoadSys", 8, &HFF2C9B2C
    Con_Blok 490, 614, 64, 32, "SaveSys", 8, &HFF8C5B4C

    'Third tier buttons: start at (0, 650) advance 70/
    Con_Blok 0, 650, 64, 32, "Brake", 0, &HFF2C9B2C
    IF cmb(vpoint).bstat = 5 OR Astat% <> 1 THEN '              if active in fleet, disabled or landed
        Panel_Blank 0, 650, 64, 32
    END IF
    Con_Blok 70, 650, 64, 32, "Options", 0, &HFF2C9B2C
    Con_Blok 140, 650, 64, 32, "Col/Chk", 0, &HFF2C9B2C
    IF NOT togs AND 4096 THEN Panel_Blank 140, 650, 64, 32 '     if Col/Chk off
    Con_Blok 210, 650, 64, 32, "Help", 1, &HFF4CCB9C
    IF togs AND 2048 THEN c& = &HFFDFDFDF ELSE c& = &HFF3F3F3F 'if MovAll enabled else disabled
    Con_Blok 280, 650, 64, 32, "MovAll", 0, c&
    IF Astat% = 3 THEN s$ = "Repair" ELSE s$ = "Adrift"
    Con_Blok 350, 650, 64, 32, s$, 0, &HFFC80000
    Con_Blok 420, 650, 64, 32, "LoadShp", 15, &HFF2C9B2C
    Con_Blok 490, 650, 64, 32, "SaveShp", 15, &HFF8C5B4C

    'DISPLAY CONTROL TOGGLES - above sensor screen
    IF togs AND 1024 THEN c& = &HFFBFBFBF ELSE c& = &HFF5F5F5F
    Con_Blok 1085, 0, 42, 18, "Belts", 1, c&
    IF togs AND 256 THEN c& = &HFF00DD00 ELSE c& = &HFF5F5F5F
    Con_Blok 1130, 0, 50, 18, "Gzones", 2, c&

    '_DISPLAY CONTROL TOGGLES - permanent images under sensor screen
    _PUTIMAGE (560, 660), XZ&, A& '                             Zoom Extents
    _PUTIMAGE (626, 660), IZ&, A& '                             Zoom In
    _PUTIMAGE (692, 660), OZ&, A& '                             Zoom Out
    COLOR clr&(7)
    _PRINTSTRING (560, 641), "Zoom Factor: " + STR$(ZoomFac), A&
    _PUTIMAGE (762, 660), RG&, A& '                             Ranging Band toggle
    IF NOT togs AND 16 THEN Panel_Blank 762, 660, _WIDTH(RG&), _HEIGHT(RG&)
    _PUTIMAGE (820, 660), OB&, A& '                             Orbit track toggle
    IF NOT togs AND 128 THEN Panel_Blank 820, 660, _WIDTH(OB&), _HEIGHT(OB&)
    _PUTIMAGE (878, 660), GD&, A& '                             Grid toggle
    IF NOT togs AND 8 THEN Panel_Blank 878, 660, _WIDTH(GD&), _HEIGHT(GD&)
    _PUTIMAGE (928, 660), AZ&, A& '                             Azimuth Wheel toggle
    IF NOT togs AND 4 THEN Panel_Blank 928, 660, _WIDTH(AZ&), _HEIGHT(AZ&)
    IF togs AND 8192 THEN '                                     if 3D mode then
        _PUTIMAGE (970, 660), IN&, A& '                         Inclinometer toggle
        IF NOT togs AND 32 THEN Panel_Blank 970, 660, _WIDTH(IN&), _HEIGHT(IN&)
    END IF
    _PUTIMAGE (1012, 660), JP&, A& '                            Jump Envelope toggle
    IF togs AND 64 THEN
        IF togs AND 512 THEN
            _PUTIMAGE (1062, 660), DI&, A& '                    Jump Diameter toggle
        ELSE
            _PUTIMAGE (1062, 660), DN&, A& '                    Jump Density toggle
        END IF
    ELSE
        Panel_Blank 1012, 660, _WIDTH(JP&), _HEIGHT(JP&)
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

    'Eliminate AI orders targeting a particular unit
    'called from: Col_Check, Delete_Ship
    'var=destroyed or deleted unit; var2=planet crash identifier for hold station
    FOR s% = 1 TO units '                   cancel all orders targeting the destroyed unit
        IF s% = var THEN _CONTINUE
        IF cmb(s%).bogey = var THEN
            SELECT CASE cmb(s%).bstat
                CASE 1, 2, 5
                    IF var2 <> 0 THEN '                         hold station pending further orders
                        cmb(s%).bstat = 6: cmb(s%).bogey = var2 'p
                        cmb(s%).bdata = PyT(3, cmb(s%).ap, hvns(var2).ps)
                    ELSE
                        cmb(s%).bstat = 0: cmb(s%).bogey = 0
                    END IF
            END SELECT
        END IF
    NEXT s%

END SUB 'Cancel_AI


'±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
FUNCTION Choose_World% (header AS STRING, mode AS _BYTE)

    'Display world list, click on desired world and its index number is returned
    'called from: Flight_Plan (as mode=-1), Mouse_Button_Left (as mode=0)
    tm% = _SHR((_HEIGHT(A&) - 95), 4) '                         compute available planet slots
    IF tm% > orbs THEN tm% = orbs '                             limit to # of planets

    Dialog_Box header, _WIDTH(A&) / 4, _HEIGHT(A&), 0, &HFF00FF00, &HFFFFFFFF
    backimage& = _COPYIMAGE(0) '                                copy screen background
    DO
        _PUTIMAGE , backimage&, A& '                            display screen background
        k$ = INKEY$
        ms = MBS
        IF ABS(_MOUSEX - _SHR(_WIDTH(A&), 1)) < _SHR(_WIDTH(A&), 3) THEN 'mousehover within 1/8 screen width of list?
            hvr% = _SHR((_MOUSEY - 47), 4) '                        index mouse x hover
        END IF
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
        $IF WIN OR LINUX THEN
            IF ms AND 512 THEN po% = po% + 1 + (po% = orbs - tm%) ' increment offset
            IF ms AND 1024 THEN po% = po% - 1 - (po% < 1) '         decrement offset
        $END IF
        IF k$ = CHR$(0) + CHR$(72) THEN po% = po% - 1 - (po% < 1) ' up arrow/ decrement offset
        IF k$ = CHR$(0) + CHR$(80) THEN po% = po% + 1 + (po% = orbs - tm%) 'down arrow/ increment offset
        FOR x% = 1 TO tm%
            xpos% = _SHR(_WIDTH(A&), 1) - 80 + (32 * (hvns(x% + po%).rank - 1)) 'indent satellites
            ypos% = 63 + ((x% - 1) * 16) '                       assign slot
            IF mode AND x% = hvr% THEN
                dis&& = PyT(3, cmb(vpoint).ap, hvns(x% + po%).ps) * 1000
                T2ar = 2 * SQR(dis&& / (cmb(vpoint).MaxG * 10)) 'Time to cover distance at max Gs
                IF T2ar > 605000 THEN '                         if time greater than one week
                    _PRINTSTRING (xpos% + (LEN(_TRIM$(hvns(x% + po%).nam)) * 8) + 16, ypos%), "micro-jump faster"
                END IF
            END IF
            IF x% = hvr% THEN COLOR &HFFFF0000 ELSE COLOR &HFFFFFFFF 'red on mouseover
            _PRINTSTRING (xpos%, ypos%), hvns(x% + po%).nam '   display planet name
        NEXT x%
        _LIMIT 30
        _DISPLAY
    LOOP UNTIL in '                                             exit loop on valid input
    COLOR &HFFFFFFFF
    _FREEIMAGE backimage&
    Choose_World% = bdy

END FUNCTION 'Choose_World


'±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
SUB Clear_MB (var AS INTEGER)

    'Clear mousebutton var buffer clicks to prevent click thru errors
    DO UNTIL NOT _MOUSEBUTTON(var)
        WHILE _MOUSEINPUT: WEND
    LOOP

END SUB 'Clear_MB


'±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
FUNCTION Closest_Rank_Body (var AS INTEGER, var2 AS INTEGER)

    'Find closest body of rank var2 to unit var. Shorter and sweeter in 0.4.4
    'Syntax: Closest_Rank_Body <unit index>, <rank, 0=all>
    'called from: various
    FOR n% = 1 TO orbs '                                        iterate all bodies
        IF hvns(n%).star = 2 THEN _CONTINUE '                   skipping ring/belt
        IF var2 = 0 THEN '                                      check all, or...
            ds&& = PyT(3, rcs(var), rcp(n%))
        ELSE '                                                  check rank var2, skipping others
            IF hvns(n%).rank <> var2 THEN _CONTINUE
            ds&& = PyT(3, rcs(var), rcp(n%))
        END IF
        IF ds&& < t&& OR t&& = 0 THEN '                         look for closest distance or set first distance
            r% = n% '                                           keep closest body index
            t&& = ds&& '                                        keep temp distance for next iteration
        END IF
    NEXT n%
    Closest_Rank_Body = r%

END FUNCTION 'Closest_Rank_Body


'±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
SUB Col_Check (var AS INTEGER)

    'Check for collision between unit 'var' and any planetary bodies
    'Called from: Move_Turn when 'togs' bit 12 set
    IF cmb(var).status MOD 2 <> 0 THEN '                        unit not landed or destroyed
        DIM movp AS V3 '                                        movement vector of planet
        srch&& = PyT(3, cmb(var).op, cmb(var).ap) '             movement radius of unit
        FOR p% = 1 TO orbs '                                    Iterate through planets
            IF hvns(p%).star = 2 THEN _CONTINUE '               skip belts/rings
            dist&& = PyT(3, cmb(var).ap, hvns(p%).ps) '         distance between unit 'var' and planet 'p'
            IF dist&& - hvns(p%).radi > 300000000 THEN _CONTINUE 'skip distances beyond 2 AU from surface
            Get_Body_Vec p%, movp '                             establish movement of planet
            prch&& = PyT(3, movp, origin) + hvns(p%).radi '     movement radius + radius of planet (danger space)
            IF dist&& <= prch&& + srch&& AND cmb(var).Ostat <> 2 THEN 'if those radii overlap then check for collision
                DIM f AS V3 '                                   end turn planet position
                f = movp: Vec_Add f, hvns(p%).ps, 1 '           f has end of turn planet position
                c = 0
                DO '                                            iterate the seconds in the turn
                    c = c + 1
                    IF Intra_Turn_Vec_Map&&(c, cmb(var).op, cmb(var).ap, hvns(p%).ps, f) <= hvns(p%).radi THEN 'is ship within planet radius on second c?
                        cmb(var).status = 0 '                   unit has been destroyed
                        cmb(var).bogey = p% '                   in collision with 'p'
                        cmb(var).Sp = 0 '                       set all vectors to zero
                        Thrust(var).Azi = 0
                        Thrust(var).Inc = 0
                        Thrust(var).Gs = 0
                        Sensor(var, var) = _RESETBIT(Sensor(var, var), 4) 'transponder silenced

                        Cancel_AI var, p% '                     end all maneuver orders targeting var
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
        NEXT p%
    END IF

END SUB 'Col_Check


'±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
SUB Col_Check_Ship (var AS INTEGER)

    'Check for proximity to other vessels
    FOR s% = 1 TO units '                                       check for unit collisions
        IF s% = var THEN _CONTINUE
        Sensor(var, s%) = _RESETBIT(Sensor(var, s%), 3) '       reset collision flag before checking
        dist&& = PyT(3, cmb(var).ap, cmb(s%).ap)
        IF dist&& > 300000000 THEN _CONTINUE '                  skip distances beyond 2 AU from unit s
        IF dist&& <= PyT(3, cmb(s%).op, cmb(s%).ap) + PyT(3, cmb(var).op, cmb(var).ap) THEN 'if movement radii exceed distance
            c = 0
            DO
                c = c + 1
                IF Intra_Turn_Vec_Map&&(c, cmb(var).op, cmb(var).ap, cmb(s%).op, cmb(s%).ap) < 5 THEN
                    Sensor(var, s%) = _SETBIT(Sensor(var, s%), 3) 'Proximity alert, collision is possible
                END IF
            LOOP UNTIL c = 1000
        END IF
    NEXT s%

END SUB 'Col_Check_Ship


'±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
SUB Coming

    Refresh
    Dialog_Box "Feature under development", 250, 100, 50, &HFFFF7F7F, &HFFFFFFFF
    tex$ = "Coming soon...maybe"
    _PRINTSTRING (_SHR(_WIDTH(A&), 1) - _SHR((LEN(tex$) * 8), 1), 100), tex$, A&
    _DISPLAY
    SLEEP 3

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
    '               Controls:           actuate
    'right button:  Astrogator:         move active unit to click
    '               Ship Data Display:  show detailed information on chosen unit
    '               Controls:           context help
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
    'Ver 0.4.0
    'Added fast mouse wheel zooming.
    'Ver 0.4.3
    'Added transponders and cleaned up file mess for scenario saves and rewrote ship
    'data display.Improved automatic moves of landing and interception.
    'Ver 0.4.4
    'Incorporates a patch to Prnt and MBS% for QB64 v.2.0 compatibility.
    'Locked out certain maneuvers for active landed units. Added right click
    'context help system. Added new material to Options and Help.
    'Consolidated VCS & Sensor_Mask into SUB Re_Calc as they were only ever
    'called from there. Improved satellite movement with recursive rank calling
    'through SUB Satellite_Move. Optimized FUNCTION Closest_Rank_Body. Rewrote
    'SUB Vec_2_Thrust to handle more general vector to polar conversions.
    'Ver 0.5.0
    'redesign of scenario files with oryr variable changed to _FLOAT to allow
    'date display. Mode variable 'togs' changed from INTEGER to LONG in order
    'to facilitate additional future expansions. Old files need conversion with
    'conversion tool '044_050converter.bas' and default.ini should be deleted
    'and reinitialized for this version. Addition of ship indexed orbit data UDT.
    'Add SUB Index_Ship to condense repetitious code throughout. Enhance functioning
    'of SUB New_Vector_Graph to include keyboard input, and overdrive indication.
    'To facilitate that, improved and optimized SUB Dialog_Box to work with all images
    'and added SUB Build_Str
    'Ver 0.5.1
    'fix SUB Draw_Ring_Belt infinite loop when zooming in to 10km and optimized its
    'algorithm. Added SpriggsySpriggs' pipecom function for Windows file ops dialogs.
    'Ver 0.5.2
    'skip G-zone drawing computation loop in SUB System_Map for bodies that can't
    'produce them. Moving fleet flagships now moves fleet subordinates even when
    'MovAll is off. Added OS metacommands for skipping _SCREENMOVE & _MOUSEWHEEL.
    'Hopefully, this will now run under Mac and Linux as well.

    'USER NOTES
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
    '      ÃÄ include\
    '      ³         ³Ä getopen.bas
    '      ³         ÀÄ pipecomqb64.bas
    '      ÃÄ scenarios\*.tfs
    '      ³           ÀÄ autosave\auto.tfs
    '      ÃÄ ships\*.tvg
    '      ÀÄ systems\*.tss

    'ALGORITHMIC STRUCTURE
    'Initial entry occurs at SUB Gate_Keeper and SUB Set_Up
    'Execution is then passed to SUB Main_Loop, from which all subsequent
    'calls are routed. Main_Loop consists of two nested DO...LOOPs, the inner
    'loop handling collection of input commands, and animation of the orientation
    'screen. The outer loop resets the input flag, and loops to update all displays.
    'Mouse input is conditioned by Steve McNeill's FUNCTION MBS%. Mr. McNeill's SUB fcirc
    'also gets the credit for the rendering of planetary orbs in the sensor display.
    'Three coordinate systems are defined. Absolute coordinates are referenced from
    'the primary system star. Relative coordinates are referenced relative to the
    'active unit. Finally, display coordinates are 2D projections of relative coordinates
    'transformed by any applied rotations around the X axis. All load and save file
    'operations are handled through SpriggsySpriggs' getopen.bas & pipecomqb64.bas.

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

    'Projecting one vector onto another:
    'Proj a onto b: Vec_Mult b, Vec_Dot(a, b) / PyT( 3, origin, b) ^ 2
    'Proj b onto a: Vec_Mult a, Vec_Dot(a, b) / PyT( 3, origin, a) ^ 2

    'color legend- for clr&(x) assignments
    '0=black,1=blue,2=green,3=aqua,4=red,5=purple,6=brown,7=white
    '8=gray, +8=bright color, except 14=yellow,

    'Mean Density of Earth = 5.514 g/cm^3 {program uses value of 1}

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

END SUB 'Comments


'±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
SUB Con_Blok (xpos AS INTEGER, ypos AS INTEGER, xsiz AS INTEGER, ysiz AS INTEGER, label AS STRING, high AS INTEGER, col AS _UNSIGNED LONG)

    'Create control block
    'called from: Button_Block, et. al.
    CN& = _NEWIMAGE(xsiz, ysiz, 32)
    _DEST CN&
    COLOR , col
    CLS
    Bevel_Button xsiz, ysiz, col
    _PRINTMODE _KEEPBACKGROUND
    l% = LEN(label)
    'color scheme for ALT {gold} and CTRL {aquamarine} hotkeys
    r% = high \ l% + 1 '                                        set label high color range
    high = high MOD l% '                                        reset high for label length
    c~& = -clr&(4) * (r% = 1) - Gold * (r% = 2) - Aquamarine * (r% = 3) 'set color
    'Check font availability
    IF fa12& > 0 THEN '                                         if font is available
        sx% = _SHR(xsiz, 1) - _SHR(_PRINTWIDTH(_TRIM$(label)), 1) + 3
        sy% = _SHR(ysiz, 1) - _SHR(_FONTHEIGHT(fa12&), 1)
        _FONT fa12&
    ELSE '                                                      if not
        sx% = _SHR(xsiz, 1) - _SHL(l%, 2): sy% = _SHR(ysiz, 1) - 8
    END IF
    'print label
    FOR p% = 1 TO l% '                                          iterate through label characters
        IF p% = high THEN COLOR c~& ELSE COLOR clr&(0) '        print hotkey highlight color else (black)
        IF col = &HFFC80000 THEN COLOR clr&(15)
        _PRINTSTRING (sx%, sy%), MID$(label, p%, 1) '           still worth tweaking IMO
        sx% = sx% + _PRINTWIDTH(MID$(label, p%, 1))
    NEXT p%
    _FONT 16
    _PUTIMAGE (xpos, ypos), CN&, A& '                           place control button
    _FREEIMAGE CN&

END SUB 'Con_Blok


'±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
SUB Coord_Update (var AS INTEGER)

    'updates cmb(var).ap
    'called from: Move_Turn if var1 not landed, landed units treated as radius satellites
    DIM AS V3 CoastD, ThrstD, TotalD
    Polar_2_Vec CoastD, cmb(var).Sp, cmb(var).In, cmb(var).Hd ' Determine coasting deltaXYZ; initial speed

    dist = Thrust(var).Gs * 5000 '                              Determine thrusting magnitude for Move_Turn
    Polar_2_Vec ThrstD, dist, Thrust(var).Inc, Thrust(var).Azi 'Determine thrusting delta XYZ for Move_Turn

    TotalD = CoastD: Vec_Add TotalD, ThrstD, 1 '                Sum Cumulative Coordinates

    'Update unit coordinates
    cmb(var).op = cmb(var).ap '                                 move present to old
    Vec_Add cmb(var).ap, TotalD, 1 '                            update present
    Grav_Well var, -1 '                                         apply gravity influences

END SUB 'Coord_Update


'±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
SUB Dev_Grid

    'visual postioning aid for development
    FOR g% = 0 TO 1200 '
        IF g% MOD 10 = 0 THEN '
            IF g% MOD 100 = 0 THEN g1 = 10 ELSE g1 = 0 '
            'LINE (g% + 25, 26)-(g% + 25, 50 + g1) '
            LINE (g%, 26)-(g%, 50 + g1) '
            IF g1 THEN '
                'LINE (g% + 25, 26)-(g% + 25, 675), &H3F7F7F7F '
                'LINE (25, g%)-(1225, g%), &H3F7F7F7F '
                LINE (g%, 26)-(g%, 675), &H3F7F7F7F '
                LINE (0, g%)-(1200, g%), &H3F7F7F7F '
            END IF '
        END IF '
    NEXT g% '

END SUB 'Dev_Grid


'±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
SUB Dialog_Box (heading AS STRING, xsiz AS INTEGER, ysiz AS INTEGER, ypos AS INTEGER, bcol AS _UNSIGNED LONG, tcol AS _UNSIGNED LONG)

    'superimpose an image centered input box for various input routines
    'called from: various
    cr& = _DEST '                                               save calling destination
    dbox& = _NEWIMAGE(xsiz, ysiz, 32) '                         define box
    _DEST dbox&
    COLOR tcol, &HFF282828 '                                    set text color with grey background
    CLS
    FOR x% = 0 TO 5 '                                           draw bounding box 6 pixels thick
        b~& = -Black * (x% < 2) - bcol * (x% >= 2) '             color=outer two black, balance bcol
        LINE (0 + x%, 0 + x%)-(xsiz - 1 - x%, ysiz - 1 - x%), b~&, B 'draw color border
    NEXT x%
    _PRINTSTRING (_SHR(xsiz, 1) - _SHL(LEN(heading), 2), 31), heading 'print heading two rows below top
    _DEST cr& '                                                 reset to calling destination
    _PUTIMAGE (_SHR(_WIDTH, 1) - _SHR(xsiz, 1), ypos), dbox& '  display box centered over calling destination image
    _FREEIMAGE dbox& '                                          clean up

END SUB 'Dialog_Box


'±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
SUB Draw_Ring_Belt (cntr AS V3, rng AS _INTEGER64, in AS _INTEGER64, rat AS SINGLE)

    'Draw Asteroid belts and ring systems
    'cntr=orbit center position, rng=ring width, in=inner diameter, rat=display ratio
    'called from: System_Map
    DIM AS V3 cen ', PT, drct
    cen.pX = cntr.pX * rat
    stp& = 5 / rat
    IF stp& < 1 THEN stp& = 1 '                                 avoid an endless pb&& loop on extreme zoom settings
    aster& = &H2F7F7FFF '                                       belt/ring color  previous &H087F7F7F too thin for pb stepping
    IF togs AND 2 THEN '                                        if in z-panning mode
        rin% = in * rat
        cen.pY = (cntr.pY * (COS(zangle)) + (cntr.pZ * SIN(zangle))) * rat
        asp! = COS(zangle)
        FOR pb&& = 0 TO rng STEP stp&
            CIRCLE (cen.pX, cen.pY), rin% + (pb&& * rat), aster&, , , asp!
        NEXT pb&&
    ELSE '                                                      if in overhead view
        big% = PyT(2, origin, cntr) > (1415 / rat) * 25
        IF big% THEN
            DIM AS V3 PT, drct '                                Point Tangent position vector & orthogonal direction vector
            DIM AS V3U du '                                     unit vector of orthogonal direction vector
            d2a## = PyT(2, cntr, origin) '                      distance from orbit track center to active unit
            drct.pX = cntr.pY: drct.pY = -cntr.pX '             orthogonal of orbit center direction
            Vec_2_UVec drct, du: Vec_Mult_Unit drct, du, 1415 ' Shrink to unit direction, then expand to screen size
        ELSE
            cen.pY = cntr.pY * rat
        END IF
        FOR pb&& = 0 TO rng STEP stp&
            frm = Frame_Sect%(cntr, (in + pb&&), rat) '         are we in the frame?
            IF frm > 1 THEN '                                   if yes then
                IF big% THEN '                                  if orad is 25 x visual screen then draw line
                    PT = cntr: Vec_Mult PT, -((in + pb&&) / d2a##): Vec_Add PT, cntr, 1 'find tangent point on orbit track
                    Vec_Mult PT, rat
                    LINE (PT.pX, PT.pY)-(PT.pX + drct.pX, PT.pY + drct.pY), aster& 'line in direction from point tangent(PT)
                    LINE (PT.pX, PT.pY)-(PT.pX - drct.pX, PT.pY - drct.pY), aster& 'line in opposite direction from PT
                ELSE
                    CIRCLE (cen.pX, cen.pY), (in + pb&&) * rat, aster&
                END IF
            END IF
        NEXT pb&&
    END IF

END SUB 'Draw_Ring_Belt


'±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
SUB Edit_Ship (var AS _BYTE)

    'called from: Main_Loop, Mouse_Button_Left, Add_Ship
    IF var THEN
        u$ = "Editing new vessel"
    ELSE
        Panel_Blank 280, 578, 64, 32
        Con_Blok 280, 578, 64, 32, "Editing", 1, &HFF8C5B4C
        u$ = "Editing " + _TRIM$(cmb(vpoint).Nam)
    END IF

    t% = 400: r% = 5
    Dialog_Box u$, t%, 250, 100, &HFF8C5B4C, clr&(15)
    in1$ = "Enter new value or press ENTER to default"
    l = _SHR(_WIDTH(A&), 1) - _SHL(LEN(in1$), 2)
    _PRINTSTRING (l, 320), in1$, A&
    _DISPLAY
    col% = _SHR((_SHR(_WIDTH(A&), 1) - _SHR(t%, 1)), 3) + 4 '   set column position
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

    'Steve's circle draw- called from: various
    DIM AS _INTEGER64 R, RError, X, Y
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
    'Accepts a planetary body index (var) and finds the parent body index it orbits
    FOR x% = 1 TO orbs
        IF hvns(var).parnt = hvns(x%).nam THEN Find_Parent = x%: EXIT FOR
    NEXT x%

END FUNCTION 'Find_Parent


'±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
FUNCTION Fix_Float$ (x##, dec AS INTEGER)

    'called from Ship_Display
    bs$ = STR$(x##) '                                           string of input number x##
    ex = INSTR(bs$, "D") + INSTR(bs$, "E")
    IF ex <> 0 THEN '                                           an exponential has been thrown
        pwr = VAL(MID$(bs$, ex + 3))
        'use pwr to loop pwr-1 0's after a "." then use left$(bs,1)
        n$ = "0."
        FOR z% = 1 TO pwr - 1
            n$ = n$ + "0"
        NEXT z%
        Fix_Float$ = n$ + LEFT$(_TRIM$(bs$), 1)
    ELSE '                                                      a decimal number has been thrown
        pnt = INSTR(bs$, ".")
        IF pnt = 0 THEN
            Fix_Float$ = bs$
        ELSE
            Fix_Float$ = LEFT$(bs$, pnt + dec)
        END IF
    END IF

END FUNCTION 'FixFloat##


'±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
SUB Flight_Plan

    'called from: Main_Loop, Mouse_Button_Left
    'Conduct an automated flight orders input - orders interpreted by Auto_Move
    Dialog_Box "Flight Plan", 400, 500, 25, _RGBA32(22, 166, 211, 255), &HFFFFFFFF
    IF cmb(vpoint).status <> 2 THEN flt% = -1 '                 If active unit is in flight
    xb% = _SHR(_WIDTH(A&), 1) - 80
    IF flt% THEN
        Con_Blok xb%, 100, 160, 48, "Jump in Matching", 1, _RGBA32(22, 166, 211, 255)
        Con_Blok xb%, 164, 160, 48, "Goto & Land", 1, _RGBA32(22, 166, 211, 255)
        Con_Blok xb%, 228, 160, 48, "Orbit", 1, _RGBA32(22, 166, 211, 255)
        Con_Blok xb%, 292, 160, 48, "Hold station", 1, _RGBA32(22, 166, 211, 255)
        Con_Blok xb%, 356, 160, 48, "Safe Jump", 1, _RGBA32(22, 166, 211, 255)
        Con_Blok xb%, 420, 160, 48, "Abort [Esc]", 0, _RGBA32(22, 166, 211, 255)
    ELSE
        Con_Blok xb%, 100, 160, 48, "Launch", 1, _RGBA32(22, 166, 211, 255)
        Con_Blok xb%, 164, 160, 48, "Goto & Land", 1, _RGBA32(22, 166, 211, 255)
        Con_Blok xb%, 420, 160, 48, "Abort [Esc]", 0, _RGBA32(22, 166, 211, 255)
    END IF
    _DISPLAY

    'Mouse and keyboard picking of Flight_Plan mode- setting choice%
    DO
        x$ = UCASE$(INKEY$)
        ms = MBS
        IF ms AND 1 THEN
            IF ABS(_MOUSEX - _SHR(_WIDTH(A&), 1)) < 80 THEN '   if mouse is in the button column
                c = (_MOUSEY - 100) / 64
                IF c - INT(c) <= .75 THEN 'if mouse is over a button
                    choice% = _CEIL(c): dl% = -1
                    Panel_Blank xb%, (choice% - 1) * 64 + 100, 160, 48
                END IF
            END IF
            Clear_MB 1
        END IF
        IF ms AND 2 THEN '                                      Right click context help bubbles without setting dl%
            rd& = _COPYIMAGE(0) '                               copy the background screen before text bubble
            IF ABS(_MOUSEX - _SHR(_WIDTH(A&), 1)) < 80 THEN '   if mouse is in the button column
                SELECT CASE _MOUSEY
                    CASE 100 TO 148
                        IF flt% THEN
                            Text_Bubble _MOUSEX, _MOUSEY, "<PMAT>" 'planet matching
                        ELSE
                            Text_Bubble _MOUSEX, _MOUSEY, "<LAUNCH>" 'launch
                        END IF
                    CASE 164 TO 212: Text_Bubble _MOUSEX, _MOUSEY, "<LANDON>" 'planet fall
                    CASE 228 TO 276: IF flt% THEN Text_Bubble _MOUSEX, _MOUSEY, "<ORBITP>" 'orbit
                    CASE 292 TO 340: IF flt% THEN Text_Bubble _MOUSEX, _MOUSEY, "<STKEEP>" 'station keeping
                    CASE 356 TO 404: IF flt% THEN Text_Bubble _MOUSEX, _MOUSEY, "<SAFEJUMP>" 'nearest safe jump point
                    CASE 420 TO 468: Text_Bubble _MOUSEX, _MOUSEY, "<FLABORT>" 'abort
                END SELECT
            END IF
            _PUTIMAGE , rd&: _DISPLAY: _FREEIMAGE rd& '         redraw the background after text bubble
            Clear_MB 2
        END IF
        IF x$ <> "" THEN
            IF x$ = CHR$(27) THEN
                EXIT SUB '                                          abort delete with ESC keypress
            ELSE
                IF flt% THEN
                    choice% = INSTR("JGOHS", x$)
                ELSE
                    choice% = INSTR("LG", x$)
                END IF
                IF choice% <> 0 THEN dl% = -1
            END IF
        END IF
        _LIMIT 30
        _DISPLAY
    LOOP UNTIL dl% '                                            loop until correct inputs

    SELECT CASE choice%
        CASE IS = 1 'JUMP IN MATCHING/LAUNCH IF LANDED: first Flight_Plan algorithm is to match nearby planet vector
            IF NOT flt% THEN '                                  launch if already landed on a body, manual launch
                New_Vector_Graph
            ELSE
                'A GM edit; not a maneuver
                DIM nw AS V3 '                                  target planet's cartesian turn displacement
                Get_Body_Vec Closest_Rank_Body(vpoint, 2), nw ' change 2 to 0 to see if combined vectors work
                cmb(vpoint).Hd = Azimuth(nw.pX, nw.pY)
                cmb(vpoint).Sp = PyT(2, nw, origin)
                cmb(vpoint).In = 0
            END IF
        CASE IS = 2 'PLANETFALL  bstat=3  bogey=target body
            IF NOT flt% THEN cmb(vpoint).status = 4 '           launch if already landed on a body, direct to automatic
            cmb(vpoint).bstat = 3: cmb(vpoint).bogey = Choose_World%("Land On...", -1)
        CASE IS = 3 'ORBIT  bstat=4    bogey=target body
            Coming
            EXIT SUB
            IF NOT flt% THEN EXIT SELECT '                      skip landed unit
            DIM AS V3 mvv, ppv, tmv
            cmb(vpoint).bogey = Choose_World%("orbit...", -1) ' choose a body to orbit
            'use law of sines to get an insertion point, whos altitude is 1.25 planet radius, modified by drive performance
            'we need to know which side to approach, distance to planet, altitude of orbit that drives can get out of
            'd2c&&: hypotenuse  {distance to center}
            'd2s&&: opposite    {distance to stable}
            'd2t&&: adjacent    {distance to travel}
            d2c&& = PyT(3, origin, rcp(cmb(vpoint).bogey)) '    distance to planet center, hypotenuse mag
            alf! = 1
            DO '                                                set minimum d2s&&
                alf! = alf! + .25
                d2s&& = hvns(cmb(vpoint).bogey).radi * alf! '   distance to safe orbit, opposite mag
                grav! = Surface_Gs!(hvns(cmb(vpoint).bogey).dens, hvns(cmb(vpoint).bogey).radi) / (d2s&& * d2s&&)
            LOOP UNTIL cmb(vpoint).MaxG > grav!
            d2t&& = SQR(d2c&& * d2c&& - d2s&& * d2s&&)
            'NOW WE HAVE ALL DISTANCES, NEXT WE NEED THE PLANE OF APPROACH UNIT MORMAL put in OrbDat(vpoint).nrm
            mvv = cmb(vpoint).ap: Vec_Add mvv, cmb(vpoint).op, -1
            ppv = hvns(cmb(vpoint).bogey).ps: Vec_Add ppv, cmb(vpoint).ap, -1
            Vec_Cross tmv, mvv, ppv: Vec_2_UVec tmv, OrbDat(vpoint).nrm


            'assign the insertion point to OrbDat(vpoint).oip, this point should be relative to rcp(cmb(vpoint).bogey)
            'OrbDat(vpoint).oip=??? remember .oip is a V3 vector and needs .pX, .pY & .pZ
            cmb(vpoint).bstat = 4 '                             consign unit to an orbital algorithm
        CASE IS = 4 'STATION KEEPING bstat=6
            IF NOT flt% THEN EXIT SELECT '                      skip landed unit
            cmb(vpoint).bstat = 6
            rk% = Rank_Max%
            st% = (_SHR(_WIDTH(A&), 1) - rk% * 35)
            Dialog_Box "Nearest Station Keeping at...", 100 + (rk% * 70), 200, 25, _RGBA32(22, 211, 166, 255), &HFFFFFFFF
            FOR x% = 1 TO rk%
                IF x% > 1 THEN l$ = "Rank " + STR$(x%) ELSE l$ = "System"
                Con_Blok st% + ((x% - 1) * 70), 100, 70, 48, l$, 0, _RGBA32(22, 211, 166, 255)
            NEXT x%
            _DISPLAY
            dl% = 0
            DO
                x$ = UCASE$(INKEY$)
                ms1 = MBS
                IF ms1 AND 1 THEN
                    SELECT CASE _MOUSEY
                        CASE 100 TO 148
                            ch% = INT(map(_MOUSEX, st%, st% + rk% * 70, 0, rk%)) + 1
                            IF ch% > 0 AND ch% <= rk% THEN
                                dl% = -1
                            ELSE
                                x$ = CHR$(27)
                            END IF
                        CASE ELSE: x$ = CHR$(27)
                    END SELECT
                    Clear_MB 1
                END IF
                IF x$ = CHR$(27) THEN
                    cmb(vpoint).bstat = 0: EXIT SUB '           clear & abort
                ELSE
                    IF VAL(x$) > 0 AND VAL(x$) <= rk% THEN 'rank number has been keyed in
                        ch% = VAL(x$)
                        dl% = -1
                    END IF
                END IF
                _LIMIT 30
            LOOP UNTIL dl% '                                    loop until valid input received
            Panel_Blank st% + ((ch% - 1) * 70), 100, 70, 48
            IF ch% = 1 THEN '                                   rank one is primary star aka system stationary
                cmb(vpoint).bogey = 1 '                         set target to primary star (or system barycenter)
            ELSE
                cmb(vpoint).bogey = Closest_Rank_Body(vpoint, ch%) 'choose the closest body, of rank ch%, to station by
            END IF
            cmb(vpoint).bdata = PyT(3, cmb(vpoint).ap, hvns(cmb(vpoint).bogey).ps) 'set the station distance
        CASE IS = 5 'PROCEED TO SAFE JUMP POINT bstat=7
            IF NOT flt% THEN EXIT SELECT
            cmb(vpoint).bstat = 7
            cmb(vpoint).bogey = Closest_Rank_Body(vpoint, 0)
        CASE ELSE
            EXIT SUB
    END SELECT

END SUB 'Flight_Plan


'±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
FUNCTION Frame_Sect% (feature AS V3, radius AS _INTEGER64, ratio AS SINGLE)

    'called from: Draw_Ring_Belt, System_Map
    'Determine feature's relation to active's {origin} viewport using relative or display coordinates
    'Purpose: determine whether and/or how to draw feature. Speeds program by not drawing off screen unnecessarily
    'SYNTAX: Frame_Sect%(feature center V3, feature radius, result of Prop! call)
    Sact = 1415 / ratio '                                       Active unit's visibility radius: 1415=circumscribed display
    dist## = PyT(2, origin, feature) '                          distance between active unit and feature center point

    IF dist## > Sact + radius THEN Frame_Sect% = 0 '            feature's radius is beyond display - no draw if 0
    IF dist## <= radius - Sact THEN Frame_Sect% = 1 '            feature's radius encompasses entire display - if fill then fill only screen
    IF dist## < Sact - radius THEN Frame_Sect% = 2 '            feature is encompassed by display - draw entire
    IF dist## < Sact + radius AND dist## > radius - Sact THEN Frame_Sect% = 3 ' feature intersects display - draw partial if possible
    'fs% = 3 + (3 * (dist## > Sact + radius))
    'fs% = fs% + (2 * (dist## <= radius - Sact)) * -(fs% > 2)
    'Frame_Sect% = fs% + (dist## < Sact - radius) * (fs% > 2)

END FUNCTION 'Frame_Sect%


'±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
SUB Gate_Keeper

    'Main program splash screen
    'called from: Main Module
    IF _FILEEXISTS("default.ini") THEN '                        If default file present, load defaults
        OPEN "default.ini" FOR BINARY AS #1
        GET #1, , togs
        GET #1, , SenMax
        GET #1, , SenLocC
        GET #1, , SenLocM
        GET #1, , RngCls
        GET #1, , RngMed
        CLOSE #1
    END IF
    COLOR , clr&(0)
    CLS
    _PUTIMAGE (0, 0), strfld, A&
    fa96& = _LOADFONT("arialbd.ttf", 96)
    IF fa96& > 0 THEN '                                           Print _TITLE
        _FONT fa96&
        COLOR &HFF5050A0
        _PRINTMODE _KEEPBACKGROUND
        _PRINTSTRING (_SHR(_WIDTH(A&), 1) - _SHR(_PRINTWIDTH(ttl), 1), 100), ttl
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
        _PRINTSTRING (_SHR(_WIDTH(A&), 1) - _SHR(_PRINTWIDTH(subtitle$), 1), 200), subtitle$
        _FONT 16
        COLOR clr&(15)
    ELSE
        Prnt subtitle$, 2, -2, 320, 200, 16, 0, &HFF505040
    END IF
    COLOR clr&(7)
    splash1$ = "Ditch the paper, compasses and protractors! CT-Vector will handle the starship maneuvers, and even do it in 3D."
    _PRINTSTRING (_SHR(_WIDTH(A&), 1) - _SHR(_PRINTWIDTH(splash1$), 1), 250), splash1$, A&
    splash2$ = "If you know a star system/scenario name and path you may load it now, or press [enter] to default to Sol"
    _PRINTSTRING (_SHR(_WIDTH(A&), 1) - _SHR(_PRINTWIDTH(splash2$), 1), 270), splash2$, A&

    'Fair Use splash screen display
    fairuse$ = "The Traveller game in all forms is owned by Far Future Enterprises. Copyright 1977 - 2008 Far Future Enterprises. "
    _PRINTSTRING (_SHR(_WIDTH(A&), 1) - _SHR(_PRINTWIDTH(fairuse$), 1), 500), fairuse$, A&
    DO
        T& = _NEWIMAGE(950, 200, 32)
        _DEST T&
        CLS
        FOR x% = 0 TO 2
            LINE (0 + x%, 0 + x%)-(949 - x%, 199 - x%), &HFF5050A0, B
        NEXT x%
        _PUTIMAGE (150, 290), T&, A&
        _DEST A&
        _FREEIMAGE T&
        LOCATE 20, 25
        INPUT "Input system/scenario name or [ENTER] to default to Sol :", sys$
        IF sys$ = "" THEN
            sys$ = "systems/Sol.tss" '                          load default Sol
            IF _FILEEXISTS(sys$) THEN lookup% = 1 ELSE lookup% = 3
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
                    lookup% = 1 '                                system present
                ELSE
                    lookup% = 3 '                                file not found
                END IF
            ELSEIF ext2% <> 0 OR bod2% <> 0 THEN '              if scenario inputs
                IF ext2% = 0 THEN tmp$ = sys$ + ".tfs"
                IF bod2% = 0 THEN tmp$ = "scenarios/" + sys$
                IF _FILEEXISTS(tmp$) THEN
                    sys$ = tmp$
                    lookup% = 2 '                                scenario present
                ELSE
                    lookup% = 3 '                                file not found
                END IF
            ELSE
                tmp1$ = "systems/" + sys$ + ".tss" '            try both
                tmp2$ = "scenarios/" + sys$ + ".tfs" '
                IF _FILEEXISTS(tmp1$) THEN
                    sys$ = tmp1$: lookup% = 1 '                  system
                ELSEIF _FILEEXISTS(tmp2$) THEN
                    sys$ = tmp2$: lookup% = 2 '                  scenario
                ELSE
                    lookup% = 3 '                                file not found
                END IF
            END IF
        END IF
        SELECT CASE lookup%
            CASE IS = 1 '                                       system file into hvns() array
                Sys_Get 0, sys$, 22, 25
                LOCATE 25, 25: INPUT "2D/3D mode (enter '2' for 2D, default 3D):", md$
                IF md$ = "2" THEN
                    togs = _RESETBIT(togs, 13) '                set 2D mode
                END IF
                Set_Up '                                        Re_Calc included in Set_Up
                EXIT DO '                                       we got good input, leave Gate_Keeper
            CASE IS = 2 '                                       load the binary scenario file
                Scene_Get sys$
                Re_Calc '                                       Recalc here since we're not calling Set_Up
                EXIT DO '                                       we got good input, leave Gate_Keeper
            CASE IS = 3
                LOCATE 22, 25: PRINT "File does not exist. Please check your path and file name."
                SLEEP 3
        END SELECT
    LOOP
    t$ = ttl + " " + sys$ '                                     add system id to _TITLE bar
    _TITLE t$
    _FREEIMAGE strfld '                                         finished with splash screen

END SUB 'Gate_Keeper


'±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
SUB Get_Body_Vec (var AS INTEGER, var2 AS V3)

    'Compute the vector of planet var, returning in var2 | <var2.pX, var2.pY, var2.pZ>
    'called from: various
    DIM AS V3 i, j '                                            relative start (i) and end (j) position
    r% = hvns(var).rank '                                       set rank decrementer to target body
    u% = var '                                                  initialize parent incrementer
    IF r% > 1 THEN
        DO
            az! = Az_From_Parent(u%)
            i.pX = hvns(u%).orad * SIN(az!) '                   starting position relative to parent
            i.pY = hvns(u%).orad * COS(az!)
            daz! = az! + (_PI * 2) / (hvns(u%).oprd * 31557.6) 'future azimuth  (31557.6 turns/year)
            j.pX = hvns(u%).orad * SIN(daz!) '                  ending position relative to parent
            j.pY = hvns(u%).orad * COS(daz!)
            Vec_Add j, i, -1 '                                  subtract past from future position vector
            Vec_Add var2, j, 1 '                                add to combined tally
            u% = Find_Parent(u%) '                              advance to parent &...
            r% = r% - 1 '                                       decrement rank to parent
        LOOP UNTIL r% < 2 '                                     stop at primary body, it doesn't move in absolute coordinates
    ELSE
        var2 = origin '                                         primary star is both stationary and at origin
    END IF

END SUB 'Get_Body_Vec


'±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
SUB Grav_Force_Vec (gravvec AS V3, gravtarg AS V3, var AS INTEGER)

    'Returns a gravity acceleration vector {gravvec} applied by a planet {var} upon a position vector {gravtarg}
    'called from: Grav_Well
    DIM AS V3U unv '                                            gravitational unit vector
    ds## = PyT(3, hvns(var).ps, gravtarg) '                     distance from planet to target
    ds## = ds## + ((ds## - hvns(var).radi) * (ds## < hvns(var).radi)) 'no less than radius BRANCHLESS
    grav! = Surface_Gs!(hvns(var).dens, hvns(var).radi) / (ds## * ds##) 'compute grav force(pull) at distance
    tc = grav! * 5000 '                                         Scalar magnitude of pull / turn
    gravvec = hvns(var).ps: Vec_Add gravvec, gravtarg, -1 '     relative position vector- gravtarg to planet
    Vec_2_UVec gravvec, unv '                                   unv=unit direction of pull
    Vec_Mult_Unit gravvec, unv, tc '                            multiply direction by magnitude

END SUB 'Grav_Force_Vec


'±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
SUB Grav_Well (var AS INTEGER, var2 AS _BYTE)

    'Determine gravity perturbations of nearby massive bodies, apply if var2 TRUE
    'called from: Coord_Update, Load_Ships
    IF cmb(var).status > 0 THEN '                               if unit (var) is destroyed there's no point in doing this
        DIM mdpnt AS V3 '                                       midpoint of ship's vector
        DIM Pull AS V3 '                                        G-force of an individual body
        DIM xu AS V3 '                                          total vectors of all bodies checked
        xu = origin

        'locate var's turn midpoint position vector
        mdpnt = cmb(var).ap: Vec_Add mdpnt, cmb(var).op, -1 '   mdpnt now = movement for the turn
        Vec_Mult mdpnt, 0.5: Vec_Add mdpnt, cmb(var).op, 1 '    add half of movement to start point

        'Iterate all bodies in system
        FOR x% = 1 TO orbs
            IF hvns(x%).star = 2 THEN _CONTINUE '               skip ring/belt systems
            Grav_Force_Vec Pull, mdpnt, x% '                    get G force vector <Pull> exterted by each planet x%
            Vec_Add xu, Pull, 1 '                               and tally them up in <xu>
        NEXT x%

        'apply the combined vector to unit if called from CoordUpdateII
        IF var2 THEN Vec_Add cmb(var).ap, xu, 1

        'extrapolate out the grav force Maneuver data displayed for unit var
        Vec_2_Thrust Gwat(var), xu, 0
    END IF '                                                    end unit not destroyed test

END SUB 'Grav_Well


'±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
SUB Help

    'called from: Main_Loop, Mouse_Button_Left
    Clear_MB 1
    i% = 0: a% = 0
    DO
        Dialog_Box "HELP", 1200, 650, 25, &HFF4CCB9C, clr&(15)
        Dev_Grid '                                              <<<<REMOVE WHEN DEVELOPMENT COMPLETE
        'left side ship data & icons
        x% = 40
        _PRINTSTRING (x%, 80), "SHIP DATA CELLS"
        _PRINTSTRING (x%, 100), "Ship ID------------>", A&
        _PRINTSTRING (x%, 116), "Absolute position-->", A&
        _PRINTSTRING (x%, 132), "Speed & course data>", A&
        IF NOT a% THEN _PRINTSTRING (x%, 148), "Bearing & Distance->", A&
        _PRINTSTRING (x%, 164), "Automove controls-->", A&
        _PRINTSTRING (x%, 180), "Status notes------->", A&
        IF a% THEN
            _PRINTSTRING (200, 83), "Active unit"
            _PUTIMAGE (200, 100), ship_hlpA
        ELSE
            _PRINTSTRING (200, 83), "Inactive unit"
            _PUTIMAGE (200, 100), ship_hlpB
        END IF

        'ICONOGRAPHY
        _PRINTSTRING (x%, 200), "ICONOGRAPHY"
        _PUTIMAGE (x%, 220), TLocn: _PRINTSTRING (x% + 20, 220), "Target lock unavailable"
        _PUTIMAGE (x%, 236), TLoc: _PRINTSTRING (x% + 20, 236), "Target lock possible {clickable}"
        _PUTIMAGE (x%, 252), TunLoc: _PRINTSTRING (x% + 20, 252), "Target lock established {clickable}"
        x% = 350
        _PUTIMAGE (x%, 220), trnon: _PUTIMAGE (x% + _WIDTH(trnon), 220), trnoff
        _PRINTSTRING (x% + _WIDTH(trnon) + _WIDTH(trnoff), 220), "Transponder on/off {clickable}"
        _PUTIMAGE (x%, 236), flag: _PRINTSTRING (x% + _WIDTH(flag), 236), "Fleet flagship"
        _PUTIMAGE (x%, 252), slave: _PRINTSTRING (x% + _WIDTH(slave), 252), "Fleet assigned prior # = flagship"

        'right side of ship data & icons
        x% = 490
        _PRINTSTRING (x%, 100), "<Flagship status"
        _PRINTSTRING (x%, 116), " Transponder state"
        LINE (x% + 4, 124)-(460, 116), clr&(10)
        _PRINTSTRING (x%, 132), " Proximity alert"
        LINE (x% + 4, 140)-(350, 108), clr&(10)
        _PRINTSTRING (x%, 148), " Fleet assignment"
        LINE (x% + 4, 156)-(460, 164), clr&(10)
        IF NOT a% THEN _PRINTSTRING (x%, 164), "<Targeting icons"

        x% = 40
        y% = 282
        _PRINTSTRING (x%, y%), "AUTOMOVE CONTROLS- left click to initiate": y% = y% + 18
        _PUTIMAGE (x%, y%), flight&: _PRINTSTRING (x% + 125, y%), "Open flightplan dialog": y% = y% + 18
        _PUTIMAGE (x%, y%), evade&: _PRINTSTRING (x% + 125, y%), "Active evades inactive unit": y% = y% + 18
        _PUTIMAGE (x%, y%), intercept&: _PRINTSTRING (x% + 125, y%), "Active intercepts inactive unit": y% = y% + 18
        _PUTIMAGE (x%, y%), fleet&: _PRINTSTRING (x% + 125, y%), "Inactive follows active in fleet maneuvers": y% = y% + 18
        _PUTIMAGE (x%, y%), break&: _PRINTSTRING (x% + 125, y%), "Unit to break from fleet maneuvers": y% = y% + 18
        _PUTIMAGE (x%, y%), cancel&: _PRINTSTRING (x% + 125, y%), "Active to cancel automoves": y% = y% + 18

        x% = 40: y% = 434
        _PRINTSTRING (x%, y%), "MOUSE OPS": y% = y% + 16
        _PRINTSTRING (x%, y%), "Left click-   Ship data display- choose active unit": y% = y% + 16
        _PRINTSTRING (x%, y%), "              Sensor display- choose closest unit to click as active": y% = y% + 16
        _PRINTSTRING (x%, y%), "              Planet display- open planetary information selection box": y% = y% + 16
        _PRINTSTRING (x%, y%), "              Controls- actuate control": y% = y% + 16
        _PRINTSTRING (x%, y%), "Right click-  Ship data display- hold click for expanded ship details": y% = y% + 16
        _PRINTSTRING (x%, y%), "              Sensor display- move active unit to the click point": y% = y% + 16
        _PRINTSTRING (x%, y%), "              Planet display- hold click to show context help text": y% = y% + 16
        _PRINTSTRING (x%, y%), "              Orientation screen- hold click to show context help text": y% = y% + 16
        _PRINTSTRING (x%, y%), "              Controls- hold click to show context help text": y% = y% + 16
        _PRINTSTRING (x%, y%), "Middle click- Sensor display- zoom to extents {factor=1}": y% = y% + 16
        _PRINTSTRING (x%, y%), "Wheel scroll- Ship data display- scroll through ship list": y% = y% + 16
        _PRINTSTRING (x%, y%), "              Sensor display- zoom in/out": y% = y% + 16
        '_PRINTSTRING (x%, y%), "": y% = y% + 16
        '_PRINTSTRING (x%, y%), "": y% = y% + 16

        'Right side hotkey list
        x% = 700
        x$ = INKEY$
        _PRINTSTRING (x%, 80), "HOTKEYS & CONTROLS", A&
        _PRINTSTRING (x%, 96), "[A] Azimuth wheel on/off->"
        _PUTIMAGE (210 + x%, 80), AZ&, A&
        _PRINTSTRING (x%, 112), "[B] Belts/Rings on/off--------->", A&
        Con_Blok x% + 260, 112, 42, 18, "Belts", 1, &HFFBFBFBF
        _PRINTSTRING (x%, 128), "[D] Jump zone mode (Density/Diameter)---->", A&
        _PUTIMAGE (340 + x%, 112), DN&, A&
        _PUTIMAGE (393 + x%, 112), DI&, A&
        _PRINTSTRING (x%, 144), "[E] Edit Active Ship", A&
        _PRINTSTRING (x%, 160), "[F] Flightplan {active}", A&
        _PRINTSTRING (x%, 176), "[G] Scale Grid on/off---->", A&
        _PUTIMAGE (210 + x%, 160), GD&, A&
        _PRINTSTRING (x%, 192), "[H] Help Menu------------------->", A&
        Con_Blok 265 + x%, 176, 64, 32, "Help", 1, &HFF4CCB9C
        _PRINTSTRING (x%, 208), "[I] Inclinometer on/off------------------>", A&
        _PUTIMAGE (340 + x%, 192), IN&, A&
        _PRINTSTRING (x%, 224), "[J] Jump Zones on/off-------------------------->", A&
        _PUTIMAGE (385 + x%, 208), JP&, A&
        _PRINTSTRING (x%, 240), "[O] Orbit tracks on/off------------------------------->", A&
        _PUTIMAGE (440 + x%, 224), OB&, A&
        _PRINTSTRING (x%, 256), "[Q] Autosave & Quit----------------------->", A&
        _PUTIMAGE (350 + x%, 256), QT&, A&
        _PRINTSTRING (x%, 272), "[R] Range bands---------->", A&
        _PUTIMAGE (210 + x%, 256), RG&, A&
        _PRINTSTRING (x%, 288), "[T] Execute Turn------------------>", A&
        Con_Blok 280 + x%, 272, 64, 32, "Turn", 1, &HFF2C9B2C
        _PRINTSTRING (x%, 304), "[U] Undo Turn------------------------------>", A&
        Con_Blok 350 + x%, 288, 64, 32, "Undo", 1, &HFF2C9B2C
        _PRINTSTRING (x%, 320), "[V] Vector input (textual)", A&
        _PRINTSTRING (x%, 336), "[X] Zoom Extents (all units)->", A&
        _PUTIMAGE (240 + x%, 320), XZ&, A&
        _PRINTSTRING (x%, 352), "[Z] Gravity Zones on/off->", A&
        Con_Blok x% + 208, 352, 50, 18, "Gzones", 2, &HFF00DD00
        _PRINTSTRING (x%, 368), "[-] Zoom Out-------------------------->", A&
        _PUTIMAGE (310 + x%, 352), OZ&, A&
        _PRINTSTRING (x%, 384), "[+] Zoom In----------------------------------->", A&
        _PUTIMAGE (380 + x%, 368), IZ&, A&
        _PRINTSTRING (x%, 400), "[up] Activate previous unit", A&
        _PRINTSTRING (x%, 416), "[down] Activate next unit", A&
        _PRINTSTRING (x%, 432), "[insert] Add new unit---------->", A&
        Con_Blok 256 + x%, 416, 64, 32, "AddShip", 0, &HFFA6A188
        _PRINTSTRING (x%, 448), "[delete] Delete active unit------------->", A&
        Con_Blok 328 + x%, 432, 64, 32, "Delete", 0, &HFFC80000
        _PRINTSTRING (x%, 464), "[3] 2D/3D toggle-------------------------------->", A&
        Con_Blok 400 + x%, 448, 40, 32, "2D", 0, &HFFB5651D
        _PRINTSTRING (x%, 490), "[ctrl-S] Save ships-->"
        Con_Blok x% + 178, 474, 64, 32, "SaveShp", 0, &HFF8C5B4C

        IF b% THEN _PRINTSTRING (x%, 639), "Left click or press any key to continue...", A&
        DO
            i% = i% + 1
            IF INKEY$ <> "" THEN in% = -1: i% = 0
            ms = MBS
            IF ms AND 1 THEN
                in% = -1: i% = 0
                Clear_MB 1
            END IF
            _LIMIT 30
            _DISPLAY
        LOOP UNTIL i% MOD 10 = 0
        b% = NOT b%
        IF i% = 100 THEN
            i% = 0: a% = NOT a%
        END IF
    LOOP UNTIL in%

END SUB 'Help


'±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
SUB Hotkey_Ops (hk AS STRING, main AS _BYTE)

    'Process input hotkeys
    'called from: MainLoop, Options
    IF main THEN '                                              if called from main loop
        IF hk = CHR$(43) THEN '                                 "+" Zoom In
            ZoomFac = ZoomFac * 2
            Panel_Blank 626, 660, 64, 32
        END IF
        IF hk = CHR$(45) THEN '                                 "-" Zoom Out
            ZoomFac = ZoomFac * .5
            Panel_Blank 692, 660, 64, 32
        END IF
        IF hk = CHR$(51) THEN '                                 "3" 2D/3D toggle
            IF togs AND 8192 THEN '                             if 3D mode
                togs = _TOGGLEBIT(togs, 1)
                IF togs AND 2 THEN
                    zangle = Ozang
                ELSE
                    Ozang = zangle: zangle = 0
                END IF
            END IF
        END IF
        IF hk = CHR$(0) + CHR$(38) THEN Load_System '           "alt L" Load system
        IF hk = CHR$(0) + CHR$(31) THEN Save_System '           "alt S" Save system
        IF hk = CHR$(12) THEN Load_Ships '                      "ctrl L" Load ships
        IF hk = CHR$(19) THEN Save_Ships '                      "ctrl S" Save ships
        IF hk = CHR$(69) OR hk = CHR$(101) THEN Edit_Ship 0 '   "E" Edit ship
        IF hk = CHR$(70) OR hk = CHR$(102) THEN Flight_Plan '   "F" Flightplan
        IF hk = CHR$(72) OR hk = CHR$(104) THEN Help '          "H" Help
        IF hk = CHR$(76) OR hk = CHR$(108) THEN Load_Scenario ' "L" Load All
        IF hk = CHR$(81) OR hk = CHR$(113) THEN '               "Q" Autosave & Quit
            TIMER(t1%) OFF: Save_Scenario 0: Terminus: SYSTEM
        END IF
        IF hk = CHR$(83) OR hk = CHR$(115) THEN Save_Scenario -1 '"S" Save scenario dialog
        IF hk = CHR$(84) OR hk = CHR$(116) THEN Move_Turn '     "T" Execute Turn
        IF hk = CHR$(85) OR hk = CHR$(117) THEN M_Turn_Undo '   "U" Undo turn
        IF hk = CHR$(86) OR hk = CHR$(118) THEN New_Vector '    "V" Vector entry (textual)
        IF hk = CHR$(88) OR hk = CHR$(120) THEN '               "X" Zoom Extents
            ZoomFac = 1
            Panel_Blank 560, 660, 64, 32
        END IF
        IF hk = CHR$(0) + CHR$(82) THEN '                       "Insert" Add ship
            Add_Ship
            Panel_Blank 280, 614, 64, 32
        END IF
        IF hk = CHR$(0) + CHR$(83) THEN '                       "Delete" Delete ship
            Remove_Units -1
            Panel_Blank 350, 578, 64, 32
        END IF
        IF hk = CHR$(0) + CHR$(147) THEN '                      "Purge" destroyed units
            Remove_Units 0
            Panel_Blank 350, 614, 64, 32
        END IF
        IF hk = CHR$(0) + CHR$(80) THEN '                       down arrow  20480
            vpoint = vpoint + 1
            IF vpoint > units THEN vpoint = 1: shipoff = 0
            IF units > 6 AND vpoint > 6 THEN shipoff = vpoint - 6
            DO
                IF cmb(vpoint).status = 0 THEN vpoint = vpoint + 1
                IF vpoint > units THEN vpoint = 1
            LOOP UNTIL cmb(vpoint).status > 0
        END IF
        IF hk = CHR$(0) + CHR$(72) THEN '                       up arrow  18432
            vpoint = vpoint - 1
            IF vpoint < 1 THEN vpoint = units: shipoff = units - 6
            IF units > 6 AND vpoint <= shipoff THEN shipoff = vpoint - 1
            DO
                IF cmb(vpoint).status = 0 THEN vpoint = vpoint - 1
                IF vpoint < 1 THEN vpoint = units
            LOOP UNTIL cmb(vpoint).status > 0
        END IF
    END IF
    'called from: Main_Loop AND Options
    IF hk = CHR$(35) THEN togs = _TOGGLEBIT(togs, 14) '                 "#" Rank show
    IF hk = CHR$(65) OR hk = CHR$(97) THEN togs = _TOGGLEBIT(togs, 2) ' "A" Azimuth
    IF hk = CHR$(66) OR hk = CHR$(98) THEN togs = _TOGGLEBIT(togs, 10) '"B" belt/ring
    IF hk = CHR$(68) OR hk = CHR$(100) THEN togs = _TOGGLEBIT(togs, 9) '"D" Diameter/Density
    IF hk = CHR$(71) OR hk = CHR$(103) THEN togs = _TOGGLEBIT(togs, 3) '"G" Grid
    IF hk = CHR$(73) OR hk = CHR$(105) THEN '                           "I" Inclinometer
        IF togs AND 8192 THEN togs = _TOGGLEBIT(togs, 5)
    END IF
    IF hk = CHR$(74) OR hk = CHR$(106) THEN togs = _TOGGLEBIT(togs, 6) '"J" Jump zones
    IF hk = CHR$(79) OR hk = CHR$(111) THEN togs = _TOGGLEBIT(togs, 7) '"O" Orbit track
    IF hk = CHR$(82) OR hk = CHR$(114) THEN togs = _TOGGLEBIT(togs, 4) '"R" Range
    IF hk = CHR$(90) OR hk = CHR$(122) THEN togs = _TOGGLEBIT(togs, 8) '"Z" Grav zones
    _KEYCLEAR

END SUB 'Hotkey_ops


'±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
SUB Inc_Meter

    'called from: Sensor_Screen
    'display inclinometer scale
    IF ABS(zangle) > .08727 THEN '                          If more than 5ø from vertical
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
SUB Index_Ship (quan AS INTEGER, p AS _BYTE)

    'Re-index ship variables for new count, Sensor done in calling SUBs if necessary
    'called from:
    IF p THEN '                                                 if adding to present units (p=-1)
        REDIM _PRESERVE cmb(quan) AS ship
        REDIM _PRESERVE Thrust(quan) AS Maneuver
        REDIM _PRESERVE Gwat(quan) AS Maneuver
        REDIM _PRESERVE OrbDat(quan) AS Odata
        REDIM _PRESERVE ship_box(quan)
    ELSE '                                                      if removing from present units (p=0)
        REDIM cmb(quan) AS ship
        REDIM Thrust(quan) AS Maneuver
        REDIM Gwat(quan) AS Maneuver
        REDIM OrbDat(quan) AS Odata
        REDIM Sensor(quan, quan) AS _BYTE
        REDIM ship_box(quan)
    END IF

END SUB 'Index_Ship


'±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
SUB Info (u AS INTEGER, detail AS INTEGER)

    'display active unit detailed information box
    'called from: Mouse_Button_Left, Mouse_Button_Right
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
                    FOR x% = 1 TO units
                        IF x% <> u THEN
                            IF cmb(x%).bstat = 5 AND cmb(x%).bogey = u THEN
                                PRINT "flagship"
                            END IF
                        END IF
                    NEXT x%
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
    PRINT "  Thrust: "; Fix_Float$(Thrust(u).Gs, 5); " Gs";
    PRINT "  Max Gs="; cmb(u).MaxG
    LOCATE 17, 47
    PRINT "Heading: "; _ROUND(_R2D(cmb(u).Hd) * 100) / 100; d$;
    PRINT "  Inclin: "; _ROUND(_R2D(cmb(u).In) * 100) / 100; d$;
    PRINT "  Velocity: "; _ROUND(cmb(u).Sp / 10) / 100; " kps"

    'Targeting
    LOCATE 19, 47
    PRINT "Targeting:"
    tg% = 0
    FOR x% = 1 TO units
        IF NOT Sensor(u, x%) AND 2 THEN _CONTINUE
        tg% = tg% + 1
        LOCATE 20 + tg%, 47
        PRINT cmb(x%).id; " "; cmb(x%).Nam
    NEXT x%
    'Targeted by
    LOCATE 19, 80
    PRINT "Targeted by:"
    tb% = 0
    FOR x% = 1 TO units
        IF NOT Sensor(x%, u) AND 2 THEN _CONTINUE
        tb% = tb% + 1
        LOCATE 20 + tb%, 80
        PRINT cmb(x%).id; " "; cmb(x%).Nam
    NEXT x%
    _PUTIMAGE (_SHR(_WIDTH(A&), 1) - _SHR(_WIDTH(ship_box(u)), 1), 490), ship_box(u), A&
    LOCATE 38, 58
    IF detail THEN PRINT "Left click or press any key to continue..."
    _DISPLAY
    Press_Click

END SUB 'Info


'±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
FUNCTION Intra_Turn_Vec_Map&& (vl%, stA AS V3, ndA AS V3, stB AS V3, ndB AS V3)

    'map distance between two moving vectors at vl% seconds in a turn
    'called from Col_Check, Col_Check_Ship
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
SUB Load_Scenario

    'called from: Mouse_Button_Left
    IF _DIREXISTS("scenarios") THEN
        fx$ = GetOpenFileName("Load Scenario File", _CWD$ + "\scenarios\", "scenario files (*.tfs)|*.tfs", 2)
        Dialog_Box "LOADING SCENARIO", 400, 250, 50, &HFF8C5B4C, clr&(15)
        IF _FILEEXISTS(fx$) THEN
            ERASE hvns, cmb, Thrust, OrbDat, Gwat, Sensor '     reset environment/ remove TLock
            FOR x% = 1 TO units '                               erase old ship data displays
                _FREEIMAGE ship_box(x%)
            NEXT x%
            Scene_Get fx$
            fcut$ = MID$(fx$, LEN(_CWD$) + 12)
            _TITLE ttl + " " + fcut$
        END IF
    ELSE
        Bad_Install "scenarios", 0 '                             Warn of missing directory, abort
    END IF

END SUB 'Load_Scenario


'±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
SUB Load_Ships

    'called from: Mouse_Button_Left, Hotkey_Ops
    IF _DIREXISTS("ships") THEN
        fn$ = GetOpenFileName("Load Ship File", _CWD$ + "\ships\", "ship files (*.tvg)|*.tvg", 2)
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
                    FOR x% = 1 TO units '                        erase old ship data displays
                        _FREEIMAGE ship_box(x%)
                    NEXT x%
                    units = ashp%
                    Index_Ship units, 0
                    FOR x% = 1 TO units
                        ship_box(x%) = _NEWIMAGE(290, 96, 32)
                    NEXT x%
                    Turncount = 0: vpoint = 1: shipoff = 0
                    FOR x% = 1 TO units
                        GET #1, , cmb(x%)
                        Sensor(x%, x%) = _SETBIT(Sensor(x%, x%), 4) 'transponders on
                    NEXT x%
                    CLOSE #1
                CASE IS = 2 '                                   Append to existing ships
                    Index_Ship units + ashp%, -1
                    DIM tmpsns(units, units) AS _BYTE '          _PRESERVE older ship's sensor data
                    FOR x% = 1 TO units: FOR y% = 1 TO units: tmpsns(x%, y%) = Sensor(x%, y%): NEXT y%, x%
                    REDIM Sensor(units + ashp%, units + ashp%)
                    FOR x% = 1 TO units: FOR y% = 1 TO units: Sensor(x%, y%) = tmpsns(x%, y%): NEXT y%, x%
                    FOR x% = 1 TO ashp%: ship_box(units + x%) = _NEWIMAGE(290, 96, 32): NEXT x% 'allocate databox images
                    FOR x% = 1 TO ashp% '                        load appended units
                        GET #1, , cmb(units + x%)
                        cmb(units + x%).id = cmb(units).id + x%
                        Sensor(units + x%, units + x%) = _SETBIT(Sensor(units + x%, units + x%), 4) 'transponders on
                    NEXT x%
                    CLOSE #1
                    units = units + ashp%: ZoomFac = 1: vpoint = 1: shipoff = 0
            END SELECT
            FOR x% = 1 TO units '                                nested loop to avoid planet/star collisions here
                FOR y% = 1 TO orbs
                    IF PyT(3, cmb(x%).ap, hvns(y%).ps) > hvns(y%).radi THEN _CONTINUE 'skip if outside radius
                    DO '                                        loop to accomodate large stars/GGs
                        cmb(x%).ap.pX = cmb(x%).ap.pX + 100000 '  Move ship 100K coreward and trailing
                        cmb(x%).ap.pY = cmb(x%).ap.pY + 100000
                    LOOP UNTIL PyT(3, cmb(x%).ap, hvns(y%).ps) > hvns(y%).radi 'stop once the unit's clear
                NEXT y%
                Grav_Well x%, 0 '                                sum gravity perturbations, but don't apply yet
            NEXT x%
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
SUB Load_System

    'Load star system file
    'called from: Mouse_Button_Left, Hotkey_Ops
    fn$ = GetOpenFileName("Load System File", _CWD$ + "\systems\", "system files (*.tss)|*.tss", 2)
    IF _DIREXISTS("systems") THEN
        Dialog_Box "LOAD NEW STAR SYSTEM", 400, 250, 50, &HFF2C9B2C, clr&(15)
        IF _FILEEXISTS(fn$) THEN
            Sys_Get -1, fn$, 12, 57
            Planet_Move 0 '                                     planets to date positions
            fcut$ = MID$(fn$, LEN(_CWD$) + 10)
            _TITLE ttl + " " + fcut$
            'cancel all existing automoves and put landed units in flight
        ELSE
            LOCATE 12, 57
            PRINT "File not found, check path and name."
            _DISPLAY
            SLEEP 3
        END IF
    ELSE '                                                      Warn and abort if directory missing
        Bad_Install "systems", 0 '                              autosave calls will likely take care of this
    END IF '                                                    during timer events, but keep it just in case.

END SUB 'Load_System


'±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
SUB Make_Buttons

    'called from: Main Module
    _DEST flight& '                                              Create Flight_Plan button
    CLS
    COLOR , &HFF16A6D3
    _PRINTSTRING (0, 0), "FLIGHTPLAN"

    _DEST evade& '                                               Create evade button
    CLS
    COLOR , &HFFF40B11
    _PRINTSTRING (0, 0), "EVADE"

    _DEST intercept& '                                           Create intercept button
    CLS
    COLOR , &HFF118B11
    _PRINTSTRING (0, 0), "INTERCEPT"

    _DEST fleet& '                                               Create fleet button
    CLS
    COLOR , &HFF8B118B
    _PRINTSTRING (0, 0), "FLEET"

    _DEST break& '                                               Create break formation button
    CLS
    COLOR , &HFF8B118B
    _PRINTSTRING (0, 0), "BREAK"

    _DEST cancel& '                                              Create cancel button
    CLS
    COLOR , &HFF434396
    _PRINTSTRING (0, 0), "CANCEL"

    _DEST XZ& ' 64x32                                            Create Zoom extents control
    COLOR clr&(0), &HFF4880DE
    CLS
    Bevel_Button 64, 32, &HFF4880DE
    _PRINTSTRING (8, 8), "Zoom"
    COLOR clr&(4)
    _PRINTSTRING (48, 8), "X"

    _DEST IZ& ' 64x32                                            Create Zoom in control
    COLOR clr&(0), &HFF4880DE
    CLS
    Bevel_Button 64, 32, &HFF4880DE
    _PRINTSTRING (8, 8), "Zoom"
    COLOR clr&(4)
    _PRINTSTRING (48, 8), "+"

    _DEST OZ& ' 64x32                                            Create Zoom out control
    COLOR clr&(0), &HFF4880DE
    CLS
    Bevel_Button 64, 32, &HFF4880DE
    _PRINTSTRING (8, 8), "Zoom"
    COLOR clr&(4)
    _PRINTSTRING (48, 8), "-"

    _DEST RG& ' 56x32                                            Create Range band toggle
    COLOR clr&(0), &HFF4880DE
    CLS
    Bevel_Button 56, 32, &HFF4880DE
    FCirc 28, 16, 20, _RGBA(252, 252, 84, 100)
    FCirc 28, 16, 12, _RGBA(252, 84, 84, 200)
    _PRINTMODE _KEEPBACKGROUND
    COLOR clr&(4)
    _PRINTSTRING (8, 8), "R"
    COLOR clr&(0)
    _PRINTSTRING (16, 8), "ange"

    _DEST OB& ' 56x32                                            Create Orbit track toggle
    COLOR clr&(0), &HFF4880DE
    CLS
    Bevel_Button 56, 32, &HFF4880DE
    CIRCLE (-15, -5), 58, clr&(1)
    CIRCLE (40, 15), 10, clr&(1)
    _PRINTMODE _KEEPBACKGROUND
    COLOR clr&(4)
    _PRINTSTRING (8, 8), "O"
    COLOR clr&(0)
    _PRINTSTRING (16, 8), "rbit"

    _DEST GD& ' 48x32                                            Create Grid toggle
    COLOR clr&(0), &HFF4880DE
    CLS
    Bevel_Button 48, 32, &HFF4880DE
    FOR h% = 8 TO 48 STEP 8
        LINE (0, h%)-(47, h%), clr&(8), BF
        LINE (h%, 0)-(h%, 31), clr&(8), BF
    NEXT h%
    _PRINTMODE _KEEPBACKGROUND
    COLOR clr&(4)
    _PRINTSTRING (8, 8), "G"
    COLOR clr&(0)
    _PRINTSTRING (16, 8), "rid"

    _DEST AZ& ' 40x32                                            Create Azimuth toggle
    COLOR clr&(0), &HFF4880DE
    CLS
    Bevel_Button 40, 32, &HFF4880DE
    FOR whl% = 0 TO 3375 STEP 225
        outerx = (14 * SIN(_D2R(whl% / 10))) + 20
        outery = (14 * COS(_D2R(whl% / 10))) + 16
        innerx = (12 * SIN(_D2R(whl% / 10))) + 20
        innery = (12 * COS(_D2R(whl% / 10))) + 16
        LINE (outerx, outery)-(innerx, innery), clr&(5) '       draw tick
    NEXT whl%
    _PRINTMODE _KEEPBACKGROUND
    COLOR clr&(4)
    _PRINTSTRING (8, 8), "A"
    COLOR clr&(0)
    _PRINTSTRING (16, 8), "zi"

    _DEST IN& ' 40x32                                            Create Inclinometer toggle
    COLOR clr&(0), &HFF4880DE
    CLS
    Bevel_Button 40, 32, &HFF4880DE
    FOR whl% = 0 TO 1800 STEP 225
        outerx = (14 * SIN(_D2R(whl% / 10))) + 20
        outery = (14 * COS(_D2R(whl% / 10))) + 16
        innerx = (12 * SIN(_D2R(whl% / 10))) + 20
        innery = (12 * COS(_D2R(whl% / 10))) + 16
        LINE (outerx, outery)-(innerx, innery), clr&(8) '       draw tick
    NEXT whl%
    LINE (20, 16)-((14 * SIN(_D2R(135))) + 20, (14 * COS(_D2R(135))) + 16), clr&(8)
    _PRINTMODE _KEEPBACKGROUND
    COLOR clr&(4)
    _PRINTSTRING (8, 8), "I"
    COLOR clr&(0)
    _PRINTSTRING (16, 8), "nc"

    _DEST JP& ' 48x32                                            Create Jump envelope toggle
    COLOR clr&(0), &HFF4880DE
    CLS
    Bevel_Button 48, 32, &HFF4880DE
    FCirc 24, 16, 12, &HC8967474
    _PRINTMODE _KEEPBACKGROUND
    COLOR clr&(4)
    _PRINTSTRING (8, 8), "J"
    COLOR clr&(0)
    _PRINTSTRING (16, 8), "ump"

    _DEST DI& ' 48x32                                            Create Jump Diameter button
    COLOR clr&(0), &HFF4880DE
    CLS
    Bevel_Button 48, 32, &HFF4880DE
    _PRINTMODE _KEEPBACKGROUND
    COLOR clr&(4)
    _PRINTSTRING (8, 8), "D"
    COLOR clr&(0)
    _PRINTSTRING (16, 8), "iam."

    _DEST DN& ' 48x32                                            Create Jump Density button
    COLOR clr&(0), &HFF4880DE
    CLS
    Bevel_Button 48, 32, &HFF4880DE
    'density graphic
    _PRINTMODE _KEEPBACKGROUND
    COLOR clr&(4)
    _PRINTSTRING (8, 8), "D"
    COLOR clr&(0)
    _PRINTSTRING (16, 8), "ens."

    _DEST QT& ' 48x32                                            Create Quit (program) button
    COLOR clr&(0), &HFFFF0032
    CLS
    Bevel_Button 48, 32, &HFFFF0032
    COLOR clr&(11)
    _PRINTSTRING (8, 8), "Q"
    COLOR clr&(0)
    _PRINTSTRING (16, 8), "uit"

END SUB 'Make_Buttons


'±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
SUB Make_Images

    'called from: Main Module
    _DEST AW& '                                                 Azimuth wheel image
    WINDOW (-1000, 1000)-(1000, -1000)
    CLS
    _CLEARCOLOR _RGB32(0, 0, 0)
    FOR whl% = 0 TO 359 '                                       iterate through azimuth wheel
        IF whl% MOD 45 = 0 THEN '                               45 degree tick and number
            y = 900
            Prnt STR$(whl%), 3.5, 3.5, (y + 20) * SIN(_D2R(whl%)) - 60, (y + 20) * COS(_D2R(whl%)), 24, 0, &H9FA800A8
        ELSEIF whl% MOD 10 = 0 THEN '                           10 degree tick
            y = 950
        ELSEIF whl% MOD 5 = 0 THEN '                            5 degree tick
            y = 970
        ELSE '                                                  1 degree tick
            y = 990
        END IF
        'Draw azimuth tick
        LINE (1000 * SIN(_D2R(whl%)), 1000 * COS(_D2R(whl%)))-(y * SIN(_D2R(whl%)), y * COS(_D2R(whl%))), &HAFA800A8
    NEXT whl%

    _DEST IW& '                                                 Inclinometer wheel image
    WINDOW (-1000, 1000)-(1000, -1000)
    CLS
    _CLEARCOLOR _RGB32(0, 0, 0)
    FOR whl% = 0 TO 359 '                                       iterate through azimuth wheel
        IF whl% MOD 45 = 0 THEN '                               45 degree tick and number
            y = 800
            SELECT CASE whl%
                CASE 0: in$ = "90"
                CASE 45, 315: in$ = "45"
                CASE 90, 270: in$ = "0"
                CASE 135, 225: in$ = "-45"
                CASE 180: in$ = "-90"
            END SELECT
            Prnt in$, 3.5, 3.5, (y + 20) * SIN(_D2R(whl%)) - 60, (y + 20) * COS(_D2R(whl%)), 24, 0, &H9F7F7F7F
        ELSEIF whl% MOD 10 = 0 THEN '                           10 degree tick
            y = 850
        ELSEIF whl% MOD 5 = 0 THEN '                            5 degree tick
            y = 870
        ELSE '                                                  1 degree tick
            y = 890
        END IF
        'Draw inclinometer tick
        LINE (900 * SIN(_D2R(whl%)), 900 * COS(_D2R(whl%)))-(y * SIN(_D2R(whl%)), y * COS(_D2R(whl%))), &HAF7F7F7F
    NEXT whl%

    _DEST ship_hlpA '                                           active ship data help page image
    COLOR clr&(15), clr&(8)
    CLS
    _PRINTSTRING (0, 0), "# Name        PROX": _PUTIMAGE (241, 0), trnon: _PUTIMAGE (273, 0), flag 'line 1
    _PRINTSTRING (0, 16), "X:###  Y:###  Z:###" '                                                   line 2
    _PRINTSTRING (0, 32), "Spd:####.##kps Hdg:###.#  Z:##.#" '                                      line 3
    _PUTIMAGE (0, 64), flight&: _PRINTSTRING (234, 64), "#": _PUTIMAGE (252, 64), slave '           line 5
    LINE (0, 0)-(289, 95), clr&(4), B

    _DEST ship_hlpB '                                           inactive ship data help page image
    COLOR clr&(3), clr&(0)
    CLS
    _PRINTSTRING (0, 0), "# Name        PROX": _PUTIMAGE (241, 0), trnon: _PUTIMAGE (273, 0), flag 'line 1
    _PRINTSTRING (0, 16), "X:###  Y:###  Z:###" '                                                   line 2
    _PRINTSTRING (0, 32), "Spd:####.##kps Hdg:###.#  Z:##.#" '                                      line 3
    _PRINTSTRING (0, 48), "Brng:###.# Z:##.## ###km/AU" '                                           line 4
    _PUTIMAGE (0, 64), evade&: _PUTIMAGE (49, 64), intercept&: _PUTIMAGE (130, 64), fleet&
    _PRINTSTRING (234, 64), "#": _PUTIMAGE (252, 64), slave: _PUTIMAGE (273, 64), TLoc '            line 5
    LINE (0, 0)-(289, 95), clr&(4), B

END SUB 'Make_Images


'±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
SUB Main_Loop

    'Main program loop, awaiting and routing mouse or keyboard input.
    'called from: Main Module
    DIM in AS _BYTE '                                           input flag
    Refresh '                                                   initial display refresh
    DO '                                                        outer loop running computations when inputs
        DO '                                                    inner loop waiting for inputs while no change
            x$ = INKEY$
            IF x$ <> "" THEN '                                  If a hotkey has been pressed
                Hotkey_Ops x$, -1
                in = -1
            END IF
            ms = MBS '                                          Mouse ops, get Steve's mouse button status
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
            IF NOT in THEN Ori_Screen vpoint '                  update ori-screen animation while waiting for inputs
            _DISPLAY
            _LIMIT 30
        LOOP UNTIL in '                                         Wait until an input is received
        in = 0
        Re_Calc '                                               update coordinates and sensor states
        Refresh '                                               Do screen and computation updates after input
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
        'MacOS does not support _MOUSEWHEEL. So skip this if Mac
        $IF WIN OR LINUX THEN
            SELECT CASE SGN(_MOUSEWHEEL)
                CASE 1: MBS = 512
                CASE -1: MBS = 1024
            END SELECT
        $END IF
    WEND

    IF _MOUSEBUTTON(1) THEN MBS = 1
    IF _MOUSEBUTTON(2) THEN MBS = 2
    IF _MOUSEBUTTON(3) THEN MBS = 4


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
                MBS = 32 * 2 ^ ButtonDown
            END IF
        END IF
    END IF
END FUNCTION 'MBS%


'±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
SUB Mouse_Button_Left (xpos AS INTEGER, ypos AS INTEGER)

    'called from: Main_Loop
    SELECT CASE xpos
        CASE 0 TO 559 '                                         ÛÛÛ LEFT TEXT DISPLAY ÛÛÛ
            SELECT CASE ypos '                                  Divide left into top and bottom
                CASE 0 TO 575
                    SELECT CASE xpos '                          Divide upper left into ship and center display
                        CASE 0 TO 287
                            'y% = INT(ypos / 96) + 1 + shipoff '  unit # range - modify by shipoff for proper unit
                            y% = ypos \ 96 + 1 + shipoff '  unit # range - modify by shipoff for proper unit
                            IF y% <= units THEN
                                IF cmb(y%).status <> 0 THEN '    unit not destroyed
                                    ln% = (_SHR(ypos, 4) + 1) MOD 6 'line position
                                    SELECT CASE ln%
                                        CASE IS = 1 '           transponder icon
                                            IF xpos > 240 AND xpos < 273 THEN
                                                Sensor(y%, y%) = _TOGGLEBIT(Sensor(y%, y%), 4) 'toggle transponder of y
                                            ELSE
                                                vpoint = y%
                                            END IF
                                        CASE IS = 5 '           automove buttons
                                            IF y% = vpoint THEN 'Flightplan or Cancel
                                                IF cmb(vpoint).bstat = 5 THEN
                                                    IF xpos < 40 THEN cmb(vpoint).bstat = 0: cmb(vpoint).bogey = 0
                                                ELSE
                                                    IF xpos < 80 THEN Flight_Plan
                                                END IF
                                            ELSE '              Evade/Intercept/Fleet or Cancel
                                                IF y% = cmb(vpoint).bogey THEN ' Cancel was clicked?
                                                    SELECT CASE xpos
                                                        CASE IS < 48
                                                            cmb(vpoint).bogey = 0: cmb(vpoint).bstat = 0 'unit no longer a solution target
                                                        CASE 48 TO 272
                                                            vpoint = y%
                                                        CASE IS > 272
                                                            GOSUB targetlock
                                                    END SELECT
                                                ELSE '          Evade/Intercept/Fleet
                                                    SELECT CASE xpos
                                                        CASE 0 TO 39 'Evade
                                                            IF cmb(vpoint).status = 2 THEN
                                                                vpoint = y%
                                                            ELSE
                                                                cmb(vpoint).bogey = y%: cmb(vpoint).bstat = 1
                                                            END IF
                                                        CASE 49 TO 120 'Intercept
                                                            IF cmb(vpoint).status = 2 THEN 'must launch before intercept order
                                                                vpoint = y%
                                                            ELSE
                                                                cmb(vpoint).bogey = y%: cmb(vpoint).bstat = 2
                                                            END IF
                                                        CASE 130 TO 168 'Fleet
                                                            IF cmb(y%).bstat = 5 THEN 'break formation
                                                                cmb(y%).bstat = 0: cmb(y%).bogey = 0
                                                            ELSE '                  join fleet maneuvers
                                                                IF cmb(y%).status <> 2 THEN 'can't fleet with a landed unit
                                                                    IF NOT Sensor(vpoint, y%) AND 1 THEN 'exclude units that are occluded
                                                                        cmb(y%).bstat = 5: cmb(y%).bogey = vpoint 'fleet y to active
                                                                    ELSE
                                                                        vpoint = y% 'but switch to the occluded unit
                                                                    END IF
                                                                ELSE
                                                                    vpoint = y% 'make the landed unit active
                                                                END IF
                                                            END IF
                                                        CASE 169 TO 272
                                                            vpoint = y%
                                                        CASE IS > 272 'target lock icon
                                                            GOSUB targetlock
                                                    END SELECT 'end: x position within line 5 test
                                                END IF '        end: unit a target of automoves test
                                            END IF '            end: vpoint test
                                        CASE ELSE
                                            vpoint = y%
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
                                CASE 325 TO 573
                                    'Ori_Screen area if we add left click funtionality
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
                            Remove_Units -1
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
                            IF cmb(vpoint).status <> 2 THEN 'exclude landed units
                                IF cmb(vpoint).bstat <> 5 THEN
                                    Panel_Blank 0, 614, 64, 32
                                    Con_Blok 0, 614, 64, 32, "Thrust 0", 0, &H502C9B2C
                                    _DISPLAY: _DELAY .5
                                    Thrust(vpoint).Gs = 0
                                    cmb(vpoint).bstat = 0: cmb(vpoint).bogey = 0
                                END IF
                            END IF
                        CASE 70 TO 133 '                        Transponder of active on/off
                            Sensor(vpoint, vpoint) = _TOGGLEBIT(Sensor(vpoint, vpoint), 4)
                        CASE 140 TO 203 '                       Active unit info display
                            Clear_MB 1
                            Panel_Blank 140, 614, 64, 32
                            Info vpoint, -1
                        CASE 210 TO 273 '                       Undo a game turn
                            M_Turn_Undo
                        CASE 280 TO 343 '                       Add a vessel
                            Panel_Blank 280, 614, 64, 32
                            Add_Ship
                        CASE 350 TO 413 '                       Remove wrecked vessels
                            Panel_Blank 350, 614, 64, 32
                            Remove_Units 0
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
        CASE 560 TO 1179 '                                      ÛÛÛ RIGHT GRAPHICS DISPLAY ÛÛÛ
            SELECT CASE ypos
                CASE 0 TO 18 '                                  narrow margin above sensor screen
                    SELECT CASE xpos
                        CASE 560 TO 600
                            Turn_Reset '                        open turn reset dialog
                        CASE 1085 TO 1127
                            togs = _TOGGLEBIT(togs, 10) '       toggle belts/rings
                        CASE 1130 TO 1180
                            togs = _TOGGLEBIT(togs, 8) '        toggle gravity zones
                    END SELECT
                CASE 19 TO 639 '                                find relative sensor screen coordinates
                    DIM clk AS V3
                    q! = Prop!: prox% = vpoint '                get proportion & set proximity unit as active
                    clk.pX = map!(xpos, 560, 1179, -1000, 1000) / q! 'where did we click?
                    clk.pY = map!(ypos, 19, 639, 1000, -1000) / q!
                    FOR a% = 1 TO units
                        IF a% = vpoint THEN _CONTINUE '         skip if active unit
                        IF PyT(2, clk, dcs(a%)) < PyT(2, clk, dcs(vpoint)) THEN 'if click is closer to 'a' than active
                            IF PyT(2, clk, dcs(a%)) < PyT(2, clk, dcs(prox%)) THEN 'if click is closer to 'a' than any other 'a' tested
                                prox% = a% '                    set proximity unit
                            END IF
                        END IF
                    NEXT a%
                    shipoff = -(prox% - 6) * (prox% > 6) '      adjust offset to put proximity unit data on screen
                    vpoint = prox% '                            set active to closest proximity unit
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
                        CASE 1132 TO 1179 '                     Quit
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
    IF Sensor(vpoint, y%) AND 2 THEN
        Sensor(vpoint, y%) = _RESETBIT(Sensor(vpoint, y%), 1) 'sever t-lock
    ELSE
        IF cmb(vpoint).mil THEN b&& = SenLocM ELSE b&& = SenLocC 'military/civilian sensor range
        IF Sensor(y%, y%) AND 16 THEN b&& = b&& ELSE b&& = _SHR(b&&, 1)
        IF PyT(3, origin, rcs(y%)) < b&& THEN
            Sensor(vpoint, y%) = _SETBIT(Sensor(vpoint, y%), 1) 'establish t-lock
        END IF
    END IF
    RETURN

END SUB 'Mouse_Button_Left


'±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
SUB Mouse_Button_Right (xpos AS INTEGER, ypos AS INTEGER)

    'called from: Main_Loop
    hp% = -1 '                                                  set help flag, clear if rt. click in no defined field
    SELECT CASE xpos
        CASE 0 TO 559 '                                         Left graphics screen
            SELECT CASE ypos
                CASE 0 TO 575
                    SELECT CASE xpos
                        CASE 0 TO 287 '                         ship data fields
                            'y% = INT(ypos / 96) + 1 + shipoff '  unit # range - modify by shipoff for proper unit
                            y% = ypos / 96 + 1 + shipoff '  unit # range - modify by shipoff for proper unit
                            IF y% <= units THEN
                                Panel_Blank 140, 614, 64, 32
                                Info y%, 0
                                hp% = 0
                            ELSE
                                m$ = "<SHIPDATA>" '             data field explanation in blank space, if available
                            END IF
                        CASE 288 TO 559 '                       center displays
                            SELECT CASE ypos
                                CASE 0 TO 324: m$ = "<PLANETD>"
                                CASE 325 TO 573: m$ = "<ORISCRN>"
                                CASE ELSE: hp% = 0
                            END SELECT
                    END SELECT
                CASE 576 TO 608 '                               tier 1 button block
                    SELECT CASE xpos
                        CASE 0 TO 63: m$ = "<VECTOR>"
                        CASE 70 TO 133: m$ = "<FUTURE>"
                        CASE 140 TO 203: m$ = "<FUTURE>"
                        CASE 210 TO 273: m$ = "<TURN>"
                        CASE 280 TO 343: m$ = "<EDIT>"
                        CASE 350 TO 413: m$ = "<DELETE>"
                        CASE 420 TO 483: m$ = "<LOADALL>"
                        CASE 490 TO 553: m$ = "<SAVEALL>"
                        CASE ELSE: hp% = 0
                    END SELECT
                CASE 614 TO 646 '                               tier 2 button block
                    SELECT CASE xpos
                        CASE 0 TO 63: m$ = "<THRUST0>"
                        CASE 70 TO 133: m$ = "<TRNSPNDR>"
                        CASE 140 TO 203: m$ = "<DETAILS>"
                        CASE 210 TO 273: m$ = "<UNDO>"
                        CASE 280 TO 343: m$ = "<ADDSHIP>"
                        CASE 350 TO 413: m$ = "<PURGE>"
                        CASE 420 TO 483: m$ = "<LOADSYS>"
                        CASE 490 TO 553: m$ = "<SAVESYS>"
                        CASE ELSE: hp% = 0
                    END SELECT
                CASE 650 TO 682 '                               tier 3 button block
                    SELECT CASE xpos
                        CASE 0 TO 63: m$ = "<BRAKE>"
                        CASE 70 TO 133: m$ = "<OPTIONS>"
                        CASE 140 TO 203: m$ = "<COL/CHK>"
                        CASE 210 TO 273: m$ = "<HELP>"
                        CASE 280 TO 343: m$ = "<MOVALL>"
                        CASE 350 TO 413: m$ = "<ADRIFT>"
                        CASE 420 TO 483: m$ = "<LOADSHP>"
                        CASE 490 TO 553: m$ = "<SAVESHP>"
                        CASE ELSE: hp% = 0
                    END SELECT
            END SELECT
        CASE 560 TO 1199 '                                      Right graphics screen
            SELECT CASE ypos
                CASE 0 TO 18
                    SELECT CASE xpos
                        CASE 560 TO 600: m$ = "<GAMETURN>"
                        CASE 1085 TO 1127: m$ = "<BELT>"
                        CASE 1130 TO 1180: m$ = "<GZONE>"
                        CASE ELSE: hp% = 0
                    END SELECT
                CASE 19 TO 639 '                                Sensor display- move active
                    'Moves active ship, on right click, to new, tilt plane defined, coordinates on the screen.
                    'moves all units as a group if MovAll button enabled, i.e. if (togs,11) aka AND 2048 = TRUE
                    DIM AS V3 shipstart, smov
                    WinMsX = map!(xpos, 560, 1179, -1000, 1000) 'relative screen mouse coordinates
                    WinMsY = map!(ypos, 19, 639, 1000, -1000)
                    q! = Prop! '                                relative coordinate divisor to find absolute position
                    IF cmb(vpoint).status = 2 THEN cmb(vpoint).status = 1: cmb(vpoint).bogey = 0 'cancel landed status if set
                    shipstart = cmb(vpoint).ap '                save initial point
                    cmb(vpoint).ap.pX = WinMsX / q! + cmb(vpoint).ap.pX ' x-axis stays the same at all times
                    cmb(vpoint).ap.pY = (WinMsY * COS(-zangle)) / q! + cmb(vpoint).ap.pY 'transform Y
                    cmb(vpoint).ap.pZ = (WinMsY * -SIN(-zangle)) / q! + cmb(vpoint).ap.pZ 'transform Z
                    smov = cmb(vpoint).ap: Vec_Add smov, shipstart, -1 'smov now has move displacement

                    'Do we need to recalculate bdata if the moved ship has AI nav orders  ???
                    Vec_Add cmb(vpoint).op, smov, 1 '       move active unit
                    FOR x% = 1 TO units
                        IF x% = vpoint THEN _CONTINUE
                        IF cmb(x%).status = 2 THEN _CONTINUE '  don't move non active, landed vessels
                        IF cmb(x%).status = 0 THEN _CONTINUE '  ghosts don't ride a group move, Purge those devils, damn it!
                        IF togs AND 2048 THEN '                 if MovAll enabled then move all units
                            Vec_Add cmb(x%).ap, smov, 1
                            Vec_Add cmb(x%).op, smov, 1
                        ELSE '                                  MovAll not enabled then move only fleet subordinates if any
                            IF cmb(x%).bstat <> 5 THEN _CONTINUE 'check if fleet subordinate
                            IF cmb(x%).bogey <> vpoint THEN _CONTINUE 'check if vpoint is flagship
                            Vec_Add cmb(x%).ap, smov, 1
                            Vec_Add cmb(x%).op, smov, 1
                        END IF
                    NEXT x%

                    q2! = Prop!
                    ZoomFac = ZoomFac * (q! / q2!) '            reset zoom factor to new limits
                    Refresh
                    hp% = 0 '                                   this was a ship move, not a help query
                CASE 660 TO 691 '                               bottom row display toggles
                    SELECT CASE xpos
                        CASE 560 TO 623: m$ = "<ZOOMX>"
                        CASE 626 TO 689: m$ = "<ZOOM+>"
                        CASE 692 TO 755: m$ = "<ZOOM->"
                        CASE 762 TO 817: m$ = "<RANGE>"
                        CASE 820 TO 875: m$ = "<ORBIT>"
                        CASE 878 TO 925: m$ = "<GRID>"
                        CASE 928 TO 967: m$ = "<AZI>"
                        CASE 970 TO 1009: m$ = "<INC>"
                        CASE 1012 TO 1059: m$ = "<JUMP>"
                        CASE 1062 TO 1109
                            IF togs AND 64 THEN '               if jump zone then
                                m$ = "<DIADENS>"
                            ELSE
                                hp% = 0
                            END IF
                        CASE 1132 TO 1179: m$ = "<QUIT>"
                        CASE ELSE: hp% = 0
                    END SELECT
                CASE ELSE: hp% = 0
            END SELECT
        CASE 1204 TO 1244
            SELECT CASE ypos
                CASE 4 TO 653 '                                 Z pan bar
                    m$ = "<ROTATE>"
                CASE 660 TO 691 '                               Angle toggle
                    m$ = "<ROTOG>"
                CASE ELSE: hp% = 0
            END SELECT
        CASE ELSE: hp% = 0
    END SELECT
    IF hp% THEN Text_Bubble xpos, ypos, m$ '                    if help flag is still set

END SUB 'Mouse_Button_Right


'±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
SUB Move_Turn

    'Apply all unit movements
    'called from: Main_Loop, Mouse_Button_Left
    Turncount = Turncount + 1
    Turn_2_Clock Turncount
    IF units > 0 THEN
        c% = 1: d% = 1
        DO '                                                    iterate all units
            IF cmb(c%).status > 0 THEN '                        if unit destroyed skip the computations
                IF cmb(c%).bstat > 0 THEN '                     execute automated orders if present
                    Auto_Move cmb(c%).bogey, c%, cmb(c%).bstat
                END IF
                IF cmb(c%).status <> 2 THEN '                   landed units handled in Planet_Move
                    Coord_Update c% '                           Update unit position
                    cmb(c%).Ostat = cmb(c%).status '            move previous turn info to undo info
                    cmb(c%).OSp = cmb(c%).Sp
                    cmb(c%).OHd = cmb(c%).Hd
                    cmb(c%).OIn = cmb(c%).In
                    IF cmb(c%).status <> 4 THEN '               launching ships prone to collision true so skip if launching
                        IF cmb(c%).bstat <> 3 THEN '            landing ships shouldn't crash either
                            IF togs AND 4096 THEN Col_Check c% 'check for collision with star/planet when enabled
                        END IF
                    END IF
                    IF cmb(c%).status = 4 THEN cmb(c%).status = 1 'complete launch sequence after skipping col_check once
                    cmb(c%).Sp = PyT(3, cmb(c%).op, cmb(c%).ap) 'Update speed and heading information
                    cmb(c%).Hd = Azimuth!(cmb(c%).ap.pX - cmb(c%).op.pX, cmb(c%).ap.pY - cmb(c%).op.pY)
                    cmb(c%).In = Slope!(cmb(c%).ap, cmb(c%).op)
                ELSEIF cmb(c%).status = 2 AND cmb(c%).Ostat <> 2 THEN 'fix turn undo on a just landed unit <<<REMOVE IF ACTING SCREWY
                    cmb(c%).Ostat = cmb(c%).status '            move previous turn info to undo info
                    cmb(c%).OSp = cmb(c%).Sp
                    cmb(c%).OHd = cmb(c%).Hd
                    cmb(c%).OIn = cmb(c%).In
                END IF
            END IF '                                            end: skip destroyed test
            c% = c% + 1
        LOOP UNTIL c% > units
        DO '                                                    reiterate after all have moved
            IF cmb(d%).status <> 0 THEN Col_Check_Ship d% '     if unit exists then check if any were in proximity
            d% = d% + 1
        LOOP UNTIL d% = units + 1
    END IF
    Planet_Move 1 '                                             move planets forward
    oryr = oryr + .00003170979 '                                add turn to oryr
    togs = _RESETBIT(togs, 0) '                                 clear turn undo flag
    Panel_Blank 210, 578, 64, 32
    Con_Blok 210, 578, 64, 32, "Applied", 0, &H502C9B2C
    _DISPLAY
    _DELAY .2

END SUB 'Move_Turn


'±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
SUB M_Turn_Undo

    'Undo the previous turn
    'called from: Main_Loop, Mouse_Button_Left
    IF togs AND 1 THEN
        'Do nothing, a turn undo is disallowed if togs bit 0 is set {second consequtive undo}
    ELSE
        oryr = oryr - .00003170979 '                            subtract turn from oryr
        Planet_Move -1 '                                        back peddle the planets
        Turncount = Turncount - 1
        Turn_2_Clock Turncount
        IF units > 0 THEN
            DIM m AS _MEM '                                     move old ship data block back to current data block
            m = _MEM(cmb())
            c% = 1
            DO
                _MEMCOPY m, m.OFFSET + c% * m.ELEMENTSIZE + 15, 37 TO m, m.OFFSET + c% * m.ELEMENTSIZE + 52
                c% = c% + 1
            LOOP UNTIL c% = units + 1
            _MEMFREE m
        END IF

        togs = _SETBIT(togs, 0) '                               set turn undo flag
        Panel_Blank 210, 614, 64, 32
        Con_Blok 210, 614, 64, 32, "Undone", 0, &H502C9B2C
        _DISPLAY
        _DELAY .2
    END IF

END SUB 'M_Turn_Undo


'±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
SUB New_Vector

    'Text based vector input
    'called from: Main_Loop
    IF cmb(vpoint).bstat <> 0 AND cmb(vpoint).bstat <> 5 THEN
        cmb(vpoint).bstat = 0: cmb(vpoint).bogey = 0
    END IF
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
            LOCATE 12, 56
            PRINT "Drive rated at "; cmb(vpoint).MaxG; "Gs"
            LOCATE 11, 56
            INPUT "New Acceleration:"; Thrust(vpoint).Gs
        END IF
    END IF

END SUB 'New_Vector


'±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
SUB New_Vector_Graph

    IF cmb(vpoint).bstat <> 0 AND cmb(vpoint).bstat <> 5 THEN
        cmb(vpoint).bstat = 0: cmb(vpoint).bogey = 0
    END IF
    IF cmb(vpoint).bstat = 5 OR cmb(vpoint).status = 3 THEN '   If in fleet formation or disabled
        IF cmb(vpoint).status = 3 THEN ms$ = "Unit presently disabled": wd% = 240: c~& = &HFFFF0000
        IF cmb(vpoint).bstat = 5 THEN ms$ = "Break from fleet before maneuver": wd% = 320: c~& = &HFF0000FF
        Dialog_Box ms$, wd%, 100, 50, c~&, &HFFFFFFFF
        _DISPLAY
        SLEEP 3
    ELSE
        DIM in AS _BYTE
        IF cmb(vpoint).status = 2 THEN '                        take off from landing algorithm here
            DIM pvec AS V3
            Get_Body_Vec cmb(vpoint).bogey, pvec '              vector of launch point body
            cmb(vpoint).status = 4 '                            status to launching
            cmb(vpoint).bogey = 0: cmb(vpoint).Ostat = 2 '      no Obogey puts us in limbo for a turn undo
            cmb(vpoint).Sp = PyT(2, origin, pvec) '             impart planet vector to launching vessel
            cmb(vpoint).Hd = Azimuth!(pvec.pX, pvec.pY)
            cmb(vpoint).In = 0
        END IF
        togsave~& = togs: zangsave! = zangle '                  save working state
        Panel_Blank 0, 578, 64, 32 '                            dim vector button
        _DISPLAY
        togs = _RESETBIT(togs, 1) '                             Z panning to overhead view for azimuth input
        zangle = 0 '                                            set to overhead angle 0ø
        Re_Calc '                                               recalculate coordinates for 0ø view
        Refresh '                                               refresh view at that angle
        'Conduct graphic based vector input
        SST& = _NEWIMAGE(620, 620, 32) '                        Vector input overlay
        SSR& = _COPYIMAGE(SST&) '                               guide scale overlay
        _DEST SSR&
        WINDOW (-1000, 1000)-(1000, -1000) '                    set relative cartesian coords
        _CLEARCOLOR _RGBA(0, 0, 0, 0) '                         full alpha background
        IF NOT togs AND 4 THEN Azimuth_Wheel '                  insure azimuth scale presence in overlay
        _PRINTMODE _KEEPBACKGROUND
        COLOR clr&(4)
        FOR x% = 200 TO 800 STEP 200
            CIRCLE (0, 0), x%, clr&(4) '                        Draw thrust percentage circle
            _PRINTSTRING (310 + (x% / 200) * 62, 294), STR$((x% / 800) * cmb(vpoint).MaxG) + "Gs"
        NEXT x%
        _DEST SST&
        WINDOW (-1000, 1000)-(1000, -1000) '                    set relative cartesian coords
        _CLEARCOLOR _RGBA(0, 0, 0, 0)
        DO '                                                    Azimuth display loop
            CLS
            k$ = INKEY$
            ms = MBS
            _PUTIMAGE , SS& '                                   overlay sensor screen
            _PUTIMAGE , SSR& '                                  overlay thrust/azimuth graph
            mosX = map!(_MOUSEX, 560, 1180, -1000, 1000)
            mosY = map!(_MOUSEY, 18, 638, 1000, -1000)
            IF azi$ <> "" THEN az = _D2R(VAL(azi$)) ELSE az = Azimuth!(mosX, mosY)
            ds = _HYPOT(mosX, mosY) + ws!
            IF ds > 800 THEN tc& = &H10FF0000 ELSE tc& = &H107F7F00
            IF ABS(mosX) < 1000 AND ABS(mosY) < 1000 THEN '     If mouse is in window then draw vector rays
                LINE (0, 0)-(1000 * SIN(az), 1000 * COS(az)), clr&(4) ' direction ray
                LINE (0, 0)-(mosX, mosY), clr&(14) '                    thrust ray
                FCirc 0, 0, ds, tc&
                _PRINTSTRING (3, 3), "Azi. " + STR$(_ROUND(_R2D(az) * 100) / 100) + CHR$(248), SST& 'Echo info in top left corner
                _PRINTSTRING (3, 21), "Acceleration " + STR$(INT((ds * cmb(vpoint).MaxG / 800) * 100) / 100) + " Gs", SST&
            END IF
            IF k$ <> "" THEN '                                  if a key has been pressed
                IF k$ = CHR$(13) THEN '                         if key is <enter>
                    IF azi$ <> "" THEN '                        if input string exists
                        Thrust(vpoint).Azi = _D2R(VAL(azi$)) '  convert to single precision yaw value
                        Thrust(vpoint).Gs = ds * cmb(vpoint).MaxG / 800
                        azi$ = ""
                        in = -1
                    END IF
                ELSE '                                          if not <enter>
                    Build_Str azi$, "0123456789.", k$ '         add to total input
                END IF
            END IF
            IF azi$ <> "" THEN '                                if keyboard input detected
                WINDOW
                Dialog_Box "Azimuth: " + azi$, 150, 64, 50, &HFF00AFAF, White
                WINDOW (-1000, 1000)-(1000, -1000)
            END IF
            IF ms AND 1 THEN
                Thrust(vpoint).Azi = az '                       Set azimuth heading
                Thrust(vpoint).Gs = ds * cmb(vpoint).MaxG / 800 'Apply percentage of 800 radius circle as thrust
                IF Thrust(vpoint).Gs > cmb(vpoint).MaxG * 1.25 THEN Thrust(vpoint).Gs = cmb(vpoint).MaxG * 1.25
                Clear_MB 1: in = -1
            END IF
            IF ms AND 512 THEN ws! = ws! - .5 '                 decrease- mousewheel fine tune
            IF ms AND 1024 THEN ws! = ws! + .5 '                increase- mousewheel fine tune
            _PUTIMAGE (560, 18), SST&, A& '                     overlay updated indicator ray
            _LIMIT 60
            _DISPLAY
        LOOP UNTIL in
        IF togs AND 8192 THEN '                                 if in 3D mode
            in = 0 '                                            reset input flag
            togs = _SETBIT(togs, 1) '                           toggle Z-panning to <ON>
            togs = _SETBIT(togs, 5) '                           toggle inclinometer to <ON>
            togs = _RESETBIT(togs, 7) '                         toggle orbit tracks to <OFF>
            zangle = _PI / 2 '                                  display angle 90ø
            Re_Calc '                                           recalculate for Z angle of 90ø display coordinates
            Refresh '                                           refresh display at that angle
            _DEST SSR&
            CLS
            _CLEARCOLOR _RGBA(0, 0, 0, 0)
            FCirc 0, 0, 100, &H3000FF00 '                       display 0ø inclination green zone
            _DEST SST&
            DO '                                                Inclination display loop
                CLS
                k$ = INKEY$
                ms = MBS
                _PUTIMAGE , SS&
                _PUTIMAGE , SSR&
                mosX = map!(_MOUSEX, 560, 1180, -1000, 1000) '  sensor screen mouse position
                mosZ = map!(_MOUSEY, 18, 638, 1000, -1000)
                COLOR _RGBA32(127, 127, 127, 255)
                IF inc$ <> "" THEN
                    az = _D2R(VAL(inc$))
                    azd = _D2R(90 - VAL(inc$))
                    dr% = SGN(COS(Thrust(vpoint).Azi))
                    _PRINTSTRING (3, 21), "Inclination= " + inc$ + CHR$(248)
                    LINE (0, 0)-(900 * dr% * SIN(azd), 900 * COS(azd)), clr&(4)
                ELSE
                    az = Azimuth!(ABS(mosX), mosZ)
                    azd = Azimuth!(mosX, mosZ)
                    IF _HYPOT(mosX, mosZ) > 100 THEN
                        LINE (0, 0)-(900 * SIN(azd), 900 * COS(azd)), clr&(4)
                        _PRINTSTRING (3, 21), "Inclination= " + STR$(_ROUND((_R2D(az - 1.570796)) * -100) / 100) + CHR$(248), SST&
                    ELSE
                        _PRINTSTRING (3, 21), "Inclination= 0" + CHR$(248), SST&
                    END IF
                END IF
                _PRINTSTRING (3, 37), "click center green for 0" + CHR$(248), SST&
                IF k$ <> "" THEN '                              if a key has been pressed
                    IF k$ = CHR$(13) THEN '                     if key is <enter>
                        IF inc$ <> "" THEN '                    if input string exists
                            Thrust(vpoint).Inc = _D2R(VAL(inc$))
                            in = -1
                        END IF
                    ELSE '                                      if not <enter>
                        Build_Str inc$, "0123456789.-", k$ '    add to total input
                    END IF
                END IF
                IF inc$ <> "" THEN
                    WINDOW
                    Dialog_Box "Incline: " + inc$, 150, 64, 50, &HFF00FF00, White
                    WINDOW (-1000, 1000)-(1000, -1000)
                END IF
                IF ms AND 1 THEN
                    Thrust(vpoint).Inc = (az - 1.570796) * 1 * (_HYPOT(mosX, mosZ) > 100)
                    Clear_MB 1: in = -1
                END IF
                _PUTIMAGE (560, 18), SST&, A&
                _LIMIT 60
                _DISPLAY
            LOOP UNTIL in
        END IF
        _DEST 0
        _FREEIMAGE SSR&: _FREEIMAGE SST&
        togs = togsave~&: zangle = zangsave! '                    replace saved working state
    END IF

END SUB 'New_Vector_Graph


'±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
SUB Options

    'Alter some parameters to reflect house rule changes UNDER CONSTRUCTION
    'called from: Mouse_Button_Left
    STATIC mil AS _BYTE
    Op& = _NEWIMAGE(500, 500, 32) '                         create visual example screen
    Opsw& = _COPYIMAGE(Op&)
    DO
        _DEST 0
        CLS
        Dialog_Box "OPTIONS", 1200, 650, 25, &HFF4CCB9C, clr&(15) '"OPTIONS" center justified @ y=56

        _PRINTSTRING (75, 82), "Display Toggles"

        IF togs AND 256 THEN c& = &HFF00B100: c$ = "ON" ELSE c& = &HFF4F4F4F: c$ = "OFF"
        Con_Blok 75, 100, 48, 24, c$, 0, c&
        _PRINTSTRING (125, 104), "Grav Zone Toggle [Z]"

        IF togs AND 16384 THEN c& = &HFF00B100: c$ = "ON" ELSE c& = &HFF4F4F4F: c$ = "OFF"
        Con_Blok 300, 100, 48, 24, c$, 0, c&
        _PRINTSTRING (350, 104), "Display ranks Toggle[#]"

        IF togs AND 1024 THEN c& = &HFF00B100: c$ = "ON" ELSE c& = &HFF4F4F4F: c$ = "OFF"
        Con_Blok 75, 130, 48, 24, c$, 0, c&
        _PRINTSTRING (125, 134), "Belt/Ring Toggle [B]"

        'if togs and ? then c& = &HFF00B100: c$ = "ON" ELSE c& = &HFF4F4F4F: c$ = "OFF"
        'Con_Blok 300, 100, 48, 24, c$, 0, c&
        '_PRINTSTRING (350, 104), "Whatever"

        'Range alter
        _PRINTSTRING (75, 164), "Gunnery Ranges"
        IF mil THEN
            Con_Blok 195, 164, 48, 16, "mil", 0, &HFF00FF00
            tl& = SenLocM
        ELSE
            Con_Blok 195, 164, 48, 16, "civ", 0, &HFF0000FF
            tl& = SenLocC
        END IF
        FOR x% = 0 TO 90 STEP 30
            Con_Blok 75, 180 + x%, 24, 24, "-", 0, &HFF00B100
            Con_Blok 105, 180 + x%, 24, 24, "/", 0, &HFF00B100
            Con_Blok 135, 180 + x%, 24, 24, "+", 0, &HFF00B100
        NEXT x%
        _PRINTSTRING (165, 184), "Target lock =" + STR$(tl&) '  contact lock range
        _PRINTSTRING (165, 214), "Contact lost=" + STR$(SenMax) 'contact lost range
        _PRINTSTRING (165, 244), "Close Range =" + STR$(RngCls) 'close range
        _PRINTSTRING (165, 274), "Medium Range=" + STR$(RngMed) 'medium range

        Con_Blok 75, 610, 144, 48, "Save as Default", 0, &HFF00FF00
        Con_Blok 1135, 610, 60, 48, "Exit", 0, &HFF7F107F

        xf = 250
        _DEST Op&
        CLS
        LINE (0, 0)-(499, 499), &HFF0000FF, B 'bounding box
        LINE (0, 249)-(499, 249), &H2F00FF00 'east/west line
        LINE (249, 0)-(249, 499), &H2F00FF00 'north/south line
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
        IF togs AND 16384 THEN nm$ = "Name (#)" ELSE nm$ = "Name"
        _PRINTMODE _KEEPBACKGROUND
        _PRINTSTRING (500000 * q! + xf, 500000 * q! + xf), nm$
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
        FCirc xf, xf, RngMed * q!, _RGBA(252, 252, 84, 15) '    Medium range band
        FCirc xf, xf, RngCls * q!, _RGBA(252, 84, 84, 30) '     Short range band

        DO '                                                    Input loop
            radar = radar + _PI / 120
            _DEST Opsw&
            CLS
            _CLEARCOLOR _RGB32(0)
            LINE (xf, xf)-(205 * SIN(radar) + xf, 205 * COS(radar) + xf)
            _DEST 0
            _PUTIMAGE (660, 90), Op&
            _PUTIMAGE (660, 90), Opsw&
            K$ = INKEY$ '                                       key input
            IF K$ <> "" THEN
                IF _KEYDOWN(27) THEN done% = -1
                Hotkey_Ops K$, 0
                in% = -1: K$ = ""
            END IF
            ms = MBS
            IF ms AND 1 THEN '                                  mouse input
                SELECT CASE _MOUSEY
                    CASE 100 TO 124
                        IF _MOUSEX > 75 AND _MOUSEX < 123 THEN togs = _TOGGLEBIT(togs, 8): in% = -1 'grav zones
                        IF _MOUSEX > 300 AND _MOUSEX < 348 THEN togs = _TOGGLEBIT(togs, 14): in% = -1 'planet ranks
                    CASE 130 TO 154
                        IF _MOUSEX > 75 AND _MOUSEX < 123 THEN togs = _TOGGLEBIT(togs, 10): in% = -1 'belt/ring
                    CASE 164 TO 180
                        IF _MOUSEX > 194 AND _MOUSEX < 243 THEN mil = NOT mil: in% = -1
                    CASE 180 TO 204 'target acquire
                        rng_id% = 1: GOSUB range_picks: in% = -1
                    CASE 210 TO 234 'target lose
                        rng_id% = 2: GOSUB range_picks: in% = -1
                    CASE 240 TO 264 'close range
                        rng_id% = 3: GOSUB range_picks: in% = -1
                    CASE 270 TO 294 'medium range
                        rng_id% = 4: GOSUB range_picks: in% = -1
                    CASE 610 TO 658
                        IF _MOUSEX > 75 AND _MOUSEX < 219 THEN Save_Ini: in = -1
                        IF _MOUSEX > 1134 AND _MOUSEX < 1196 THEN in% = -1: done% = -1
                END SELECT
                Clear_MB 1
            END IF
            _LIMIT 30
            _DISPLAY
        LOOP UNTIL in%
        in = 0
    LOOP UNTIL done%
    _FREEIMAGE Op&
    _FREEIMAGE Opsw&
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

    'display orientation graphic and place and move stars according to heading and speed; var=active
    'called from: Main_Loop, Screen_Limits
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
        FOR x% = 1 TO 12 '                                       iterate through stars
            PSET (starx(x%), stary(x%))
            starx(x%) = starx(x%) + xm
            stary(x%) = stary(x%) + ym
            'recycle stars that leave screen to opposite boundaries
            starx(x%) = starx(x%) + (254 * (starx(x%) > 127)) + (-254 * (starx(x%) < -127))
            stary(x%) = stary(x%) + (254 * (stary(x%) > 127)) + (-254 * (stary(x%) < -127))
        NEXT x%
    ELSE '                                                      unit is landed display a moon scape
        _DEST ORI&
        CLS
        _PUTIMAGE , Moon&, ORI&
    END IF
    LINE (-127, 127)-(127, -127), clr&(4), B
    _PRINTMODE _KEEPBACKGROUND
    _PRINTSTRING (127 - LEN((_TRIM$(cmb(var).Nam))) * 4, 2), cmb(var).Nam, ORI&

    Nshp& = _COPYIMAGE(ShpO) '                                  copy ship image
    _DEST Nshp&
    COLOR Black
    _PRINTMODE _KEEPBACKGROUND
    _PRINTSTRING (84, 156), STR$(cmb(var).id) '                 add active unit ID # to tail
    _DEST ORI&
    COLOR White
    RotoZoom3 127, 127, Nshp&, 1, 1, Thrust(var).Azi '          ship with tail ID
    _FREEIMAGE Nshp&
    IF Thrust(var).Gs > 0 THEN '                                if engines on then drive plume
        IF Thrust(var).Gs > cmb(var).MaxG THEN
            RotoZoom3 127, 127, ShpOT, 1, 1, Thrust(var).Azi '  overthrusting
        ELSE
            RotoZoom3 127, 127, ShpT, 1, 1, Thrust(var).Azi '   normal
        END IF
    END IF
    _PUTIMAGE (295, 325)-(543, 573), ORI&, A&
    IF _MOUSEX > 295 AND _MOUSEX < 543 AND _MOUSEY > 325 AND _MOUSEY < 573 THEN 'on mouse hover
        _PRINTMODE _KEEPBACKGROUND
        _PRINTSTRING (300, 560), " " + LTRIM$(Fix_Float$(Thrust(var).Gs, 2)) + "Gs" +_
         " @= " + LTRIM$(Fix_Float$(_R2D(Thrust(var).Azi), 2)) + CHR$(248) + " Z= " +_
          LTRIM$(Fix_Float$(_R2D(Thrust(var).Inc), 2)) + CHR$(248), A&
    END IF
    _DEST A&

END SUB 'Ori_Screen


'±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
SUB Panel_Blank (xpos AS INTEGER, ypos AS INTEGER, xsiz AS INTEGER, ysiz AS INTEGER)

    'Background blank to mark and mask button use and/or changes
    LINE (xpos, ypos)-(xpos + xsiz - 1, ypos + ysiz - 1), &H7F000000, BF

END SUB 'Panel_Blank


'±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
SUB Planet_Dist

    'Show distances to major system bodies in center top screen
    'called from: Refresh
    T& = _NEWIMAGE(248, 315, 32)
    _DEST T&
    CLS
    LINE (0, 0)-(247, 314), clr&(4), B
    _PRINTSTRING (156, 2), "AU", T&
    _PRINTSTRING (202, 2), "Brng", T&
    yp% = 2
    DO
        x% = x% + 1
        IF hvns(x%).star = 2 THEN _CONTINUE '                     exclude planetoid belts
        IF hvns(x%).rank > 2 THEN _CONTINUE '                     exclude satellites
        IF yp% MOD 2 = 0 THEN
            bb& = &H1F7F7F7F
        ELSE
            bb& = &HFF000000
        END IF
        COLOR clr&(3), bb&
        ds = INT((PyT(3, cmb(vpoint).ap, hvns(x%).ps) / KMtoAU) * 100) / 100
        br = _R2D(Azimuth!(rcp(x%).pX, rcp(x%).pY))
        LOCATE yp%, 2
        PRINT _TRIM$(hvns(x%).nam); SPC(16 - LEN(_TRIM$(hvns(x%).nam)));
        LOCATE , 18
        PRINT USING "###.##"; ds; SPC(2);
        LOCATE , 26
        PRINT USING "###.#"; br
        yp% = yp% + 1
    LOOP UNTIL x% = orbs
    _PUTIMAGE (295, 5)-(543, 320), T&, A&
    _DEST A&
    _FREEIMAGE T&

END SUB 'Planet_Dist


SUB Planet_Info (var AS INTEGER)

    DIM plin AS body
    plin = hvns(var)
    Dialog_Box _TRIM$(plin.nam), _WIDTH(A&) / 2.5, _HEIGHT(A&), 0, &HFF00FF00, &HFFFFFFFF
    xp% = _SHR(_WIDTH(A&), 1) - (_WIDTH(A&) / 5) + 16
    yp% = 63
    SELECT CASE plin.star
        CASE IS = -1 '                                          star
            typ$ = plin.class + plin.siz + " " + "Star"
            IF plin.rank = 1 THEN
                ord$ = "Primary"
            ELSE
                ord$ = "Companion of " + plin.parnt
            END IF
        CASE IS = 0 '                                           planetary body
            ord$ = "satellite of " + plin.parnt
            IF plin.class = "GG" THEN
                typ$ = "Gas Giant"
            ELSE
                typ$ = "Rocky/Icy body"
            END IF
        CASE IS = 2 '                                           ring/belt
            ord$ = "satellite of " + plin.parnt
            IF hvns(Find_Parent(var)).star = -1 THEN
                typ$ = "Planetoid Belt"
            ELSE
                typ$ = "Ring system"
            END IF
    END SELECT
    _PRINTSTRING (xp%, yp%), typ$ + "/ " + ord$: yp% = yp% + 32
    IF plin.star <> 2 THEN
        DIM AS V3 tmp, gv
        _PRINTSTRING (xp%, yp%), "PHYSICAL DATA": yp% = yp% + 16
        _PRINTSTRING (xp%, yp%), "Radius: " + STR$(plin.radi) + " km": yp% = yp% + 16
        _PRINTSTRING (xp%, yp%), "Mean Density: " + STR$(plin.dens) + "  " + STR$(plin.dens * 5.514) + " g/cubic cm": yp% = yp% + 16
        grav! = Surface_Gs!(plin.dens, plin.radi) / (plin.radi * plin.radi)
        _PRINTSTRING (xp%, yp%), "Surface Gravity: " + STR$(grav!) + " Gs": yp% = yp% + 32
        _PRINTSTRING (xp%, yp%), "ORBITAL DATA": yp% = yp% + 16
        Get_Body_Vec var, tmp
        _PRINTSTRING (xp%, yp%), "Orbital Velocity: " + STR$(PyT(3, origin, tmp) / 1000) + " km/s": yp% = yp% + 16
        _PRINTSTRING (xp%, yp%), "Orbital Radius: " + STR$(plin.orad) + " km": yp% = yp% + 32
        'orbital period here
        _PRINTSTRING (xp%, yp%), "POSITION/DISTANCE DATA (from active)": yp% = yp% + 16
        d## = INT(PyT(3, origin, rcp(var)))
        IF cmb(vpoint).status = 2 AND cmb(vpoint).bogey = var THEN
            _PRINTSTRING (xp%, yp%), "On surface": yp% = yp% + 16
        ELSE
            _PRINTSTRING (xp%, yp%), "Distance: " + STR$(d##) + " km": yp% = yp% + 16
        END IF
        _PRINTSTRING (xp%, yp%), "Azimuth: " + STR$(INT(_R2D(Azimuth!(rcp(var).pX, rcp(var).pY)) * 10) / 10) + CHR$(248): yp% = yp% + 16
        'inclination from active
        _PRINTSTRING (xp%, yp%), "Inclination: " + STR$(_R2D(Slope!(rcp(var), origin))) + CHR$(248): yp% = yp% + 32
        _PRINTSTRING (xp%, yp%), "GRAVITATIONAL INFLUENCE (on active)": yp% = yp% + 16
        Grav_Force_Vec gv, cmb(vpoint).ap, var
        '_PRINTSTRING (xp%, yp%), "Acceleration: " + STR$(PyT(3, origin, gv) / 5000) + " Gs": yp% = yp% + 16
        _PRINTSTRING (xp%, yp%), "Acceleration: " + Fix_Float$(PyT(3, origin, gv) / 5000, 6) + " Gs": yp% = yp% + 16
        _PRINTSTRING (xp%, yp%), "Azimuth: " + STR$(INT(_R2D(Azimuth!(gv.pX, gv.pY)) * 10) / 10) + CHR$(248): yp% = yp% + 16
        _PRINTSTRING (xp%, yp%), "Inclination: " + STR$(_R2D(Slope!(gv, origin))) + CHR$(248): yp% = yp% + 32
        'ETA @ Max Gs of active
        T2ar = 2 * SQR((d## * 1000) / (cmb(vpoint).MaxG * 10)) 'ETA time to cover distance in seconds at max Gs
        'day = INT(T2ar / 86400) '                               ETA time days
        day = T2ar \ 86400 '                               ETA time days
        'hour = INT((T2ar - day * 86400) / 3600) '               ETA time hours
        hour = (T2ar - day * 86400) \ 3600 '               ETA time hours
        'min = INT((T2ar - (day * 86400 + hour * 3600)) / 60) '  ETA time minutes
        min = (T2ar - (day * 86400 + hour * 3600)) \ 60 '  ETA time minutes
        _PRINTSTRING (xp%, yp%), "ETA @ max G: " + STR$(day) + " days " + STR$(hour) + " hours " + STR$(min) + " minutes ": yp% = yp% + 16
        _PRINTSTRING (xp%, yp%), "ETA is formulaic, actual time will vary": yp% = yp% + 16
    ELSE
        _PRINTSTRING (xp%, yp%), "PHYSICAL DATA": yp% = yp% + 16
        wid = -plin.dens * (plin.dens > 0) + -.3 * (plin.dens <= 0) 'calculate ring/belt width
        _PRINTSTRING (xp%, yp%), "Mean width: " + STR$(plin.orad * wid) + " km": yp% = yp% + 32
        _PRINTSTRING (xp%, yp%), "ORBITAL DATA": yp% = yp% + 16
        _PRINTSTRING (xp%, yp%), "Mean Orbital Radius: " + STR$(plin.orad) + " km": yp% = yp% + 16
    END IF
    '_PRINTSTRING (xp%, yp%), : yp% = yp% + 16
    '_PRINTSTRING (xp%, yp%), : yp% = yp% + 16

    _DISPLAY
    Press_Click

END SUB 'Planet_Info


'±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
SUB Planet_Move (var AS _BYTE)

    'Apply turn movement to planetary bodies- var=turncount (1 for normal turn, -1 for undo, 0 for initial setup)
    'called from: Set_Up, Load_System, Move_Turn, M_Turn_Undo
    DIM AS V3 p, o, tmp '                                       parent position, old var position & temp vector
    FOR x% = 2 TO Rank_Max% '                                   rank iteration, rank 1 primary doesn't move
        FOR v% = 1 TO orbs '                                    iterate all bodies
            IF hvns(v%).star = 2 THEN _CONTINUE '               don't move belt/ring systems except relative to parent
            IF hvns(v%).rank <> x% THEN _CONTINUE '             don't move before higher ranks
            'compute new x,y,z for body v of x rank relative to primary/parent
            IF Turncount = 0 AND var = 0 THEN '                 Initial date setup and not a turn undo to turn 0
                'Divide date by orbital period, apply remainder to planet movement {branchless}
                rot = oryr / hvns(v%).oprd + (INT(oryr / hvns(v%).oprd) * ((oryr / hvns(v%).oprd) <> INT(oryr / hvns(v%).oprd)))
                prdtrnaz## = (rot * _PI * 2) '                  multiply remainder by 360 for azimuth change
            ELSE '                                              Not initial setup so compute turn change
                prdtrnaz## = (_PI * 2) / (hvns(v%).oprd * 31557.6 * var) 'azimuth change / turn  negative .oprd yields retrograde motion (31557.6 turns/year)
            END IF
            newaz## = Az_From_Parent(v%) + prdtrnaz## '         add azimuth change to present azimuth
            p = hvns(Find_Parent(v%)).ps
            o = hvns(v%).ps '                                   preserve old position for baseline satellite calculations
            hvns(v%).ps.pX = hvns(v%).orad * SIN(newaz##) + p.pX 'update planet position
            hvns(v%).ps.pY = hvns(v%).orad * COS(newaz##) + p.pY
            'put new planet Z position here if the option for tilted orbits is later added
            tmp = hvns(v%).ps: Vec_Add tmp, o, -1 '             compute movement vector of v%
            Satellite_Move v%, tmp '                            apply parent motion to rank children of v%
            FOR u% = 1 TO units '                               check for landed vessels on v%
                IF cmb(u%).status <> 2 THEN _CONTINUE '         status 2 gives control to Planet_Move
                IF cmb(u%).bogey <> v% THEN _CONTINUE '         skip if not on v%
                DIM lnd AS V3
                cmb(u%).op = cmb(u%).ap: cmb(u%).Ostat = cmb(u%).status
                cmb(u%).OSp = cmb(u%).Sp: cmb(u%).Sp = 0
                cmb(u%).OHd = cmb(u%).Hd: cmb(u%).Hd = 0
                cmb(u%).OIn = cmb(u%).In: cmb(u%).In = 0
                lnd = hvns(v%).ps: Vec_Add lnd, o, -1: Vec_Add cmb(u%).ap, lnd, 1 'move unit with planet before checking azimuths
                shpstaz = Azimuth!(cmb(u%).ap.pX - hvns(v%).ps.pX, cmb(u%).ap.pY - hvns(v%).ps.pY) 'start azimuth
                rt = (_PI * 2) / (hvns(v%).rota * 86.4 * var) ' radian turn rotation {86.4 day rotation constant}
                shpenaz = shpstaz + rt '                        end azimuth
                cmb(u%).ap.pX = hvns(v%).radi * SIN(shpenaz) + hvns(v%).ps.pX 'update ship position
                cmb(u%).ap.pY = hvns(v%).radi * COS(shpenaz) + hvns(v%).ps.pY
                cmb(u%).ap.pZ = 0 '                             landed units assumed on ecliptic for now
    NEXT u%, v%, x%

END SUB 'Planet_Move


'±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
SUB Polar_2_Vec (vec AS V3, mag AS _INTEGER64, inc AS SINGLE, azi AS SINGLE)

    'Converts polar direction to vector- Note:Trig functions reversed for this application
    vec.pZ = mag * SIN(inc)
    vec.pX = mag * COS(inc) * SIN(azi)
    vec.pY = mag * COS(inc) * COS(azi)

END SUB 'Polar_2_Vec


'±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
SUB Press_Click

    'Pauses and waits for key press or left click to continue
    DO
        x$ = INKEY$
        IF x$ <> "" THEN in = -1
        ms = MBS
        IF ms AND 1 THEN in = -1: Clear_MB 1
        IF ms AND 2 THEN in = -1: Clear_MB 2 'enable= r.c. hold/release / remark out= r.c. dwell
        _LIMIT 30
    LOOP UNTIL in

END SUB 'Press_Click


'±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
SUB Prnt (text AS STRING, wsize AS SINGLE, hsize AS SINGLE, StartX AS _INTEGER64, StartY AS _INTEGER64,_
    Xspace AS INTEGER, Yspace AS INTEGER, col AS _UNSIGNED LONG)

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

    x% = StartX
    y% = StartY
    FOR f% = 1 TO LEN(text)
        ch% = ASC(text, f%)
        x% = x% + Xspace
        y% = y% + Yspace
        ColoredChar& = _COPYIMAGE(chr_img(ch%))
        DIM m AS _MEM, c AS _UNSIGNED LONG
        m = _MEMIMAGE(ColoredChar&)
        x& = 0
        DO UNTIL x& = m.SIZE - 4
            x& = x& + 4
            c = _MEMGET(m, m.OFFSET + x&, _UNSIGNED LONG)
            IF c = Whitesmoke THEN _MEMPUT m, m.OFFSET + x&, col
        LOOP
        _MEMFREE m
        _PUTIMAGE (x%, y%)-(x% + (wsize * 8), y% - (hsize * 16)), ColoredChar& ', 0 <<<removed to Make_Images without SCREEN
        _FREEIMAGE ColoredChar&
    NEXT f%

END SUB 'Prnt


'±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
FUNCTION Prop!

    'find the relative offsets of all units to the active unit and resize
    'to keep all in 80% of the screen, subject to zoom factor override.
    'called from: Sensor_Screen, Mouse_Button_Left, Mouse_Button_Right
    DIM deltamax AS _INTEGER64 ' carries the widest axial separation of units in km
    IF exists > 1 THEN '                                        multiple units present
        deltamax = 1000 '                                       set a minimum of 1000km
        x% = 0 '                                                reset unit counter
        DO
            x% = x% + 1
            IF cmb(x%).status = 0 OR x% = vpoint THEN _CONTINUE 'skip if active, destroyed or immobile
            IF PyT(3, origin, rcs(x)) > 300000000 THEN _CONTINUE 'skip if unit at extreme range from active
            deltamax = deltamax + (-(ABS(rcs(x%).pX) - deltamax) * (ABS(rcs(x%).pX) > deltamax)) 'X-axis branchless
            deltamax = deltamax + (-(ABS(rcs(x%).pY) - deltamax) * (ABS(rcs(x%).pY) > deltamax)) 'Y-axis branchless
        LOOP UNTIL x% = units
    ELSE '                                                      only single unit, or none present?
        IF exists THEN
            deltamax = PyT(2, origin, rcp(Closest_Rank_Body(vpoint, 0))) 'include nearest planet for orientation with single unit
        ELSE
            deltamax = hvns(1).radi '                           0 units center on primary, zoom to fit
        END IF
    END IF
    Prop! = 800 * (ZoomFac / deltamax) '                        all units on screen; subject to zoom factor

END FUNCTION 'Prop!


'±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
FUNCTION PyT (var AS _BYTE, var1 AS V3, var2 AS V3)

    'find distance/magnitude between 2D or 3D points
    SELECT CASE var
        CASE IS = 2
            PyT = _HYPOT(var1.pX - var2.pX, var1.pY - var2.pY)
        CASE IS = 3
            PyT = _HYPOT(_HYPOT(var1.pX - var2.pX, var1.pY - var2.pY), var1.pZ - var2.pZ)
    END SELECT

END FUNCTION 'PyT


'±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
FUNCTION Rank_Max%

    FOR x% = 1 TO orbs
        IF hvns(x%).rank > r% THEN r% = hvns(x%).rank
    NEXT x%
    Rank_Max% = r%

END FUNCTION 'Rank_Max%


'±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
FUNCTION Ray_Trace## (var1 AS V3, var2 AS V3, var3 AS V3, var4 AS _INTEGER64)

    'Check for Line Of Sight for sensor occlusion
    'var1= first ship, var2= second ship, var3= planet position, var4= planet radius
    'called from: Re_Calc (formerly Sensor_Mask)
    dx## = var2.pX - var1.pX: dy## = var2.pY - var1.pY: dz## = var2.pZ - var1.pZ 'vector components between ships
    A## = (dx## * dx##) + (dy## * dy##) + (dz## * dz##) 'distance between ships squared
    B## = 2 * dx## * (var1.pX - var3.pX) + 2 * dy## * (var1.pY - var3.pY) + 2 * dz## * (var1.pZ - var3.pZ)
    C## = (var3.pX * var3.pX) + (var3.pY * var3.pY) + (var3.pZ * var3.pZ) + (var1.pX * var1.pX) + (var1.pY * var1.pY) +_
                (var1.pZ * var1.pZ) + -2 * (var3.pX * var1.pX + var3.pY * var1.pY + var3.pZ * var1.pZ) - (var4 * var4)
    disabc## = (B## * B##) - 4 * A## * C## ' if disabc## < 0 then no intersection =0 tangent >0 intersects two points
    Ray_Trace## = disabc##

END FUNCTION 'Ray_Trace##


'±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
SUB Re_Calc

    'Relative/Display Vector Coordinate System- formerly separate SUB VCS
    DIM AS INTEGER c ', d
    REDIM AS V3 rcs(units), rcp(orbs), dcs(units), dcp(orbs) '  Relative/Display Coordinate Ship/Planet

    IF units = 0 THEN vpoint = 0: c = 0 ELSE c = 1 '            if no ships then set origin of VCS at primary
    exists = 0
    DO '                                                        ITERATE THROUGH SHIPS, setting coordinates for unit c
        exists = exists - (cmb(c).status <> 0) '                Set number of non-destroyed units {used in FUNCTION Prop!}
        rcs(c) = cmb(c).ap: Vec_Add rcs(c), cmb(vpoint).ap, -1 'Set relative ship coordinate system from active unit
        dcs(c) = rcs(c) '                                       initialize display coordinate
        IF togs AND 2 THEN Vec_Rota dcs(c) '                    adjust display coordinates for rotation
        c = c + 1
    LOOP UNTIL c > units

    c = 1 '                                                     start at first celestial object
    DO '                                                        ITERATE THROUGH PLANETS
        IF hvns(c).star <> 2 THEN '                             Belts and rings have parent centers and orbit radii instead of coordinates
            rcp(c) = hvns(c).ps: Vec_Add rcp(c), cmb(vpoint).ap, -1 'Set relative planet coordinate point from active unit
            dcp(c) = rcp(c)
            IF togs AND 2 THEN Vec_Rota dcp(c)
        END IF
        c = c + 1
    LOOP UNTIL c > orbs

    'Determine which units may be sensor occluded by planetary bodies. Clear any too distant target locks. Formerly SUB Sensor_Mask
    FOR x% = 1 TO units '                                       Active unit iteration  x=active
        FOR y% = 1 TO units '                                   Passive unit iteration  y=passive
            Sensor(x%, y%) = _RESETBIT(Sensor(x%, y%), 0) '     Assume innocent until proven guilty
            IF x% = y% THEN _CONTINUE '                         if unit is self then skip and leave at zero
            IF PyT(3, cmb(x%).ap, cmb(y%).ap) > SenMax THEN Sensor(x%, y%) = _RESETBIT(Sensor(x%, y%), 1) 'too far to target
            FOR z% = 1 TO orbs '                                Planetary body iteration
                IF hvns(z%).star = 2 THEN _CONTINUE '           Skip belt/ring systems
                IF PyT(3, rcs(x%), rcp(z%)) < PyT(3, rcs(x%), rcs(y%)) THEN 'is planet closer to active than passive is?
                    IF PyT(3, rcs(y%), rcp(z%)) < PyT(3, rcs(x%), rcs(y%)) THEN 'is planet closer to passive than active is?
                        IF Ray_Trace##(rcs(x%), rcs(y%), rcp(z%), hvns(z%).radi) > 0 THEN 'if ray trace indicates no LOS then
                            Sensor(x%, y%) = _SETBIT(Sensor(x%, y%), 0) 'Passive is sensor occluded and not visible to Active
                            IF Sensor(x%, y%) AND 2 THEN Sensor(x%, y%) = _RESETBIT(Sensor(x%, y%), 1) 'no target lock if occluded
                        END IF
                    END IF '                                    end: is planet between?
                END IF '                                        end: is planet close?
    NEXT z%, y%, x% '                                           end: iterations planetary body/ passive unit/ active unit

END SUB 'ReCalc


'±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
SUB Refresh

    'Redraw main program screen using current data
    'called from: various
    Screen_Limits '                                             Open sensor display viewport
    Sensor_Screen '                                             display sensor data
    Ship_Display '                                              print unit positions, speeds and headings
    Button_Block '                                              control panel
    Planet_Dist '                                               show main planet bearings and distances

END SUB 'Refresh


'±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
SUB Remove_Units (mode AS _BYTE)

    'Delete active {mode -1}, or purge destroyed {mode 0}, ships from session
    'called from: Hotkey_Ops, Mouse_Button_Left
    IF units > 0 THEN
        IF mode THEN
            n$ = "You're about to delete " + RTRIM$(cmb(vpoint).Nam) + ". Continue?"
            ct% = 1
        ELSE
            n$ = "You're about to purge destroyed units. Continue?"
            I$ = cmb(vpoint).Nam '                              Preserve an active unit identifier
            FOR x% = 1 TO units
                ct% = ct% - (cmb(x%).status = 0) '              Count number of destroyed units
            NEXT x%
            IF ct% = 0 THEN EXIT SUB
        END IF
        Dialog_Box n$, 500, 200, 100, clr&(4), clr&(15)
        Con_Blok 480, 225, 120, 32, "Yes [enter]", 0, &HFFC80000
        Con_Blok 660, 225, 120, 32, "No [Esc]", 0, &HFFC80000
        _DISPLAY
        IF mode THEN Cancel_AI vpoint, 0
        DO
            x$ = UCASE$(INKEY$)
            ms = MBS
            IF ms AND 1 THEN
                SELECT CASE _MOUSEY
                    CASE 225 TO 257
                        SELECT CASE _MOUSEX
                            CASE 480 TO 600 '                   delete with mouseclick on "Yes"
                                dl% = -1
                            CASE 660 TO 780 '                   abort delete with mouseclick on "No"
                                EXIT SUB
                        END SELECT
                END SELECT
                Clear_MB 1
            END IF
            IF x$ = CHR$(13) THEN dl% = -1 '                    delete with ENTER
            IF x$ = CHR$(27) THEN EXIT SUB '                    abort delete with ESC keypress
            _LIMIT 30
        LOOP UNTIL dl%
        n% = units - ct%
        DIM tmpshp(units) AS ship
        DIM tmpthrs(units) AS Maneuver
        DIM tmpordt(units) AS Odata
        DIM tmpG(units) AS Maneuver
        DIM tmpsens(units, units) AS _BYTE
        y% = 0
        FOR x% = 1 TO units '                                   outer iteration of all units
            IF mode THEN '                                      if <delete>
                IF x% = vpoint THEN _CONTINUE '                 skip over active unit
            ELSE '                                              if <purge>
                IF cmb(x%).status = 0 THEN _CONTINUE '          skip over any destroyed unit
            END IF '
            y% = y% + 1 '                                       increment outer temp count
            tmpshp(y%) = cmb(x%) '                              put whatever screens through in temporary variables
            tmpthrs(y%) = Thrust(x%) '
            tmpordt(y%) = OrbDat(x%) '
            tmpG(y%) = Gwat(x%) '
            z% = 0 '
            FOR q% = 1 TO units '                               inner iteration for 2 dimensional Sensor array
                IF mode THEN '                                  if <delete>
                    IF q% = vpoint THEN _CONTINUE '             skip over passive sensor dimension
                ELSE '                                          if <purge>
                    IF cmb(q%).status = 0 THEN _CONTINUE '      skip over passive sensor dimension
                END IF '
                z% = z% + 1 '                                   increment inner counter
                tmpsens(y%, z%) = Sensor(x%, q%) '              put filtered results in temporary 2D array
        NEXT q%, x% '

        units = n% '                                            set new units value
        REDIM cmb(units) AS ship '                              DON'T use Index_Ship units, 0 here
        REDIM Thrust(units) AS Maneuver '                       it frags the whole display somehow
        REDIM OrbDat(units) AS Odata
        REDIM Gwat(units) AS Maneuver
        REDIM Sensor(units, units) AS _BYTE
        FOR x% = 1 TO units '                                   Move temps back into primary variables
            cmb(x%) = tmpshp(x%)
            Thrust(x%) = tmpthrs(x%)
            OrbDat(x%) = tmpordt(x%)
            Gwat(x%) = tmpG(x%)
            IF NOT mode THEN
                IF cmb(x%).Nam = I$ THEN vpoint = x% '          set active to new position
            END IF
            FOR y% = 1 TO units
                Sensor(x%, y%) = tmpsens(x%, y%)
            NEXT y%
        NEXT x%
        IF mode THEN
            _FREEIMAGE ship_box(units + 1) '                    free data box memory
            vpoint = vpoint + (vpoint > units) '                decrement the active counter if over units
        ELSE
            a% = units + 1: b% = units + ct
            FOR x% = a% TO b% '                                 free abandoned ship display memory handles
                _FREEIMAGE ship_box(x%)
            NEXT x%
        END IF
    ELSE
        Dialog_Box "There are no further units to be deleted", 400, 200, 100, clr&(4), clr&(15)
        SLEEP 4
    END IF

END SUB 'Remove_Units


'±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
SUB RotoZoom3 (X AS LONG, Y AS LONG, Image AS LONG, xScale AS SINGLE, yScale AS SINGLE, radianRotation AS SINGLE)

    'With grateful thanks to Galleon and Bplus for this SUB, wish I was this good...
    'called from: Ori_Screen, Z_Panner
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
SUB Satellite_Move (var AS INTEGER, mov AS V3)

    'Move all satellites and sub-satellites of {var} by var's turn movement vector {mov}
    'recursive calls to sub satellites as needed
    'called from: Planet_Move, or self
    FOR s% = 1 TO orbs
        IF hvns(s%).rank <= hvns(var).rank THEN _CONTINUE '     skip parents and equals
        IF hvns(s%).parnt = hvns(var).nam THEN '                if var is a parent of s%
            Vec_Add hvns(s%).ps, mov, 1 '                       move s% with var's mov
            Satellite_Move s%, mov '                            recursive check for children of s%
        END IF
    NEXT s%

END SUB 'Satellite_Move


'±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
SUB Save_Ini

    f$ = "default.ini"
    IF _FILEEXISTS(f$) THEN KILL f$
    ff& = FREEFILE
    OPEN f$ FOR BINARY AS ff&
    PUT ff&, , togs
    PUT ff&, , SenMax
    PUT ff&, , SenLocC
    PUT ff&, , SenLocM
    PUT ff&, , RngCls
    PUT ff&, , RngMed
    CLOSE ff&

END SUB 'Save_Ini


'±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
SUB Save_Scenario (var AS _BYTE)

    'Save the present scenario
    'called from: Main_Loop, Mouse_Button_Left
    IF _DIREXISTS("scenarios") THEN '                           if "scenarios\" folder exists
        IF var THEN '                                           if not autosave then get scenario name
            fl$ = GetSaveFileName("Save Scenario", _CWD$ + "\scenarios\", "scenario files (*.tfs)|*.tfs", 1)
            t% = 400: r% = 2
            Dialog_Box "SAVING PRESENT SCENARIO", t%, 250, 50, &HFF8C5B4C, clr&(15)
            LOCATE r% + 5, _SHR((_SHR(_WIDTH(A&), 1) - _SHR(t%, 1)), 3) + 4
            PRINT "Scenario name: "; MID$(fl$, LEN(_CWD$) + 12)
            LOCATE r% + 7, _SHR((_SHR(_WIDTH(A&), 1) - 40), 3)
            PRINT "Saving..."
            _DISPLAY
            fx$ = fl$
        ELSE
            IF _DIREXISTS("scenarios\autosave") THEN '          set or create autosave path
                fl$ = "autosave\auto"
            ELSE '                                              autosave does not exist, create it
                CHDIR "scenarios"
                MKDIR "autosave"
                CHDIR "..\"
                fl$ = "autosave\auto"
            END IF
            fx$ = "scenarios\" + _TRIM$(fl$) + ".tfs"
        END IF
        IF _FILEEXISTS(fx$) THEN KILL fx$ '                     write system scenario state file
        t& = FREEFILE
        OPEN fx$ FOR BINARY AS t&
        PUT t&, , VerA
        PUT t&, , VerB
        PUT t&, , VerC
        PUT t&, , units
        PUT t&, , orbs
        PUT t&, , Turncount
        PUT t&, , oryr
        PUT t&, , vpoint
        PUT t&, , shipoff
        PUT t&, , togs
        PUT t&, , zangle
        PUT t&, , Ozang
        FOR h% = 1 TO orbs
            PUT t&, , hvns(h%)
        NEXT h%
        FOR s% = 1 TO units
            PUT t&, , cmb(s%)
            PUT t&, , Thrust(s%)
            PUT t&, , OrbDat(s%)
            FOR sm% = 1 TO units
                PUT t&, , Sensor(s%, sm%)
            NEXT sm%
        NEXT s%
        CLOSE t&
        IF var THEN _DELAY .5 '                                 pause for visual feedback of save
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

    'Save the present ship list
    'called from: Main_Loop, Mouse_Button_Left
    IF _DIREXISTS("ships") THEN
        fl$ = GetSaveFileName("Save Ship Group", _CWD$ + "\ships\", "ship files (*.tvg)|*.tvg", 1)
        t% = 400
        Dialog_Box "SAVING PRESENT VESSEL(s) & POSITION(s)", t%, 250, 50, &HFF8C5B4C, clr&(15)
        LOCATE r% + 8, _SHR((_SHR(_WIDTH(A&), 1) - _SHR(t%, 1)), 3) + 4
        PRINT "Vessel group: "; MID$(fl$, LEN(_CWD$) + 8)
        LOCATE r% + 10, _SHR((_SHR(_WIDTH(A&), 1) - 40), 3)
        PRINT "Saving..."
        _DISPLAY
        sn& = FREEFILE
        OPEN fl$ FOR BINARY AS sn&
        FOR x% = 1 TO units: PUT sn&, , cmb(x%): NEXT '           Save all ships
        CLOSE sn&
        _DELAY .5 '                                             pause for visual feedback of save
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

    'Save a non-zero year system state
    'called from: Mouse_Button_Left
    IF _DIREXISTS("systems") THEN
        fl$ = GetSaveFileName("Save System", _CWD$ + "\systems\", "system files (*.tss)|*.tss", 1)
        t% = 600
        Dialog_Box "SAVING SYSTEM", t%, 250, 50, &HFF8C5B4C, clr&(15)
        IF _FILEEXISTS(fl$) THEN
            in1$ = "Warning an existing system file will be over written!"
            in2$ = "This will overwrite existing system ephemeris"
            l = _SHR(_WIDTH(A&), 1) - _SHL(LEN(in1$), 2)
            _PRINTSTRING (l, 120), in1$, A&
            l = _SHR(_WIDTH(A&), 1) - _SHL(LEN(in2$), 2)
            _PRINTSTRING (l, 136), in2$, A&
            Con_Blok 480, 225, 120, 32, "Save [enter]", 0, &HFF00C800
            Con_Blok 660, 225, 120, 32, "Abort [Esc]", 0, &HFFC80000
            Clear_MB 1
            DO
                k$ = INKEY$
                ms = MBS
                IF k$ <> "" THEN
                    IF k$ = CHR$(13) THEN in = -1
                    IF k$ = CHR$(27) THEN EXIT SUB
                END IF
                IF ms AND 1 THEN
                    IF _MOUSEY > 224 AND _MOUSEY < 258 THEN
                        SELECT CASE _MOUSEX
                            CASE 480 TO 600
                                in = -1
                            CASE 660 TO 780
                                EXIT SUB
                        END SELECT
                    END IF
                    Clear_MB 1
                END IF
                _LIMIT 30
                _DISPLAY
            LOOP UNTIL in
        END IF
        fs& = FREEFILE
        OPEN fl$ FOR BINARY AS fs&
        FOR x% = 1 TO orbs: PUT fs&, , hvns(x%): NEXT x% '          save all planets
        CLOSE fs&
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
SUB Scene_Get (sysname AS STRING)

    'Loads all saved scenario data
    'called from: Gate_Keeper, Load_Scenario
    ff& = FREEFILE
    OPEN sysname FOR BINARY AS ff&
    FOR vr% = 1 TO 3 '                                          version tags, future compatibility expansions
        GET ff&, , vt%%
    NEXT vr%
    GET ff&, , units '                                           Load environment
    GET ff&, , orbs
    GET ff&, , Turncount
    GET ff&, , oryr
    GET ff&, , vpoint
    GET ff&, , shipoff
    GET ff&, , togs
    GET ff&, , zangle
    GET ff&, , Ozang
    REDIM hvns(orbs) AS body '                                  Create required variable and image states
    Index_Ship units, 0
    FOR x% = 1 TO units '                                       define sufficient ship data images
        ship_box(x%) = _NEWIMAGE(290, 96, 32)
    NEXT x%
    FOR h% = 1 TO orbs '                                        Load system details
        GET ff&, , hvns(h%)
    NEXT h%
    FOR s% = 1 TO units '                                       Load ships and sensor states
        GET ff&, , cmb(s%)
        GET ff&, , Thrust(s%)
        GET ff&, , OrbDat(s%)
        FOR sm% = 1 TO units
            GET ff&, , Sensor(s%, sm%)
    NEXT sm%, s%
    CLOSE ff&
    Turn_2_Clock Turncount

END SUB 'Scene_Get


'±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
SUB Screen_Limits

    'Create screen border info
    'called from: Refresh
    _DEST A&
    COLOR , &HFF0F0F0F '                                        dark grey background
    CLS

    _PRINTSTRING (560, 0), "Turn #" + STR$(Turncount), A& '     Turn and time elapsed
    IF etd THEN tm$ = _TRIM$(STR$(etd)) + "d "
    IF eth OR Turncount > 3 THEN tm$ = tm$ + _TRIM$(STR$(eth)) + "h "
    IF Turncount > 0 THEN tm$ = tm$ + _TRIM$(STR$(etm)) + "m " + _TRIM$(STR$(ets)) + "s"
    _PRINTSTRING (672, 0), tm$, A&

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

    FOR x% = 1 TO 8
        _PRINTSTRING (1187, 249 + (x% * 16)), MID$("TRAILING", x%, 1), A& 'Galactic orientation screen right
        _PRINTSTRING (547, 249 + (x% * 16)), MID$("SPINWARD", x%, 1), A& 'Galactic orientation screen left
    NEXT

    _PRINTSTRING (1062, 641), "Date:"
    d$ = _TRIM$(STR$(INT((oryr - INT(oryr)) * 365))) + "-"
    y$ = _TRIM$(STR$(INT(oryr)))
    _PRINTSTRING (1116, 641), d$
    _PRINTSTRING (1148, 641), y$

    Ori_Screen vpoint '                                          need Ori_Screen here to display during out of loop operations
    IF togs AND 8192 THEN Z_Panner

END SUB 'Screen_Limits


'±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
SUB Sensor_Screen

    'Graphic navigation sensor screen
    'called from: Refresh
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
    q! = Prop! '                                                get zoom factor proportions
    IF togs AND 8 THEN '                                        If grid toggle is TRUE
        DIM dynagrid AS SINGLE
        dynagrid = 10 ^ INT(LOG(600 / q!) / LOG(10.#)) '        size grid by powers of 10
        g = 0: dc% = 0: dynaq = q! * dynagrid
        DO UNTIL g > 1000 '                                     Draw grid
            IF dc% MOD 10 = 0 THEN gl& = &H28FFFFFF ELSE gl& = &H0FFFFFFF 'set 10 power line fade
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

    System_Map q! '                                             Draw system details @ zoom factor

    'UNIT PLACEMENTS, VECTORS, RANGES AND ID                    Draw each unit and index number on screen
    DIM UDisp AS V3 '                                           proportional dcs unit placement
    DIM VDisp AS V3 '                                           vector indicator transformation

    shipcl& = clr&(2) '                                         set default ship name color to green (going)
    FOR x% = 1 TO units '                                       Iterate through all ships
        UDisp = dcs(x%): Vec_Mult UDisp, q! '                   unit positions for display
        rtds% = PyT(2, origin, dcs(x%)) * q! '                  relative distance factor {active to x}

        Polar_2_Vec VDisp, cmb(x%).Sp, cmb(x%).In, cmb(x%).Hd ' calculate heading vector tails, returning in VDisp,
        Vec_Add VDisp, rcs(x%), 1 '                             add relative unit postion to it,
        Vec_Rota VDisp: Vec_Mult VDisp, q! '                    apply any rotations and scale to display factor

        IF ABS(UDisp.pX) < 1415 OR ABS(UDisp.pY) < 1415 THEN '  skip draw if out of frame
            IF NOT Sensor(vpoint, x%) AND 1 THEN '              If ship x is not sensor occluded then draw it
                cp = -9 * (dcs(x%).pZ > dcs(vpoint).pZ) + -12 * (dcs(x%).pZ < dcs(vpoint).pZ) + -7 * (dcs(x%).pZ = dcs(vpoint).pZ) 'nearer or farther colors
                IF PyT(3, origin, rcs(x%)) > 300000000 THEN '   extreme distance (grey)
                    cp = 7: tfr% = -1 '
                END IF

                IF cmb(x%).status > 0 THEN '                     Draw point box, name & reticle/laser if target locks
                    LINE (UDisp.pX - 5, UDisp.pY + 5)-(UDisp.pX + 5, UDisp.pY - 5), clr&(cp), BF 'point box
                    IF x% <> vpoint AND (Sensor(vpoint, x%) AND 2) THEN 'Draw target lock indicator if targeted by active
                        rtm = -1 * (rtds% > 400) + -(rtds% / 400) * (rtds% <= 400) 'resize reticle on zoom in with reticle multiplier
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
                        IF x% <> vpoint AND (Sensor(x%, vpoint) AND 2) THEN 'Draw target laser if inactive targeting active
                            LINE (0, 0)-(UDisp.pX, UDisp.pY), &H7FCD9575, , &B0011001100001111 '  &H5FFC5454original &HFFCD9575AntiqueBrass
                        END IF
                    END IF
                    IF x% = vpoint AND cmb(x%).status <> 3 THEN 'bright green unless damaged
                        shipcl& = clr&(10)
                        GOSUB shipID
                        shipcl& = clr&(2)
                    ELSE
                        IF tfr% THEN '                          if at extreme range/ more than a light turn
                            shipcl& = clr&(cp)
                            GOSUB shipID
                            shipcl& = clr&(2)
                        ELSE
                            IF cmb(x%).status = 3 THEN '        red if damaged and drifting, active or otherwise
                                shipcl& = clr&(4)
                                GOSUB shipID
                                shipcl& = clr&(2)
                            ELSE '                              green undamaged non-active units
                                GOSUB shipID
                                shipcl& = clr&(2)
                            END IF
                        END IF
                    END IF
                    IF cmb(x%).status <> 2 THEN '               if unit x isn't landed
                        IF x% = vpoint THEN '                   draw active unit's vector indicator yellow
                            LINE (0, 0)-(VDisp.pX, VDisp.pY), _RGB32(222, 188, 17)
                        ELSE '                                  draw inactive units vector indicator bluegreen
                            LINE (UDisp.pX, UDisp.pY)-(VDisp.pX, VDisp.pY), _RGB32(17, 188, 222)
                        END IF
                    END IF
                END IF '                                        end: destroyed test
            END IF '                                            end Sensor(vpoint,x) check
        END IF '                                                end out of frame skip

        ' RANGING BANDS & CIRCLES
        IF NOT togs AND 16 THEN _CONTINUE '                     if range toggle is false then skip the rest
        IF x% = vpoint THEN '                                   Draw ranging circles of active unit
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
    NEXT x%

    'Grav watcher- upper right sensor screen
    _PRINTMODE _KEEPBACKGROUND
    COLOR _RGBA(0, 255, 0, 50)
    _PRINTSTRING (550, 5), "G:" + STR$(_ROUND(Gwat(vpoint).Gs * 100) / 100), SS&
    _PRINTSTRING (550, 21), "A:" + STR$(_ROUND(_R2D(Gwat(vpoint).Azi) * 100) / 100), SS&
    _PRINTSTRING (550, 37), "I:" + STR$(_ROUND(_R2D(Gwat(vpoint).Inc) * 100) / 100), SS&

    _DEST A& '                                                  return output to main screen
    _PUTIMAGE (560, 18), SS&, A& '                              update sensor screen to mainscreen
    EXIT SUB

    shipID: '                                                   print ship names in font or image if font failed
    IF rtds% > 100 OR x% = vpoint THEN
        IF x% = vpoint OR (Sensor(x%, x%) AND 16) THEN
            trn$ = cmb(x%).Nam
        ELSE
            trn$ = "??? (" + _TRIM$(STR$(cmb(x%).id)) + ")"
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

    Planet_Move 0 '                                             Initial planet position determined by date
    RANDOMIZE TIMER
    DO '                                                        select a random body for ship cluster
        pl% = INT(RND * orbs) + 1
    LOOP UNTIL hvns(pl%).star <> 2 AND hvns(pl%).radi > 100 '   don't place in belt/ring or near trash
    'pl% = 6 '<<< use this line if desiring a specific body for testing purposes, otherwise remark out

    RESTORE ships
    READ a
    units = a
    Index_Ship units, 0
    FOR x% = 1 TO units '                                       initialize unit data
        ship_box(x%) = _NEWIMAGE(290, 96, 32) '                 data box
        cmb(x%).id = x%: READ cmb(x%).Nam: READ cmb(x%).MaxG
        READ cmb(x%).ap.pX: READ cmb(x%).ap.pY: READ cmb(x%).ap.pZ
        READ cmb(x%).Sp: READ cmb(x%).Hd: READ cmb(x%).In: READ cmb(x%).mil
        cmb(x%).op = cmb(x%).ap
        AZ = RND * (_PI * 2)
        cmb(x%).status = 1
        Thrust(x%).Azi = RND * (_PI * 2) '                      random orientation
        ds = RND * 500 + 40 '                                   random distance in radii of body
        dz = RND * 20 - 10
        cmb(x%).ap.pX = (hvns(pl%).radi * ds) * SIN(AZ) + hvns(pl%).ps.pX
        cmb(x%).ap.pY = (hvns(pl%).radi * ds) * COS(AZ) + hvns(pl%).ps.pY
        IF togs AND 8192 THEN
            cmb(x%).ap.pZ = hvns(pl%).radi * dz
        ELSE
            cmb(x%).ap.pZ = 0
        END IF
        cmb(x%).op = cmb(x%).ap '                               prevent first turn runaway
        Sensor(x%, x%) = _SETBIT(Sensor(x%, x%), 4) '           all transponders on by default
    NEXT x%
    Re_Calc

END SUB 'Set_Up


'±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
SUB Ship_Display

    'Create ship data displays
    'called from: Refresh
    DIM AS _BYTE vpt, dst, lan, far, ovr, flt, occ, stl '       logic test variables
    IF cmb(vpoint).mil THEN s&& = _SHR(SenLocM, 1) ELSE s&& = _SHR(SenLocC, 1) 'set active's sensor range

    FOR x% = 1 TO units '                                       Iterate all units
        vpt = (x% = vpoint) '                                   Is x% the active unit?
        dst = (cmb(x%).status = 0) '                            Is x% destroyed?
        lan = (cmb(x%).status = 2) '                            Is x% landed?
        far = (PyT(3, cmb(vpoint).ap, cmb(x%).ap) > 1500000000) 'Is x% greater than 10 AU distant?
        ovr = (Thrust(x%).Gs > cmb(x%).MaxG) '                  Is x% overloading its drives?
        flt = (cmb(x%).bstat = 5) '                             Is x% slaved to a fleet maneuver?
        occ = _READBIT(Sensor(vpoint, x%), 0) '                 Is x% sensor occluded from the active unit?
        stl = ((NOT (Sensor(x%, x%) AND 16)) AND (PyT(3, cmb(vpoint).ap, cmb(x%).ap) > s&&)) 'Is x% running silent? {transponder OFF}
        IF Sensor(vpoint, x%) AND 2 THEN stl = 0

        _DEST ship_box(x%) '                                    Set ship box x%
        _PRINTMODE _KEEPBACKGROUND
        IF fa14& > 0 THEN _FONT fa14&
        IF vpt THEN '                                           Clear with correct colors for x%
            COLOR clr&(15), clr&(8)
        ELSE
            IF (Sensor(vpoint, x%) AND 1) OR dst THEN '         Occluded or destroyed
                COLOR clr&(8), clr&(0)
            ELSE
                COLOR clr&(3), clr&(0)
            END IF
        END IF
        CLS

        IF cmb(x%).status = 3 THEN _PUTIMAGE , dsabl '          overlay shatter image for disabled unit
        IF ovr THEN '                                           Overdrive watermark
            f% = INT(((Thrust(x%).Gs / cmb(x%).MaxG) - 1) * 100)
            IF fa32& > 0 THEN
                prefont& = _FONT
                precolor& = _DEFAULTCOLOR
                _FONT fa32&
                IF vpt THEN COLOR &HFFFF6000 ELSE COLOR &H8FFF6000 'adjust constrast
                _PRINTSTRING (12, 30), "Overdriven " + STR$(f%) + "%"
                _FONT prefont&
                COLOR precolor&
            ELSE
                Prnt "Overdriven", 3.5, -3.5, -22, 18, 28, 0, &H6FFF6000
            END IF
        END IF

        'Create unit 'x%' data display line by line---unit ID & transponder----------------------- line 1  (x%,0)
        PRINT cmb(x%).id; " ";
        IF vpt THEN
            PRINT cmb(x%).Nam;
            IF Sensor(x%, x%) AND 16 THEN _PUTIMAGE (241, 0), trnon ELSE _PUTIMAGE (241, 0), trnoff
        ELSE
            IF NOT occ THEN
                IF Sensor(x%, x%) AND 16 THEN
                    PRINT cmb(x%).Nam;
                    _PUTIMAGE (241, 0), trnon ', ship_box(x%)
                ELSE
                    PRINT "no signal"
                    _PUTIMAGE (241, 0), trnoff ', ship_box(x%)
                END IF
            END IF
        END IF
        FOR o = 1 TO units 'If any other units are slaved to unit x%, display flagship icon
            IF o = x% THEN _CONTINUE
            IF Sensor(x%, o) AND 8 THEN '      Proximity with Sensor bit 3 test
                _PRINTSTRING (119, 0), "PROX " + _TRIM$(STR$(o))
            END IF
            IF cmb(o).bstat = 5 AND cmb(o).bogey = x% THEN
                _PUTIMAGE (273, 0), flag ', ship_box(x%)
            END IF
        NEXT o
        '---------------------------------------------unit absolute position--------------------- line 2  (x%,16)
        IF (NOT far) AND (NOT stl) AND (NOT occ) THEN
            LOCATE 2, 1
            PRINT "X:";: Trunc_Coord cmb(x%).ap.pX: PRINT " "; 'Absolute coordinate position
            PRINT "Y:";: Trunc_Coord cmb(x%).ap.pY: PRINT " ";
            PRINT "Z:";: Trunc_Coord cmb(x%).ap.pZ: PRINT
        END IF
        '---------------------------------------------unit speed & heading----------------------- line 3  (x%,32)
        IF NOT stl THEN
            IF far THEN
                COLOR clr&(3), clr&(0)
                _PRINTSTRING (0, 32), "Extreme Range"
            ELSE
                IF occ THEN
                    _PRINTSTRING (0, 32), "Contact is sensor occluded"
                ELSE '                                          speed/heading/inclination
                    _PRINTSTRING (0, 32), "Spd:" + Fix_Float$(cmb(x%).Sp / 1000, 2) + "kps"
                    _PRINTSTRING (128, 32), "Hdg: " + Fix_Float$(_R2D(cmb(x%).Hd), 1)
                    _PRINTSTRING (216, 32), "Z:" + Fix_Float$(_R2D(cmb(x%).In), 1)
                END IF
            END IF
        ELSE
            COLOR clr&(3), clr&(0)
            _PRINTSTRING (0, 32), "Contact Indistinct"
        END IF
        '---------------------------------------------bearing & distance------------------------- line 4  (x%,48)
        IF (NOT far) AND (NOT stl) AND (NOT vpt) AND (NOT occ) THEN
            _PRINTSTRING (0, 48), "Brng:" '                     unit bearing
            br = Bearing(x%)
            IF collision THEN presclr& = _DEFAULTCOLOR: COLOR clr&(12)
            _PRINTSTRING (40, 48), Fix_Float$(_R2D(br), 1)
            slp = _R2D(Slope!(cmb(x%).ap, cmb(vpoint).ap)) '    Z-angle
            _PRINTSTRING (88, 48), "Z: " + Fix_Float$(slp, 2) ' + _TRIM$(STR$(slp))  if Fix_Float doesn't work
            d## = PyT(3, cmb(vpoint).ap, cmb(x%).ap) '          Distance
            IF d## < 10000000 THEN
                d$ = "km: " + STR$(INT(d##))
            ELSE
                d$ = "AU: " + Fix_Float$(d## / KMtoAU, 3)
            END IF
            _PRINTSTRING (160, 48), d$
            IF collision THEN COLOR presclr&
            collision = NOT collision
        END IF
        '---------------------------------------------automoves, fleet status & targeting-------- line 5  (x%,64)
        IF vpt THEN
            IF flt THEN
                _PUTIMAGE (0, 64), break& ', ship_box(x%) '       Break instead of flight
                GOSUB fleet_icons
            ELSE
                _PUTIMAGE (0, 64), flight& ', ship_box(x%) '      Flightplan image
                IF cmb(x%).bstat <> 0 THEN _PRINTSTRING (260, 64), "auto"
            END IF
        ELSE
            IF (NOT dst) AND (NOT far) AND (NOT stl) AND (NOT occ) THEN
                IF cmb(vpoint).status <> 2 THEN '               if vpoint not landed
                    IF x% = cmb(vpoint).bogey AND cmb(vpoint).bstat < 3 THEN 'cancel image
                        _PUTIMAGE (0, 64), cancel& ', ship_box(x%)
                        SELECT CASE cmb(vpoint).bstat
                            CASE IS = 1: _PRINTSTRING (50, 64), "evade"
                            CASE IS = 2: _PRINTSTRING (50, 64), "intercept"
                        END SELECT
                    ELSE '                                      Automove images
                        _PUTIMAGE (0, 64), evade& ', ship_box(x%)
                        _PUTIMAGE (49, 64), intercept& ', ship_box(x%)
                        IF flt THEN
                            _PUTIMAGE (130, 64), break& ', ship_box(x%) 'w/break
                            GOSUB fleet_icons
                        ELSE
                            IF NOT lan THEN
                                _PUTIMAGE (130, 64), fleet& ', ship_box(x%) 'w/fleet
                            END IF
                        END IF
                    END IF
                END IF '                                        end: landed skip
                IF cmb(vpoint).mil THEN b&& = SenLocM ELSE b&& = SenLocC 'target lock state
                IF Sensor(vpoint, x%) AND 2 THEN
                    _PUTIMAGE (273, 64), TunLoc, ship_box(x%) ' break target lock
                ELSE
                    IF PyT(3, cmb(vpoint).ap, cmb(x%).ap) <= b&& THEN
                        _PUTIMAGE (273, 64), TLoc ', ship_box(x%) 'target possible
                    ELSE
                        _PUTIMAGE (273, 64), TLocn ', ship_box(x%) 'target impossible
                    END IF
                END IF '                                        end targeting test
            END IF '                                            end obscuration tests
        END IF '                                                end vpoint test
        '---------------------------------------------status notes------------------------------- line 6  (x%,80)
        IF (NOT far) AND (NOT occ) THEN
            SELECT CASE cmb(x%).status
                CASE IS = 0
                    _PRINTSTRING (0, 80), "Crashed on " + hvns(cmb(x%).bogey).nam ', ship_box(x%)
                CASE IS = 1 '                                   in flight targeting/targeted by
                    IF vpt THEN
                        tl = 0: c = 0 '                         "targeted by x%... "
                        COLOR clr&(12)
                        FOR o = 1 TO units
                            IF NOT Sensor(o, vpoint) AND 2 THEN _CONTINUE
                            IF tl THEN
                                c = c + LEN(_TRIM$(STR$(cmb(o).id))) + 16
                                tb$ = _TRIM$(STR$(cmb(o).id)) + ", "
                                _PRINTSTRING (104 + c, 80), tb$ ', ship_box(x%)
                            ELSE
                                _PRINTSTRING (3, 80), "Targeted by:" ', ship_box(x%)
                                tl = -1
                                c = c + LEN(_TRIM$(STR$(cmb(o).id)))
                                tb$ = _TRIM$(STR$(cmb(o).id)) + ", "
                                _PRINTSTRING (104 + c, 80), tb$ ', ship_box(x%)
                            END IF
                        NEXT o
                    ELSE
                        IF Sensor(x%, vpoint) AND 2 THEN tg% = 1 ELSE tg% = 0 'x% targeting active
                        IF Sensor(vpoint, x%) AND 2 THEN td% = 2 ELSE td% = 0 'active targeting x%
                        targ% = tg% + td%
                        SELECT CASE targ%
                            CASE IS = 1
                                COLOR clr&(12)
                                _PRINTSTRING (0, 80), "Targeting active" 'x% targeting active
                            CASE IS = 2
                                COLOR clr&(12)
                                _PRINTSTRING (0, 80), ">>Target Locked<<" 'x% targeted by active
                            CASE IS = 3
                                COLOR clr&(12)
                                _PRINTSTRING (0, 80), ">>Target mutual<<" 'simultaneous x%/active targeting
                        END SELECT
                    END IF
                CASE IS = 2
                    _PRINTSTRING (0, 80), "landed on " + hvns(cmb(x%).bogey).nam ', ship_box(x%)
                CASE IS = 3
                    _PRINTSTRING (0, 80), "Disabled"
            END SELECT
        END IF
        LINE (0, 0)-(289, 95), clr&(4), B '                     bounding box & we're done
        _FONT 16
    NEXT x%

    'PLACE SHIP_BOX DATA DISPLAY IMAGES:                        6 display slots available
    lim% = 6 - (units - 6) * (units < 7) '                      limit to 6 or 'units' whichever is lower
    shipoff = -shipoff * (units > 6) '                          shipoff (if any) applied only if more than 6 units else 0
    FOR y% = 1 TO lim%
        _PUTIMAGE (0, 96 * (y% - 1)), ship_box(y% + shipoff), A& ' display ship info- adding any offset if more than 6 units
    NEXT y%
    _DEST A&
    COLOR clr&(15)
    EXIT SUB

    fleet_icons: '                                              Fleet icon gosub for both active & inactive units
    _PRINTSTRING (234, 64), STR$(cmb(x%).bogey)
    _PUTIMAGE (252, 64), slave, ship_box(x%)
    RETURN

END SUB 'Ship_Display


'±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
FUNCTION Slope! (var1 AS V3, var2 AS V3)

    'returns radian declination of var1 point relative to var2
    'called from: various
    D&& = _HYPOT(var1.pX - var2.pX, var1.pY - var2.pY) '          distance on X,Y plane
    Slope! = _ATAN2(var1.pZ - var2.pZ, D&&)

END FUNCTION 'Slope!


'±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
FUNCTION Surface_Gs! (dens AS SINGLE, radius AS _INTEGER64)

    Surface_Gs! = ((dens * ((4 / 3) * _PI * (radius * radius * radius))) / 26687)

END FUNCTION 'Surface_Gs!


'±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
SUB Sys_Get (src AS _BYTE, sysname AS STRING, row AS INTEGER, col AS INTEGER)

    'Get system data
    'called from: Gate_Keeper, Load_System
    ff& = FREEFILE
    OPEN sysname FOR BINARY AS ff&
    orbs = LOF(1) / LEN(hvns(0))
    REDIM hvns(orbs) AS body
    IF src THEN '                                               -1 = Load_System, 0 = Gate_Keeper
        Turncount = 0: Turn_2_Clock Turncount
    END IF
    FOR x% = 1 TO orbs '                                        Load data array
        GET ff&, , hvns(x%)
    NEXT x%
    CLOSE ff&
    'put a dialog box here if using pipecom
    LOCATE row, col: INPUT "Input year: ", yr '                 get date for ephemeris info
    LOCATE row + 1, col: INPUT "Input day (0-365): ", dy
    IF dy = 0 THEN oryr = yr ELSE oryr = yr + (dy / 365)

END SUB 'Sys_Get


'±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
SUB System_Map (g AS SINGLE)

    'displays the star system
    'called from: Sensor_Screen

    'Results of Frame_Sect% calls
    '0 = feature is beyond display zoom- don't draw it
    '1 = features radius encompasses entire display zoom- fill screen circumscription
    '2 = feature is fully encompassed by display zoom- draw the entire feature
    '3 = portion of feature intersects display zoom- draw entire feature, or portion if feasible

    DIM OTC AS V3 '                                             locates foci of orbit tracks & belt/ring systems

    FOR p% = 1 TO orbs '                                        Iterate through all system bodies

        'BARYCENTERS OF ORBIT TRACKS
        IF hvns(p%).rank > 1 THEN '                             find orbit track center
            OTC = rcp(Find_Parent(p%))
        ELSE
            OTC = rcp(p%) '                                     system primary doesn't orbit
        END IF

        'MAIN SKIPPING ALGORITHM- don't draw any feature that is extremely remote
        IF hvns(p%).star = 2 THEN '                             process belt/ring differently because it has a hvns(p%).radi=0
            wid = -(hvns(p%).dens / 2) * (hvns(p%).dens > 0) - .15 * (hvns(p%).dens <= 0) 'calculate ring/belt width
            IF togs AND 2 THEN
                infrm% = Frame_Sect%(OTC, hvns(p%).orad - (hvns(p%).orad * wid), g / 10)
                outfrm% = Frame_Sect%(OTC, hvns(p%).orad + (hvns(p%).orad * wid), g / 10)
            ELSE
                infrm% = Frame_Sect%(OTC, hvns(p%).orad - (hvns(p%).orad * wid), g)
                outfrm% = Frame_Sect%(OTC, hvns(p%).orad + (hvns(p%).orad * wid), g)
            END IF
            IF infrm% = 1 OR outfrm% = 0 THEN _CONTINUE '       None of the ring/belt is in frame so skip to next feature
        ELSE '                                                  feature is a star/planetary body
            IF togs AND 2 THEN
                mfrm% = Frame_Sect%(rcp(p%), hvns(p%).radi * 1000, g)
                ofrm% = Frame_Sect%(OTC, hvns(p%).orad, g)
            ELSE
                mfrm% = Frame_Sect%(rcp(p%), hvns(p%).radi, g)
                ofrm% = Frame_Sect%(OTC, hvns(p%).orad, g)
            END IF
            IF mfrm% = 0 AND ofrm% < 2 THEN _CONTINUE '         neither sphere, nor it's orbit track is in frame, so skip to next
        END IF
        '                                                       IF WE'VE MADE IT TO HERE THEN WE'RE GOING TO DRAW SOME ASPECT OF p%
        'ON JUMP TOGGLE TRUE, display jump spheres- rejecting those out of frame
        IF (togs AND 64) AND hvns(p%).star <> 2 THEN '          jump zones toggled & not asteroid belt
            IF togs AND 512 THEN l! = hvns(p%).dens ELSE l! = 1 'density or diameter jump zone
            '100 diameters/densities
            IF hvns(p%).radi * 400 * l! * g > 25 THEN '         only draw if > 25 pixels
                IF Frame_Sect%(rcp(p%), hvns(p%).radi * 200 * l!, g) > 1 THEN
                    FCirc (dcp(p%).pX) * g, (dcp(p%).pY) * g, (hvns(p%).radi * 200 * l!) * g, _RGBA(150, 116, 116, 10)
                END IF
            END IF '                                            end: > 25 pixel test
            '10 diameters/densities
            IF hvns(p%).radi * 40 * l! * g > 25 THEN '          only draw if > 25 pixels
                IF Frame_Sect%(rcp(p%), hvns(p%).radi * 20 * l!, g) > 1 THEN
                    FCirc (dcp(p%).pX) * g, (dcp(p%).pY) * g, (hvns(p%).radi * 20 * l!) * g, _RGBA(200, 116, 116, 5)
                END IF
            END IF '                                            end: > 25 pixel test
        END IF

        'CORONAS AND COLORS
        IF hvns(p%).star = -1 THEN '                            if a star then build star corona
            'DETERMINE ANY STELLAR CLASS/SIZE CONSTANTS HERE- use them in place of 50000
            '
            IF Frame_Sect%(rcp(p%), hvns(p%).radi + (30 * 50000), g) > 0 THEN 'if no corona band in frame then skip drawing
                FOR x = 1 TO 30 '                               draw corona bands
                    IF Frame_Sect%(rcp(p%), hvns(p%).radi + (x * 50000), g) > 0 THEN
                        FCirc (dcp(p%).pX) * g, (dcp(p%).pY) * g, (hvns(p%).radi + (x * 50000)) * g, _RGBA32(127, 127, 227, 30 - x)
                    END IF
                NEXT x
            END IF
            SELECT CASE MID$(hvns(p%).class, 1, 1) '            source: http://www.vendian.org/mncharity/dir3/starcolor/
                CASE IS = "A": c& = &HFFCAD7FF '                202 215 255  #cad7ff
                CASE IS = "B": c& = &HFFAABFFF '                170 191 255  #aabfff
                CASE IS = "F": c& = &HFFF8F7FF '                248 247 255  #f8f7ff
                CASE IS = "G": c& = &HFFFFF4EA '                255 244 234  #fff4ea
                CASE IS = "K": c& = &HFFFFD2A1 '                255 210 161  #ffd2a1
                CASE IS = "M": c& = &HFFFFCC6F '                255 204 111  #ffcc6f
                CASE IS = "O": c& = &HFF9BB0FF '                155 176 255  #9bb0ff  Spectral class colors
            END SELECT '                                        old star color c& = &HFFFC5454
        ELSE
            IF hvns(p%).class = "GG" THEN '                     planet color
                c& = &HFF545454 '                               gas giant
            ELSE
                c& = &HFF347474 '                               rocky/icy body
            END IF
        END IF

        IF hvns(p%).star < 2 THEN '******************************BODY IS A MASSIVE PLANETARY FEATURE, NOT A RING
            IF togs AND 128 THEN '                              if orbit toggle is true then display orbit tracks
                IF _SHL(hvns(p%).orad, 1) * g > 50 THEN '       if large enough to see on screen
                    IF togs AND 2 THEN '                        if Z-pan toggle is true
                        frm = Frame_Sect%(OTC, hvns(p%).orad, g / 10) 'exclude insystem OTs
                        IF frm > 1 THEN
                            Vec_Rota OTC
                            CIRCLE (OTC.pX * g, OTC.pY * g), hvns(p%).orad * g, _RGBA32(111, 72, 233, 70), , , COS(zangle)
                        END IF
                    ELSE
                        IF Frame_Sect%(OTC, hvns(p%).orad, g) = 3 THEN 'if track intersects viewport frame
                            IF hvns(p%).orad > (1415 / g) * 2000 THEN 'if orad is 2000x visual screen then draw line instead of circle
                                DIM drct AS V3 '                direction vector
                                DIM PT AS V3 '                  Point Tangent
                                Vec_Cross drct, OTC, khat '     get orthogonal of vertical and orbit track radius
                                d2a## = PyT(2, OTC, origin) '   distance from orbit track center to active unit
                                PT = OTC: Vec_Mult PT, -1 * (hvns(p%).orad / d2a##): Vec_Add PT, OTC, 1 'find tangent point on orbit track
                                Vec_Mult PT, g
                                Vec_Mult drct, g
                                'dashed orbit track indicates not a true curve
                                LINE (PT.pX, PT.pY)-(PT.pX + drct.pX, PT.pY + drct.pY), _RGBA32(111, 72, 233, 70), , &B0000000011111111
                                LINE (PT.pX, PT.pY)-(PT.pX + drct.pX * -1, PT.pY + drct.pY * -1), _RGBA32(111, 72, 233, 70), , &B1111111100000000
                            ELSE
                                CIRCLE (OTC.pX * g, OTC.pY * g), hvns(p%).orad * g, _RGBA32(111, 72, 233, 70)
                            END IF '                            end: tight angle line/wide angle circle
                        END IF '                                end: out of frame test
                    END IF '                                    end: Z-pan test
                END IF '                                        end: size test
            END IF '                                            end: orbit toggle test

            'display gravity zones
            IF togs AND 256 THEN '                              if grav zone toggle is true
                IF hvns(p%).star <> 2 THEN '                    and not a belt/ring system
                    grv! = 0
                    dsx## = Surface_Gs(hvns(p%).dens, hvns(p%).radi)
                    IF dsx## > .25 THEN '                           if 1/4G zones present over world
                        DO
                            grv! = grv! + .25 '                     zones drawn in 1/4G increments
                            IF grv! > cmb(vpoint).MaxG THEN '       indicate danger bands of active unit
                                esc& = _RGBA(0, 255, 0, 70) '       dense green = heavier Gs than active's Max G
                            ELSE
                                esc& = _RGBA(0, 255, 0, 25) '       light green = lighter Gs than active's Max G
                            END IF
                            ds## = (dsx## / grv!) ^ .5 '            set grav zone radius
                            IF ds## * g < 50 THEN _CONTINUE '       if too small to see then skip
                            IF Frame_Sect%(rcp(p%), ds##, g) = 3 THEN
                                CIRCLE (dcp(p%).pX * g, dcp(p%).pY * g), ds## * g, esc&
                            END IF
                        LOOP UNTIL ds## < hvns(p%).radi
                    END IF '                                    end: 1/4G zones present test
                END IF '                                        end: belt/ring test
            END IF '                                            end: grav zone toggled test

            'display star/planet body, rejecting those that are out of frame
            IF Frame_Sect%(dcp(p%), hvns(p%).radi, g) > 0 THEN 'is the feature within the frame
                IF _SHL(hvns(p%).radi, 1) * g > 2 THEN '        if large enough to see
                    frm = Frame_Sect%(dcp(p%), hvns(p%).radi, g)
                    IF frm = 1 THEN '                           planetary body fills screen
                        FCirc 0, 0, 1415, c& '                  fill screen only
                    ELSE
                        FCirc dcp(p%).pX * g, dcp(p%).pY * g, hvns(p%).radi * g, c& 'display planet orb
                        CIRCLE (dcp(p%).pX * g, dcp(p%).pY * g), hvns(p%).radi * g, c& 'and outline it
                    END IF
                ELSE '                                          if not, draw placekeeping point
                    PSET (dcp(p%).pX * g, dcp(p%).pY * g), c&
                END IF '                                        end: size test

                'display name if there's room
                dsp&& = PyT(2, dcp(Find_Parent(p%)), dcp(p%)) * g 'display distance to parent planet
                dss&& = PyT(2, dcp(p%), origin) * g '           display distance to active unit
                IF (dsp&& > 100 AND dss&& > 50) OR hvns(p%).rank = 1 THEN GOSUB print_name 'print name if not too close on screen
            END IF '                                            end planet out of frame reject

        ELSE '**************************************************BODY IS A BELT/RING SYSTEM
            IF togs AND 1024 THEN '                             If belt/ring toggle on
                IF ABS(zangle) <> _PI / 2 THEN '                view point is not on ecliptic plane
                    IF _SHL(hvns(p%).orad, 1) * g < 100 THEN _CONTINUE 'skip if belt/ring too small to see
                    wid = -(hvns(p%).dens / 2) * (hvns(p%).dens > 0) + -.15 * (hvns(p%).dens <= 0)
                    outbnd&& = hvns(p%).orad + hvns(p%).orad * wid 'outer limit of planetoid/ring belt wid% orbital radius
                    SELECT CASE Frame_Sect%(OTC, outbnd&&, g / 10)
                        CASE IS = 0 '                           skip draw as no part of feature is in display
                            EXIT SELECT
                        CASE IS = 1 '                           Outer boundary is beyond display limits
                            inbnd&& = hvns(p%).orad - hvns(p%).orad * wid 'inner limit of planetoid/ring belt wid% orbital radius
                            frmin = Frame_Sect%(OTC, inbnd&&, g)
                            IF frmin = 0 THEN '                 Display limits are beyond inner boundary
                                FCirc 0, 0, 1415, &H127F7F7F
                                IF ft16& > 0 THEN
                                    COLOR &H5F7F7F7F
                                    _PRINTSTRING (_SHR(_WIDTH(SS&), 1) - _SHR(_PRINTWIDTH(_TRIM$(hvns(p%).nam)), 1), _HEIGHT(SS&) / 3), "Within " + _TRIM$(hvns(p%).nam)
                                END IF
                            ELSEIF frmin >= 2 THEN Draw_Ring_Belt OTC, outbnd&& - inbnd&&, inbnd&&, g
                            END IF
                        CASE IS = 2 '                           outer limit is fully in display
                            inbnd&& = hvns(p%).orad - hvns(p%).orad * wid 'inner limit of planetoid/ring belt wid% orbital radius
                            IF Frame_Sect%(OTC, inbnd&&, g) = 2 THEN Draw_Ring_Belt OTC, outbnd&& - inbnd&&, inbnd&&, g
                        CASE IS = 3 '                           outer limit intersects display
                            inbnd&& = hvns(p%).orad - hvns(p%).orad * wid 'inner limit of planetoid/ring belt wid% orbital radius
                            IF Frame_Sect%(OTC, inbnd&&, g) <> 1 THEN Draw_Ring_Belt OTC, outbnd&& - inbnd&&, inbnd&&, g
                    END SELECT
                END IF '                                        end view parallel to ecliptic test
            END IF '                                            end belt/ring toggle
        END IF '                                                end planetary or belt display
    NEXT p%
    EXIT SUB '                                                  iterations done, leave before gosub block

    print_name:
    fl$ = ""
    IF zangle < 0 THEN
        fl = -1
        FOR n = LEN(_TRIM$(hvns(p%).nam)) TO 1 STEP -1
            fl$ = fl$ + MID$(hvns(p%).nam, n, 1)
        NEXT n
    ELSE
        fl = 1
        fl$ = hvns(p%).nam
    END IF
    sz! = 3.6 - hvns(p%).rank / 4
    IF ft16& > 0 AND ft14& > 0 AND ft12& > 0 THEN
        SELECT CASE hvns(p%).rank
            CASE IS = 1: _FONT ft16&
            CASE IS = 2: _FONT ft14&
            CASE IS >= 3: _FONT ft12&
        END SELECT
        COLOR _RGBA32(200, 67, 55, 170)
        pnx% = map!(dcp(p%).pX * g, -1000, 1000, 0, 620) + (hvns(p%).radi * g * .3)
        pny% = map!(dcp(p%).pY * g, 1000, -1000, 0, 620) + (hvns(p%).radi * g * .3)
        nr$ = _TRIM$(hvns(p%).nam)
        IF togs AND 16384 THEN nr$ = nr$ + " (" + _TRIM$(STR$(hvns(p%).rank)) + ")" 'If show rank set
        _PRINTMODE _KEEPBACKGROUND
        _PRINTSTRING (pnx%, pny%), nr$
        IF zangle < 0 THEN
            ul$ = "___"
            _PRINTSTRING (pnx%, pny% - 16), ul$
        END IF
        _FONT 16
    ELSE
        Prnt fl$, sz! * fl, sz! * fl, (dcp(p%).pX * g) + (hvns(p%).radi * g * .7), (dcp(p%).pY * g) - (hvns(p%).radi * g * .7),_
         28, 0,_RGBA32(255 - (hvns(p%).rank - 1) * 50, 67, 55, 170)
    END IF
    RETURN

END SUB 'System_Map


'±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
SUB Terminus

    'Free all images on exit
    FOR x% = 0 TO 255: _FREEIMAGE chr_img(x%): NEXT x%
    FOR x% = 1 TO units: _FREEIMAGE ship_box(x%): NEXT x%
    _FREEIMAGE SS&: _FREEIMAGE AW&: _FREEIMAGE ZS&: _FREEIMAGE ORI&
    _FREEIMAGE flight&: _FREEIMAGE evade&: _FREEIMAGE intercept&
    _FREEIMAGE cancel&: _FREEIMAGE XZ&: _FREEIMAGE IZ&
    _FREEIMAGE OZ&: _FREEIMAGE RG&: _FREEIMAGE OB&: _FREEIMAGE GD&
    _FREEIMAGE AZ&: _FREEIMAGE IN&: _FREEIMAGE JP&: _FREEIMAGE DI&
    _FREEIMAGE DN&: _FREEIMAGE QT&: _FREEIMAGE ShpT: _FREEIMAGE ShpO
    _FREEIMAGE TLoc: _FREEIMAGE TLocn: _FREEIMAGE TunLoc
    _FREEIMAGE flag: _FREEIMAGE slave: _FREEIMAGE trnon: _FREEIMAGE trnoff
    _FREEIMAGE ship_hlpA: _FREEIMAGE ship_hlpB
    IF fa12& > 0 THEN _FREEFONT (fa12&)
    IF fa10& > 0 THEN _FREEFONT (fa10&)
    IF fa32& > 0 THEN _FREEFONT (fa32&)
    IF fa14& > 0 THEN _FREEFONT (fa14&)
    IF ft16& > 0 THEN _FREEFONT (ft16&)
    IF ft14& > 0 THEN _FREEFONT (ft14&)
    IF ft12& > 0 THEN _FREEFONT (ft12&):

END SUB 'Terminus


'±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
SUB Text_Bubble (xpos AS INTEGER, ypos AS INTEGER, remark AS STRING)

    'displays context help text bubbles at most program controls on right mouse click & hold
    'called from Mouse_Button_Right
    OPEN "context.txt" FOR INPUT AS #1
    DO
        LINE INPUT #1, s$
        IF EOF(1) THEN n% = -1
        IF s$ = remark THEN '                                   reached the correct help block
            lines% = 0
            DO
                REDIM _PRESERVE b(lines% + 1) AS STRING
                LINE INPUT #1, t$ '                             get a help line
                IF t$ <> "<0>" THEN '                           if not end of block
                    b(lines%) = t$ '                            assign
                    IF LEN(b(lines%)) * 8 > lng% THEN lng% = LEN(b(lines%)) * 8 'pick longest line
                    lines% = lines% + 1 '                       increment lines
                ELSE
                    n% = -1
                END IF
            LOOP UNTIL n%
        END IF
    LOOP UNTIL n%
    CLOSE #1

    T& = _NEWIMAGE(lng% + 4, lines% * 16 + 4, 32)
    _DEST T&
    CLS
    FOR y% = 0 TO 1 '                                            draw bounding box
        c~& = -Black * (y% < 1) - White * (y% > 0)
        LINE (0 + y%, 0 + y%)-(_WIDTH(T&) - 1 - y%, _HEIGHT(T&) - 1 - y%), c~&, B
    NEXT y%
    FOR y% = 0 TO lines% - 1
        IF b(lines% - 1) = "" THEN _CONTINUE
        _PRINTSTRING (2, 16 * y% + 2), b(y%)
    NEXT y%
    xp% = xpos + ((xpos + lng% + 4) - _WIDTH(A&) + 5) * (xpos + lng% + 4 >= _WIDTH(A&) - 1)
    yp% = ypos - ((lines% + 1) * 16 + 4)
    IF yp% < 0 THEN yp% = 0
    _PUTIMAGE (xp%, yp%), T&, A&
    _DEST A&
    _FREEIMAGE T&
    _DISPLAY
    Press_Click

END SUB 'Text_Bubble


'±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
SUB Trunc_Coord (var AS _INTEGER64)

    'called from: Ship_Display
    IF ABS(var) >= 100000000 THEN '                             convert long coordinates
        'x$ = STR$(INT(var / 1000000)) + "M" '                   to abbreviated versions
        x$ = STR$(var \ 1000000) + "M" '                   to abbreviated versions
    ELSEIF ABS(var) >= 100000000000 THEN
        'x$ = STR$(INT(var / 1000000000)) + "G"
        x$ = STR$(var \ 1000000000) + "G"
    ELSE
        x$ = STR$(var)
    END IF
    PRINT x$;

END SUB 'Trunc_Coord


'±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
SUB Turn_2_Clock (var AS INTEGER)

    'called from: Load_Scenario, Move_Turn, M_Turn_Undo
    s = var * 1000 '                                            convert turns to seconds
    'etd = INT(s / 86400) '                                      elapsed time days
    etd = s \ 86400 '                                      elapsed time days
    'eth = INT((s - etd * 86400) / 3600) '                       elapsed time hours
    eth = (s - etd * 86400) \ 3600 '                       elapsed time hours
    'etm = INT((s - (etd * 86400 + eth * 3600)) / 60) '          elapsed time minutes
    etm = (s - (etd * 86400 + eth * 3600)) \ 60 '          elapsed time minutes
    ets = s - (etd * 86400 + eth * 3600 + etm * 60) '           elapsed time seconds

END SUB 'Turn_2_Clock


'±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
SUB Turn_Reset

    Clear_MB 1
    Dialog_Box "Reset Turn Counter?", 300, 150, 50, &HFFFF0000, &HFFFFFFFF
    Con_Blok 500, 125, 100, 32, "Yes [enter]", 0, &HFFC80000 ' clr&(4)
    Con_Blok 640, 125, 100, 32, "No [Esc]", 0, &HFFC80000 ' clr&(4)

    DO
        k$ = INKEY$
        ms = MBS
        IF k$ <> "" THEN
            IF k$ = CHR$(27) THEN in = -1
            IF k$ = CHR$(13) THEN rs% = -1: in = -1
        END IF
        IF ms AND 1 THEN
            IF _MOUSEY > 124 AND _MOUSEY < 158 THEN
                SELECT CASE _MOUSEX
                    CASE 500 TO 599: rs% = -1: in = -1
                    CASE 640 TO 739: in = -1
                END SELECT
            END IF
            Clear_MB 1
        END IF
        IF rs% THEN Turncount = 0: Turn_2_Clock Turncount
        _LIMIT 30
        _DISPLAY
    LOOP UNTIL in

END SUB 'Turn_Reset


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
    'Right hand rule: var=thumb, var2=index, var3=middle
    'var is returned as perpendicular plane defining vector
    'flip order of var2 & var3 to flip var direction
    var.pX = var2.pY * var3.pZ - var2.pZ * var3.pY
    var.pY = -(var2.pX * var3.pZ - var2.pZ * var3.pX)
    var.pZ = var2.pX * var3.pY - var2.pY * var3.pX

END SUB 'Vec_Cross


'±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
SUB Vec_Cross_Unit (var AS V3U, var2 AS V3U, var3 AS V3U)

    'Obtain cross product vector of unit vectors var2 and var3
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

    'rotate a location vector around X axis
    y&& = var.pY: z&& = var.pZ
    var.pY = y&& * COS(zangle) + z&& * SIN(zangle)
    var.pZ = y&& * -SIN(zangle) + z&& * COS(zangle)

END SUB 'Vec_Rota


'±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
SUB Vec_2_Thrust (var AS Maneuver, var2 AS V3, lim AS SINGLE)

    'Change an input vector to a polar maneuver
    var.Gs = PyT(3, origin, var2) / 5000
    IF var.Gs > lim AND lim <> 0 THEN var.Gs = lim
    var.Azi = Azimuth!(var2.pX, var2.pY)
    var.Inc = Slope!(var2, origin)

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
    IF cmb(vpoint).bstat = 5 OR cmb(vpoint).status = 3 OR cmb(vpoint).status = 2 THEN
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

    'Draw Z-pan label
    'called from: Screen_Limits
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


'$INCLUDE:'\include\getopen.bas'
