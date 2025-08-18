const build = require("./config/esbuild.defaults.js")

/**
 * @typedef { import("esbuild").BuildOptions } BuildOptions
 * @type {BuildOptions}
 */
const esbuildOptions = {
  publicPath: "/sorbet-baml/_bridgetown/static",
  plugins: [
    // add new plugins here if needed...
  ],
  globOptions: {
    excludeFilter: /\.(dsd|lit)\.css$/
  }
}

build(esbuildOptions)