jai src/build.jai -release -exe piotr -output_path ..

if exist "deploy\windows" rmdir /s /q deploy\windows

if not exist "deploy" mkdir deploy
if not exist "deploy\windows" mkdir deploy\windows
if not exist "deploy\windows\res" mkdir deploy\windows\res

xcopy piotr.exe deploy\windows\ /Y
xcopy SDL2.dll deploy\windows\ /Y
xcopy res deploy\windows\res\ /E /Y
