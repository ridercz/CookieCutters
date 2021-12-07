@ECHO OFF
SETLOCAL EnableDelayedExpansion

REM -- Configuration
SET OSBS_VERSION=1.0.0
SET OSBS_SCAD="C:\Program Files\OpenSCAD\openscad.com"
SET OSBS_TARGET_FOLDER=.\STL
SET OSBS_TARGET_FORMAT=stl

REM -- Print banner
ECHO ^ _____ _____ _____ _____
ECHO ^|     ^|   __^| __  ^|   __^| OSBS - OpenSCAD Build System version %OSBS_VERSION%
ECHO ^|  ^|  ^|__   ^| __ -^|__   ^| (c) Michal Altair Valasek, 2018 ^| MIT license
ECHO ^|_____^|_____^|_____^|_____^| www.rider.cz ^| github.com/ridercz/OSBS
ECHO.

REM -- Create output folder
IF NOT EXIST %OSBS_TARGET_FOLDER%\NUL (
    ECHO Creating output folder %OSBS_TARGET_FOLDER%...
    MKDIR %OSBS_TARGET_FOLDER%
) ELSE (
    ECHO Deleting files in output %OSBS_TARGET_FOLDER%...
    DEL %OSBS_TARGET_FOLDER%\*.%OSBS_TARGET_FORMAT%
)

REM -- Process all *.scad files
FOR %%I IN (*.scad) DO (
    REM -- Get number of extruders specified in file
    SET OSBS_EC=0
    FIND /i "/* OSBS:build */" "%%I" >NUL && SET OSBS_EC=1
    FIND /i "/* OSBS:build:1E */" "%%I" >NUL && SET OSBS_EC=1
    FIND /i "/* OSBS:build:2E */" "%%I" >NUL && SET OSBS_EC=2
    FIND /i "/* OSBS:build:3E */" "%%I" >NUL && SET OSBS_EC=3
    FIND /i "/* OSBS:build:4E */" "%%I" >NUL && SET OSBS_EC=4
    FIND /i "/* OSBS:build:5E */" "%%I" >NUL && SET OSBS_EC=5
    FIND /i "/* OSBS:build:6E */" "%%I" >NUL && SET OSBS_EC=6
    FIND /i "/* OSBS:build:7E */" "%%I" >NUL && SET OSBS_EC=7
    FIND /i "/* OSBS:build:8E */" "%%I" >NUL && SET OSBS_EC=8
    FIND /i "/* OSBS:build:9E */" "%%I" >NUL && SET OSBS_EC=9
    
    IF !OSBS_EC!==0 (
        REM -- No build instructions present in file
        ECHO Ignoring %%I, no build instructions present
    ) ELSE IF NOT EXIST %%I.vars (
        REM -- Build instructions present, but no something.scad.vars file found
        ECHO Building %%I for !OSBS_EC! extruder(s^):

        REM -- Build all-in-one model
        ECHO ^ ^ %%~nI.%OSBS_TARGET_FORMAT%
        %OSBS_SCAD% -D "osbs_selected_extruder=0" -o "%OSBS_TARGET_FOLDER%\%%~nI.%OSBS_TARGET_FORMAT%" "%%I"

        REM -- Build models for all extruders
        IF !OSBS_EC! GTR 1 FOR /L %%E IN (1,1,!OSBS_EC!) DO (
            ECHO ^ ^ %%~nI-E%%E.%OSBS_TARGET_FORMAT%
            %OSBS_SCAD% -D "osbs_selected_extruder=%%E" -o "%OSBS_TARGET_FOLDER%\%%~nI-E%%E.%OSBS_TARGET_FORMAT%" "%%I"
        )
    ) ELSE (
        REM -- Build instructions present and we have something.scad.vars file
        ECHO Building %%I for !OSBS_EC! extruder(s^) with additional variables:

        REM -- Parse the .vars file; %%V is set name, %%W is code to be added
        FOR /F "eol=# tokens=1* delims=:" %%V IN (%%I.vars) DO (
            ECHO ^ ^ Set %%V:

            REM -- Copy file to working copy ~something.scad and append variable line
            COPY /Y "%%I" "~%%~nI-%%V.scad" > NUL
            ECHO. >> "~%%~nI-%%V.scad"
            ECHO %%W >> "~%%~nI-%%V.scad"

            REM -- Build all-in-one model
            ECHO ^ ^ ^ ^ %%~nI-%%V.%OSBS_TARGET_FORMAT%
            %OSBS_SCAD% -D "osbs_selected_extruder=0" -o "%OSBS_TARGET_FOLDER%\%%~nI-%%V.%OSBS_TARGET_FORMAT%" "~%%~nI-%%V.scad"

            REM -- Build models for all extruders
            IF !OSBS_EC! GTR 1 FOR /L %%E IN (1,1,!OSBS_EC!) DO (
                ECHO ^ ^ ^ ^ %%~nI-%%V-E%%E.%OSBS_TARGET_FORMAT%
                %OSBS_SCAD% -D "osbs_selected_extruder=%%E" -o "%OSBS_TARGET_FOLDER%\%%~nI-%%V-E%%E.%OSBS_TARGET_FORMAT%" "~%%~nI-%%V.scad"
            )

            REM -- Delete working copy of .scad file
            DEL "~%%~nI-%%V.scad"
        )
    )
)