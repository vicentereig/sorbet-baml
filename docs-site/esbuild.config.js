const esbuildOptions = {
  target: "es2020",
  minify: process.argv.includes("--minify"),
  bundle: true,
  entryPoints: ["frontend/javascript/index.js"],
  outdir: "output/_bridgetown/static",
  entryNames: "index.[hash]",
  publicPath: "/sorbet-baml/_bridgetown/static",
}

module.exports = esbuildOptions