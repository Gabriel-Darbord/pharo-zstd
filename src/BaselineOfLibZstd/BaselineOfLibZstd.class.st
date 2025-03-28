Class {
	#name : 'BaselineOfLibZstd',
	#superclass : 'BaselineOf',
	#category : 'BaselineOfLibZstd',
	#package : 'BaselineOfLibZstd'
}

{ #category : 'baselines' }
BaselineOfLibZstd >> baseline: spec [

	<baseline>
	spec for: #common do: [
		spec package: 'LibZstd'.
		spec group: 'default' with: #( 'LibZstd' ) ]
]
