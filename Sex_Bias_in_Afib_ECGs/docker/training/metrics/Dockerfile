# Use an official Python runtime as a parent image
FROM python:3.10-buster

# Set the working directory to /app
WORKDIR /app

# Copy the requirements.txt into the container at /app
COPY [ "requirements.txt", "/app/" ]

# Install any needed packages specified in requirements.txt
RUN apt-get update && apt-get -y install procps
RUN pip install --upgrade pip
RUN rm -rf /var/lib/apt/lists/*
RUN pip install --no-cache-dir --trusted-host pypi.python.org -r requirements.txt

# Copy the current directory contents into the container at /app
COPY . /app

#CMD ["python","training_dataset_test.py"]
#ENTRYPOINT ["python"]

# Make the entry point training_dataset_validation.py
# docker run -v /home/cfurtick/Desktop/Projects/Severo\ Ochoa/Sex\ Bias\ in\ Afib\ ECGs/input_data:/input_data/ -v /home/cfurtick/Desktop/Projects/Severo\ Ochoa/Sex\ Bias\ in\ Afib\ ECGs/metrics_output:/metrics_output baiha_dataset_metrics:v1 -i /input_data/Nuubo_dataset.csv -com BAIHA -c training_dataset -p Nuubo_dataset -o /metrics_output/assessment.json