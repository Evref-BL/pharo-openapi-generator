Class {
	#name : #OpenAPIPaths,
	#superclass : #OpenAPIComponent,
	#instVars : [
		'paths'
	],
	#category : #'OpenAPI-Generator-Core-Model',
	#package : 'OpenAPI-Generator-Core'
}

{ #category : #initialization }
OpenAPIPaths >> initializeWithJSON: aJSONObject [
	super initializeWithJSON: aJSONObject.
	
	paths := Dictionary new.
	aJSONObject keysAndValuesDo: [ :pathString :pathDef |
		paths at: pathString put: (OpenAPIPathItem fromJSON: pathDef path: pathString)
	].
]

{ #category : #accessing }
OpenAPIPaths >> paths [
	^ paths
]

{ #category : #resolving }
OpenAPIPaths >> resolveReferencesWithSpecification: aSpecification [
	"Resolve references in all paths"
	
	paths keysAndValuesDo: [ :pathString :pathItem |
		pathItem resolveReferencesWithSpecification: aSpecification
	].
]