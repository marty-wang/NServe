NServe is a nodejs-powered static file server that is created to facilitate local software development. It is not designed for production use. 

# Features

* Easy and Fast. One command and serve away.
* Allow user-defined transfer rate to mimck the real situations.
* More to come...

# Installation
        npm install nserve -g

or install the development version from source code

        npm install {source code folder} -g

# Usage
In the folder where you want to serve the files. Run the command below. 

**nserve** [options]

Options:
        
        -h, --help                  output usage information
        -V, --version               output the version number
        -p, --port <n>              specify the port number [3000]
        -r, --rate <bit rate>       specify the file transfer rate, e.g. 100k or 5m
        -v, --verbose               enter verbose mode
        -d, --directory <root>      specify the root directory, either relative or absolute [current directory]

and open [http://localhost:3000](http://localhost:3000) in your browser.
