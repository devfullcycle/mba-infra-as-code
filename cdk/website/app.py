#!/usr/bin/env python3
import aws_cdk as cdk

from website.website_stack import WebsiteStack


app = cdk.App()
WebsiteStack(app, "DevWebsiteStack", "dev-website-",
             env=cdk.Environment(account="304851244121", region="us-west-2"))
WebsiteStack(app, "ProdWebsiteStack", "prod-website-",
             env=cdk.Environment(account="590183902691", region="us-west-2"))

app.synth()
