module.exports = {
  plugins: [
    require("postcss-easy-import"),
    require("tailwindcss"),
    require("postcss-extend"),
    require("postcss-nested"),
    require("autoprefixer"),
    require("cssnano")({
      preset: "default"
    })
  ]
}
