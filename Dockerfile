### specify trident release version e.g. 20.07.0
ARG TRIDENT_VERSION
FROM bitnami/kubectl:1.19
ARG TRIDENT_VERSION
RUN if [ "$TRIDENT_VERSION" = "" ] ; then TRIDENT_VERSION=20.10.1 ; fi
RUN echo $TRIDENT_VERSION
RUN if [ "$TRIDENT_VERSION" = "" ] ; then TRIDENT_VERSION=20.10.1 ; fi \
  && cd /opt \
  && wget https://github.com/NetApp/trident/releases/download/v${TRIDENT_VERSION}/trident-installer-${TRIDENT_VERSION}.tar.gz \
  && tar -xf trident-installer-${TRIDENT_VERSION}.tar.gz
