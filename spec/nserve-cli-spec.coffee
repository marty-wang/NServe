vows = require 'vows'
should = require 'should'

ncli = require '../lib/nserve-cli'

_defaults = 
    port: 3000
    root: '.'
    rate: 'unlimited'
    webserviceFolder: 'ws'
    webserviceDelay: 0

ncli.defaults _defaults

vows.describe('nserve cli')
    .addBatch(
        
        '#parse':

            'no options and arguments':
                topic: ->
                    ncli.parse []
                
                'should return default values': (result) ->
                    result.root.should.eql _defaults.root
                    result.port.should.equal _defaults.port     
                    result.rate.should.equal _defaults.rate  
                    result.webserviceFolder.should.equal _defaults.webserviceFolder
                    result.webserviceDelay.should.equal _defaults.webserviceDelay
                    result.verbose.should.be.false   
                    result.liveReload.should.be.false          

            'root':
                topic: ->
                    ncli.parse ['foo', 'bar']

                'should be the first item of arguments array': (result) ->
                    result.root.should.eql 'foo'

            '--port or -p':
                
                "if a integer value is provided":            
                    topic: ->
                        ncli.parse ['--port', "4000"]
                
                    'should equal to the integer value': (result) ->
                        result.port.should.eql 4000

                'if a non-integer value is provided':
                    topic: ->
                        ncli.parse ['--port', "invalid_value"]
                    
                    'should use default value': (result) ->
                        result.port.should.eql _defaults.port

            '--rate or -r':
                topic: ->
                    ncli.parse ['--rate', 'some_rate']

                'should equal to the same value provided': (result) ->
                    result.rate.should.eql 'some_rate'

            '--webservice-folder or -W':
                topic: ->
                    ncli.parse ['--webservice-folder', 'folder']                    
                
                'should equal to the value provided': (result) ->
                    result.webserviceFolder.should.equal 'folder'

            '--webservice-delay or -D':

                'if a integer value is provided':
                    topic: ->
                        ncli.parse ['-D', '15']
                    
                    "should equal to the integer value": (result) ->
                        result.webserviceDelay.should.eql 15

                'if a non-iteger value is provided': ->
                    topic: ->
                        ncli.parse ['-D', 'invalid_value']
                    
                    "should use the default value": (result) ->
                        result.webserviceDelay.should.eql _defaults.webserviceDelay

            '--verbose or -v':
                topic: ->
                    ncli.parse ['--verbose']
                
                'should be true': (result) ->
                    result.verbose.should.be.true

            '--live-reload or -L':
                topic: ->
                    ncli.parse ['--live-reload']

                'should be true': (result) ->
                    result.liveReload.should.be.true
    )
    .export module