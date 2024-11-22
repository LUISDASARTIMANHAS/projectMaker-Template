@ECHO OFF
:: Leitura do versao a partir do arquivo info.json
for /f "tokens=2 delims=:," %%a in ('type info.json ^| findstr /C:"\"version\""') do (
    set "versao=%%~a"
)

:: Remove espaços em branco ao redor do versao
set "versao=%versao: =%"
set "versao=%versao:~1,-1%"

:: Verifica se o versao foi obtido corretamente
if "%versao%"=="" (
    echo Erro: Falha ao obter o nome do arquivo info.json.
    exit /b 1
)
:: =============================================
:: Leitura do nome a partir do arquivo info.json
for /f "tokens=2 delims=:," %%a in ('type info.json ^| findstr /C:"\"name\""') do (
    set "fileName=%%~a"
)

:: Remove espaços em branco ao redor do nome
set "fileName=%fileName: =%"
set "fileName=%fileName:~1,-1%"

:: Verifica se o nome foi obtido corretamente
if "%fileName%"=="" (
    echo Erro: Falha ao obter o nome do arquivo info.json.
    exit /b 1
)
set fullFileName=%fileName%.V%versao%

if not exist "rascunho" (
    mkdir "rascunho"
)

gcc -Wall -g3 -Wextra -static -static-libgcc -static-libstdc++ "rascunho/%fileName%.c" -o "builds/rascunho.exe"

@REM verifica se a build foi feita com sucesso
if not exist "builds/rascunho.exe" (
    echo.
    echo.
    echo nao foi possivel gerar a build rascunho/%fileName%
    pause
    exit /b 1
)

if not exist "builds" (
    mkdir "builds"
)
if not exist "zip" (
    mkdir "zip"
)

if exist "builds/debug.exe" (
   del "builds/debug.exe"
)
gcc -Wall -g3 -Wextra -static -static-libgcc -static-libstdc++ %fileName%.c -o "builds/debug.exe"

gcc -Wall -g3 -Wextra -static -static-libgcc -static-libstdc++ %fileName%.c -o "builds/%fullFileName%.exe"

@REM verifica se a build foi feita com sucesso 
if not exist "builds/%fullFileName%.exe" (
    echo.
    echo.
    echo nao foi possivel gerar a build %fileName%
    pause
    exit /b 1
)

tar -a -c -f "zip/%fullFileName%.zip" *data *builds *rascunho *.pdf *.h *.c *.c functions.c *.cmd *.md

msg * /v /w %fullFileName%.exe foi compilado!

start "RUN" "builds/%fullFileName%.exe"

start "autoGit" "autoGit.cmd"
