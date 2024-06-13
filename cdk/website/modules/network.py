from aws_cdk import Stack, aws_ec2 as ec2, Fn, CfnTag

class Network:
    def __init__(
        self,
        stack: Stack,
        prefix: str,
        vpc_cirdr_block: str,
        subnets_cidr_blocks: list[str],
    ) -> None:
        self.vpc = ec2.CfnVPC(
            stack,
            f"{prefix}vpc",
            cidr_block=vpc_cirdr_block,
            tags=[CfnTag(key="Name", value=f"{prefix}vpc")],
        )

        igw = ec2.CfnInternetGateway(stack, f"{prefix}igw")

        ec2.CfnVPCGatewayAttachment(
            stack,
            f"{prefix}igwattachment",
            vpc_id=self.vpc.attr_vpc_id,
            internet_gateway_id=igw.attr_internet_gateway_id,
        )

        route_table = ec2.CfnRouteTable(
            stack, f"{prefix}routetable", vpc_id=self.vpc.attr_vpc_id
        )

        ec2.CfnRoute(
            stack,
            f"{prefix}internetroute",
            route_table_id=route_table.attr_route_table_id,
            gateway_id=igw.attr_internet_gateway_id,
            destination_cidr_block="0.0.0.0/0",
        )

        self.subnets = []
        max_azs = 3
        for index, block in enumerate(subnets_cidr_blocks):
            az = Fn.select(index % max_azs, Fn.get_azs())
            subnet = ec2.CfnSubnet(
                stack,
                f"{prefix}subnet" + str(index),
                availability_zone=az,
                vpc_id=self.vpc.attr_vpc_id,
                cidr_block=block,
                tags=[CfnTag(key="Name", value=f"{prefix}subnet-" + str(index))],
            )
            ec2.CfnSubnetRouteTableAssociation(
                stack,
                f"{prefix}rtassociation" + str(index),
                route_table_id=route_table.attr_route_table_id,
                subnet_id=subnet.attr_subnet_id,
            )
            self.subnets.append(subnet)

        self.security_group = ec2.CfnSecurityGroup(
            stack,
            f"{prefix}sg",
            group_name=f"{prefix}allow-ssh-http",
            group_description=f"{prefix}allow-ssh-http",
            vpc_id=self.vpc.attr_vpc_id,
            security_group_ingress=[
                ec2.CfnSecurityGroup.IngressProperty(
                    cidr_ip="0.0.0.0/0",
                    from_port=22,
                    to_port=22,
                    ip_protocol="tcp",
                    description="Allow SSH",
                ),
                ec2.CfnSecurityGroup.IngressProperty(
                    cidr_ip="0.0.0.0/0",
                    from_port=80,
                    to_port=80,
                    ip_protocol="tcp",
                    description="Allow HTTP",
                )
            ],
            security_group_egress=[
                ec2.CfnSecurityGroup.EgressProperty(
                    cidr_ip="0.0.0.0/0",
                    ip_protocol="-1",
                    description="Allow Egress",
                )
            ]
        )

