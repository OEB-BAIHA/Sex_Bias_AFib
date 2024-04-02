# Use an official Python runtime as a parent image
FROM python:3.10-buster

# Set the working directory to /app
WORKDIR /app

# Copy the requirements.txt into the container at /app
COPY ["requirements.txt", "constraints.txt", "/app/"]

# These were suggestions from chatGPT given the errors, but when uncommented, there are still other errors
# The issue is with library versions because it works with 3.7 but not 3.10
# RUN apt-get update && \
#     apt-get install -y libblas-dev liblapack-dev

# RUN apt-get install -y gfortran

# Install any needed packages specified in requirements.txt
RUN apt-get update && apt-get -y install procps && rm -rf /var/lib/apt/lists/* && pip install --no-cache-dir --trusted-host pypi.python.org -r requirements.txt -c constraints.txt

# Copy the current directory contents into the container at /app
COPY . /app