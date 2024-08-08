from aws_cdk import (
    Stack,
)
from constructs import Construct
from modules.network import Network
from modules.cluster import Cluster

class WebsiteStack(Stack):

    def __init__(self, scope: Construct, construct_id: str, prefix: str, **kwargs) -> None:
        super().__init__(scope, construct_id, **kwargs)

        network = Network(
            self,
            prefix=prefix,
            vpc_cirdr_block="10.0.0.0/16",
            subnets_cidr_blocks=["10.0.0.0/24","10.0.1.0/24"]
        )

        f = open("website/user_data.sh", "r")
        user_data = f.read()
        f.close()

        Cluster(
            self,
            prefix=prefix,
            user_data=user_data,
            security_group_ids=[network.security_group.attr_group_id],
            desired_capacity=2,
            min_size=1,
            max_size=3,
            subnet_ids=[subnet.attr_subnet_id for subnet in network.subnets],
            vpc_id=network.vpc.attr_vpc_id,
            scale_in_adjustment=-1,
            scale_in_cooldown=60,
            scale_in_threshold=20,
            scale_out_adjustment=1,
            scale_out_cooldown=60,
            scale_out_threshold=70
        )