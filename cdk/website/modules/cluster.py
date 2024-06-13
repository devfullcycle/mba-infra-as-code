from aws_cdk import (
    Stack,
    aws_ec2 as ec2,
    aws_autoscaling as autoscaling,
    aws_cloudwatch as cloudwatch,
    aws_elasticloadbalancingv2 as elbv2,
    Fn,
    CfnTag
)

class Cluster():
    def __init__(
        self,
        stack: Stack,
        prefix: str,
        user_data: str,
        security_group_ids: list,
        desired_capacity: int,
        min_size: int,
        max_size: int,
        subnet_ids: list,
        vpc_id: str,
        scale_in_adjustment: int,
        scale_in_cooldown: int,
        scale_in_threshold: int,
        scale_out_adjustment: int,
        scale_out_cooldown: int,
        scale_out_threshold: int,
    ) -> None:
        launch_template = ec2.CfnLaunchTemplate(
            stack,
            f"{prefix}template",
            launch_template_name=f"{prefix}template",
            launch_template_data=ec2.CfnLaunchTemplate.LaunchTemplateDataProperty(
                image_id="ami-01cd4de4363ab6ee8",
                instance_type="t2.micro",
                user_data=Fn.base64(user_data),
                network_interfaces=[
                    ec2.CfnLaunchTemplate.NetworkInterfaceProperty(
                        associate_public_ip_address=True,
                        groups=security_group_ids,
                        device_index=0
                    )
                ],
                tag_specifications=[
                    ec2.CfnLaunchTemplate.TagSpecificationProperty(
                        resource_type="instance",
                        tags=[CfnTag(key="Name", value=f"{prefix}node")],
                    )
                ],
            ),
        )

        # Target Group
        target_group = elbv2.CfnTargetGroup(
            stack,
            f"{prefix}app-tg",
            name=f"{prefix}app-tg",
            port=80,
            protocol="HTTP",
            vpc_id=vpc_id,
            health_check_enabled=True,
            health_check_interval_seconds=30,
            health_check_path="/",
            health_check_port="traffic-port",
            health_check_protocol="HTTP",
            health_check_timeout_seconds=5,
            healthy_threshold_count=3,
            unhealthy_threshold_count=3,
            matcher=elbv2.CfnTargetGroup.MatcherProperty(http_code="200"),
            tags=[CfnTag(key="Name", value=f"{prefix}app-tg")],
        )

        # Auto Scaling Group
        asg = autoscaling.CfnAutoScalingGroup(
            stack,
            f"{prefix}asg",
            auto_scaling_group_name=f"{prefix}asg",
            desired_capacity=str(desired_capacity),
            min_size=str(min_size),
            max_size=str(max_size),
            vpc_zone_identifier=subnet_ids,
            target_group_arns=[target_group.attr_target_group_arn],
            launch_template=autoscaling.CfnAutoScalingGroup.LaunchTemplateSpecificationProperty(
                launch_template_id=launch_template.ref, version=launch_template.attr_latest_version_number
            ),
        )

         # Auto Scaling Policies
        scale_out_policy = autoscaling.CfnScalingPolicy(
            stack,
            f"{prefix}scale-out",
            auto_scaling_group_name=str(asg.auto_scaling_group_name),
            policy_type="SimpleScaling",
            adjustment_type="ChangeInCapacity",
            scaling_adjustment=scale_out_adjustment,
            cooldown=str(scale_out_cooldown)
        )
        scale_out_policy.add_dependency(asg)

        scale_in_policy = autoscaling.CfnScalingPolicy(
            stack,
            f"{prefix}scale-in",
            auto_scaling_group_name=str(asg.auto_scaling_group_name),
            policy_type="SimpleScaling",
            adjustment_type="ChangeInCapacity",
            scaling_adjustment=scale_in_adjustment,
            cooldown=str(scale_in_cooldown),
        )
        scale_in_policy.add_dependency(asg)


        # CloudWatch Alarms
        cloudwatch.CfnAlarm(
            stack,
            f"{prefix}scale-out-alarm",
            alarm_description="Monitors CPU utilization",
            alarm_actions=[scale_out_policy.ref],
            alarm_name=f"{prefix}scale-out-alarm",
            comparison_operator="GreaterThanOrEqualToThreshold",
            namespace="AWS/EC2",
            metric_name="CPUUtilization",
            threshold=scale_out_threshold,
            statistic="Average",
            evaluation_periods=3,
            period=30,
            dimensions=[
                cloudwatch.CfnAlarm.DimensionProperty(
                    name="AutoScalingGroupName", value=str(asg.auto_scaling_group_name)
                )
            ],
        )

        cloudwatch.CfnAlarm(
            stack,
            f"{prefix}scale-in-alarm",
            alarm_description="Monitors CPU utilization",
            alarm_actions=[scale_in_policy.ref],
            alarm_name=f"{prefix}scale-in-alarm",
            comparison_operator="LessThanOrEqualToThreshold",
            namespace="AWS/EC2",
            metric_name="CPUUtilization",
            threshold=scale_in_threshold,
            statistic="Average",
            evaluation_periods=3,
            period=30,
            dimensions=[
                cloudwatch.CfnAlarm.DimensionProperty(
                    name="AutoScalingGroupName", value=str(asg.auto_scaling_group_name)
                )
            ],
        )

         # Load Balancer
        lb = elbv2.CfnLoadBalancer(
            stack,
            f"{prefix}app-lb",
            name=f"{prefix}app-lb",
            subnets=subnet_ids,
            security_groups=security_group_ids,
            scheme="internet-facing",
            type="application",
            tags=[CfnTag(key="Name", value=f"{prefix}app-lb")],
        )

        # Load Balancer Listener
        elbv2.CfnListener(
            stack,
            f"{prefix}app-lb-listener",
            load_balancer_arn=lb.ref,
            port=80,
            protocol="HTTP",
            default_actions=[
                elbv2.CfnListener.ActionProperty(
                    type="forward", target_group_arn=target_group.ref
                )
            ],
        )

