@echo off

rem Create folders
rm -rf res
mkdir res\pak_src
mkdir res\pak_src\images
mkdir res\pak_src\sounds
mkdir res\pak_src\spritepack
mkdir res\pak_src\fonts
mkdir res\pak_src\shaders

rem Pack stage resouces that don't need more processing
cp -r res_src/sounds/*.wav res/pak_src/sounds
cp -r res_src/sounds/*.ogg res/pak_src/sounds

rem Copy all images, premult alpha, and create mipmaps
cp -r res_src/images/* res/pak_src/images
gtool premultalpha res/pak_src/images
gtool mipmap res/pak_src/images

rem Create pixel font by splitting a point image into glyphs
mkdir res_src\spritepack\sprites\fonts
mkdir res_src\spritepack\sprites\fonts\expire
gtool spritesplit res_src/fonts/expire.png 9 9 glyph_ res_src/spritepack/sprites/fonts/expire

rem Spritepack the pixel assets including the font
gtool spritepack res_src/spritepack/spritepack.sp res/pak_src/spritepack
gtool premultalpha res/pak_src/spritepack

rem Clean up the pixel font glyph images after packing
rm -rf res_src/spritepack/sprites/fonts

rem Compile shaders
fxc /T fx_2_0 /nologo /E main /Fo"res/pak_src/shaders/retro.fxo" "res_src/shaders/retro.fx" && echo.

rem Pack everything
gtool resourcepack res/pak_src res/res.pak
