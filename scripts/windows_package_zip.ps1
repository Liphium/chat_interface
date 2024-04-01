flutter build windows --release
cd ..\build\windows\x64\runner\Release
Compress-Archive -Path .\* -DestinationPath "$HOME\Downloads\windows.zip"