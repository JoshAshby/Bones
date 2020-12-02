const colors = require('tailwindcss/colors')

module.exports = {
  theme: {
    extend: {
      colors: {
        orange: colors.orange,
        brand: '#23334B',
        steelblue: {
          '50':  '#f7fafb',
          '100': '#eef7f8',
          '200': '#d7ebf0',
          '300': '#b9d8e7',
          '400': '#83b6d7',
          '500': '#4e8ec1',
          '600': '#366aa1',
          '700': '#2f527d',
          '800': '#263f5b',
          '900': '#1f3246',
        },
        palevioletred: {
          '50':  '#fafafa',
          '100': '#f8f6f6',
          '200': '#efe5eb',
          '300': '#e5ccdc',
          '400': '#d79fc1',
          '500': '#c3739e',
          '600': '#9b4e75',
          '700': '#6e3b5a',
          '800': '#4d2e44',
          '900': '#3a2536',
        },
        plum: {
          '50':  '#fbfafa',
          '100': '#f8f6f6',
          '200': '#f0e5ec',
          '300': '#e7cadd',
          '400': '#da9dc2',
          '500': '#c870a0',
          '600': '#a24c77',
          '700': '#733a5c',
          '800': '#502d44',
          '900': '#3c2436',
        },
        indianred: {
          '50':  '#fbfafa',
          '100': '#f9f6f5',
          '200': '#f2e7e6',
          '300': '#eaced0',
          '400': '#dea1a9',
          '500': '#ce757b',
          '600': '#a85053',
          '700': '#783d43',
          '800': '#532e35',
          '900': '#3e252c',
        },
      }
    }
  },
  //purge: ['./app/**/*.erb'],
  variants: {},
  plugins: [
    require('@tailwindcss/forms'),
    //require('@tailwindcss/typography'),
  ],
}
