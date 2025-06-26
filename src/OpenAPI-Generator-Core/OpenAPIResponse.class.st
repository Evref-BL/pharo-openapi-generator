Class {
	#name : #OpenAPIResponse,
	#superclass : #OpenAPIComponent,
	#instVars : [
		'description',
		'content',
		'headers'
	],
	#category : #'OpenAPI-Generator-Core-Model',
	#package : 'OpenAPI-Generator-Core'
}

{ #category : #'instance creation' }
OpenAPIResponse class >> fromJSON: aJSONObject [
	"Create a response from a JSON object"
	(OpenAPIReference isReference: aJSONObject) ifTrue: [
		^ OpenAPIReference fromJSON: aJSONObject
	].
	
	^ super fromJSON: aJSONObject
]

{ #category : #accessing }
OpenAPIResponse >> content [
	^ content
]

{ #category : #accessing }
OpenAPIResponse >> description [
	^ description
]

{ #category : #accessing }
OpenAPIResponse >> headers [
	^ headers
]

{ #category : #initialization }
OpenAPIResponse >> initializeWithJSON: aJSONObject [
	super initializeWithJSON: aJSONObject.
	
	description := aJSONObject at: 'description' ifAbsent: [ '' ].
	
	"Initialize content"
	content := Dictionary new.
	(aJSONObject at: 'content' ifAbsent: [ Dictionary new ]) keysAndValuesDo: [ :mediaType :contentDef |
		| schema |
		schema := contentDef at: 'schema' ifAbsent: [ nil ].
		schema ifNotNil: [
			content at: mediaType put: (OpenAPISchema fromJSON: schema)
		].
	].
	
	"Initialize headers"
	headers := Dictionary new.
	(aJSONObject at: 'headers' ifAbsent: [ Dictionary new ]) keysAndValuesDo: [ :headerName :headerDef |
		headers at: headerName put: headerDef
	].
]

{ #category : #resolving }
OpenAPIResponse >> resolveReferencesWithSpecification: aSpecification [
	"Resolve references in this response"
	
	content keysAndValuesDo: [ :mediaType :schema |
		(schema isKindOf: OpenAPIReference)
			ifTrue: [ content at: mediaType put: (schema resolveWithSpecification: aSpecification) ]
			ifFalse: [ schema resolveReferencesWithSpecification: aSpecification ]
	].
]