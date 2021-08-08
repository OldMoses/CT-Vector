$COLOR:32
'ÉÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ»
'º                     System Input (CT Vector utility)                       º
'ÌÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹
'º Star system creator/editor for CT Vector                                   º
'º sysinput040.bas (version 0.4.0)                                            º
'º                                                                            º
'º user must have v.1.4 or later to compile                                   º
'º                                                                            º
'º Made possible with guidance and code contributions by Bplus, Petr,         º
'º SMcNeill, SierraKen, FellippeHeitor and many others at QB64.org forum.     º
'º Thank you.                                                                 º
'º                                                                            º
'º                                                                            º
'º                                                                            º
'º                                                                            º
'ÈÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼

'TYPE DEFINITIONS
TYPE V3 '                                                       relative unit placement
    pX AS _INTEGER64 '                                          X coordinate / mem 0-7
    pY AS _INTEGER64 '                                          Y coordinate / mem 8-15
    pZ AS _INTEGER64 '                                          Z coordinate / mem 16-23
END TYPE

TYPE body '                                                     Celestial bodies
    nam AS STRING * 20 '                                        Name / mem 0-19
    parnt AS STRING * 20 '                                      name of parent body / mem 20-39
    radi AS _INTEGER64 '                                        Size (needs INTEGER64 in event of large star) / mem 40-47
    orad AS _INTEGER64 '                                        Orbital radius / mem 48-55
    oprd AS SINGLE '                                            Orbital period (years) / mem 56-59
    rota AS SINGLE '                                            Rotational period / mem 60-63
    dens AS SINGLE '                                            Density, basis for grav(Gs) calculation / mem 64-67
    rank AS _BYTE '                                             1=primary, 2=planet/companion, 3=satelite / mem 68
    star AS _BYTE '                                             -1=star  0=non-stellar body 2=planetoid belt / mem 69
    class AS STRING * 2 '                                       Two digit code, use for stellar class, GG, etc. / mem 70-71
    siz AS STRING * 3 '                                         three digit code, use for stellar size, / mem 72-74
    ps AS V3 '                                                  coordinate position / mem 75-98
END TYPE

TYPE sort '                                                     Display sortation variable
    index AS INTEGER
    value AS _INTEGER64
END TYPE

'                                                               VARIABLE DECLARATIONS
REDIM SHARED hvns(0) AS body
REDIM SHARED dcp(0) AS V3
DIM SHARED Rseed(1000000) AS _FLOAT
DIM SHARED orbit2(20) AS _INTEGER64
DIM SHARED pov AS V3
DIM SHARED sys_in AS INTEGER
DIM SHARED rank AS INTEGER
DIM SHARED file_name AS STRING * 100
DIM SHARED count AS INTEGER
DIM SHARED scrw AS INTEGER
DIM SHARED scrh AS INTEGER
DIM SHARED rows AS _BYTE
DIM SHARED drows AS _BYTE
DIM SHARED offset AS INTEGER
DIM SHARED offmax AS INTEGER
DIM SHARED insert AS INTEGER
DIM SHARED mouse_y AS INTEGER
DIM SHARED mouse_x AS INTEGER
DIM SHARED ZoomFac AS SINGLE
DIM SHARED rankmax AS _BYTE
DIM SHARED togs AS INTEGER '                                    Mode Toggles
'                                                               0 bit = edit mode
'                                                               1 bit = map mode
'                                                               2 bit = map left:0 / right:1
DIM SHARED maptogs AS _UNSIGNED INTEGER
DIM SHARED A&
DIM SHARED SS&

DIM SHARED f& '                                                 font handles
DIM SHARED fc&
DIM SHARED ff&
DIM SHARED fp1&
DIM SHARED fp2&
DIM SHARED fp3&

f& = _LOADFONT("images\arialbd.ttf", 12, "monospace")
fc& = _LOADFONT("images\arialbd.ttf", 10)
ff& = _LOADFONT("images\arialbd.ttf", 32)
fp1& = _LOADFONT("images\timesbd.ttf", 16) '           planetary fonts
fp2& = _LOADFONT("images\timesbd.ttf", 14)
fp3& = _LOADFONT("images\timesbd.ttf", 12)

'CONSTANTS
CONST AUtokm = 149668990
CONST Solrad = 695700

'SCREEN AND STATE SETUP
RESTORE Orbits
FOR x = 0 TO 19
    READ au
    orbit2(x) = au * AUtokm
NEXT x
maptogs = &B0011010110001101
scrw = _DESKTOPWIDTH: scrh = _DESKTOPHEIGHT - 80
rows = INT(scrh / 16): drows = rows - 4
A& = _NEWIMAGE(scrw, scrh, 32)
SS& = _NEWIMAGE(620, 620, 32)
SCREEN A&
DO: LOOP UNTIL _SCREENEXISTS
_TITLE "System Input 0.4.0"
_SCREENMOVE 0, 0
rank = 1
count = 0
insert = 1
ZoomFac = 1
pov.pX = 0: pov.pY = 0: pov.pZ = 0
MainLoop '                                                      Enter main loop
_FREEIMAGE SS&
SYSTEM

'DATA
Orbits:
'Orbit radii in AU
DATA 0.2,0.4,0.7,1,1.6,2.8,5.2,10,19.6,38.8,77.2
DATA 154,307.6,614.8,1229.2,2458,4915.6,9830.8,19661.2,39322

'END MAIN MODULE
'BEGIN SUBROUTINES


'²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²
SUB Add_Edit (v AS INTEGER, rank AS INTEGER)

    'Add new bodies or edit existing ones
    lf = 50: xset = 400
    _AUTODISPLAY
    '--------------------------------------------------------------Parent
    IF togs AND 1 THEN
        'move to new parent here?
        'if so...
        'need to determine relative orbital position from old parent
        'check existing satellites of new parent, and process accordingly
        DialogBox "Edit " + hvns(v).nam, 700, 350, lf, &HFF00FF00, &HFFFFFFFF, "c"
    ELSE
        IF v > UBOUND(hvns) THEN
            REDIM _PRESERVE hvns(v) AS body
        END IF
        hvns(v).rank = rank
        IF rank > rankmax THEN rankmax = rank
        SELECT CASE rank '                                      determine body's parent
            CASE 1 '                                            rank 1 has no parent
                hvns(v).parnt = ""
            CASE 2 '                                            rank 2 parent is always rank 1
                hvns(v).parnt = hvns(1).nam
            CASE ELSE
                'pick parent body here
                DO
                    p = ChooseWorld%("Choose Parent", rank - 1)
                LOOP UNTIL hvns(p).star <> 2 'redo until choice is not a belt
                hvns(v).parnt = hvns(p).nam
        END SELECT
        DialogBox "Enter planet details", 700, 350, lf, &HFF00FF00, &HFFFFFFFF, "c"
    END IF
    '--------------------------------------------------------------Name
    backimg& = _COPYIMAGE(0): lf = lf + 64
    NameIn v
    _PUTIMAGE , backimg&: _FREEIMAGE backimg&
    _PRINTSTRING (xset, lf), "Name: " + _TRIM$(hvns(v).nam)
    '--------------------------------------------------------------Type
    backimg& = _COPYIMAGE(0): lf = lf + 16
    TypeIn v
    _PUTIMAGE , backimg&: _FREEIMAGE backimg&
    SELECT CASE hvns(v).star
        CASE IS = -1: t$ = "Star " + hvns(v).class + " " + hvns(v).siz
        CASE IS = 0
            SELECT CASE _TRIM$(hvns(v).class)
                CASE IS = "": t$ = "Rocky/Icy world"
                CASE IS = "GG": t$ = "Gas Giant"
            END SELECT
        CASE IS = 2: t$ = "Belt/Ring system": hvns(v).radi = 0
    END SELECT
    _PRINTSTRING (xset, lf), t$
    '--------------------------------------------------------------Radius
    IF hvns(v).star <> 2 THEN
        backimg& = _COPYIMAGE(0): lf = lf + 16
        RadIn v
        _PUTIMAGE , backimg&: _FREEIMAGE backimg&
        _PRINTSTRING (xset, lf), "Radius= " + _TRIM$(STR$(hvns(v).radi))
    ELSE
        hvns(v).radi = 0
    END IF
    '--------------------------------------------------------------Orbit radius
    IF hvns(v).rank > 1 THEN
        backimg& = _COPYIMAGE(0): lf = lf + 16
        OradIn v
        _PUTIMAGE , backimg&: _FREEIMAGE backimg&
        _PRINTSTRING (xset, lf), "Mean orbit radius= " + _TRIM$(STR$(hvns(v).orad))
    ELSE
        hvns(v).orad = 0
    END IF
    '--------------------------------------------------------------Zero Year Ephemeris
    IF hvns(v).star <> 2 AND hvns(v).rank > 1 THEN
        backimg& = _COPYIMAGE(0): lf = lf + 16
        ZeroYearIn v
        _PUTIMAGE , backimg&: _FREEIMAGE backimg&
        _PRINTSTRING (xset, lf), "Azimuth: " + STR$(_R2D(Azimuth!(hvns(v).ps.pX, hvns(v).ps.pY)))
    END IF
    '--------------------------------------------------------------Density
    backimg& = _COPYIMAGE(0): lf = lf + 16
    DensIn v
    _PUTIMAGE , backimg&: _FREEIMAGE backimg&
    IF hvns(v).star = 2 THEN '                                  belt/ring
        inner& = hvns(v).orad - (hvns(v).orad * hvns(v).dens)
        _PRINTSTRING (xset, lf), "inner limits= " + STR$(inner&) + " km" 'inner boundary
        lf = lf + 16
        outer& = hvns(v).orad + (hvns(v).orad * hvns(v).dens)
        _PRINTSTRING (xset, lf), "outer limits= " + STR$(outer&) + " km" 'outer boundary
    ELSE '                                                      planetary body
        _PRINTSTRING (xset, lf), "Mean density= " + _TRIM$(STR$(hvns(v).dens))
    END IF
    IF hvns(v).star <> 2 THEN
        '--------------------------------------------------------------Orbital period
        IF hvns(v).rank > 1 THEN '                              no orbital period for primaries or belts
            backimg& = _COPYIMAGE(0): lf = lf + 16
            OprdIn v
            _PUTIMAGE , backimg&: _FREEIMAGE backimg&
            _PRINTSTRING (xset, lf), "Orbital Period= " + _TRIM$(STR$(hvns(v).oprd)) + " years"
        END IF
        '--------------------------------------------------------------Rotational period
        backimg& = _COPYIMAGE(0): lf = lf + 16
        RotaIn v
        _PUTIMAGE , backimg&: _FREEIMAGE backimg&
        _PRINTSTRING (xset, lf), "Rotation Period= " + STR$(hvns(v).rota) + " days"
    END IF
    lf = lf + 48
    _PRINTSTRING (xset, lf), "Any key or mouse click to continue"
    DO
        x$ = INKEY$
        ms = MBS
        IF x$ <> "" THEN in = -1
        IF ms AND 1 THEN in = -1: Clear_MB 1
        IF ms AND 2 THEN in = -1: Clear_MB 2
        IF ms AND 4 THEN in = -1: Clear_MB 3
        _LIMIT 50
    LOOP UNTIL in
    IF togs AND 1 THEN togs = _RESETBIT(togs, 0) '              if edit mode then leave edit mode

END SUB 'Add_Edit


'²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²
SUB AzPos (p AS INTEGER, a AS SINGLE)

    'Azimuth position from parent
    hvns(p).ps.pX = hvns(FindParent(p)).ps.pX + hvns(p).orad * SIN(_D2R(a))
    hvns(p).ps.pY = hvns(FindParent(p)).ps.pY + hvns(p).orad * COS(_D2R(a))
    hvns(p).ps.pZ = 0

END SUB 'AzPos


'²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²
SUB RotaIn (var AS INTEGER)

    'enter or calculate planetary rotation
    yset = _WIDTH(0) / 16 - 28
    IF togs AND 1 THEN
        DialogBox "Edit Rotation Period (days)", 500, 200, 400, &HFF00FF00, &HFFFFFFFF, "c"
        LOCATE 31, yset
        PRINT "<enter> to default, 'T'= tidal locked, 'R'= random"
        LOCATE 30, yset
        PRINT "Rotational Period= "; hvns(var).rota; " change to ?";: INPUT x$
        IF x$ <> "" THEN
            IF UCASE$(_TRIM$(x$)) = "T" THEN
                hvns(var).rota = hvns(var).oprd * 365.25 '      tidal lock computation
            ELSEIF UCASE$(_TRIM$(x$)) = "R" THEN
                hvns(var).rota = Period_Rotation!(var) '        random rotation here
            ELSE
                hvns(var).rota = VAL(_TRIM$(x$)) '              accept entered value
            END IF
        END IF
    ELSE
        DialogBox "Enter Rotation Period", 500, 200, 400, &HFF00FF00, &HFFFFFFFF, "c"
        LOCATE 31, yset
        PRINT "'T'= tidal locked, <enter>= random"
        LOCATE 30, yset
        PRINT "Rotation period (days): ";: INPUT x$
        IF x$ <> "" THEN
            IF UCASE$(_TRIM$(x$)) = "T" THEN
                hvns(var).rota = hvns(var).oprd * 365.25 '      tidal lock computation
            ELSE
                hvns(var).rota = VAL(_TRIM$(x$)) '              accept entered value
            END IF
        ELSE
            hvns(var).rota = Period_Rotation!(var) '            random rotation here
        END IF
    END IF

END SUB 'RotaIn


'²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²
SUB OprdIn (var AS INTEGER)

    'enter or calculate orbital period of var
    yset = _WIDTH(0) / 16 - 28
    IF togs AND 1 THEN
        DialogBox "Edit Orbital Period", 500, 200, 400, &HFF00FF00, &HFFFFFFFF, "c"
        LOCATE 31, yset
        PRINT "<enter> to default, 'C' to calculate"
        LOCATE 30, yset
        PRINT "Orbital Period= "; hvns(var).oprd; " change to ";: INPUT x$
        IF _TRIM$(x$) = "" THEN EXIT SUB '                      no change
    ELSE
        DialogBox "Enter Orbital Period", 500, 200, 400, &HFF00FF00, &HFFFFFFFF, "c"
        LOCATE 31, yset
        PRINT "'C' or <enter> to calculate"
        LOCATE 30, yset
        PRINT "Orbital period (years): ";: INPUT x$
        IF _TRIM$(x$) = "" THEN x$ = "C"
    END IF
    IF UCASE$(x$) = "C" THEN
        hvns(var).oprd = Period_Orbit(var)
    ELSE
        hvns(var).oprd = VAL(_TRIM$(x$))
    END IF

END SUB 'OprdIn


'²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²
SUB ZeroYearIn (var AS INTEGER)

    yset = _WIDTH(0) / 16 - 28
    IF togs AND 1 THEN
        DIM AS V3 op, pp, datum
        op = hvns(var).ps
        pp = hvns(FindParent(var)).ps
        DialogBox "Edit Zero Year Azimuth", 500, 200, 400, &HFF00FF00, &HFFFFFFFF, "c"
        LOCATE 30, yset
        PRINT "Zero year azimuth= "; _R2D(Azimuth!(op.pX - pp.pX, op.pY - pp.pY)); " change to ?";: INPUT x$
        IF x$ <> "" THEN
            ang = VAL(x$)
            AzPos var, ang
        ELSE
            EXIT SUB
        END IF
        datum = hvns(var).ps: VecAdd datum, op, -1 '            datum now has movement of kids
        IF hvns(var).rank < rankmax THEN '                      if kids are potentially present
            x = 0
            DO
                x = x + 1
                IF x = var THEN _CONTINUE '                     var is already done
                p = ChildOf%(var, x) '                          is x a child of var? T/F
                IF NOT p THEN _CONTINUE '                       skip if not a child of var
                VecAdd hvns(x).ps, datum, 1 '                   move body who's ancester is var
            LOOP UNTIL x = UBOUND(hvns)
        END IF
    ELSE
        DialogBox "Enter Zero Year Azimuth", 500, 200, 400, &HFF00FF00, &HFFFFFFFF, "c"
        LOCATE 30, yset
        INPUT "Zero year azimuth (r = random): ", x$
        IF x$ <> "" THEN
            IF x$ = "r" OR x$ = "R" THEN '                      get a random result
                ang = DiceRoll%(1, 360, -1)
            ELSE
                ang = VAL(_TRIM$(x$))
            END IF
        ELSE
            ang = 0
        END IF
        AzPos var, ang
    END IF

END SUB 'ZeroYearIn


'²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²
SUB DensIn (var AS INTEGER)

    yset = _WIDTH(0) / 16 - 28
    IF hvns(var).star = 2 THEN '                                if a belt/ring system
        IF togs AND 1 THEN
            DialogBox "Edit Belt width" + STR$(hvns(var).dens * 100) + "% of orbit", 500, 200, 400, &HFF00FF00, &HFFFFFFFF, "c"
            LOCATE 30, yset
            PRINT "Ring/Belt width= "; hvns(var).dens * 100; "% change to ";: INPUT x$
            IF x$ <> "" THEN hvns(var).dens = VAL(_TRIM$(x$)) / 100
            'SELECT CASE x$
            '    CASE IS = ""
            '    case is = "D"
            'END SELECT
        ELSE
            DialogBox "Enter Belt width (default 15%)", 500, 200, 400, &HFF00FF00, &HFFFFFFFF, "c"
            LOCATE 30, yset
            INPUT "Belt/Ring width (% of orbit radius): ", wd$
            IF wd$ = "" THEN
                hvns(var).dens = .15
            ELSE
                hvns(var).dens = VAL(_TRIM$(wd$)) / 100
            END IF
        END IF
    ELSE '                                                      if a planetary object
        IF togs AND 1 THEN
            DialogBox "Edit Density (present=" + STR$(hvns(var).dens) + ")", 500, 200, 400, &HFF00FF00, &HFFFFFFFF, "c"
            LOCATE 30, yset
            PRINT "Density= "; hvns(var).dens; " change to ?";: INPUT x$
            IF x$ <> "" THEN hvns(var).dens = VAL(_TRIM$(x$))
        ELSE
            DialogBox "Enter Density", 500, 200, 400, &HFF00FF00, &HFFFFFFFF, "c"
            'treat stars with spectral classes differently from planets and GGs
            'if hvns(var).star=-1 then
            '   'star code here
            '   'enter a solar mass figure
            '   'calculate density relative to solar density
            '   'Sol radi=695700 density=.255
            'else
            LOCATE 30, yset
            INPUT "Density (Earth=1): ", hvns(var).dens
            'end if
        END IF
    END IF '

END SUB 'DensIn


'²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²
SUB OradIn (var AS INTEGER)

    try_again:
    yset = _WIDTH(0) / 16 - 28
    IF togs AND 1 THEN or$ = "Edit orbit radius (present=" + STR$(hvns(var).orad) + ")" ELSE or$ = "Enter Orbit Radius"
    DialogBox or$, 500, 200, 400, &HFF00FF00, &HFFFFFFFF, "c"
    IF within THEN
        LOCATE 31, yset
        PRINT "Previous Orbit radius is within parent sphere, try again."
    END IF

    IF togs AND 1 THEN '                                        Edit mode
        DIM datum AS V3 '                                       position offset
        DIM op AS V3 '                                          original position
        op = hvns(var).ps
        ang = Azimuth!(hvns(var).ps.pX - hvns(FindParent(var)).ps.pX, hvns(var).ps.pY - hvns(FindParent(var)).ps.pY)
        LOCATE 30, yset
        INPUT "Change(km / 'O'#) or <enter> to default: ", x$
        IF x$ = "" THEN
            EXIT SUB '                                          leave, there's no change
        ELSE
            GOSUB In_or_O
            AzPos var, ang '                                    new orbit radius necessitates new x,y,z position
            datum = hvns(var).ps: VecAdd datum, op, -1 '        datum is new.ps minus op
            IF hvns(var).rank < rankmax THEN '                  move the satellites of var
                x = 0
                DO
                    x = x + 1
                    IF x = var THEN _CONTINUE '                 var is already done
                    p = ChildOf%(var, x)
                    IF NOT p THEN _CONTINUE '                   skip if not a child of var
                    VecAdd hvns(x).ps, datum, 1 '               move body who's ancester is var
                LOOP UNTIL x = UBOUND(hvns)
            END IF
        END IF
    ELSE '                                                      Input mode
        LOCATE 30, yset
        INPUT "Orbit radius(km or 'O'#): ", x$
        GOSUB In_or_O
    END IF
    IF hvns(var).orad < hvns(FindParent(var)).radi THEN '       if within parent radius
        within = -1
        GOTO try_again
    END IF
    EXIT SUB

    In_or_O: '                                                  km or orbit # computation
    IF MID$(_TRIM$(x$), 1, 1) = "O" OR MID$(_TRIM$(x$), 1, 1) = "o" THEN
        IF hvns(FindParent(var)).star THEN
            hvns(var).orad = orbit2(VAL(MID$(x$, 2)))
        ELSE
            hvns(var).orad = VAL(MID$(x$, 2)) * hvns(FindParent(var)).radi * 2
        END IF
    ELSE
        hvns(var).orad = VAL(x$)
    END IF
    RETURN

END SUB 'OradIn


'²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²
SUB RadIn (var AS INTEGER)

    yset = _WIDTH(0) / 16 - 28
    IF togs AND 1 THEN rd$ = "Edit Radius (present=" + STR$(hvns(var).radi) + ")" ELSE rd$ = "Enter Radius"
    DialogBox rd$, 500, 200, 400, &HFF00FF00, &HFFFFFFFF, "c"
    IF togs AND 1 THEN
        LOCATE 30, yset
        INPUT "New radius(km) or <enter> to keep old: ", rd&&
        IF rd&& <> 0 THEN hvns(var).radi = rd&&
    ELSE
        LOCATE 30, yset
        'treat stars with spectral class differently
        'if hvns(var).star =-1 then
        '   'star spectral class code here
        'else
        INPUT "Radius(km): ", hvns(var).radi
        'end if
    END IF

END SUB 'RadIn


'²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²
SUB StellarIn (var AS INTEGER)

    '-----------------------------------------------------------Class letter
    DialogBox "Stellar Class", 500, 200, 400, &HFF00FF00, &HFFFFFFFF, "c"
    x = scrw / 2 - 175
    Con_Blok x, 540, 50, 50, "O", 1, &HFF9BB0FF
    Con_Blok x + 50, 540, 50, 50, "B", 1, &HFFCAD7FF
    Con_Blok x + 100, 540, 50, 50, "A", 1, &HFFAABFFF
    Con_Blok x + 150, 540, 50, 50, "F", 1, &HFFF8F7FF
    Con_Blok x + 200, 540, 50, 50, "G", 1, &HFFFFF4EA
    Con_Blok x + 250, 540, 50, 50, "K", 1, &HFFFFD2A1
    Con_Blok x + 300, 540, 50, 50, "M", 1, &HFFFFCC6F
    DO
        x$ = UCASE$(INKEY$)
        ms = MBS
        IF ms AND 1 THEN
            IF _MOUSEY > 540 AND _MOUSEY < 590 THEN
                SELECT CASE _MOUSEX
                    CASE x TO x + 49: x$ = "O": specindex = 0
                    CASE x + 50 TO x + 99: x$ = "B": specindex = 10
                    CASE x + 100 TO x + 149: x$ = "A": specindex = 20
                    CASE x + 150 TO x + 199: x$ = "F": specindex = 30
                    CASE x + 200 TO x + 249: x$ = "G": specindex = 40
                    CASE x + 250 TO x + 299: x$ = "K": specindex = 50
                    CASE x + 300 TO x + 349: x$ = "M": specindex = 60
                END SELECT
            END IF
            Clear_MB 1
        END IF
        IF x$ <> "" THEN
            ch% = INSTR("OBAFGKM", x$)
            IF ch% <> 0 THEN in = -1
        END IF
        _LIMIT 50
    LOOP UNTIL in
    '-----------------------------------------------------------Class Number
    in = 0
    DialogBox "Stellar Class", 500, 200, 400, &HFF00FF00, &HFFFFFFFF, "c"
    x = scrw / 2 - 250
    FOR sn = 0 TO 9
        Con_Blok x + (sn * 50), 540, 50, 50, STR$(sn), 1, &HFF7F7F7F
    NEXT sn
    DO
        xn$ = INKEY$
        ms = MBS
        IF ms AND 1 THEN
            IF _MOUSEY > 540 AND _MOUSEY < 590 THEN
                IF _MOUSEX >= x AND _MOUSEX < x + 500 THEN
                    xn$ = _TRIM$(STR$(INT((_MOUSEX - x - 1) / 50)))
                END IF
            END IF
            Clear_MB 1
        END IF
        IF xn$ <> "" THEN
            'assign stellar class
            ch% = INSTR("0123456789", xn$)
            IF ch% <> 0 THEN
                hvns(var).class = _TRIM$(x$) + _TRIM$(xn$)
                specindex = specindex + (ch% - 1)
                in = -1
            END IF
        END IF
        _LIMIT 50
    LOOP UNTIL in
    '-----------------------------------------------------------Size
    in = 0
    DialogBox "Stellar Size", 500, 200, 400, &HFF00FF00, &HFFFFFFFF, "c"
    x = scrw / 2 - 200
    Con_Blok x, 540, 50, 50, "1:Ia", 1, &HFF7F7F7F
    Con_Blok x + 50, 540, 50, 50, "2:Ib", 1, &HFF7F7F7F
    Con_Blok x + 100, 540, 50, 50, "3:II", 1, &HFF7F7F7F
    Con_Blok x + 150, 540, 50, 50, "4:III", 1, &HFF7F7F7F
    IF specindex < 50 THEN '                                    size IV has nothing past K0
        Con_Blok x + 200, 540, 50, 50, "5:IV", 1, &HFF7F7F7F
    END IF
    Con_Blok x + 250, 540, 50, 50, "6:V", 1, &HFF7F7F7F
    IF specindex > 34 THEN '                                    size VI has nothing prior to F5
        Con_Blok x + 300, 540, 50, 50, "7:VI", 1, &HFF7F7F7F
    END IF
    Con_Blok x + 350, 540, 50, 50, "8:D", 1, &HFF7F7F7F
    DO
        xs$ = INKEY$
        ms = MBS
        IF ms AND 1 THEN
            IF _MOUSEY > 540 AND _MOUSEY < 590 THEN
                IF _MOUSEX >= x AND _MOUSEX < x + 400 THEN
                    sz = INT((_MOUSEX - x - 1) / 50)
                    in = -1
                END IF
            END IF
            Clear_MB 1
        END IF
        IF xs$ <> "" THEN
            ch% = INSTR("12345678", xs$)
            IF ch% <> 0 THEN
                sz = ch% - 1
                in = -1
            END IF
        END IF
        IF in THEN
            SELECT CASE sz
                CASE 0: hvns(var).siz = "Ia"
                CASE 1: hvns(var).siz = "Ib"
                CASE 2: hvns(var).siz = "II"
                CASE 3: hvns(var).siz = "III"
                CASE 4: hvns(var).siz = "IV"
                CASE 5: hvns(var).siz = "V"
                CASE 6: hvns(var).siz = "VI"
                CASE 7: hvns(var).siz = "D"
            END SELECT
        END IF
        _LIMIT 50
    LOOP UNTIL in
    'get appropriate stellar class information

END SUB 'StellarIn


'²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²
SUB TypeIn (var AS INTEGER)

    IF togs AND 1 THEN prompt$ = "Change " + _TRIM$(hvns(var).nam) + " to:" ELSE prompt$ = "Choose Type of Feature"
    DialogBox prompt$, 500, 200, 400, &HFF00FF00, &HFFFFFFFF, "c"
    x = scrw / 2 - 250
    Con_Blok x, 540, 100, 50, "Star", 1, &HFF7F7F7F
    Con_Blok x + 100, 540, 100, 50, "Gas Giant", 1, &HFF7F7F7F
    Con_Blok x + 200, 540, 100, 50, "Belt/Ring", 1, &HFF7F7F7F
    Con_Blok x + 300, 540, 100, 50, "Rock/Ice", 1, &HFF7F7F7F
    IF togs AND 1 THEN
        Con_Blok x + 400, 540, 100, 50, "Default", 1, &HFF7F7F7F
    END IF
    DO
        x$ = UCASE$(INKEY$)
        ms = MBS
        IF ms AND 1 THEN
            IF _MOUSEY > 540 AND _MOUSEY < 590 THEN
                SELECT CASE _MOUSEX
                    CASE x TO x + 99: x$ = "S"
                    CASE x + 100 TO x + 199: x$ = "G"
                    CASE x + 200 TO x + 299: x$ = "B"
                    CASE x + 300 TO x + 399: x$ = "R"
                    CASE x + 400 TO x + 499: x$ = "D"
                END SELECT
            END IF
            Clear_MB 1
        END IF
        IF x$ <> "" THEN
            ch% = INSTR("SGBRD", x$)
            IF ch% <> 0 THEN
                in = -1
                SELECT CASE ch%
                    CASE IS = 1
                        hvns(var).star = -1
                        StellarIn var
                    CASE IS = 2
                        hvns(var).star = 0: hvns(var).class = "GG"
                    CASE IS = 3
                        hvns(var).star = 2: hvns(var).class = ""
                    CASE IS = 4
                        hvns(var).star = 0: hvns(var).class = ""
                    CASE IS = 5
                        IF NOT togs AND 1 THEN in = 0
                END SELECT
            END IF
        END IF
        _LIMIT 50
    LOOP UNTIL in

END SUB 'Type_In


'²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²
SUB NameIn (var AS INTEGER)

    yset = _WIDTH(0) / 16 - 14
    IF togs AND 1 THEN '                                        If edit mode
        DialogBox "New Name or <Enter> to keep old", 500, 200, 400, &HFF00FF00, &HFFFFFFFF, "c"
        LOCATE 30, yset '                                       Planetary name
        PRINT "Change "; _TRIM$(hvns(var).nam); " to: ";: INPUT x$
        IF x$ <> "" THEN
            'rename the children
            FOR j = 1 TO count
                IF hvns(j).parnt = hvns(var).nam THEN hvns(j).parnt = _TRIM$(x$)
            NEXT j
            hvns(var).nam = _TRIM$(x$)
        END IF
    ELSE '                                                      if not edit mode
        DialogBox "New Name", 500, 200, 400, &HFF00FF00, &HFFFFFFFF, "c"
        LOCATE 30, yset
        INPUT "Name: ", hvns(var).nam
    END IF '                                                    end: mode test

END SUB 'NameIn


'²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²
FUNCTION Azimuth! (x AS _INTEGER64, y AS _INTEGER64)

    'Returns the azimuth bearing of a relative (x,y) offset
    IF x < 0 AND y >= 0 THEN
        Azimuth! = 7.853981 - ABS(_ATAN2(y, x))
    ELSE
        Azimuth! = 1.570796 - _ATAN2(y, x)
    END IF

END FUNCTION 'Azimuth!


'²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²² adaptation of code by SierraKen
SUB BevelB (xsiz AS INTEGER, ysiz AS INTEGER, col AS _UNSIGNED LONG)

    'Create control button bevels for 3D effect - called from Con_Blok
    brdr = ABS(INT(ysiz / 4) * (ysiz <= xsiz) + INT(xsiz / 4) * (ysiz > xsiz)) 'select smaller border axis
    FOR bb = 0 TO brdr
        c = c + 100 / brdr
        LINE (0 + bb, 0 + bb)-(xsiz - 1 - bb, ysiz - 1 - bb), _RGBA32(_RED32(col) - 100 + c, _GREEN32(col) - 100 + c, _BLUE32(col) - 100 + c, _ALPHA(col)), B
    NEXT bb

END SUB 'BevelB


'²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²
SUB BodyDelete (var AS INTEGER)

    'Delete var and its children
    DialogBox "WARNING: Deleteing " + _TRIM$(hvns(var).nam) + " and its satellites", INT(scrw * .75), INT(scrh * .75), 25, &HFFFF0000, &HFFFFFFFF, "c"
    'confirm/abort buttons
    Con_Blok INT(scrw / 2 - 250), INT(scrh * .5), 200, 50, "Delete <enter>", 1, &HFF7F7F7F
    Con_Blok INT(scrw / 2 + 50), INT(scrh * .5), 200, 50, "Abort <esc>", 1, &HFF7F7F7F
    _DISPLAY
    DO
        x$ = INKEY$
        ms = MBS
        IF ms AND 1 THEN
            IF _MOUSEY >= INT(scrh * .5) AND _MOUSEY < INT(scrh * .5) + 50 THEN
                IF _MOUSEX >= INT(scrw / 2 - 250) AND _MOUSEX < INT(scrw / 2 - 50) THEN x$ = CHR$(13)
                IF _MOUSEX >= INT(scrw / 2 + 50) AND _MOUSEX < INT(scrw / 2 + 250) THEN x$ = CHR$(27)
            END IF
            Clear_MB 1
        END IF
        _LIMIT 50
    LOOP UNTIL x$ <> ""
    SELECT CASE x$
        CASE IS = CHR$(13) '                                    choose delete
            IF hvns(var).rank < rankmax THEN '                  if children could exist
                x = 0
                DO
                    x = x + 1
                    IF x = var THEN _CONTINUE '                 wait to delete var last
                    p = ChildOf%(var, x)
                    IF NOT p THEN _CONTINUE '                   if not a child go to the next one
                    Collapse x: x = x - 1 '                     delete the child and decrement the counter
                LOOP UNTIL x = UBOUND(hvns)
            ELSE '                                              if no children check to see if rankmax should be set back
                j = 0
                FOR p = 1 TO count '                            iterate through all
                    IF p = var THEN _CONTINUE '                 skip the subject
                    IF hvns(p).rank = hvns(var).rank THEN j = j + 1 'if another rankmax unit exists
                NEXT p
                IF j > 0 THEN rankmax = rankmax - 1 '           if no others exist decrement rankmax
            END IF
            Collapse var '                                      delete unit
            togs = _RESETBIT(togs, 0) '                         exit edit mode
        CASE IS = CHR$(27) '                                    choose abort
            EXIT SUB
    END SELECT

END SUB 'BodyDelete


'²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²
SUB ButtonBlock

    IF sys_in THEN
        Con_Blok 5, scrh - 37, 64, 32, "Add", 1, &HFFA0C0C0

        IF _READBIT(togs, 0) THEN
            Con_Blok 75, scrh - 37, 64, 32, "Cancel", 1, &HFFFFC0C0
        ELSE
            Con_Blok 75, scrh - 37, 64, 32, "Edit", 1, &HFFA0C0C0
        END IF
    END IF
    Con_Blok 145, scrh - 37, 64, 32, "Load", 1, &HFFA0C0C0
    IF sys_in THEN
        IF _READBIT(togs, 1) THEN
            Con_Blok 215, scrh - 37, 64, 32, "Map", 1, &HFFA0C0C0
        ELSE
            Con_Blok 215, scrh - 37, 64, 32, "Map", 1, &HFFF5F5F5F
        END IF
    END IF
    Con_Blok 285, scrh - 37, 64, 32, "New", 1, &HFFA0C0C0
    Con_Blok 355, scrh - 37, 64, 32, "Quit", 1, &HFFA0C0C0
    IF _READBIT(togs, 0) THEN
        ed$ = "Edit " + _TRIM$(STR$(insert))
        Con_Blok 435, scrh - 37, 64, 32, ed$, 1, &HFFFFC0C0
        Con_Blok 505, scrh - 37, 64, 32, "Delete", 1, &HFFFFC0C0
    END IF

END SUB 'ButtonBlock


'²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²
FUNCTION ChildOf% (target AS INTEGER, check AS INTEGER)

    'Determine if 'check' is in subsystem of 'target', true or false
    IF hvns(check).rank > hvns(target).rank THEN '              is check down the rank hierarchy from target
        ns% = hvns(check).rank - hvns(target).rank '            how far down rank hierarchy?
        p% = check
        DO '                                                    ascend hierarchy finding parent at each step
            p% = FindParent(p%)
            ns% = ns% - 1
        LOOP UNTIL ns = 0
        IF p% = target THEN '                                   if loop resolves to a match then true
            ChildOf% = -1
        ELSE '                                                  else false
            ChildOf% = 0
        END IF
    ELSE
        ChildOf% = 0 '                                          if rank = or less then false
    END IF

END FUNCTION 'ChildOf%


'²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²
FUNCTION ChooseWorld% (chshd AS STRING, rank AS INTEGER)

    'Display list of worlds, allow choice of 'rank' worlds and return their index value
    'if rank is 0 then allow all
    tm% = INT((_HEIGHT(A&) - 95) / 16) '                        compute available planet slots
    IF tm% > count THEN tm% = count '                           limit to # of planets
    po% = 0 '                                                   initialize mousewheel offset to 0
    backimage& = _COPYIMAGE(0) '                                copy screen background
    DO
        DialogBox chshd, _WIDTH(A&) / 3, _HEIGHT(A&), 0, &HFF00FF00, &HFFFFFFFF, "c"
        ms = MBS
        hvr% = INT((_MOUSEY - 47) / 16) '                       index mouse x hover
        IF ms AND 1 THEN '                                      left mouse click
            IF hvr% > 0 AND hvf% <= tm% THEN
                IF rank = 0 THEN
                    in = -1: bdy = hvr% + po%
                ELSE
                    IF hvns(hvr% + po%).rank = rank THEN
                        in = -1: bdy = hvr% + po%
                    END IF
                END IF
            END IF
            Clear_MB 1
        END IF
        IF ms AND 512 THEN po% = po% + 1 + (po% = count - tm%) ' increment offset
        IF ms AND 1024 THEN po% = po% - 1 - (po% < 1) '         decrement offset
        FOR x = 1 TO tm%
            xpos% = _WIDTH(A&) / 2 - 80 + (32 * (hvns(x + po%).rank)) 'indent satellites
            ypos% = 63 + ((x - 1) * 16) '                       assign slot
            IF hvns(x + po%).rank = rank THEN
                IF x = hvr% THEN
                    COLOR &HFFFF0000
                ELSE
                    COLOR &HFFFFFFFF
                END IF
            ELSE
                COLOR &HFF7F7F7F
            END IF
            _PRINTSTRING (xpos%, ypos%), hvns(x + po%).nam '    display planet name
        NEXT x
        _LIMIT 30
        _DISPLAY
    LOOP UNTIL in
    COLOR &HFFFFFFFF
    _PUTIMAGE , backimage&, A& '                                reinstate background
    _FREEIMAGE backimage&
    _AUTODISPLAY
    ChooseWorld% = bdy

END FUNCTION 'ChooseWorld%


'²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²
SUB Clear_MB (var AS INTEGER)

    DO UNTIL NOT _MOUSEBUTTON(var)
        WHILE _MOUSEINPUT: WEND
    LOOP

END SUB 'Clear_MB


'²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²
SUB Collapse (var AS INTEGER)

    'remove an array element and pancake upper elements down on it
    n% = count - 1
    DIM tmp(n%) AS body
    y% = 0
    FOR x = 1 TO count
        IF x = var THEN _CONTINUE
        y% = y% + 1
        tmp(y%) = hvns(x)
    NEXT x
    count = n%
    REDIM hvns(count) AS body
    FOR x = 1 TO count
        hvns(x) = tmp(x)
    NEXT x

END SUB 'Collapse


'²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²
SUB Comments

    'Utilizing Sysmap from CTVector

    'ORBITAL PERIOD FORMULA
    'P = (D ^ 3 / M) ^ .5

    'ORBITAL DISTANCE FORMULA
    'D = (M * P ^ 2) ^ .33

    '   if planet orbiting star:
    '       D in AU (150,000,000km)  AUtokm
    '       M in solar masses
    '       P in years
    '   if satellite orbiting planet
    '       D in Earth/Moon distances (400,000km)
    '       M in Earth/Moon masses
    '       P in Lunar months

END SUB 'Comments


'²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²
SUB Con_Blok (xpos AS INTEGER, ypos AS INTEGER, xsiz AS INTEGER, ysiz AS INTEGER, label AS STRING, high AS INTEGER, col AS _UNSIGNED LONG)

    'Create control block
    CN& = _NEWIMAGE(xsiz, ysiz, 32)
    _DEST CN&
    COLOR , col
    CLS
    BevelB xsiz, ysiz, col
    _PRINTMODE _KEEPBACKGROUND
    x = LEN(label)
    IF f& > 0 THEN '                                            if font is available
        sx = (xsiz / 2) - (x * _FONTWIDTH(f&)) / 3
        sy = ysiz / 2 - 6
        _FONT f&
    ELSE '                                                      if not
        sx = xsiz / 2 - x * 4: sy = ysiz / 2 - 8
    END IF
    FOR p = 1 TO x '                                            iterate through label characters
        IF p = high THEN '                                      print hotkey highlight color (red) else (black)
            COLOR &HFFFF0000
        ELSE
            COLOR &HFF000000
        END IF
        IF col = &HFFC80000 THEN COLOR clr&(15)
        _PRINTSTRING (sx + (p - 1) * 8, sy), MID$(label, p, 1)
    NEXT p
    _FONT 16
    _PUTIMAGE (xpos, ypos), CN&, A&
    _FREEIMAGE CN&

END SUB 'Con_Blok


'²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²
SUB DialogBox (heading AS STRING, xsiz AS INTEGER, ysiz AS INTEGER, ypos AS INTEGER, bcol AS _UNSIGNED LONG, tcol AS _UNSIGNED LONG, justify AS STRING)

    'superimpose a screen centered input box for various input routines

    'call syntax: DialogBox <heading string>, box x, box y, y position, bounding box color, text color,{r,c,l}
    T& = _NEWIMAGE(xsiz, ysiz, 32) '                             define box
    _DEST T&
    COLOR tcol, Black '                                       set text color with black background
    CLS
    FOR x = 0 TO 5 '                                            draw bounding box 3 pixels thick
        IF x < 2 THEN
            LINE (0 + x, 0 + x)-(_WIDTH(T&) - 1 - x, _HEIGHT(T&) - 1 - x), 0, B
        ELSE
            LINE (0 + x, 0 + x)-(_WIDTH(T&) - 1 - x, _HEIGHT(T&) - 1 - x), bcol, B
        END IF
    NEXT x
    l = _WIDTH(T&) / 2 - (LEN(heading) * 8) / 2 '                set heading position
    _PRINTSTRING (l, 31), heading, T& '                          print heading
    'Justify left/center/right
    SELECT CASE justify
        CASE IS = "r"
            _PUTIMAGE (_WIDTH(A&) - _WIDTH(T&), ypos), T&, A& '    display box
        CASE IS = "c"
            _PUTIMAGE (_WIDTH(A&) / 2 - _WIDTH(T&) / 2, ypos), T&, A& '    display box
        CASE IS = "l"
            _PUTIMAGE (0, ypos), T&, A& '    display box
    END SELECT
    _DEST A&
    _FREEIMAGE T&

END SUB 'DialogBox


'²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²
FUNCTION DiceRoll% (quan AS INTEGER, dice AS INTEGER, plus AS INTEGER)

    'Rolls any number of dice of any number of sides and adds modifiers
    'syntax usage: DiceRoll% (number of dice rolled, number of sides, any modifier)
    DIM t%, x%
    t% = plus '                                                 add modifier
    FOR x% = 1 TO quan '                                        roll die <quan>tity of times
        t% = t% + INT(Rand * dice) + 1 '                         total up results
    NEXT x%
    DiceRoll% = t%

END FUNCTION 'DiceRoll%


'²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²
SUB DrawRingBelt (vpnt AS V3, cntr AS V3, rng AS _INTEGER64, in AS _INTEGER64, rat AS SINGLE)

    'Draw appropriate portion of ring/belt
    aster& = &H087F7F7F '                                       belt/ring color
    FOR pb = 0 TO rng STEP 1 / rat
        frm = FrameSect(vpnt, cntr, (in + pb), rat) '       are we in the frame?
        IF frm > 0 THEN '                                   if yes then
            CIRCLE (cntr.pX * rat, cntr.pY * rat), (in + pb) * rat, aster&
        END IF
    NEXT pb

END SUB 'DrawRingBelt


'²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²
SUB Echo (var AS INTEGER)

    k = var + 1 - offset
    IF var MOD 2 = 0 THEN
        bb& = &H1F7F7F7F
    ELSE
        bb& = &HFF000000
    END IF
    IF var = insert AND _READBIT(togs, 0) THEN bb& = &H9FFF0000
    COLOR , bb&
    LOCATE k
    PRINT USING "###"; var;
    PRINT SPC(((hvns(var).rank - 1) * 4) + 2); '                indent satellites
    LOCATE k, ((hvns(var).rank - 1) * 4) + 5
    IF hvns(var).rank = 1 AND hvns(var).star = -1 THEN
        PRINT _TRIM$(hvns(var).nam);
        PRINT "  "; hvns(var).class; " "; hvns(var).siz;
        COLOR Red
        PRINT "  System Primary";
        COLOR White
    ELSE
        IF hvns(var).rank > 1 AND hvns(var).star = -1 THEN
            PRINT _TRIM$(hvns(var).nam);
            PRINT "  "; hvns(var).class; " "; hvns(var).siz;
            COLOR Red
            PRINT "  Companion";
            COLOR White
        ELSE
            PRINT _TRIM$(hvns(var).nam);
            COLOR Lime
            PRINT "  {"; _TRIM$(hvns(var).parnt); "}";
            COLOR White
        END IF
    END IF
    COLOR Gray
    PRINT "  rank:"; hvns(var).rank;
    COLOR White
    PRINT SPC(80 - POS(0));
    LOCATE k, 80 'radius
    PRINT USING "#################"; hvns(var).radi;

    LOCATE k, 97 'orbital radius
    PRINT USING "#################"; hvns(var).orad;

    LOCATE k, 114 'orbital period
    PRINT USING "#########.####"; hvns(var).oprd;

    LOCATE k, 128 'rotational period
    PRINT USING "##########.####"; hvns(var).rota;

    LOCATE k, 143 'density
    PRINT USING "#######.##"; hvns(var).dens;
    PRINT
    COLOR , &HFF000000

END SUB 'Echo


'²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²² by Steve McNeill
SUB FCirc (CX AS _INTEGER64, CY AS _INTEGER64, RR AS _INTEGER64, C AS _UNSIGNED LONG)
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


'²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²
FUNCTION FindParent (var AS INTEGER)

    'Accepts a planetary body index (var) and finds the index of its parent body
    FOR x = 1 TO UBOUND(hvns)
        IF hvns(var).parnt = hvns(x).nam THEN p = x
    NEXT x
    FindParent = p

END FUNCTION 'FindParent


'²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²
FUNCTION FrameSect (active AS V3, feature AS V3, range AS _INTEGER64, ratio AS SINGLE)

    'Determine feature's relation to active's viewport
    'SYNTAX: FrameSect(active V3, feature center V3, feature radius, result of Prop! call)
    'Sact = 1415 / ratio '                                       gives display sphere radius
    Sact = 1415 / (ratio / ZoomFac)
    dist## = PythXY(active, feature) '                          distance between active unit and feature center point

    IF dist## > Sact + range THEN FrameSect = 0 '               feature is beyond display
    IF dist## < range - Sact THEN FrameSect = 1 '               feature encompasses entire display
    IF dist## < Sact - range THEN FrameSect = 2 '               feature is encompassed by display
    IF dist## < Sact + range AND dist## > range - Sact THEN FrameSect = 3 ' feature intersects display

END FUNCTION 'FrameSect


'²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²
SUB Header
    LOCATE , 1: PRINT " #";
    PRINT SPC(4);
    LOCATE , 7: PRINT "Name";
    PRINT SPC(69);
    LOCATE , 80: PRINT "           Radius";
    LOCATE , 97: PRINT "      Orb. Radius";
    LOCATE , 114: PRINT "   Orb. Period";
    LOCATE , 128: PRINT "    Rot. Period";
    LOCATE , 143: PRINT "   Density"
END SUB 'Header


'²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²
SUB InsOff
    SELECT CASE insert
        CASE IS = offset: offset = insert - 1
        CASE IS > drows + offset: offset = insert - drows
    END SELECT
END SUB 'InsOff


'²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²
SUB LeftOps (var AS STRING)

    SELECT CASE mouse_y
        CASE 0 TO scrh - 38
            IF _READBIT(togs, 1) THEN '                     if map mode
                IF _READBIT(togs, 2) THEN '                 map on right
                    SELECT CASE mouse_x
                        CASE IS < scrw - 620
                            insert = RedLine 'click out map
                            pov = hvns(insert).ps
                        CASE IS >= scrw - 620
                            IF mouse_y > 17 AND mouse_y < 639 THEN
                                SetPOV mouse_x, mouse_y
                            END IF 'click in map
                    END SELECT
                ELSE '                                      map on left
                    SELECT CASE mouse_x
                        CASE IS <= 620
                            IF mouse_y > 17 AND mouse_y < 639 THEN
                                SetPOV mouse_x, mouse_y
                            END IF 'click in map
                        CASE IS > 620
                            insert = RedLine 'click out map
                            pov = hvns(insert).ps
                    END SELECT
                END IF
            ELSE '                                          if map mode off
                insert = RedLine
            END IF
        CASE scrh - 37 TO scrh - 5
            SELECT CASE mouse_x
                'add sys_in test to Map
                CASE 5 TO 69: IF sys_in THEN var = "A" 'Add
                CASE 75 TO 139
                    IF sys_in THEN
                        IF _READBIT(togs, 0) THEN '                 Cancel
                            togs = _RESETBIT(togs, 0)
                        ELSE '                                      Edit in display
                            var = "E" 'Edit
                        END IF
                    END IF
                CASE 145 TO 209: var = "L" 'Load
                CASE 215 TO 279: IF sys_in THEN var = "M" 'Map
                CASE 285 TO 349: var = "N" 'New
                CASE 355 TO 419: var = "Q" 'Quit
                CASE 435 TO 499: IF _READBIT(togs, 0) THEN var = "E" 'Edit commit
                CASE 505 TO 569: IF _READBIT(togs, 0) THEN var = "D" 'Delete
            END SELECT
    END SELECT

END SUB 'LeftOps


'²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²
SUB LoadSys
    CLS
    DialogBox "OPEN SYSTEM", 700, 150, 50, LimeGreen, LimeGreen, "c"
    LOCATE 8, 50
    INPUT "Name of system: ", fnex$
    file_name = "systems/" + _TRIM$(fnex$) + ".tss"
    IF _FILEEXISTS(file_name) THEN
        OPEN file_name FOR RANDOM AS #1 LEN = LEN(hvns(0))
        count = LOF(1) / LEN(hvns(0))
        REDIM hvns(count) AS body
        rankmax = 1
        FOR x = 1 TO count
            GET #1, x, hvns(x)
            IF hvns(x).rank > rankmax THEN rankmax = hvns(x).rank
        NEXT x
        sys_in = -1
        _TITLE file_name
    ELSE
        PRINT "File does not exist, check path and file name"
    END IF

END SUB 'LoadSys


'²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²
SUB MainLoop

    DIM in AS _BYTE
    DO '                                                        display refresh loop
        IF count > 0 THEN
            IF count > drows THEN offmax = count - drows
            RefreshScreen
            ButtonBlock
        ELSE '                                                  just prompt no echo
            IF sys_in THEN
                RefreshScreen
                ButtonBlock
            ELSE
                CLS
                PRINT "No system present"
                ButtonBlock
            END IF
        END IF

        DO '----------------------------------------------------input loop   °±²
            x$ = UCASE$(INKEY$)
            IF x$ <> "" THEN in = -1

            ms = MBS%
            IF ms AND 1 THEN '                                  mouse left click
                mouse_y = _MOUSEY '                             get y on mouse click
                mouse_x = _MOUSEX '                             get x on mouse click
                LeftOps x$
                Clear_MB 1
                in = -1
            END IF
            IF ms AND 2 THEN '                                  mouse right click
                'Not yet in use
                Clear_MB 2
                in = -1
            END IF
            IF count > drows THEN
                IF ms AND 512 THEN
                    'add an if map on left/right test for mousewheel zooms
                    offset = offset + 1: in = -1
                    RangeStop offset, 0, offmax
                END IF
                IF ms AND 1024 THEN
                    'add an if map on left/right test for mousewheel zooms
                    offset = offset - 1: in = -1
                    RangeStop offset, 0, offmax
                END IF
            ELSE
                offset = 0
            END IF

            'hotkeys
            SELECT CASE x$
                CASE IS = "A" 'add
                    IF _READBIT(togs, 0) THEN togs = _RESETBIT(togs, 0)
                    RefreshScreen: ButtonBlock: _DISPLAY
                    IF sys_in THEN '                            if a system file is active
                        _AUTODISPLAY
                        rank = RankIn 'count + 1

                        'INPUT "input rank (2=planet/companion, rank 3+=satellite, 0=abort): ", rank
                        'IF rank = 0 THEN EXIT DO
                        count = count + 1
                        Add_Edit count, rank
                        Resort
                        SaveFile
                    ELSE '                                      if a system file is not yet created/loaded
                        CLS
                        INPUT "Enter a name for the new system: ", n$
                        file_name = "systems/" + _TRIM$(n$) + ".tss"
                        OPEN file_name FOR RANDOM AS #1 LEN = LEN(hvns(0))
                        count = count + 1
                        Add_Edit count, 1
                        SaveFile
                        sys_in = -1 '                           working system file is now on disk/in memory
                    END IF
                CASE IS = "C" 'cancel
                    IF _READBIT(togs, 0) THEN togs = _RESETBIT(togs, 0)
                CASE IS = "D" 'delete
                    BodyDelete insert
                    Resort
                    SaveFile
                CASE IS = "E" 'edit
                    IF _READBIT(togs, 0) THEN
                        Add_Edit insert, hvns(insert).rank
                        Resort
                        SaveFile
                    ELSE
                        togs = _SETBIT(togs, 0)
                        IF insert < 0 OR insert > count THEN insert = 1
                    END IF
                CASE IS = "L" 'load
                    IF _READBIT(togs, 0) THEN togs = _RESETBIT(togs, 0)
                    CLOSE #1
                    LoadSys
                CASE IS = "M" 'map
                    togs = _TOGGLEBIT(togs, 1)
                CASE IS = "N" 'new
                    IF _READBIT(togs, 0) THEN togs = _RESETBIT(togs, 0)
                    CLOSE #1
                    REDIM hvns(0)
                    CLS
                    INPUT "Enter a name for the new system: ", n$
                    file_name = "systems/" + _TRIM$(n$) + ".tss"
                    OPEN file_name FOR RANDOM AS #1 LEN = LEN(hvns(0))
                    count = 1
                    Add_Edit count, 1
                    SaveFile
                    sys_in = -1
                CASE IS = "Q" 'quit
                    EXIT SUB
                CASE IS = "+"
                    ZoomFac = ZoomFac * 2
                CASE IS = "-"
                    ZoomFac = ZoomFac * .5
                CASE IS = CHR$(0) + CHR$(72) '                  up arrow
                    IF _READBIT(togs, 0) THEN
                        insert = insert - 1: RangeStop insert, 1, count
                        InsOff
                    ELSE
                        offset = offset - 1: RangeStop offset, 0, offmax 'scroll up
                    END IF
                CASE IS = CHR$(0) + CHR$(80) '                  down arrow
                    IF _READBIT(togs, 0) THEN
                        insert = insert + 1: RangeStop insert, 1, count
                        InsOff
                    ELSE
                        offset = offset + 1: RangeStop offset, 0, offmax 'scroll down
                    END IF
                CASE IS = CHR$(0) + CHR$(75) '                  left arrow
                    IF _READBIT(togs, 1) THEN togs = _RESETBIT(togs, 2) 'map on left
                CASE IS = CHR$(0) + CHR$(77) '                  right arrow
                    IF _READBIT(togs, 1) THEN togs = _SETBIT(togs, 2) 'map on right
            END SELECT

            _LIMIT 50
            _DISPLAY
        LOOP UNTIL in '-----------------------------------------end: input loop
        in = 0
    LOOP '                                                      end: display refresh loop

END SUB 'MainLoop


'²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²
FUNCTION map! (value!, minRange!, maxRange!, newMinRange!, newMaxRange!)

    map! = ((value! - minRange!) / (maxRange! - minRange!)) * (newMaxRange! - newMinRange!) + newMinRange!

END FUNCTION 'map!


'²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²² by Steve McNeill
FUNCTION MBS%
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


'²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²
FUNCTION Period_Orbit! (unit AS INTEGER)

    punit = FindParent(unit)
    vd## = hvns(punit).dens * ((4 / 3) * _PI * (hvns(punit).radi ^ 3))
    vdt## = hvns(unit).dens * ((4 / 3) * _PI * (hvns(unit).radi ^ 3))
    IF hvns(punit).star THEN '                                  unit orbits a star
        solt## = vd## / 3.596622028E17 '                        mass / solar masses Sol=695700 radius & .255 average density
        'compute period in years
        p = ((hvns(unit).orad / AUtokm) ^ 3 / solt##) ^ .5
    ELSE '                                                      unit orbits a planet
        solp## = vd## / 1.083206917E12 '                        planet mass
        solc## = vdt## / 1.083206917E12 '                       satellite mass
        solt## = solp## + solc## '                              mass / earth/moon masses
        'compute period in months then convert to years
        p = (((hvns(unit).orad / 400000) ^ 3 / solt##) ^ .5) * (28 / 365.25)
    END IF
    Period_Orbit! = p

END FUNCTION 'Period_Orbit


'²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²
FUNCTION Period_Rotation! (unit AS INTEGER)

    p% = FindParent(unit)
    a% = DiceRoll%(2, 6, -2) '                                  2D-2
    IF hvns(p%).star THEN
        sm## = .255 * (Solrad ^ 3) '                            Sol mass
        pm## = hvns(p%).dens * (hvns(p%).radi ^ 3) '            Parent mass
        m! = pm## / sm## '                                      Parent in Sol masses
        d## = hvns(unit).orad / AUtokm '                        distance in AU
    ELSE
        tm## = 6371 ^ 3 '                                       Earth mass
        pm## = hvns(p%).dens * (hvns(p%).radi ^ 3) '            Parent mass
        m! = pm## / tm## '                                      Parent in Earth masses
        d## = hvns(unit).orad / 400000 '                        distance per 400000km
    END IF
    rot! = (a% * 4) + 5 + m! / d##
    'if result is more than 40 then use special case table
    SELECT CASE rot!
        CASE IS <= 40
            Period_Rotation! = rot!
        CASE IS > 40
            b% = DiceRoll%(2, 6, 0)
            SELECT CASE b%
                CASE 2: Period_Rotation! = DiceRoll%(1, 6, 0) * -10
                CASE 3: Period_Rotation! = DiceRoll%(1, 6, 0) * 20
                CASE 4, 10: Period_Rotation! = DiceRoll%(1, 6, 0) * 10
                CASE 5, 9: Period_Rotation! = rot!
                CASE 6 TO 8: Period_Rotation! = hvns(unit).oprd / 365.25
                CASE 11: Period_Rotation! = DiceRoll%(1, 6, 0) * 50
                CASE 12: Period_Rotation! = DiceRoll%(1, 6, 0) * -50
            END SELECT
    END SELECT

END FUNCTION 'Period_Rotation


'²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²
FUNCTION Prop!

    DIM deltamax AS _INTEGER64 ' carries the widest axial separation of units in km

    IF count > 1 THEN '                                         multiple units present
        deltamax = 1000
        x = 0
        DO
            x = x + 1
            IF ABS(dcp(x).pX) > deltamax THEN deltamax = ABS(dcp(x).pX) 'X limits
            IF ABS(dcp(x).pY) > deltamax THEN deltamax = ABS(dcp(x).pY) 'Y limits
        LOOP UNTIL x = count
    ELSE '                                                      only single unit present
        deltamax = 1000000
    END IF
    Prop! = 800 * (ZoomFac / deltamax) '                        all units on screen subject to zoom factor

END FUNCTION 'Prop!


'²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²
FUNCTION PythXY (var1 AS V3, var2 AS V3)

    'Use to find distance between two 2D points. Also calculate speed/magnitude of updated vectors
    PythXY = _HYPOT(ABS(var1.pX - var2.pX), ABS(var1.pY - var2.pY))

END FUNCTION 'PythXY


'²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²² 'by Steve McNeill
FUNCTION Rand

    STATIC Init, IndexOn
    IF Init = 0 THEN
        Init = -1
        FOR I = 0 TO 1000000
            Rseed(I) = I / 1000001
        NEXT
    END IF
    IF IndexOn = 0 THEN
        RANDOMIZE TIMER
        FOR I = 0 TO 1000000
            SWAP Rseed(I), Rseed(INT(RND * 1000001))
        NEXT
    END IF
    IndexOn = (IndexOn + 1) MOD 1000000
    Rand = Rseed(IndexOn)

END FUNCTION 'Rand


'²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²
SUB RangeStop (var AS INTEGER, min AS INTEGER, max AS INTEGER)

    SELECT CASE var
        CASE IS < min: var = min
        CASE IS > max: var = max
    END SELECT

END SUB 'RangeStop


'²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²
FUNCTION RankIn

    DialogBox "Enter Rank", 700, 350, 50, &HFF00FF00, &HFFFFFFFF, "c"
    'choose the rank of the body to be entered, allow for one rank above rankmax but not two
    'there must be a parent
    x = scrw / 2 - (rankmax * 50)
    FOR r% = 2 TO rankmax + 1
        Con_Blok x + (r% - 2) * 50, 290, 50, 50, STR$(r%), 1, &HFF7F7F7F
        ch$ = ch$ + STR$(r%)
    NEXT r%
    DO
        x$ = INKEY$
        ms = MBS
        IF ms AND 1 THEN '                                      if left click input
            IF _MOUSEY > 290 AND _MOUSEY < 340 THEN
                IF _MOUSEX > x AND _MOUSEX < x + rankmax * 50 THEN
                    RankIn = INT((_MOUSEX - x) / 50) + 2: in = -1
                END IF
            END IF
            Clear_MB 1
        END IF
        IF x$ <> "" THEN '                                      if keyboard input
            'handle keyboard input here
            RankIn = INSTR(ch$, x$): in = -1
        END IF
        _LIMIT 50
    LOOP UNTIL in
    IF RankIn > rankmax THEN rankmax = RankIn '                 increment rankmax if rank is higher

END FUNCTION 'RankIn


'²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²
FUNCTION RedLine

    yline = INT(mouse_y / 16)
    a% = yline + offset
    SELECT CASE yline
        CASE IS < 1
            togs = _RESETBIT(togs, 0)
        CASE 1 TO drows
            IF yline > count THEN
                togs = _RESETBIT(togs, 0)
            ELSE
                togs = _SETBIT(togs, 0)
                RedLine = a%
            END IF
        CASE IS > drows
            togs = _RESETBIT(togs, 0)
    END SELECT

END FUNCTION 'RedLine


'²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²
SUB RefreshScreen

    CLS
    COLOR Yellow, Blue
    Header
    COLOR White, Black
    FOR x = 1 TO drows
        IF x + offset > UBOUND(hvns) THEN EXIT FOR
        Echo x + offset
    NEXT x
    IF _READBIT(togs, 1) THEN '                                 display map when map mode
        VCS
        SensorScreen
        IF _READBIT(togs, 2) THEN
            _PUTIMAGE (scrw - 620, 18), SS&, A& '               update sensor screen to mainscreen
        ELSE
            _PUTIMAGE (0, 18), SS&, A&
        END IF
        _DISPLAY
    END IF

END SUB 'RefreshScreen


'²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²
SUB Resort

    'SORT DATA BY RANK & ORBITAL RADII
    DIM tmp(UBOUND(hvns)) AS sort '                             imdexer variable
    DIM tmor(UBOUND(hvns)) AS body '                            temporary data holder
    FOR x = 1 TO UBOUND(hvns) '                                 iterate through data
        SELECT CASE hvns(x).rank
            CASE IS = 1 '                                       rank 1 is always record 1
                tmp(x).index = x
                tmp(x).value = 0
            CASE ELSE
                tmp(x).index = x '                              set indexer to data
                tmp(x).value = hvns(x).orad '                   put data in indexer
                y = hvns(x).rank '                              set data rank countdown variable
                p = FindParent(x) '                             set parent of data
                DO '                                            work back through the ranks
                    blen&& = hvns(p).orad '                     get orbit radius of parent rank
                    tmp(x).value = tmp(x).value + blen&& '      add it to orbit radius tally
                    p = FindParent(p) '                         locate the next rank parent
                    y = y - 1 '                                 decrement rank
                LOOP UNTIL y = 1 '                              stop on rank of primary
        END SELECT
    NEXT x

    'distance sort here
    FOR x = 1 TO UBOUND(tmp)
        FOR y = 1 TO UBOUND(tmp)
            IF tmp(x).value < tmp(y).value THEN SWAP tmp(x), tmp(y)
    NEXT y, x

    FOR x = 1 TO UBOUND(hvns) '                                 copy to temporary data by indexer values
        tmor(x) = hvns(tmp(x).index)
    NEXT x

    FOR x = 1 TO UBOUND(hvns) '                                 move temporary data back to main data
        hvns(x) = tmor(x)
    NEXT x

END SUB 'Resort


'²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²
SUB SaveFile

    'rewrite the file
    CLOSE #1
    KILL file_name
    OPEN file_name FOR RANDOM AS #1 LEN = LEN(hvns(0))
    FOR y = 1 TO count
        PUT #1, y, hvns(y)
    NEXT y

END SUB 'SaveFile


'²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²
SUB SensorScreen

    D& = _DEST
    _DEST SS&
    CLS
    VIEW (1, 1)-(618, 618), &HFF000000, &HFFFF0000 '            set graphics port full image SS& w/box
    WINDOW (-1000, 1000)-(1000, -1000) '                        set relative cartesian coords
    LINE (0, 50)-(0, 25), &HFFFF0000 '                          draw pov reference point xhair
    LINE (0, -25)-(0, -50), &HFFFF0000
    LINE (-50, 0)-(-25, 0), &HFFFF0000
    LINE (25, 0)-(50, 0), &HFFFF0000
    SysMap
    'Dynamic scale grid display
    DIM q!
    q! = Prop!
    DIM dynagrid AS SINGLE
    dynagrid = .001 '                                           start at 1 meters grid size
    DO
        IF (q! * dynagrid) > 60 THEN EXIT DO '                  adjust the number to change the grid behaviour
        dynagrid = dynagrid * 10 '                              jump by power of 10 when necessary
    LOOP

    g = 0: dc% = 0
    DO UNTIL g > 1000 '                                         Draw grid
        IF dc% MOD 10 = 0 THEN
            COLOR _RGBA32(255, 255, 255, 40) '                  semi-transparent white for grid by 10s  &H28FFFFFF
        ELSE
            COLOR _RGBA32(255, 255, 255, 15) '                  semi-transparent white for grid  &H0FFFFFFF
        END IF
        LINE (-1000, g)-(1000, g) '                             horizontal grid lines
        IF g > 0 THEN LINE (-1000, (-1 * g))-(1000, (-1 * g))
        LINE (g, -1000)-(g, 1000) '                             vertical grid lines
        IF g > 0 THEN LINE ((-1 * g), -1000)-((-1 * g), 1000)
        g = g + (q! * dynagrid)
        dc% = dc% + 1
    LOOP
    scalelegend$ = "grid=" + STR$(dynagrid) + " km   +/- to zoom " + STR$(q!)
    _FONT f&
    COLOR _RGBA32(255, 255, 255, 100)
    _PRINTSTRING (5, 600), scalelegend$
    _DEST D&

END SUB 'SensorScreen


'²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²
SUB SetPOV (xpos AS INTEGER, ypos AS INTEGER)

    IF _READBIT(togs, 2) THEN
        winx = map!(xpos, scrw - 620, scrw, -1000, 1000)
    ELSE
        winx = map!(xpos, 0, 620, -1000, 1000)
    END IF
    winy = map!(ypos, 18, 638, 1000, -1000)
    q! = Prop!
    pov.pX = winx / q! + pov.pX
    pov.pY = winy / q! + pov.pY

END SUB 'SetPOV


'²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²
SUB SysMap

    'Displays the star system, called from SUB SensorScreen

    DIM g! '                                                    holds result of Prop! call for this display loop
    DIM OT AS V3 '                                              locates orbit tracks & belt/ring systems
    g! = Prop!

    'Iterate through all system bodies
    FOR p = 1 TO count

        'on jump toggle display diameters- rejecting those out of frame
        IF _READBIT(maptogs, 6) AND hvns(p).star <> 2 THEN '      jump zones toggled & not asteroid belt
            IF _READBIT(maptogs, 9) THEN l! = hvns(p).dens ELSE l! = 1 'density or diameter jump zone
            '100 diameters/densities
            IF hvns(p).radi * 400 * l! * g! > 25 THEN
                frm = FrameSect(pov, dcp(p), hvns(p).radi * 200 * l!, g!)
                IF frm > 1 THEN
                    FCirc (dcp(p).pX) * g!, (dcp(p).pY) * g!, (hvns(p).radi * 200 * l!) * g!, _RGBA(150, 116, 116, 10)
                END IF
            END IF '                                            end: size test
            '10 diameters/densities
            IF hvns(p).radi * 40 * l! * g! > 25 THEN
                frm = FrameSect(pov, dcp(p), hvns(p).radi * 20 * l!, g!)
                IF frm > 1 THEN
                    FCirc (dcp(p).pX) * g!, (dcp(p).pY) * g!, (hvns(p).radi * 20 * l!) * g!, _RGBA(200, 116, 116, 5)
                END IF
            END IF '                                            end: size test
        END IF '                                                end: jump zones toggled

        'If star then build star and star corona otherwise set planet color
        IF hvns(p).star = -1 THEN '                              if a star then build star corona
            'DETERMINE ANY STELLAR CLASS CONSTANTS HERE- use them in place of 50000
            frm = FrameSect(pov, dcp(p), hvns(p).radi + (30 * 50000), g!)
            IF frm > 0 THEN
                FOR x = 1 TO 30
                    frm = FrameSect(pov, dcp(p), hvns(p).radi + (x * 50000), g!)
                    IF frm > 0 THEN
                        FCirc (dcp(p).pX) * g!, (dcp(p).pY) * g!, (hvns(p).radi + (x * 50000)) * g!, _RGBA32(127, 127, 227, 30 - x)
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
            c& = &HFF545454 '                               planet color
        END IF

        'find orbit track center
        IF hvns(p).rank > 1 THEN
            OT = dcp(FindParent(p))
        ELSE
            OT.pX = 0: OT.pY = 0: OT.pZ = 0
        END IF

        IF hvns(p).star < 2 THEN

            'display orbit tracks
            IF g! < .1 THEN '                                   if zoomed out far enough- improves speed on zoom in
                IF _READBIT(maptogs, 7) THEN '                      if orbit toggle is true
                    IF hvns(p).orad * 2 * g! > 50 THEN '        if large enough to see on screen
                        frm = FrameSect(pov, dcp(FindParent(p)), hvns(p).orad, g!)
                        IF frm = 3 THEN 'exclude circles that don't intersect view port to speed zoom in
                            CIRCLE (OT.pX * g!, OT.pY * g!), hvns(p).orad * g!, _RGBA(111, 72, 233, 70)
                        END IF
                    END IF '                                    end: size test
                END IF '                                        end: orbit toggle test
            END IF '                                            end: close zoom test

            'display gravity zones
            IF _READBIT(maptogs, 8) THEN '                          if grav zone toggle is true
                IF hvns(p).star <> 2 THEN
                    grv! = 0
                    radius## = hvns(p).radi
                    dsx## = hvns(p).dens * ((4 / 3) * PI * (radius## * radius## * radius##)) / 26687
                    DO
                        grv! = grv! + .25 '                     zones drawn in 1/4G increments
                        esc& = _RGBA(0, 255, 0, 25) '        light green = lighter Gs than active's Max G
                        ds## = (dsx## / grv!) ^ .5 '            set grav zone radius
                        IF ds## * g! < 50 THEN _CONTINUE '       if too small to see then skip
                        frm = FrameSect(pov, dcp(p), ds##, g!)
                        IF frm = 3 THEN
                            CIRCLE (dcp(p).pX * g!, dcp(p).pY * g!), ds## * g!, esc&
                        END IF
                    LOOP UNTIL ds## < hvns(p).radi
                END IF '                                        end: belt/ring test
            END IF '                                            end: grav zone toggled test

            'display star/planet body, rejecting those that are out of frame
            frm = FrameSect(pov, dcp(p), hvns(p).radi, g!)
            IF frm > 0 THEN
                '*** TO BE ADDED modify radii based upon distance
                IF hvns(p).radi * 2 * g! > 2 THEN '             if large enough to see
                    FCirc dcp(p).pX * g!, dcp(p).pY * g!, hvns(p).radi * g!, c&
                    CIRCLE (dcp(p).pX * g!, dcp(p).pY * g!), hvns(p).radi * g!, c& '&HFF777777
                ELSE '                                          if not, draw placekeeping point
                    PSET (dcp(p).pX * g!, dcp(p).pY * g!), c&
                END IF '                                        end: size test
                '*** TO BE ADDED end distance radii modification

                'display name if there's room
                IF g! > .03 AND hvns(p).rank = 4 THEN '         drop sub-satellite names first
                    GOSUB print_name
                END IF
                IF g! > .0003 AND hvns(p).rank = 3 THEN '       drop satellite names first
                    GOSUB print_name
                END IF
                IF g! > .00000003 AND hvns(p).rank = 2 THEN '   Then drop planets names
                    GOSUB print_name
                END IF
                IF hvns(p).star THEN '                          always keep star names visible
                    GOSUB print_name
                END IF
            END IF '                                            end planet out of frame reject
        ELSE
            'Display planetoid belts and rings
            IF _READBIT(maptogs, 10) THEN
                IF hvns(p).orad * 2 * g! > 100 THEN '       Is belt/ring large enough to see? Maybe replace with CONTINUE
                    IF hvns(p).dens > 0 THEN '              belt/ring width- stored in dens element
                        wid = hvns(p).dens / 2
                    ELSE
                        wid = .15 '                         default width
                    END IF
                    inbnd&& = (hvns(p).orad - (hvns(p).orad * wid)) 'inner limit of planetoid/ring belt wid% orbital radius
                    outbnd&& = (hvns(p).orad + (hvns(p).orad * wid)) 'outer limit of planetoid/ring belt wid% orbital radius
                    frmout = FrameSect(pov, dcp(FindParent(p)), outbnd&&, g!)
                    frmin = FrameSect(pov, dcp(FindParent(p)), inbnd&&, g!)
                    rng&& = INT(outbnd&& - inbnd&&)
                    SELECT CASE frmout
                        CASE IS = 1 '                       outer band beyond frame
                            SELECT CASE frmin
                                CASE IS = 0 '               belt fills frame- print name
                                    B& = _NEWIMAGE(620, 620, 32)
                                    _DEST B&
                                    'Prnt TRIM$(hvns(p).nam), 12, 12, -70 * LEN(TRIM$(hvns(p).nam)), 280, 120, 0, &H1F7F7F7F
                                    'COLOR &H1F7F7F7F
                                    '_FONT ff&
                                    '_printstring
                                    _DEST SS&
                                    _PUTIMAGE (560, 18), B&, A&
                                    _FREEIMAGE B&
                                CASE IS >= 2 '              inner band intersects or is fully within frame
                                    DrawRingBelt pov, OT, rng&&, inbnd&&, g!
                            END SELECT
                        CASE IS = 2 '                       outer band fully within frame
                            SELECT CASE frmin
                                CASE IS = 2 '               inner band fully within frame
                                    DrawRingBelt pov, OT, rng&&, inbnd&&, g! 'Draw band- fully
                            END SELECT
                        CASE IS = 3 '                       outer band intersects frame
                            SELECT CASE frmin
                                CASE IS <> 1 '              inner band out of frame
                                    DrawRingBelt pov, OT, rng&&, inbnd&&, g! 'Draw band- partial outer
                            END SELECT
                    END SELECT '                            end draw/no draw tests
                END IF '                                    end show belt/ring if large enough to see
            END IF '                                            end belt/ring toggle
        END IF '                                                end planetary or belt display
    NEXT p

    EXIT SUB
    print_name:
    fl$ = ""
    fl = 1
    fl$ = hvns(p).nam
    sz! = 3.6 - hvns(p).rank / 4
    IF fp1& > 0 AND fp2& > 0 AND fp3& > 0 THEN
        SELECT CASE hvns(p).rank
            CASE IS = 1: _FONT fp1&
            CASE IS = 2: _FONT fp2&
            CASE IS >= 3: _FONT fp3&
        END SELECT
        COLOR _RGBA32(200, 67, 55, 170)
        pnx% = (((dcp(p).pX * g!) / 2000) * 620 + 310) + (hvns(p).radi * g! * .3)
        pny% = (((-dcp(p).pY * g!) / 2000) * 620 + 310) + (hvns(p).radi * g! * .3)
        _PRINTMODE _KEEPBACKGROUND
        _PRINTSTRING (pnx%, pny%), hvns(p).nam
        _FONT 16
    END IF
    RETURN

END SUB 'SysMap


'²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²
FUNCTION TrueFalse (var AS STRING)
    PRINT var
    _DISPLAY
    DO
        x$ = UCASE$(INKEY$)
    LOOP UNTIL x$ = "T" OR x$ = "F"
    IF x$ = "T" THEN
        TrueFalse = -1
    ELSE
        TrueFalse = 0
    END IF
END FUNCTION 'TrueFalse


'²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²
SUB VCS

    REDIM dcp(count) AS V3
    c = 0
    DO '                                                        ITERATE THROUGH PLANETS
        c = c + 1
        IF hvns(c).star = 2 THEN _CONTINUE '                    Belts and rings have parent centers and orbit radii instead of coordinates
        dcp(c) = hvns(c).ps: VecAdd dcp(c), pov, -1 '           Set relative planet coordinate system from pov
    LOOP UNTIL c >= count

END SUB 'VCS


'²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²
SUB VecAdd (var AS V3, var2 AS V3, var3 AS INTEGER)
    var.pX = var.pX + (var2.pX * var3) '                        add (or subtract) two vectors defined by V3
    var.pY = var.pY + (var2.pY * var3) '                        var= base vector, var2= vector to add
    var.pZ = var.pZ + (var2.pZ * var3) '                        var3 multiple of var2 to add (-sign to subtract)
END SUB 'VecAdd





'²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²
FUNCTION NumeralIn (x AS INTEGER, y AS INTEGER, spec AS STRING)

    'AS YET UNUSED
    DO
        x$ = _TRIM$(INKEY$)
        IF x$ = "" THEN _CONTINUE
        SELECT CASE ASC(x$)
            CASE IS = 8 '                                           backspace has been pressed
                x = x - 1
                LOCATE y, x
                PRINT " " '                                         blank last numeral
                l = LEN(num$) - 1 '                                 pop numeral off numeral stack
                num$ = MID$(num$, 1, l)
            CASE IS = 46, 48, 49, 50, 51, 52, 53, 54, 55, 56, 57 '  numeral 0-9 or decimal has been pressed
                num$ = num$ + x$ '                                  push numeral on numeral stack
                LOCATE y, x
                PRINT _TRIM$(x$) '                                  echo keypress
                x = x + 1
        END SELECT
        _LIMIT 50
    LOOP UNTIL x$ = CHR$(13)
    NumeralIn = VAL(num$)

END FUNCTION 'NumeralIn


