#!/usr/bin/env python3

from aws_cdk import core

from cdk_eks_python.cdk_eks_python_stack import CdkEksPythonStack


app = core.App()
CdkEksPythonStack(app, "cdk-eks-python")

app.synth()
