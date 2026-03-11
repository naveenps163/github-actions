#!/bin/bash
# Usage: ./manage-ec2.sh <action> [count_or_instance_id]
# Example:
# ./manage-ec2.sh create 2
# ./manage-ec2.sh stop i-0123456789abcdef0
# ./manage-ec2.sh terminate i-0123456789abcdef0

ACTION=$1
INPUT=$2

if [[ "$ACTION" == "create" ]]; then
    if [[ -z "$INPUT" ]]; then
        echo "Please provide number of instances to create."
        exit 1
    fi
    COUNT=$INPUT
    echo "Creating $COUNT EC2 instance(s)..."
    for i in $(seq 1 $COUNT); do
        INSTANCE_ID=$(aws ec2 run-instances \
            --image-id ami-03f4878755434977f \
            --count 1 \
            --instance-type t2.micro \
            --tag-specifications "ResourceType=instance,Tags=[{Key=Name,Value=github-actions-ec2-$i}]" \
            --query 'Instances[0].InstanceId' --output text)
        echo "Created EC2 Instance: $INSTANCE_ID"
    done

elif [[ "$ACTION" == "stop" ]]; then
    echo "Listing running EC2 instances..."
    aws ec2 describe-instances \
        --filters "Name=instance-state-name,Values=running" \
        --query "Reservations[*].Instances[*].[InstanceId,Tags[?Key=='Name'].Value | [0]]" \
        --output table

    if [[ -z "$INPUT" ]]; then
        echo "Please provide instance ID to stop."
        exit 1
    fi
    echo "Stopping EC2 instance $INPUT..."
    aws ec2 stop-instances --instance-ids "$INPUT"

elif [[ "$ACTION" == "terminate" ]]; then
    echo "Listing running EC2 instances..."
    aws ec2 describe-instances \
        --filters "Name=instance-state-name,Values=running,stopped" \
        --query "Reservations[*].Instances[*].[InstanceId,Tags[?Key=='Name'].Value | [0]]" \
        --output table

    if [[ -z "$INPUT" ]]; then
        echo "Please provide instance ID to terminate."
        exit 1
    fi
    echo "Terminating EC2 instance $INPUT..."
    aws ec2 terminate-instances --instance-ids "$INPUT"

else
    echo "Invalid action: $ACTION. Use create | stop | terminate."
    exit 1
fi