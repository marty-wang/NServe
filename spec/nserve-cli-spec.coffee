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
        
        '#parse':
            topic: ->
                ncli.defaults _defaults

            'root':

                'should be default root if there is not arguments': ->
                    result = ncli.parse []
                    result.root.should.equal _defaults.root

                'should be the first item of arguments array': ->
                    result = ncli.parse ['foo', 'bar']
                    result.root.should.equal 'foo'

            'port':
                
                'should be default port if nothing is assigned to --port or -p': ->
                    result = ncli.parse [];
                    result.port.should.equal _defaults.port

                'should be default port if invalid value is assigned to --port or -p': ->
                    result = ncli.parse ['--port', 'InvalidPortValue']
                    result.port.should.equal _defaults.port

                'should be the same value as assigned to --port or -p': ->
                    result = ncli.parse ['--port', "4000"]
                    result.port.should.equal 4000

            'rate':

                'should be default rate if nothing is assigned to --rate or -r': ->
                    result = ncli.parse []
                    result.rate.should.equal _defaults.rate

                'should be the same value as assinged to --rate or -rat': ->
                    result = ncli.parse ['--rate', 'some_rate']
                    result.rate.should.equal 'some_rate'

            'verbose':
                
                'should be false if not specified': ->
                    result = ncli.parse []
                    result.verbose.should.be.false
                
                'should be true if specified': ->
                    result = ncli.parse ['--verbose']
                    result.verbose.should.be.true

            'webserviceFolder':
                
                'should be default folder if nothing is assigned to --webservice-folder or -W': ->
                    result = ncli.parse []
                    result.webserviceFolder.should.equal _defaults.webserviceFolder

                'should be the same as assigned to --webservice-folder or -W': ->
                    result = ncli.parse ['--webservice-folder', 'folder']
                    result.webserviceFolder.should.equal 'folder'

            'webserviceDelay':

                'should be default delay if nothing is assigned to --webservice-delay or -D': ->
                    result = ncli.parse []
                    result.webserviceDelay.should.equal _defaults.webserviceDelay

                'should be same as assigned to --webservice-delay or -D': ->
                    result = ncli.parse ['-D', '15']
                    result.webserviceDelay.should.equal 15

                'should be default delay if invalid value assigned to --webservice-delay or -D': ->
                    result = ncli.parse ['--webservice-delay', 'invalid_delay']
                    result.webserviceDelay.should.equal _defaults.webserviceDelay

            'livereload':
                
                'should be false if not specified': ->
                    result = ncli.parse []
                    result.liveReload.should.be.false

                'should be true if specified': ->
                    result = ncli.parse ['-L']
                    result.liveReload.should.be.true
    )
    .export module