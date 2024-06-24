@echo off
setlocal enabledelayedexpansion

:: Prompt user for environment
set /p env_choice="Enter the environment (dev, tst, prd): "

:: Validate user input
if not "%env_choice%"=="dev" if not "%env_choice%"=="tst" if not "%env_choice%"=="prd" (
    echo Invalid environment choice. Please enter "dev", "tst", or "prd".
    exit /b 1
)

:: Load environment variables from .env file
for /f "tokens=1,2 delims==" %%i in (.env) do (
    set %%i=%%j
)

:: Set AWS environment variables
set AWS_ACCESS_KEY_ID=!AWS_ACCESS_KEY_ID!
set AWS_SECRET_ACCESS_KEY=!AWS_SECRET_ACCESS_KEY!
set AWS_SESSION_TOKEN=!AWS_SESSION_TOKEN!

:: Change to Serverless directory
cd .\services\demo\

:: Debugging output for current directory and environment variables
echo Current directory for Serverless deployment:
cd
echo Environment: %env_choice%

:: Check if current directory is a Serverless service directory
if not exist serverless.yml (
    echo serverless.yml not found in the current directory. Exiting.
    exit /b 1
)


:: Deploy the Serverless function if not already deployed
serverless deploy --stage %env_choice%

:: Check if Serverless deploy succeeded
if %errorlevel% neq 0 (
    echo Serverless deploy failed
    exit /b 1
) else (
    echo Serverless deploy succeeded
)


endlocal
