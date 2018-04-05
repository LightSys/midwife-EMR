# Continuous deployment of the Elm medical client.
#
# Build the image and run the container to produce 
# the compiled JS in the dist folder.
#
# Build the image:
#   cd client/elm/medical
#   docker build -f Dockerfile -t midwife-emr-watch-medical-client --no-cache .
#
# Run the container (run from the top of the Midwife-EMR project):
#   docker run --init --name=midwife-emr-watch-medical-client --rm -v $(pwd)/client/elm/medical:/opt/src -v $(pwd)/static/js:/opt/dist midwife-emr-watch-medical-client:latest
#
# Run tests
#   - First make sure that this container is running per above.
#   - docker container exec -it midwife-emr-watch-medical-client elm-test
#
# To stop the container:
#   Ctrl-C
FROM node:6.11.3 as build

WORKDIR /opt
RUN npm install elm@0.18.0 elm-test@0.18.0 \
    webpack@3.11.0 elm-webpack-loader@4.5.0 extract-text-webpack-plugin@3.0.2 \
    css-loader@0.28.11 style-loader@0.20.3 url-loader@1.0.1 file-loader@1.1.11 \
    underscore@1.8.3 socket.io@2.1.0

ENV PATH /opt/node_modules/.bin:$PATH

WORKDIR /opt/src
RUN ["elm", "package", "install", "-y"]

CMD ["webpack", "--watch"]

VOLUME ["/opt/src"]
VOLUME ["/opt/dist"]
