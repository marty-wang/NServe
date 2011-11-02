Using Node.js, this project simply serves out static files with the correct mimetype.

**Note:** nserve should be used to facilitate local development. It is not designed for production use. 

# Installation
        npm install nserve -g

# Usage
In the folder where you want to serve the files. Run the command below. 

**nserve** [options]

Options:
        
        -h, --help                  output usage information
        -v, --version               output the version number
        -p, --port <n>              specify the port number [3000]
        -r --rate <bit rate>        specify the file transfer rate, e.g. 100k or 5m

and open [http://localhost:3000](http://localhost:3000) in your browser.
