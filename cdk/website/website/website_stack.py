from aws_cdk import (
    Stack,
)
from constructs import Construct
from modules.network import Network

class WebsiteStack(Stack):

    def __init__(self, scope: Construct, construct_id: str, prefix: str, **kwargs) -> None:
        super().__init__(scope, construct_id, **kwargs)

        network = Network(
            self,
            prefix=prefix,
            vpc_cirdr_block="10.0.0.0/16",
            subnets_cidr_blocks=["10.0.0.0/24","10.0.1.0/24"]
        )