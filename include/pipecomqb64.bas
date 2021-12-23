FUNCTION pipecom& (cmd AS STRING, stdout AS STRING, stderr AS STRING)
    $IF WIN THEN
        TYPE SECURITY_ATTRIBUTES
            AS LONG nLength
            $IF 64BIT THEN
                AS LONG padding
            $END IF
            AS _OFFSET lpSecurityDescriptor
            AS LONG bInheritHandle
            $IF 64BIT THEN
                AS LONG padding2
            $END IF
        END TYPE

        TYPE STARTUPINFO
            AS LONG cb
            $IF 64BIT THEN
                AS LONG padding
            $END IF
            AS _OFFSET lpReserved, lpDesktop, lpTitle
            AS LONG dwX, dwY, dwXSize, dwYSize, dwXCountChars, dwYCountChars, dwFillAttribute, dwFlags
            AS INTEGER wShowWindow, cbReserved2
            $IF 64BIT THEN
                AS LONG padding2
            $END IF
            AS _OFFSET lpReserved2, hStdInput, hStdOutput, hStdError
        END TYPE

        TYPE PROCESS_INFORMATION
            AS _OFFSET hProcess, hThread
            AS LONG dwProcessId
            $IF 64BIT THEN
                AS LONG padding
            $END IF
        END TYPE

        CONST STARTF_USESTDHANDLES = &H00000100
        CONST CREATE_NO_WINDOW = &H8000000

        CONST INFINITE = 4294967295
        CONST WAIT_FAILED = &HFFFFFFFF

        DECLARE CUSTOMTYPE LIBRARY
            FUNCTION CreatePipe%% (BYVAL hReadPipe AS _OFFSET, BYVAL hWritePipe AS _OFFSET, BYVAL lpPipeAttributes AS _OFFSET, BYVAL nSize AS LONG)
            FUNCTION CreateProcess%% ALIAS CreateProcessA (BYVAL lpApplicationName AS _OFFSET, BYVAL lpCommandLine AS _OFFSET, BYVAL lpProcessAttributes AS _OFFSET, BYVAL lpThreadAttributes AS _OFFSET, BYVAL bInheritHandles AS INTEGER, BYVAL dwCreationFlags AS LONG, BYVAL lpEnvironment AS _OFFSET, BYVAL lpCurrentDirectory AS _OFFSET, BYVAL lpStartupInfor AS _OFFSET, BYVAL lpProcessInformation AS _OFFSET)
            FUNCTION GetExitCodeProcess%% (BYVAL hProcess AS _OFFSET, BYVAL lpExitCode AS _OFFSET)
            FUNCTION HandleClose%% ALIAS CloseHandle (BYVAL hObject AS _OFFSET)
            FUNCTION ReadFile%% (BYVAL hFile AS _OFFSET, BYVAL lpBuffer AS _OFFSET, BYVAL nNumberOfBytesToRead AS LONG, BYVAL lpNumberOfBytesRead AS _OFFSET, BYVAL lpOverlapped AS _OFFSET)
            FUNCTION WaitForSingleObject& (BYVAL hHandle AS _OFFSET, BYVAL dwMilliseconds AS LONG)
        END DECLARE

        DIM AS _BYTE ok: ok = 1
        DIM AS _OFFSET hStdOutPipeRead, hStdOutPipeWrite, hStdReadPipeError, hStdOutPipeError
        DIM AS SECURITY_ATTRIBUTES sa: sa.nLength = LEN(sa): sa.lpSecurityDescriptor = 0: sa.bInheritHandle = 1

        IF CreatePipe(_OFFSET(hStdOutPipeRead), _OFFSET(hStdOutPipeWrite), _OFFSET(sa), 0) = 0 THEN
            pipecom = -1
            EXIT FUNCTION
        END IF

        IF CreatePipe(_OFFSET(hStdReadPipeError), _OFFSET(hStdOutPipeError), _OFFSET(sa), 0) = 0 THEN
            pipecom = -1
            EXIT FUNCTION
        END IF

        DIM AS STARTUPINFO si
        si.cb = LEN(si)
        si.dwFlags = STARTF_USESTDHANDLES
        si.hStdError = hStdOutPipeError
        si.hStdOutput = hStdOutPipeWrite
        si.hStdInput = 0
        DIM AS PROCESS_INFORMATION pi
        DIM AS _OFFSET lpApplicationName
        DIM AS STRING fullcmd: fullcmd = "cmd /c " + cmd + CHR$(0)
        DIM AS STRING lpCommandLine: lpCommandLine = fullcmd
        DIM AS _OFFSET lpProcessAttributes, lpThreadAttributes
        DIM AS INTEGER bInheritHandles: bInheritHandles = 1
        DIM AS LONG dwCreationFlags: dwCreationFlags = CREATE_NO_WINDOW
        DIM AS _OFFSET lpEnvironment, lpCurrentDirectory
            ok = CreateProcess(lpApplicationName,_
            _Offset(lpCommandLine),_
            lpProcessAttributes,_
            lpThreadAttributes,_
            bInheritHandles,_
            dwCreationFlags,_
            lpEnvironment,_
            lpCurrentDirectory,_
            _Offset(si),_
            _Offset(pi))
        IF ok = 0 THEN
            pipecom = -1
            EXIT FUNCTION
        END IF

        ok = HandleClose(hStdOutPipeWrite)
        ok = HandleClose(hStdOutPipeError)

        DIM AS STRING buf: buf = SPACE$(4096 + 1)
        DIM AS LONG dwRead
        WHILE ReadFile(hStdOutPipeRead, _OFFSET(buf), 4096, _OFFSET(dwRead), 0) <> 0 AND dwRead > 0
            buf = MID$(buf, 1, dwRead)
            GOSUB RemoveChr13
            stdout = stdout + buf
            buf = SPACE$(4096 + 1)
        WEND

        WHILE ReadFile(hStdReadPipeError, _OFFSET(buf), 4096, _OFFSET(dwRead), 0) <> 0 AND dwRead > 0
            buf = MID$(buf, 1, dwRead)
            GOSUB RemoveChr13
            stderr = stderr + buf
            buf = SPACE$(4096 + 1)
        WEND

        DIM AS LONG exit_code, ex_stat
        IF WaitForSingleObject(pi.hProcess, INFINITE) <> WAIT_FAILED THEN
            IF GetExitCodeProcess(pi.hProcess, _OFFSET(exit_code)) THEN
                ex_stat = 1
            END IF
        END IF

        ok = HandleClose(hStdOutPipeRead)
        ok = HandleClose(hStdReadPipeError)
        IF ex_stat = 1 THEN
            pipecom = exit_code
        ELSE
            pipecom = -1
        END IF

        EXIT FUNCTION

        RemoveChr13:
        DIM AS LONG j
        j = INSTR(buf, CHR$(13))
        DO WHILE j
            buf = LEFT$(buf, j - 1) + MID$(buf, j + 1)
            j = INSTR(buf, CHR$(13))
        LOOP
        RETURN
    $ELSE
        Declare CustomType Library
        Function popen%& (cmd As String, readtype As String)
        Function feof& (ByVal stream As _Offset)
        Function fgets$ (str As String, Byval n As Long, Byval stream As _Offset)
        Function pclose& (ByVal stream As _Offset)
        End Declare

        Declare Library
        Function WEXITSTATUS& (ByVal stat_val As Long)
        End Declare

        Dim As String pipecom_buffer
        Dim As _Offset stream

        Dim buffer As String * 4096
        If _FileExists("pipestderr") Then
        Kill "pipestderr"
        End If
        stream = popen(cmd + " 2>pipestderr", "r")
        If stream Then
        While feof(stream) = 0
        If fgets(buffer, 4096, stream) <> "" And feof(stream) = 0 Then
        stdout = stdout + Mid$(buffer, 1, InStr(buffer, Chr$(0)) - 1)
        End If
        Wend
        Dim As Long status, exit_code
        status = pclose(stream)
        exit_code = WEXITSTATUS(status)
        If _FileExists("pipestderr") Then
        Dim As Integer errfile
        errfile = FreeFile
        Open "pipestderr" For Binary As #errfile
        If LOF(errfile) > 0 Then
        stderr = Space$(LOF(errfile))
        Get #errfile, , stderr
        End If
        Close #errfile
        Kill "pipestderr"
        End If
        pipecom = exit_code
        Else
        pipecom = -1
        End If
    $END IF
END FUNCTION

FUNCTION pipecom_lite$ (cmd AS STRING)
    DIM AS LONG a
    DIM AS STRING stdout, stderr
    a = pipecom(cmd, stdout, stderr)
    IF stderr <> "" THEN
        pipecom_lite = stderr
    ELSE
        pipecom_lite = stdout
    END IF
END FUNCTION

