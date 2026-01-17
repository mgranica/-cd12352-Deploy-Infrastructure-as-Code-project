#!/bin/sh
# Automatic Script for Cloud Formation templates
#
# Parameters
#   $1: Execution mode. Valid values: deploy, delete, preview
#   $2: Region
#   $3: Name of the CloudFormation stack
#   $4: Path to the CloudFormation template file
#   $5: Path to the parameter file (JSON format)

# Usage example
#   ./run.sh deploy us-east-1 UdagramProject udagram.yml udagram-parameters.json
#   ./run.sh delete us-east-1 UdagramProject udagram.yml udagram-parameters.json
#   ./run.sh preview us-east-1 UdagramProject udagram.yml udagram-parameters.json

# Validate parameters
if [[ $1 != "deploy" && $1 != "delete" && $1 != "preview" ]]; then
    echo "Invalid execution mode. Valid values are: deploy, delete, preview"
    exit 1
fi

EXECUTION_MODE=$1
REGION=$2
STACK_NAME=$3
TEMPLATE_FILE=$4
PARAMETER_FILE=$5


# Execute CloudFormation command
if [ $EXECUTION_MODE == "deploy" ]
then
    aws cloudformation deploy \
        --stack-name $STACK_NAME \
        --template-file $TEMPLATE_FILE \
        --parameter-overrides file://$PARAMETER_FILE \
        --capabilities CAPABILITY_NAMED_IAM \
        --region $REGION
fi

if [ $EXECUTION_MODE == "delete" ]
then
    aws cloudformation delete-stack \
        --region $REGION \
        --stack-name $STACK_NAME
fi

if [ $EXECUTION_MODE == "preview" ]
then
    aws cloudformation deploy \
        --stack-name $STACK_NAME \
        --template-file $TEMPLATE_FILE \
        --parameter-overrides file://$PARAMETER_FILE \
        --region $REGION \
        --capabilities CAPABILITY_NAMED_IAM \
        --no-execute-changeset
fi
