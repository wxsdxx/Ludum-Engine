@echo off
color 6
title Installing Psych Engine 0.6.3 Components

echo.
echo Installing Psych 0.6.3 Haxe Components
echo --------------------------------------
echo Requirements: Haxe 4.2.5, Git
echo.
timeout /t 5 /nobreak >nul
cls

:: === Core Libraries ===
color 2
echo Installing Core HaxeLib Components...
haxelib install lime
haxelib install openfl
haxelib install flixel
haxelib run lime setup flixel
haxelib run lime setup
haxelib install flixel-tools
haxelib run flixel-tools setup
haxelib install flixel-addons
haxelib install flixel-ui
haxelib install hscript
haxelib install newgrounds
cls

:: === Git Libraries ===
echo Installing Git-Based Components...
haxelib git polymod https://github.com/larsiusprime/polymod.git
haxelib git discord_rpc https://github.com/Aidan63/linc_discord-rpc
haxelib git flixel-addons https://github.com/HaxeFlixel/flixel-addons
cls

:: === Additional Tools ===
color 6
echo.
echo Visual Studio 2019 is required.
echo VS Code is optional.
echo.
timeout /t 5 /nobreak >nul
cls

color 2
echo Installing Additional HaxeLibs...
haxelib install hxCodec
haxelib install Brewscript
haxelib git hxCodec https://github.com/polybiusproxy/hxCodec.git
haxelib git linc_luajit https://github.com/superpowers04/linc_luajit
haxelib git flxanimate https://github.com/ShadowMario/flxanimate dev
cls

:: === Version Setup ===
color 6
echo.
echo Setting Up Specific Versions...
echo.
timeout /t 5 /nobreak >nul
cls

color 2
haxelib set flixel-addons 3.0.2
haxelib set flixel-demos 2.9.0
haxelib set flixel-templates 2.6.6
haxelib set flixel-tools 1.5.1
haxelib set flixel-ui 2.5.0
haxelib set flixel 5.2.2
haxelib set flxanimate 3.0.4
haxelib set hscript 2.5.0
haxelib set lime-samples 7.0.0
haxelib set lime 8.0.1
haxelib set openfl 9.2.1
cls

:: === Bug Fixing ===
color 6
echo.
echo Fixing Bugs...
echo.
timeout /t 5 /nobreak >nul
cls

color 2
echo Fixing VLC Error...
echo.
haxelib remove hxCodec
haxelib install hxCodec 2.5.1
echo.
echo Fixing 'updateFramerate' Error...
echo.
haxelib remove flixel
haxelib install flixel 4.11.0
haxelib remove flixel-addons
haxelib install flixel-addons 2.11.0
haxelib remove flixel-ui
haxelib install flixel-ui 2.4.0
echo.
echo Fixing No Colored Credits...
echo.
haxelib remove hxcpp
haxelib install hxcpp 4.2.1

:: === Done ===
cls
color 6
echo.
echo Setup Complete!
echo You can now build the engine.
echo.
timeout /t 3 /nobreak >nul 
pause
