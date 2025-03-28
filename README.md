Pharo FFI bindings for [Zstandard](https://github.com/facebook/zstd).

## Installing

```st
Metacello new
  githubUser: 'Gabriel-Darbord' project: 'pharo-zstd' commitish: 'main' path: 'src';
  baseline: 'LibZstd';
  load
```

## Usage

```st
"Let's make a file to play with"
src := 'tmp.txt' asFileReference ensureCreateFile.
src writeStreamDo: [ :s | s truncate nextPutAll: String loremIpsum ].

"Compress then uncompress it"
zstd := LibZstd uniqueInstance.
zstd compressFile: src into: 'tmp.zstd'.
zstd decompressFile: 'tmp.zstd' into: 'tmp.zstd.txt'.

"Should be the truth"
src contents = 'tmp.zstd.txt' asFileReference contents.
```
