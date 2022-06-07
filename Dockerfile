FROM python:3.9-alpine3.13
LABEL maintainer="jaysheel"

# Tell python, do not buffer the output
# O/P from python is printed directly to the console
# Avoid delays of messaging getting delivered from python
ENV PYTHONUNBUFFERED 1

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

# jpeg-dev is added for handling images
# zlib zlib-dev is needed as dependency for pillow

# create a directory /vol/web/media
# -p create subdirectories

# create static and media directories
# change owner (-R recursively of all sub-dirs)
# chmod django-user can make changes
ARG DEV=false
RUN python -m venv /py && \
    /py/bin/pip install --upgrade pip && \
    apk add --update --no-cache postgresql-client jpeg-dev && \
    apk add --update --no-cache --virtual .tmp-build-deps \
      build-base postgresql-dev musl-dev zlib zlib-dev &&\
    /py/bin/pip install -r /tmp/requirements.txt && \
    if [ $DEV = "true" ]; \
        then /py/bin/pip install -r /tmp/requirements.dev.txt ; \
    fi && \
    rm -rf /tmp && \
    apk del .tmp-build-deps && \
    adduser \
        --disabled-password \
        --no-create-home \
        django-user && \
    mkdir -p /vol/web/media && \
    mkdir -p /vol/web/static && \
    chown -R django-user:django-user /vol && \
    chmod -R 755 /vol

# Update path inside the container to add python venv
ENV PATH="/py/bin:$PATH"

# Should be the last line
# User we are switching to
# Upto here we were root
USER django-user
