vows = require 'vows'
should = require 'should'

ncli = require '../lib/nserve-cli'

_defaults = 
    port: 3000
    root: '.'
    rate: 'unlimited'
    webserviceFolder: 'ws'
    webserviceDelay: 0

vows.describe('nserve cli')
    .addBatch(
        '*parse*':
            'no options and arguments':
                topic: ->
                    ncli.parse ['node', 'test'], _defaults
                
                'should return default values': (parser) ->
                    parser.root().should.eql _defaults.root
                    parser.option('port').should.eql _defaults.port
                    parser.option('rate').should.eql _defaults.rate  
                    parser.option('webserviceFolder').should.eql _defaults.webserviceFolder
                    parser.option('webserviceDelay').should.eql _defaults.webserviceDelay
                    parser.option('verbose').should.be.false
                    parser.option('liveReload').should.be.false

            'root argument if provided':
                topic: ->
                    ncli.parse ['node', 'test', 'foo', 'bar'], _defaults

                'should be the first item of arguments array': (parser) ->
                    parser.root().should.eql 'foo'

            '--port or -p':
                "if a integer value is provided":            
                    topic: ->
                        ncli.parse ['node', 'tet', '--port', "4000"],  _defaults
                
                    'should equal to the integer value': (parser) ->
                        parser.option('port').should.eql 4000

                'if a non-integer value is provided':
                    topic: ->
                        ncli.parse ['node', 'test', '--port', "invalid_value"], _defaults
                    
                    'should be NaN': (parser) ->
                        isNaN(parser.option('port')).should.be.true

            '--rate or -r':
                topic: ->
                    ncli.parse ['node', 'test', '--rate', 'some_rate'], _defaults

                'should equal to the same value provided': (parser) ->
                    parser.option('rate').should.eql 'some_rate'

            '--webservice-folder or -W':
                topic: ->
                    ncli.parse ['node', 'test', '--webservice-folder', 'folder'], _defaults
                
                'should equal to the value provided': (parser) ->
                    parser.option('webserviceFolder').should.eql 'folder'

            '--webservice-delay or -D':
                'if a integer value is provided':
                    topic: ->
                        ncli.parse ['node', 'test', '-D', '15'], _defaults
                    
                    "should equal to the integer value": (parser) ->
                        parser.option('webserviceDelay').should.eql 15

                'if a non-iteger value is provided':
                    topic: ->
                        ncli.parse ['node', 'test', '-D', 'invalid_value'], _defaults
    
                    "should be NaN": (parser) ->
                        isNaN(parser.option('webserviceDelay')).should.be.true

            '--verbose or -v':
                topic: ->
                    ncli.parse ['node', 'test', '--verbose'], _defaults
                
                'should be true': (parser) ->
                    parser.option('verbose').should.be.true

            '--live-reload or -L':
                topic: ->
                    ncli.parse ['node', 'test', '--live-reload'], _defaults

                'should be true': (parser) ->
                    parser.option('liveReload').should.be.true
    )
    .export module