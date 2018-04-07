# Continuous deployment of the Elm medical client.
#
# Build the image and run the container to produce 
# the compiled JS in the dist folder.
#
# Build the image:
#   cd client/elm/medical
#   docker build -f Dockerfile -t midwife-emr-compile-medical-client --no-cache .
#
# Run the container in dev mode (run from the top of the Midwife-EMR project):
#   docker run --init --name=midwife-emr-compile-medical-client --rm -v $(pwd)/client/elm/medical:/opt/src -v $(pwd)/static/js:/opt/dist midwife-emr-compile-medical-client:latest
#
# Override the default settings in order to generate a production build:
#   docker run --init --name=midwife-emr-compile-medical-client --rm -v $(pwd)/client/elm/medical:/opt/src -v $(pwd)/static/js:/opt/dist midwife-emr-compile-medical-client:latest webpack --config webpack.prod.js
#
# Run tests
#   - First make sure that this container is running per above in dev mode.
#   - docker container exec -it midwife-emr-compile-medical-client elm-test
#
# To stop the container:
#   Ctrl-C
FROM node:6.11.3 as build

WORKDIR /opt

RUN npm install elm@0.18.0 elm-test@0.18.0 \
    webpack@4.5.0 elm-webpack-loader@4.5.0 mini-css-extract-plugin@0.4.0 \
    css-loader@0.28.11 style-loader@0.20.3 url-loader@1.0.1 file-loader@1.1.11 \
    uglifyjs-webpack-plugin@1.2.4 underscore@1.8.3 socket.io@2.1.0

RUN npm install --save-dev webpack-merge webpack-cli

ENV PATH /opt/node_modules/.bin:$PATH

WORKDIR /opt/src

RUN ["elm", "package", "install", "-y"]

# Defaults to watching for development.
CMD ["webpack", "--config", "webpack.dev.js", "--watch"]

VOLUME ["/opt/src"]
VOLUME ["/opt/dist"]
