should = require 'should'
sinon = require 'sinon'

fs = require 'fs'

livepage = require '../lib/livepage'

describe 'livepage', ->
    testLiveScriptPath = '/live/script/path'
    lg = null

    beforeEach ->
        lg = livepage.create testLiveScriptPath

    describe '#insertLiveScript', ->
        describe 'if it fails to read live script file', ->
            it 'should throw error', ->
                readFileStub = sinon
                    .stub(fs, 'readFileSync')
                    .throws('error')

                should.throws lg.insertLiveScript

                readFileStub.restore()

        describe 'if it succeeds to read live script file', ->
            readFileStub = null
            beforeEach ->
                readFileStub = sinon
                    .stub(fs, 'readFileSync')
                    .returns('livescript')
            afterEach ->
                readFileStub.restore()

            it 'should insert the script before the closing body tag of the content and return the resulted content', ->
                testContent = '<html><body></body></html>'

                retVal = lg.insertLiveScript testContent
                retVal.should.eql '<html><body><script type="text/javascript">livescript</script></body></html>'

            it 'should throw error if no closing body tag is found', ->
                testContent = '<html><body></html>'

                should.throws ->
                    lg.insertLiveScript testContent
