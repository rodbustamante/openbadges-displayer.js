gulp = require 'gulp'
expressService = require 'gulp-express-service'
coffee = require 'gulp-coffee'
path = require 'path'
browserify = require 'gulp-browserify'
uglify = require 'gulp-uglify'
minifyCSS = require 'gulp-minify-css'
rename = require 'gulp-rename'
less = require 'gulp-less'
base64 = require 'gulp-base64'
minifyHTML = require 'gulp-minify-html'
header = require 'gulp-header'
pkg = require path.join __dirname, 'package.json'

banner = [
    '/*!'
    '<%= pkg.name %> v<%= pkg.version %>'
    ' | @license <%= pkg.license %>'
    '*/'].join ' '
banner += '\n'


# Define paths
assets = path.join '.', 'assets'
clientAssets = path.join assets, 'demo', 'client'
serverAssets = path.join assets, 'demo', 'server'

paths =
  client:
    css:path.join clientAssets, 'css'
    coffee:path.join 'assets', 'src'
    less:path.join 'assets', 'src'
    templates:path.join clientAssets, 'templates'
    images:path.join clientAssets, 'imgs'
  vendor:path.join assets, 'vendor'
  server:coffee:path.join serverAssets
  dist:demo:path.join 'dist', 'demo'
  public: path.join 'dist', 'demo', 'public'
  public_css: path.join 'dist'
  public_images: path.join 'dist', 'demo', 'imgs'
  compiled_js: path.join 'dist', 'js'
  public_js: path.join 'dist', 'demo', 'public', 'js'
  temp: 'temp'

# run gulp-coffee on server files
gulp.task 'server_coffee', ()->
  return gulp.src(
    path.join paths.server.coffee, '*.coffee'
  ).pipe(
    coffee()
  ).pipe(
    uglify()
  ).pipe(
    gulp.dest paths.dist.demo
  )

# watch server files for changes
gulp.task 'watch_server', ()->
  gulp.watch path.join(paths.server.coffee, '*.coffee'), ['server_coffee']

# run gulp-coffee on client files
gulp.task 'client_coffee', ['less'], ()->
  return gulp.src(
    path.join paths.client.coffee, '*.coffee'
  ).pipe(
    coffee()
  ).pipe(
    browserify {
      transform:['brfs']
    }
  ).pipe(
    uglify()
  ).pipe(
    header banner, { pkg: pkg }
  ).pipe(
    rename 'openbadges-displayer.min.js'
  ).pipe(
    gulp.dest './dist'
  )

# watch less files
gulp.task 'watch_less', ()->
  gulp.watch path.join(paths.client.less, '*.less'), ['client_coffee']

# watch client files for changes
gulp.task 'watch_client', ()->
  gulp.watch path.join(paths.client.coffee, '*.coffee'), ['client_coffee']

# copy templates
gulp.task 'copy_templates', ()->
  # Copy index file
  return gulp.src(
    path.join paths.client.templates,'index.html'
  ).pipe(
    minifyHTML()
  ).pipe(
    gulp.dest(
      paths.public
    )
  )

# copy images
gulp.task 'copy_images', ()->
  return gulp.src(
    path.join paths.client.images,'*.png'
  ).pipe(
    gulp.dest(
      paths.public_images
    )
  )

# less
gulp.task 'less', () ->
  gulp.src(
    path.join paths.client.less, '*.less'
  ).pipe(
    less()
  ).pipe(
    base64()
  ).pipe(
    minifyCSS()
  ).pipe(
    header banner, { pkg: pkg }
  ).pipe(
    rename 'openbadges-displayer.min.css'
  ).pipe(
    gulp.dest(
      paths.public_css
    )
  )

gulp.task 'compile_coffee', ['server_coffee', 'client_coffee']

gulp.task 'runserver', ['copy_templates', 'compile_coffee', 'copy_images', 'watch_less', 'watch_server', 'watch_client'], ()->
  return gulp.src(
    './dist/demo/server.js'
  ).pipe(
    expressService({
      file: './dist/demo/server.js',
      NODE_ENV: 'DEV'
    })
  )

gulp.task 'default', ['runserver']