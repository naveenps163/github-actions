#!/bin/bash

# Usage: ./manage-ec2.sh <action> <value>
# action = create | stop | terminate
# value = number of instances (create) or instance-id (stop/terminate)

ACTION=$1
VALUE=$2

echo "Action: $ACTION"
echo "Input Value: $VALUE"

# Function to list running EC2 instances
list_running_instances() {
    aws ec2 describe-instances \
        --filters "Name=instance-state-name,Values=running" \
        --query "Reservations[*].Instances[*].[InstanceId,Tags[?Key=='Name']|[0].Value,InstanceType,PublicIpAddress]" \
        --output table
}

# Create EC2 instances
if [ "$ACTION" == "create" ]; then
    if [ -z "$VALUE" ]; then
        echo "Please provide number of instances to create."
        exit 1
    fi
    echo "Creating $VALUE EC2 instance(s)..."
    for i in $(seq 1 $VALUE); do
        aws ec2 run-instances \
            --image-id ami-0f58b397bc5c1f2e8 \
            --instance-type t2.micro \
            --count 1 \
            --tag-specifications 'ResourceType=instance,Tags=[{Key=Name,Value=github-actions-ec2}]' \
            --output json
    done
    echo "EC2 instance(s) creation triggered."

# Stop EC2 instances
elif [ "$ACTION" == "stop" ]; then
    echo "Listing running EC2 instances..."
    list_running_instances
    if [ -z "$VALUE" ]; then
        echo "Provide Instance ID to stop via workflow input."
        exit 1
    fi
    echo "Stopping EC2 instance: $VALUE"
    aws ec2 stop-instances --instance-ids $VALUE --output json
    echo "Stop request sent."

# Terminate EC2 instances
elif [ "$ACTION" == "terminate" ]; then
    echo "Listing all EC2 instances..."
    aws ec2 describe-instances \
        --query "Reservations[*].Instances[*].[InstanceId,State.Name,Tags[?Key=='Name']|[0].Value]" \
        --output table
    if [ -z "$VALUE" ]; then
        echo "Provide Instance ID to terminate via workflow input."
        exit 1
    fi
    echo "Terminating EC2 instance: $VALUE"
    aws ec2 terminate-instances --instance-ids $VALUE --output json
    echo "Terminate request sent."

else
    echo "Invalid action. Choose: create | stop | terminate"
    exit 1
fi