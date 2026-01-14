from setuptools import setup, find_packages

setup(
    name="slash-python-pkg",
    version="0.2.0",
    packages=find_packages(),
    description="A sample Python package",
    long_description=open("README.md").read(),
    long_description_content_type="text/markdown",
    author="Slash Liu",
    author_email="jingyil@jfrog.com",
    install_requires=[
        "requests>=2.25.1",  # 示例依赖
    ],
    python_requires=">=3.6",
)
