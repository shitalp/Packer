import json
import boto3
from datetime import datetime

def lambda_handler(event, context):
    # Retrieve the list of instances in the ASG
    autoscaling = boto3.client('autoscaling')
    response = autoscaling.describe_auto_scaling_groups(AutoScalingGroupNames=['test-asg'])
    instances = response['AutoScalingGroups'][0]['Instances']

    # Create AMI for the first running instance in the ASG
    if instances:
        instance_id = instances[0]['InstanceId']
        ami_name = f'AMI for instance {datetime.now().strftime("%Y-%m-%d-%H-%M-%S")}'
        response = create_ami(instance_id, ami_name)
        ami_id = response['ImageId']
        print(f'Created AMI: {ami_id}')
    else:
        print('No running instances found in the ASG')

def create_ami(instance_id, ami_name):
    # Create AMI with a unique name
    ec2 = boto3.client('ec2')
    response = ec2.create_image(
        InstanceId=instance_id,
        Name=ami_name,
        Description='Automatically created AMI',
        NoReboot=True
    )
    ami_id = response['ImageId']
    
    # Add the name tag to the AMI
    ec2.create_tags(
        Resources=[ami_id],
        Tags=[
            {
                'Key': 'Name',
                'Value': ami_name
            }
        ]
    )
    
    return response

