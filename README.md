# Divshot Alloy

**Alloy** is a simple web tool that provides an API for the compilation of
CSS using a variety of preprocessors. Built for developers who offer the
use of custom CSS in their products, this allows for the use of the more
advanced and useful CSS preprocessors as well.

We created this because we needed it for [Divshot](http://divshot.com) and
decided to open source it so that everyone can benefit.

## Hosted Version

Note that you can always use Alloy from its home at [divshot.com/alloy](http://divshot.com/alloy).
Usage of this free hosted service is currently limited to 100 requests per hour.

## Dependencies

Alloy depends on Ruby 1.9.3 and several RubyGems for the core web
functionality. It also needs Node.js and NPM installed in order
to compile LessCSS and Stylus code. Finally, you will need Java
1.4 or greater installed to be able to compress the CSS using
the `yui-compressor` gem.

## Installation

To run Alloy locally, you will first need to clone this repo:

    git clone https://github.com/divshot/alloy.git

Next, you'll need to get everything up and running with Bundler:

    bundle

That's it! You can now run this the way you would any other Rack
application, for example with `rackup`.

## License

Copyright (c) 2012 Divshot, Inc.

Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.