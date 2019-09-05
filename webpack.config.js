const path = require('path')
const webpack = require('webpack')

module.exports = {
  module: {
    rules: [
      {
        test: /\.js$/,
        use: ['babel-loader']
      }
    ]
  },
  entry: './app/assets/javascripts/arclight/arclight.js',
  output: {
    library: '@arclight/engine',
    libraryTarget: 'umd',
    umdNamedDefine: true,
    filename: 'index.js',
    path: path.resolve(__dirname, 'app/assets/javascripts/arclight')
  },
  resolve: {
    extensions: ['.js']
  }
};
