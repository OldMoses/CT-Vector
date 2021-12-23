'OPTION _EXPLICIT
'With many thanks to SpriggsySpriggs for this API call

'DIM x$
'x$ = GetOpenFileName("Load Scenario File", _CWD$ + "\systems\", "scenario files (*.tss)|*.tss", 2)
'PRINT "We can now open " + x$

'PRINT GetOpenFileName("This is a test", _DIR$("desktop"), "txt files (*.txt)|*.txt|All files (*.*)|*.*", 2)

'Dim As String savefile
'savefile = GetSaveFileName("Save test", _CWD$, "txt files (*.txt)|*.txt|All files (*.*)|*.*", 1)
'If savefile <> "" Then
'    Open savefile For Output As #1
'    Print #1, Chr$(34) + "Success! Success! We've done it! We've done it!" + Chr$(34)
'    Print #1, Chr$(9) + Chr$(9) + Chr$(9) + "-Every diplomatic leader in The Batman Movie";
'    Close
'End If

'Print GetFolderName("Pick a folder")

'ReDim As String filelist(1 To 1)
'GetOpenFileNames "Pick multiple files", _Dir$("desktop"), "txt files (*.txt)|*.txt|All files (*.*)|*.*", 1, filelist()

'Dim x
'For x = LBound(filelist) To UBound(filelist)
'    Print filelist(x)
'Next

FUNCTION GetOpenFileName$ (Title AS STRING, InitialDir AS STRING, Filter AS STRING, FilterIndex AS LONG)
    DIM AS STRING cmd, stdout, stderr
    DIM AS LONG exit_code
    IF MID$(InitialDir, LEN(InitialDir) - 1) <> "\" THEN InitialDir = InitialDir + "\"
    cmd = "PowerShell Add-Type -AssemblyName System.Windows.Forms;$FileBrowser = New-Object System.Windows.Forms.OpenFileDialog -Property @{ Title = '" + CHR$(34) + Title + CHR$(34) + "'; InitialDirectory = '" + CHR$(34) + InitialDir + CHR$(34) + "'; Filter = '" + CHR$(34) + Filter + CHR$(34) + "'; FilterIndex = '" + CHR$(34) + LTRIM$(STR$(FilterIndex)) + CHR$(34) + "'; };$null = $FileBrowser.ShowDialog();$FileBrowser.FileName;exit $LASTEXITCODE"
    exit_code = pipecom(cmd, stdout, stderr)
    IF stdout <> "" THEN GetOpenFileName = MID$(stdout, 1, LEN(stdout) - 1)
END FUNCTION

SUB GetOpenFileNames (Title AS STRING, InitialDir AS STRING, Filter AS STRING, FilterIndex AS LONG, filenames() AS STRING)
    DIM AS STRING cmd, stdout, stderr
    DIM AS LONG exit_code
    IF MID$(InitialDir, LEN(InitialDir) - 1) <> "\" THEN InitialDir = InitialDir + "\"
    cmd = "PowerShell Add-Type -AssemblyName System.Windows.Forms;$FileBrowser = New-Object System.Windows.Forms.OpenFileDialog -Property @{ Title = '" + CHR$(34) + Title + CHR$(34) + "'; InitialDirectory = '" + CHR$(34) + InitialDir + CHR$(34) + "'; Filter = '" + CHR$(34) + Filter + CHR$(34) + "'; FilterIndex = '" + CHR$(34) + LTRIM$(STR$(FilterIndex)) + CHR$(34) + "'; Multiselect = 'true'; };$null = $FileBrowser.ShowDialog();$FileBrowser.FileNames;exit $LASTEXITCODE"
    exit_code = pipecom(cmd, stdout, stderr)
    IF stdout <> "" THEN
        stdout = MID$(stdout, 1, LEN(stdout) - 1)
        IF INSTR(stdout, CHR$(10)) = 0 THEN
            filenames(1) = stdout
        ELSE
            String.Split stdout, CHR$(10), filenames()
        END IF
    END IF
END SUB

FUNCTION GetSaveFileName$ (Title AS STRING, InitialDir AS STRING, Filter AS STRING, FilterIndex AS LONG)
    DIM AS STRING cmd, stdout, stderr
    DIM AS LONG exit_code
    IF MID$(InitialDir, LEN(InitialDir) - 1) <> "\" THEN InitialDir = InitialDir + "\"
    cmd = "PowerShell Add-Type -AssemblyName System.Windows.Forms;$FileBrowser = New-Object System.Windows.Forms.SaveFileDialog -Property @{ Title = '" + CHR$(34) + Title + CHR$(34) + "'; InitialDirectory = '" + CHR$(34) + InitialDir + CHR$(34) + "'; Filter = '" + CHR$(34) + Filter + CHR$(34) + "'; FilterIndex = '" + CHR$(34) + LTRIM$(STR$(FilterIndex)) + CHR$(34) + "'; };$null = $FileBrowser.ShowDialog();$FileBrowser.FileName;exit $LASTEXITCODE"
    exit_code = pipecom(cmd, stdout, stderr)
    IF stdout <> "" THEN GetSaveFileName = MID$(stdout, 1, LEN(stdout) - 1)
END FUNCTION

FUNCTION GetFolderName$ (Title AS STRING)
    DIM AS STRING cmd, stdout, stderr
    DIM AS LONG exit_code
    cmd = "PowerShell Add-Type -AssemblyName System.Windows.Forms;$FolderBrowser = New-Object System.Windows.Forms.FolderBrowserDialog -Property @{ Description = '" + CHR$(34) + Title + CHR$(34) + "'; ShowNewFolderButton = 'true'; };$null = $FolderBrowser.ShowDialog();$FolderBrowser.SelectedPath;exit $LASTEXITCODE"
    exit_code = pipecom(cmd, stdout, stderr)
    IF stdout <> "" THEN GetFolderName = MID$(stdout, 1, LEN(stdout) - 1)
END FUNCTION

SUB String.Split (Expression AS STRING, delimiter AS STRING, StorageArray() AS STRING)
    DIM copy AS STRING, p AS LONG, curpos AS LONG, arrpos AS LONG, dpos AS LONG
    copy = Expression
    IF delimiter = " " THEN
        copy = RTRIM$(LTRIM$(copy))
        p = INSTR(copy, "  ")
        WHILE p > 0
            copy = MID$(copy, 1, p - 1) + MID$(copy, p + 1)
            p = INSTR(copy, "  ")
        WEND
    END IF
    curpos = 1
    arrpos = UBOUND(StorageArray)
    dpos = INSTR(curpos, copy, delimiter)
    DO UNTIL dpos = 0
        StorageArray(UBOUND(StorageArray)) = MID$(copy, curpos, dpos - curpos)
        REDIM _PRESERVE StorageArray(UBOUND(StorageArray) + 1) AS STRING
        curpos = dpos + LEN(delimiter)
        dpos = INSTR(curpos, copy, delimiter)
    LOOP
    StorageArray(UBOUND(StorageArray)) = MID$(copy, curpos)
    REDIM _PRESERVE StorageArray(UBOUND(StorageArray)) AS STRING
END SUB

'$INCLUDE:'pipecomqb64.bas'

