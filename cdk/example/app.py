#!/usr/bin/env python3
import os

import aws_cdk as cdk

from example.example_stack import ExampleStack


app = cdk.App()
ExampleStack(app, "fc-iac-cdk-test")
ExampleStack(app, "fc-iac-cdk-test-2")

app.synth()
