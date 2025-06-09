@echo off
color 6
title Installing Ludum Engine Components

echo.
echo Installing Ludum Engine Haxe Components
echo --------------------------------------
echo Requirements: Haxe (4.2.5 or newer), Git
echo.
timeout /t 5 /nobreak >nul
cls

:: === Additional Tools ===
color 6
echo.
echo Visual Studio 2019 is required.
echo VS Code is optional.
echo.
timeout /t 5 /nobreak >nul
cls

:: === Install HMM ===
color 2
echo Installing Haxe Module Manager (HMM)...
haxelib --global install hmm
cls

:: === Version Setup ===
color 6
echo Installing Ludum Engine Haxe Libraries
cd ..
haxelib --global run hmm install

:: === Done ===
cls
color 6
echo.
echo Setup Complete!
echo You can now build the engine.
echo.
timeout /t 3 /nobreak >nul 
pause
