@echo off
setlocal enabledelayedexpansion

REM Load AWS credentials from environment variables
set AWS_ACCESS_KEY_ID=%AWS_ACCESS_KEY_ID%
set AWS_SECRET_ACCESS_KEY=%AWS_SECRET_ACCESS_KEY%
set AWS_SESSION_TOKEN=%AWS_SESSION_TOKEN%

REM Prompt user for environment
set /p env_choice="Enter the environment (dev, tst, prd): "

REM Validate user input
if /i "%env_choice%"=="dev" (
    set ACCOUNT_ID_VAR=DEV_ACCOUNT_ID
    set EMAIL_VAR=DEV_EMAIL
    set ROLE_ARN_VAR=DEV_ROLE_ARN
    set STACK_NAME_VAR=STACK_NAME
) else if /i "%env_choice%"=="tst" (
    set ACCOUNT_ID_VAR=TST_ACCOUNT_ID
    set EMAIL_VAR=TST_EMAIL
    set ROLE_ARN_VAR=TST_ROLE_ARN
    set STACK_NAME_VAR=STACK_NAME
) else if /i "%env_choice%"=="prd" (
    set ACCOUNT_ID_VAR=PRD_ACCOUNT_ID
    set EMAIL_VAR=PRD_EMAIL
    set ROLE_ARN_VAR=PRD_ROLE_ARN
    set STACK_NAME_VAR=STACK_NAME
) else (
    echo Invalid environment choice. Please enter "dev", "tst", or "prd".
    exit /b 1
)

REM Load environment variables from .env file
for /f "tokens=1,2 delims==" %%i in ('type .env') do (
    set %%i=%%j
)

REM Set selected environment variables
set ACCOUNT_ID=!%ACCOUNT_ID_VAR%!
set EMAIL=!%EMAIL_VAR%!
set ROLE_ARN=!%ROLE_ARN_VAR%!
set STACK_NAME=!%STACK_NAME_VAR%!

REM Debugging output
echo Environment: %env_choice%
echo Account ID: !ACCOUNT_ID!
echo Email: !EMAIL!
echo Role ARN: !ROLE_ARN!
echo Stack Name: !STACK_NAME!

REM Check if CloudFormation stack exists
aws cloudformation describe-stacks --stack-name "%STACK_NAME%-%env_choice%" --region eu-central-1 >nul 2>&1
if %errorlevel% neq 0 (
    REM Run CloudFormation stack creation if it doesn't exist
    echo CloudFormation stack does not exist. Creating stack...
    aws cloudformation create-stack --stack-name "%STACK_NAME%-%env_choice%" --template-body file://cloud_formation/terraform_backend.yml --region eu-central-1 --capabilities CAPABILITY_NAMED_IAM --parameters ^
      ParameterKey=EnvLabel,ParameterValue=%env_choice% ^
      ParameterKey=AccId,ParameterValue=!ACCOUNT_ID!

    REM Wait for the CloudFormation stack creation to complete
    echo Waiting for CloudFormation stack creation to complete...
    set wait_time=30

    :wait_loop
    timeout /T 30
    aws cloudformation describe-stacks --stack-name "%STACK_NAME%-%env_choice%" --region eu-central-1 --query "Stacks[0].StackStatus" --output text > stack_status.txt
    set /p stack_status=<stack_status.txt
    echo Stack status is: !stack_status!

    if "!stack_status!"=="CREATE_IN_PROGRESS" (
        echo Stack creation still in progress...
        goto wait_loop
    ) else if "!stack_status!"=="CREATE_COMPLETE" (
        echo CloudFormation stack creation completed successfully.
    ) else (
        echo CloudFormation stack creation failed with status: !stack_status!
        exit /b 1
    )
) else (
    echo CloudFormation stack already exists.
)

REM Change to the terraform directory
cd .\terraform\

REM Check if Terraform workspace exists and select it
terraform workspace list | findstr /r "\<%env_choice%\>" >nul
if %errorlevel% neq 0 (
    terraform workspace new %env_choice%
)
terraform workspace select %env_choice%

REM Check if Terraform resources are already applied
terraform plan -detailed-exitcode >nul 2>&1
if %errorlevel% neq 2 (
    echo Terraform resources are already applied.
    goto serverless_batch_file
) else (
    REM Initialize Terraform
    terraform init -backend-config=env/backend_s3_%env_choice%.hcl

    REM Run Terraform apply commands
    terraform apply -auto-approve

    REM Check if Terraform succeeded
    if errorlevel 1 (
        echo Terraform apply failed
        exit /b 1
    ) else (
        echo Terraform apply succeeded
        goto serverless_batch_file
    )
)

:serverless_batch_file
REM Call the Serverless deployment script
cd ..
cd services/demo

call serverless_deploy.bat

endlocal
