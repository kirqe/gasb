const path = require('path');
const webpack = require("webpack");
const MiniCssExtractPlugin = require("mini-css-extract-plugin");

module.exports = {
  entry: './webpack/main.js',
  output: {
    path: path.resolve(__dirname, 'public/assets/build/'),
    filename: 'bundle.js'
  },
  module: {
    rules: [
      {
        test: /\.js$/,
        exclude: /(node_modules)/,
        use: {
          loader: 'babel-loader',
          options: {
            presets: ['@babel/preset-env']
          }
        }
      },
      {
        test: /\.(sa|sc|c)ss$/,
        use: [
          MiniCssExtractPlugin.loader, 
          "css-loader",
          "sass-loader"
        ]
      },
    ]
  },
  plugins: [new MiniCssExtractPlugin()],
  mode: 'development'
}