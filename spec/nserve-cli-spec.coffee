vows = require 'vows'
should = require 'should'

program = require 'commander'

ncli = require '../lib/nserve-cli'

DEFAULT_PORT = ncli.DEFAULT_PORT

vows.describe('nserve cli')
    .addBatch(
        
        '#parse':

            'args':
                
                'should be an array': ->
                    ncli.parse ['node', 'test', 'hello', 'world']
                    ncli.args.should.be.an.instanceof Array
                    ncli.args[0].should.equal 'hello'
                    ncli.args[1].should.equal 'world'
            
            'version':
                
                'should be the same as the passed-in version': ->
                    ncli.parse ['node', 'test'], '0.1.0'
                    ncli.version.should.equal '0.1.0'

            'port':

                'should be the same value as assigned to --port or -p': ->
                    ncli.parse ['node', 'test', '--port', 4000]
                    ncli.port.should.equal 4000
                
                'should be DEFAULT_PORT if nothing is assigned to --port or -p': ->
                    ncli.parse ['node', 'test']
                    ncli.port.should.equal DEFAULT_PORT

                'should be DEFAULT_PORT if invalid value is assigned to --port or -p': ->
                    ncli.parse ['node', 'test', '--port', 'InvalidPortValue']
                    ncli.port.should.equal DEFAULT_PORT

    )
    .export module