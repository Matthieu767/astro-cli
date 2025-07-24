from setuptools import find_packages, setup

setup(
    name="bronze_silver_pipeline",
    packages=find_packages(exclude=["bronze_silver_pipeline_tests"]),
    install_requires=[
        "dagster",
        "dagster-cloud"
    ],
    extras_require={"dev": ["dagster-webserver", "pytest"]},
)
