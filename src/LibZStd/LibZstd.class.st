Class {
	#name : 'LibZstd',
	#superclass : 'FFILibrary',
	#category : 'LibZStd',
	#package : 'LibZStd'
}

{ #category : 'compressing' }
LibZstd >> compress: source size: srcSize into: destination capacity: dstCapacity compressionLevel: compressionLevel [
	"Compresses `source` content as a single zstd compressed frame into already allocated `destination`.
	NOTE: Providing `dstCapacity >= compressBound(srcSize)` guarantees that zstd will have enough space to successfully compress the data.
	Returns compressed size written into `destination` (<= dstCapacity), or an error code if it fails, which can be tested using isError()."

	self ffiCall: #(size_t ZSTD_compress(void* destination, size_t dstCapacity, void* source, size_t srcSize, int compressionLevel))
]

{ #category : 'compressing' }
LibZstd >> compressBound: srcSize [

	self ffiCall: #(size_t ZSTD_compressBound(size_t srcSize))
]

{ #category : 'compressing' }
LibZstd >> compressBytes: srcBuffer atLevel: compressionLevel [

	| srcSize dstBuffer dstSize resultSize |
	srcSize := srcBuffer size.
	dstSize := self compressBound: srcSize. "maximum capacity required"
	dstBuffer := ByteArray new: dstSize.

	resultSize := self
		              compress: srcBuffer
		              size: srcSize
		              into: dstBuffer
		              capacity: dstSize
		              compressionLevel: compressionLevel.

	(self isError: resultSize) ifTrue: [
		self error:
			'Compression failed with error code: ' , resultSize printString ].

	^ dstSize = resultSize
		  ifTrue: [ dstBuffer ]
		  ifFalse: [ dstBuffer copyFrom: 1 to: resultSize ]
]

{ #category : 'compressing' }
LibZstd >> compressFile: sourceFile into: destinationFile [

	self compressFile: sourceFile into: destinationFile atLevel: 1
]

{ #category : 'compressing' }
LibZstd >> compressFile: sourceFile into: destinationFile atLevel: compressionLevel [

	| srcBuffer dstBuffer |
	srcBuffer := sourceFile asFileReference binaryReadStreamDo: [ :s |
		             s contents ].

	dstBuffer := self compressBytes: srcBuffer atLevel: compressionLevel.

	destinationFile asFileReference ensureCreateFile
		binaryWriteStreamDo: [ :s | s truncate nextPutAll: dstBuffer ]
]

{ #category : 'decompressing' }
LibZstd >> decompress: source size: compressedSize into: destination capacity: dstCapacity [
	"`compressedSize` must be the _exact_ size of some number of compressed and/or skippable frames.
	Multiple compressed frames can be decompressed at once with this method.
	The result will be the concatenation of all decompressed frames, back to back.
	`dstCapacity` is an upper bound of originalSize to regenerate.
	First frame's decompressed size can be extracted using getFrameContentSize().
	If maximum upper bound isn't known, prefer using streaming mode to decompress data.
	Returns the number of bytes decompressed into `dst` (<= `dstCapacity`), or an errorCode if it fails, which can be tested using isError()."

	self ffiCall: #(size_t ZSTD_decompress(void* destination, size_t dstCapacity, void* source, size_t compressedSize))
]

{ #category : 'decompressing' }
LibZstd >> decompressBytes: srcBuffer [

	| srcSize dstSize dstBuffer resultSize |
	srcSize := srcBuffer size.
	dstSize := self getFrameContentSize: srcBuffer. "expected decompressed size"
	dstBuffer := ByteArray new: dstSize.

	resultSize := self
		              decompress: srcBuffer
		              size: srcSize
		              into: dstBuffer
		              capacity: dstSize.

	(self isError: resultSize) ifTrue: [
		self error:
			'Decompression failed with error code: ' , resultSize printString ].

	^ dstSize = resultSize
		  ifTrue: [ dstBuffer ]
		  ifFalse: [ dstBuffer copyFrom: 1 to: resultSize ]
]

{ #category : 'decompressing' }
LibZstd >> decompressFile: sourceFile into: destinationFile [

	| srcBuffer dstBuffer |
	srcBuffer := sourceFile asFileReference binaryReadStreamDo: [ :s |
		             s contents ].

	dstBuffer := self decompressBytes: srcBuffer.

	destinationFile asFileReference ensureCreateFile
		binaryWriteStreamDo: [ :s | s truncate nextPutAll: dstBuffer ]
]

{ #category : 'decompressing' }
LibZstd >> getFrameContentSize: source [

	| result |
	result := self getFrameContentSize: source size: source size.

	"Check for unknown or error values"
	(result = self class contentSizeUnknown or: [
		 result = self class contentSizeError ]) ifTrue: [
		self error:
			'Unknown or invalid decompressed size; streaming decompression required.' ].

	^ result
]

{ #category : 'decompressing' }
LibZstd >> getFrameContentSize: source size: srcSize [

	self ffiCall: #(ulong ZSTD_getFrameContentSize(void* source, size_t srcSize))
]

{ #category : 'testing' }
LibZstd >> isError: returnCode [

	self ffiCall: #(bool ZSTD_isError(size_t returnCode))
]

{ #category : 'accessing - platform' }
LibZstd >> macLibraryName [
	"Can be installed with homebrew."

	^ FFIMacLibraryFinder findLibrary: 'libzstd.dylib'
]

{ #category : 'accessing - platform' }
LibZstd >> unix32LibraryName [

	^ FFIUnix32LibraryFinder findLibrary: 'libzstd.so'
]

{ #category : 'accessing - platform' }
LibZstd >> unix64LibraryName [

	^ FFIUnix64LibraryFinder findLibrary: 'libzstd.so'
]

{ #category : 'accessing - platform' }
LibZstd >> unixLibraryName [

	^ self unix32LibraryName
]

{ #category : 'accessing - platform' }
LibZstd >> win32LibraryName [

	^ FFIWindowsLibraryFinder findLibrary: 'libzstd.dll'
]
