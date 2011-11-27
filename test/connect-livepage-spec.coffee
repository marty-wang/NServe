should = require 'should'
sinon = require 'sinon'

fs = require 'fs'

connectLivePage = require '../lib/connect-livepage'

describe 'connect-livepage', ->
    describe '#conncet', ->
        it 'should return a function', ->
            connect = connectLivePage.connect()
            connect.should.be.a 'function'

        describe 'if it is not HEAD request', ->
            it 'should call next', ->
                req = method: 'Other'
                nextSpy = sinon.spy()
                connect = connectLivePage.connect()

                connect(req, null, nextSpy)

                nextSpy.calledOnce.should.be.true

        describe 'if it is HEAD request', ->
            writeHeadStub = null
            endStub = null
            testRes =
                writeHead: ->
                end: ->

            beforeEach ->
                writeHeadStub = sinon.stub testRes, 'writeHead'
                endStub = sinon.stub testRes, 'end'
            afterEach ->
                writeHeadStub.restore()
                endStub.restore()

            describe 'and if it is other content type', ->
                it 'should call next', ->
                    req =
                        method: 'HEAD'
                        url: '/some.file'
                    nextSpy = sinon.spy()
                    connect = connectLivePage.connect()

                    connect(req, null, nextSpy)

                    nextSpy.calledOnce.should.be.true

            describe 'and if it is javascript file and if it succeeds to read the file', ->
                connect = null
                testReq =
                    method: 'HEAD'
                    url: '/some.js'
                statStub = null

                beforeEach ->
                    connect = connectLivePage.connect('/root')
                    statStub = sinon
                        .stub(fs, 'stat')
                        .callsArgWith(1, null, {})

                afterEach ->
                    statStub.restore()

                it 'should get stat of the file', ->
                    connect testReq, testRes

                    statStub.calledWith('/root/some.js').should.be.true

                it 'should response with 200 and Etag and end the request', ->
                    connect testReq, testRes

                    args = writeHeadStub.getCall(0).args
                    args[0].should.eql 200
                    args[1].should.have.property 'Content-Type', 'application/javascript'
                    args[1].should.have.property 'Etag'

                    endStub.calledOnce.should.be.true


            describe 'and if it is html file and if it succeeds to read the file', ->
                connect = null
                testReq =
                    method: 'HEAD'
                    url: '/some.html'
                statStub = null

                beforeEach ->
                    connect = connectLivePage.connect('/root')
                    statStub = sinon
                        .stub(fs, 'stat')
                        .callsArgWith(1, null, {})

                afterEach ->
                    statStub.restore()

                it 'should get stat of the file', ->
                    connect testReq, testRes

                    statStub.calledWith('/root/some.html').should.be.true

                it 'should response with 200 and Etag and end the request', ->
                    connect testReq, testRes

                    args = writeHeadStub.getCall(0).args
                    args[0].should.eql 200
                    args[1].should.have.property 'Content-Type', 'text/html'
                    args[1].should.have.property 'Etag'

                    endStub.calledOnce.should.be.true

            describe 'and if it is css file and if it succeeds to read the file', ->
                connect = null
                testReq =
                    method: 'HEAD'
                    url: '/some.css'
                statStub = null

                beforeEach ->
                    connect = connectLivePage.connect('/root')
                    statStub = sinon
                        .stub(fs, 'stat')
                        .callsArgWith(1, null, {})

                afterEach ->
                    statStub.restore()

                it 'should get stat of the file', ->
                    connect testReq, testRes

                    statStub.calledWith('/root/some.css').should.be.true

                it 'should response with 200 and Etag and end the request', ->
                    connect testReq, testRes

                    args = writeHeadStub.getCall(0).args
                    args[0].should.eql 200
                    args[1].should.have.property 'Content-Type', 'text/css'
                    args[1].should.have.property 'Etag'

                    endStub.calledOnce.should.be.true
            
            describe 'and if it fails to read js, ccs or html files', ->
                it 'should just end the response', ->
                    connect = connectLivePage.connect('/root')
                    statStub = sinon
                        .stub(fs, 'stat')
                        .callsArgWith(1, new Error(), null)
                    testReq =
                        method: 'HEAD'
                        url: '/some.css'

                    connect testReq, testRes

                    endStub.calledOnce.should.be.true
                    
                    statStub.restore()