flutter build windows --release --dart-define DEBUG_MODE=true --dart-define CHECK_VERSION=false
cd ..\build\windows\x64\runner\Release
Compress-Archive -Path .\* -DestinationPath "$HOME\Downloads\windows.zip" -Force