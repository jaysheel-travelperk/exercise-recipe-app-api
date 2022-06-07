FROM python:3.9-alpine3.13
LABEL maintainer="jaysheel"

# Tell python, do not buffer the output
# O/P from python is printed directly to the console
# Avoid delays of messaging getting delivered from python
ENV PTHONUNBUFFERED 1

# Copy from project to docker container (COPY SRC DST)
COPY ./requirements.txt /tmp/requirements.txt
COPY ./requirements.dev.txt /tmp/requirements.dev.txt
COPY ./app  /app

# working directory, default directory from where all commands are executed
# location of django proejcts synced to
WORKDIR /app

# Expose port 8000 from container to machine
EXPOSE 8000

# Runs this command on the alpine image (first line) when we are building our image
# NOTE multiple run command will create a new layer for every single command
## Avoid so that image is light-weight
# -m venv /py --> Virtual env to store our dependencies  --> not much overhead and avoid conflicts
# --upgrade pip --> Upgrade pip inside virtual env
# requirements --> Install our requirements inside virtual env
# -rf /tmp --> remove tmp directory (keeping image light-weight)
# adduser --> do not run as root user, adding new user without full privilidges for security purposes
ARG DEV=false
RUN python -m venv /py && \
    /py/bin/pip install --upgrade pip && \
    /py/bin/pip install -r /tmp/requirements.txt && \
    if [ $DEV = "true" ]; \
        then /py/bin/pip install -r /tmp/requirements.dev.txt ; \
    fi && \
    rm -rf /tmp && \
    adduser \
        --disabled-password \
        --no-create-home \
        django-user

# Update path inside the container to add python venv
ENV PATH="/py/bin:$PATH"

# Should be the last line
# User we are switching to
# Upto here we were root
USER django-user
