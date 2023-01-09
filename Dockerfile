ARG BUILD_IMAGE=debian:buster-slim
ARG RUN_IMAGE=gcr.io/distroless/python3-debian10

FROM $BUILD_IMAGE AS build
RUN apt-get update && \
    apt-get install --no-install-suggests --no-install-recommends --yes python3-venv gcc libpython3-dev ca-certificates && \
    update-ca-certificates && \
    python3 -m venv /venv && \
    /venv/bin/pip install --upgrade pip
RUN cat /etc/hosts
# Build the virtualenv as a separate step: Only re-execute this step when requirements.txt changes
FROM build AS build-venv
COPY requirements.txt /requirements.txt
RUN /venv/bin/pip install --disable-pip-version-check -r /requirements.txt

FROM build-venv AS test
COPY ./project /app
WORKDIR /app/
RUN /venv/bin/python3 -m pytest --junitxml=report.xml || (touch /app/build/build.failed && echo "There were failing tests!")
RUN rm -Rf /app/tests

# Copy the virtualenv into a distroless image
FROM $RUN_IMAGE
COPY --from=build-venv /venv /venv
COPY --from=build-venv /usr/share/zoneinfo /usr/share/zoneinfo
COPY --from=build-venv /etc/ssl/certs /etc/ssl/certs
#COPY --from=build-venv /etc/nsswitch.conf /etc/nsswitch.conf


COPY ./project /app
WORKDIR /app
EXPOSE 8080
ENTRYPOINT ["/venv/bin/gunicorn", "-b", "0.0.0.0:8080", "main:app"]
# https://iximiuz.com/en/posts/containers-distroless-images/#pitfall-3-no-ca-certs
# https://stackoverflow.com/a/55308819
###@todo mount certs to /etc/ssl/certs
