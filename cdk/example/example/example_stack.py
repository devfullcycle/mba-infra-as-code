from aws_cdk import (
    Stack,
    CfnOutput,
    aws_s3 as s3
)
from constructs import Construct

class ExampleStack(Stack):

    def __init__(self, scope: Construct, construct_id: str, **kwargs) -> None:
        super().__init__(scope, construct_id, **kwargs)

        bucket = s3.Bucket(
            self,
            "MyS3Bucket",
            bucket_name=construct_id + "-bucket",
            versioned=True
        )

        CfnOutput(
            self,
            "BucketName",
            value=bucket.bucket_name,
            description="Name of the S3 bucket"
        )

