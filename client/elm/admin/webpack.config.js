/* Webpack 2 */
const webpack = require('webpack');
const ExtractTextPlugin = require("extract-text-webpack-plugin");
const path = require('path');

const ELM_ADMIN = path.resolve(__dirname, 'src', 'administrator.js');
const BUILD_PATH = path.resolve('/opt', 'dist');

module.exports = {
  entry: {
    'elm-vendor': 'socket.io-client/lib/index.js',
    administrator: ELM_ADMIN
  },
  output: {
    path: BUILD_PATH,
    filename: '[name].mwemr-bundle.js',
    chunkFilename: '[id].mwemr-bundle.js'
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
        use: ExtractTextPlugin.extract({
          fallback: 'style-loader',
          use: 'css-loader'
        })
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
    new ExtractTextPlugin('[name].styles.css')
  ],
};
