module.exports = {
  plugins: [
    require("autoprefixer"),
    require("postcss-easy-import"),
    require("tailwindcss"),
    require("postcss-extend"),
    require("postcss-nested"),
    //require('@fullhuman/postcss-purgecss')({
      //content: [
        //'./app/**/*.erb'
      //],
      //defaultExtractor: content => content.match(/[A-Za-z0-9-_:/]+/g) || []
    //}),
    require("cssnano")({
      preset: "default"
    }),
  ]
}
