from setuptools import setup, find_packages

setup(
    name="project",
    version="0.1.0",
    description="Modular ML and Data Engineering code for Azure Databricks projects",
    author="Your Name",
    author_email="your.email@example.com",
    packages=find_packages(where="src"),
    package_dir={"": "src"},
    install_requires=[
        "pandas",
        "scikit-learn",
        "mlflow",
        "pyspark>=3.3.0"
    ],
    classifiers=[
        "Programming Language :: Python :: 3",
        "License :: OSI Approved :: Apache Software License",
        "Operating System :: OS Independent",
    ],
    python_requires=">=3.8",
)