should = require 'should'
sinon = require 'sinon'

fs = require 'fs'
path = require 'path'

util = require '../lib/util'

describe 'util', ->
    describe '#getVersionNumber', ->
        it 'should return the version number if well-formated package.json can be found', ->
            readFileStub = sinon
                .stub(fs, 'readFileSync')
                .returns('{"version":"some_number"}')

            version = util.getVersionNumber()
            version.should.eql 'some_number'

            readFileStub.restore()

        it 'should return undefined if package.json does not have version entry', ->
            readFileStub = sinon
                .stub(fs, 'readFileSync')
                .returns('{}')

            version = util.getVersionNumber()
            should.not.exist version

            readFileStub.restore()

        it 'should throw error if package.json cannot be found', ->
            readFileStub = sinon
                .stub(fs, 'readFileSync')
                .throws('error')

            should.throws util.getVersionNumber

            readFileStub.restore()

        it 'should throw error if package.json has ill-formatted JSON content', ->
            readFileStub = sinon
                .stub(fs, 'readFileSync')
                .returns('{version:some_number}')

            should.throws util.getVersionNumber

            readFileStub.restore()

    describe '#strSplice', ->
        testStr = 'hello bar'
        testSubStr = 'foo'

        it 'should insert substring at specified index and return the resulted string', ->
            newString = util.strSplice testStr, 6, 0, testSubStr
            newString.should.eql 'hello foobar'

        it 'should remove specified number of letters at specified index and insert substring at that index and return the resulted string ', ->
            newString = util.strSplice testStr, 6, 3, testSubStr
            newString.should.eql 'hello foo'

    describe '#absoluteDirPath', ->
        it 'should return null if no argument', ->
            retVal = util.absoluteDirPath()
            should.not.exist retVal

        it 'should return absolute path if it is absolute path to a directory', ->
            stats =
                isDirectory: ->
                    true
            statStub = sinon
                .stub(fs, 'statSync')
                .returns(stats)

            util.absoluteDirPath('/dir').should.eql '/dir'

            statStub.restore()

        it 'should return its absolute path if it is relative path to a directory', ->
            stats =
                isDirectory: ->
                    true
            statStub = sinon
                .stub(fs, 'statSync')
                .returns(stats)

            absPath = path.resolve 'dir'
            util.absoluteDirPath('dir').should.eql absPath

            statStub.restore()

        it 'should return null if it is not a path to directory', ->
            stats =
                isDirectory: ->
                    false
            statStub = sinon
                .stub(fs, 'statSync')
                .returns(stats)

            retVal = util.absoluteDirPath('/file')

            should.not.exist retVal

            statStub.restore()

        it 'should return null if it fails to get the stats', ->
            statStub = sinon
                .stub(fs, 'statSync')
                .throws('error')

            retVal = util.absoluteDirPath('/non-exist')

            should.not.exist retVal

            statStub.restore()
