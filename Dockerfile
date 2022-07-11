FROM perl:5.30.3-slim-bullseye
LABEL maintainer="Dave Code Ruiz"
# Set app dir
WORKDIR /app
#Update system and install packages
RUN apt-get update && apt-get install -yq \
        build-essential \
        cpanminus
# Install cpan modules
RUN cpanm Data::Dumper JSON Net::MQTT::Simple JSON::PP::Boolean
# Copy perl script
COPY ./dvralarmserver.pl /app
# Copy perl script
COPY ./sofiactl.pl /app
# Copy config
COPY ./config.json /app/config/config.json
# Set Entrypoint
CMD [ "perl", "/app/dvralarmserver.pl" ]
