Class {
	#name : #OpenAPIPathItem,
	#superclass : #OpenAPIComponent,
	#instVars : [
		'path',
		'operations',
		'parameters'
	],
	#category : #'OpenAPI-Generator-Core-Model',
	#package : 'OpenAPI-Generator-Core'
}

{ #category : #'instance creation' }
OpenAPIPathItem class >> fromJSON: aJSONObject path: aPath [
	"Create a path item from a JSON object and path"
	^ (self fromJSON: aJSONObject)
		path: aPath;
		yourself
]

{ #category : #initialization }
OpenAPIPathItem >> initializeWithJSON: aJSONObject [
	| httpMethods |
	super initializeWithJSON: aJSONObject.
	
	httpMethods := #('get' 'post' 'put' 'delete' 'patch' 'head' 'options').
	operations := Dictionary new.
	
	httpMethods do: [ :method |
		(aJSONObject includesKey: method) ifTrue: [
			operations at: method put: (OpenAPIOperation fromJSON: (aJSONObject at: method))
		]
	].
	
	"Initialize parameters"
	parameters := (aJSONObject at: 'parameters' ifAbsent: [ #() ]) collect: [ :paramDef |
		OpenAPIParameter fromJSON: paramDef
	].
]

{ #category : #accessing }
OpenAPIPathItem >> operations [
	^ operations
]

{ #category : #accessing }
OpenAPIPathItem >> parameters [
	^ parameters
]

{ #category : #accessing }
OpenAPIPathItem >> path [
	^ path
]

{ #category : #accessing }
OpenAPIPathItem >> path: aString [
	path := aString
]

{ #category : #resolving }
OpenAPIPathItem >> resolveReferencesWithSpecification: aSpecification [
	"Resolve references in this path item"
	
	"Resolve operations"
	operations keysAndValuesDo: [ :method :operation |
		operation resolveReferencesWithSpecification: aSpecification
	].
	
	"Resolve parameters"
	parameters := parameters collect: [ :param |
		(param isKindOf: OpenAPIReference)
			ifTrue: [ param resolveWithSpecification: aSpecification ]
			ifFalse: [ 
				param resolveReferencesWithSpecification: aSpecification.
				param
			]
	].
]