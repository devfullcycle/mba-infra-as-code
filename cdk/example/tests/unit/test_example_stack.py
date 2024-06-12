import aws_cdk as core
import aws_cdk.assertions as assertions

from example.example_stack import ExampleStack

# example tests. To run these tests, uncomment this file along with the example
# resource in example/example_stack.py
def test_sqs_queue_created():
    app = core.App()
    stack = ExampleStack(app, "example")
    template = assertions.Template.from_stack(stack)

#     template.has_resource_properties("AWS::SQS::Queue", {
#         "VisibilityTimeout": 300
#     })
