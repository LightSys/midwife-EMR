/*
 * -------------------------------------------------------------------------------
 * webpack.config.js
 *
 *
 * -------------------------------------------------------------------------------
 */
var webpack = require('webpack');
const ExtractTextPlugin = require('extract-text-webpack-plugin')
var path = require('path');

const CommonsChunkPlugin = webpack.optimize.CommonsChunkPlugin
const OccurenceOrderPlugin = webpack.optimize.OccurenceOrderPlugin

const TOP_PATH = path.resolve(__dirname, 'client', 'js', 'react')
const APP_START = path.resolve(TOP_PATH, 'index.js')
const BUILD_PATH = path.resolve(__dirname, 'static', 'js')
const MODULE_DIRS = ['node_modules', 'bower_components', 'themes']

module.exports = {
  amd: {jQuery: true},
  entry: {
    'vendor': [
      'jquery/dist/jquery.js',
      'bootstrap/dist/js/bootstrap.js',
      'react/react.js',
      'socket.io-client/lib/index.js',
      'react-dom/index.js'
    ],
    'app': APP_START
  },
  resolve: {
    root: __dirname,
    extensions: ['', '.js', '.jsx', '.css'],
    modulesDirectories: MODULE_DIRS
  },
  output: {
    path: BUILD_PATH,
    filename: '[name].mwemr-bundle.js',
    chunkFilename: '[id].mwemr-bundle.js'
  },
  plugins: [
    new OccurenceOrderPlugin(),
    new CommonsChunkPlugin({
      name: 'vendor',
      minChunks: Infinity,
      filename: 'vendor.mwemr-bundle.js'
    }),
    // Getting jQuery to load correctly.
    // https://github.com/webpack/webpack/issues/1034
    // https://github.com/webpack/webpack/issues/108
    new webpack.ResolverPlugin([
        new webpack.ResolverPlugin.DirectoryDescriptionFilePlugin("bower.json", ["main"])
    ], ["normal", "loader"]),
    new webpack.ProvidePlugin({
      $: 'jquery/dist/jquery.js',
      jQuery: 'jquery/dist/jquery.js'
    }),
    new ExtractTextPlugin('styles.css')
  ],
  module: {
    loaders: [
      {
        // Extract the CSS during the build.
        test: /\.css$/,
        loader: ExtractTextPlugin.extract('style', 'css')
        //loaders: ['style', 'css']
      },
      {
        test: /\.jsx?$/,
        exclude: MODULE_DIRS,
        loader: 'babel',
        query: {
          presets: ['react', 'es2015'],
          cacheDirectory: true
        }
      },
      {
        test: /\.woff(2)?(\?v=[0-9]\.[0-9]\.[0-9])?$/,
        loader: "url-loader?limit=10000&minetype=application/font-woff"
      },
      {
        test: /\.(ttf)(\?v=[0-9]\.[0-9]\.[0-9])?$/,
        loader: "url-loader?limit=10000&mimetype=application/octet-stream"
      },
      {
        test: /\.(eot)(\?v=[0-9]\.[0-9]\.[0-9])?$/,
        loader: "file"
      },
      {
        test: /\.(svg)(\?v=[0-9]\.[0-9]\.[0-9])?$/,
        loader: "url-loader?limit=10000&mimetype=image/svg+xml"
      }

    ]
  }
};

