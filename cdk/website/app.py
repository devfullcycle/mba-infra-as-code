#!/usr/bin/env python3
import aws_cdk as cdk

from website.website_stack import WebsiteStack


app = cdk.App()
WebsiteStack(app, "WebsiteStack", "website-")

app.synth()
