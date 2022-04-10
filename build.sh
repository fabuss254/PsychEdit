echo "Cleanup export folders"
rm -rf exports/linux
rm -rf exports/windows
rm -rf exports/zip

echo "Make a folder to build export"
mkdir exports/linux
mkdir exports/windows
mkdir exports/zip
mkdir exports/zip/source

echo "Copy all sources for executable creation"
cp -r assets exports/zip/source/assets
cp -r src exports/zip/source/src
cp conf-release.lua exports/zip/source/conf.lua
cp main.lua exports/zip/source/main.lua

echo "Zip the whole thing"
cd exports/zip/source
zip -9 -r ../PsychEdit.zip .
cd ../../..

echo "Move to zip folder"
cp exports/zip/PsychEdit.zip exports/zip/PsychEdit.love

echo "Create executable for windows 64 bit"
cat "./exports/love/love.exe" "./exports/zip/PsychEdit.love" > exports/windows/PsychEdit.exe
cp exports/love/SDL2.dll exports/windows/SDL2.dll
cp exports/love/OpenAL32.dll exports/windows/OpenAL32.dll
cp exports/love/love.dll exports/windows/love.dll
cp exports/love/license.txt exports/windows/license.txt
cp exports/love/lua51.dll exports/windows/lua51.dll
cp exports/love/mpg123.dll exports/windows/mpg123.dll
cp exports/love/msvcp120.dll exports/windows/msvcp120.dll
cp exports/love/msvcr120.dll exports/windows/msvcr120.dll
cp exports/love/love.dll exports/windows/love.dll