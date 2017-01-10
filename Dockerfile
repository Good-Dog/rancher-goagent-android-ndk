FROM openjdk:8-jre-alpine
MAINTAINER Albert Tavares de Almeida <alberttava@gmail.com>

# Set environment
ENV GOCD_VERSION=16.12.0 \
  GOCD_RELEASE=go-agent \
  GOCD_REVISION=4352 \
  GOCD_HOME=/opt/go-agent \
  PATH=$GOCD_HOME:$PATH \
  USER_HOME=/root

ENV ANDROID_HOME /opt/android-sdk-linux

ENV PATH $PATH:$ANDROID_HOME/tools
ENV PATH $PATH:$ANDROID_HOME/platform-tools

ENV ANDROID_SDK_ZIP http://dl.google.com/android/android-sdk_r24.4.1-linux.tgz

ENV GOCD_REPO=https://download.go.cd/binaries/${GOCD_VERSION}-${GOCD_REVISION}/generic \
  GOCD_RELEASE_ARCHIVE=${GOCD_RELEASE}-${GOCD_VERSION}-${GOCD_REVISION}.zip \
  SERVER_WORK_DIR=${GOCD_HOME}/work

# Install and Configure Android
RUN apk add --no-cache curl ca-certificates bash && \
    mkdir -p /opt && curl -L $ANDROID_SDK_ZIP | tar zxv -C /opt

RUN echo "y" | android update sdk -u -a -t tools,platform-tools,extra-android-support,extra-android-m2repository,extra-google-google_play_services,extra-google-m2repository,extra-google-analytics_sdk_v2

ARG ANDROID_BUILD_TOOLS_VERSION=25.0.2
ARG ANDROID_APIS="android-10,android-15,android-16,android-17,android-18,android-19,android-20,android-21,android-22,android-23,android-24,android-25"

RUN echo "y" | android update sdk -u -a -t build-tools-${ANDROID_BUILD_TOOLS_VERSION},${ANDROID_APIS}

# Install and configure gocd
RUN apk add --no-cache --update git curl bash openssh ca-certificates && rm -rf /var/cache/apk/* \
  && mkdir /var/log/go-agent /var/run/go-agent \
  && cd /opt && curl -sSL ${GOCD_REPO}/${GOCD_RELEASE_ARCHIVE} -O && unzip ${GOCD_RELEASE_ARCHIVE} && rm ${GOCD_RELEASE_ARCHIVE} \
  && mv /opt/${GOCD_RELEASE}-${GOCD_VERSION} ${GOCD_HOME} \
  && chmod 774 ${GOCD_HOME}/*.sh \
  && mkdir -p ${GOCD_HOME}/work

# Add docker-entrypoint script
ADD docker-entrypoint.sh /usr/bin/docker-entrypoint.sh
RUN chmod +x /usr/bin/docker-entrypoint.sh

WORKDIR ${GOCD_HOME}

ENTRYPOINT ["/usr/bin/docker-entrypoint.sh"]
