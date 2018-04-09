const webpack = require('webpack');
const MiniCssExtractPlugin = require("mini-css-extract-plugin");
const path = require('path');

const ELM_ADMIN = path.resolve(__dirname, 'src', 'administrator.js');
const BUILD_PATH = path.resolve('/opt', 'dist');

module.exports = {
  entry: {
    'vendor': 'socket.io-client/lib/index.js',
    'app': ELM_ADMIN
  },
  output: {
    path: BUILD_PATH,
    filename: '[name].mwemr-admin-client-bundle.js',
    chunkFilename: '[id].mwemr-admin-client-bundle.js'
  },
  module: {
    rules: [
      { test: /\.elm$/,
        exclude: [/elm-stuff/, /node_modules/],
        use: {
          loader: 'elm-webpack-loader',
          options: {}
        }
      },
      { test: /\.css$/,
        use: [
          MiniCssExtractPlugin.loader,
          "css-loader"
        ]
      },
      { test: /\.woff(2)?(\?v=[0-9]\.[0-9]\.[0-9])?$/,
        loader: "url-loader?limit=10000&minetype=application/font-woff"
      },
      { test: /\.(ttf)(\?v=[0-9]\.[0-9]\.[0-9])?$/,
        loader: "url-loader?limit=10000&mimetype=application/octet-stream"
      },
      { test: /\.(eot)(\?v=[0-9]\.[0-9]\.[0-9])?$/,
        loader: "file-loader"
      },
      { test: /\.(svg)(\?v=[0-9]\.[0-9]\.[0-9])?$/,
        loader: "url-loader?limit=10000&mimetype=image/svg+xml"
      }
    ]
  },
  plugins: [
    new MiniCssExtractPlugin({
      filename: "[name].admin-styles.css",
      chunkFilename: "[id].css"
    })
  ],
  mode: "development"
};
