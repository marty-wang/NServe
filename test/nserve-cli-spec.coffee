should = require 'should'

ncli = require '../lib/nserve-cli'

describe 'nserve-cli', ->
    defaults =
        port: 3000
        root: '.'
        rate: 'unlimited'
        webserviceDelay: 0

    describe '#option port', ->
        it 'should return default port if no port is specified', ->
            parser = ncli.parse ['node', 'test'], defaults
            parser.option('port').should.eql defaults.port
        it 'should return the port if port is specified and it is an integer value', ->
            parser = ncli.parse ['node', 'test', '-p', '8080'], defaults
            parser.option('port').should.eql 8080
        it 'should return NaN if port is specified and it is not an integer value', ->
            parser = ncli.parse ['node', 'test', '-p', 'someport'], defaults
            isNaN(parser.option('port')).should.be.true

    describe '#option rate', ->
        it 'should return default rate if no rate is specified', ->
            parser = ncli.parse ['node', 'test'], defaults
            parser.option('rate').should.eql defaults.rate
        it 'should return the rate if rate is specified', ->
            parser = ncli.parse ['node', 'test', '-r', 'somerate'], defaults
            parser.option('rate').should.eql 'somerate'

    describe '#option webserviceFolder', ->
        it 'should return undefined if no web service folder is specified', ->
            parser = ncli.parse ['node', 'test'], defaults
            should.not.exist parser.option('webserviceFolder')
        it 'should return the web service folder if it is specified', ->
            parser = ncli.parse ['node', 'test', '-W', 'somefolder'], defaults
            parser.option('webserviceFolder').should.eql 'somefolder'

    describe '#option webserviceDelay', ->
        it 'should return default delay if no delay is specified', ->
            parser = ncli.parse ['node', 'test'], defaults
            parser.option('webserviceDelay').should.eql defaults.webserviceDelay
        it 'should return the delay if delay is specified and it is an integer value', ->
            parser = ncli.parse ['node', 'test', '-D', '1000'], defaults
            parser.option('webserviceDelay').should.eql 1000
        it 'should return NaN if delay is specified and it is not an integer value', ->
            parser = ncli.parse ['node', 'test', '-D', 'somedelay'], defaults
            isNaN(parser.option('webserviceDelay')).should.be.true

    describe '#option verbose', ->
        it 'should return false if verbose is not specified', ->
            parser = ncli.parse ['node', 'test'], defaults
            parser.option('verbose').should.be.false
        it 'should return true if verbose is specified', ->
            parser = ncli.parse ['node', 'test', '-v'], defaults
            parser.option('verbose').should.be.true

    describe '#option liveReload', ->
        it 'should return false if liveReload is not specified', ->
            parser = ncli.parse ['node', 'test'], defaults
            parser.option('liveReload').should.be.false
        it 'should return true if liveReload is specified', ->
            parser = ncli.parse ['node', 'test', '-L'], defaults
            parser.option('liveReload').should.be.true

    describe '#root', ->
        it 'should return default root if root is not specified', ->
            parser = ncli.parse ['node', 'test'], defaults
            parser.root().should.eql defaults.root
        it 'should return the root if it is specified', ->
            parser = ncli.parse ['node', 'test', 'someroot', 'etc'], defaults
            parser.root().should.eql 'someroot'
