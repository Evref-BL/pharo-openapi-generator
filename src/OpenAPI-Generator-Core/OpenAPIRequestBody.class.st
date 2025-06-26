Class {
	#name : #OpenAPIRequestBody,
	#superclass : #OpenAPIComponent,
	#instVars : [
		'description',
		'content',
		'required'
	],
	#category : #'OpenAPI-Generator-Core-Model',
	#package : 'OpenAPI-Generator-Core'
}

{ #category : #'instance creation' }
OpenAPIRequestBody class >> fromJSON: aJSONObject [
	"Create a request body from a JSON object"
	(OpenAPIReference isReference: aJSONObject) ifTrue: [
		^ OpenAPIReference fromJSON: aJSONObject
	].
	
	^ super fromJSON: aJSONObject
]

{ #category : #accessing }
OpenAPIRequestBody >> content [
	^ content
]

{ #category : #accessing }
OpenAPIRequestBody >> description [
	^ description
]

{ #category : #initialization }
OpenAPIRequestBody >> initializeWithJSON: aJSONObject [
	super initializeWithJSON: aJSONObject.
	
	description := aJSONObject at: 'description' ifAbsent: [ '' ].
	required := aJSONObject at: 'required' ifAbsent: [ false ].
	
	"Initialize content"
	content := Dictionary new.
	(aJSONObject at: 'content' ifAbsent: [ Dictionary new ]) keysAndValuesDo: [ :mediaType :contentDef |
		| schema |
		schema := contentDef at: 'schema' ifAbsent: [ nil ].
		schema ifNotNil: [
			content at: mediaType put: (OpenAPISchema fromJSON: schema)
		].
	].
]

{ #category : #accessing }
OpenAPIRequestBody >> required [
	^ required
]

{ #category : #resolving }
OpenAPIRequestBody >> resolveReferencesWithSpecification: aSpecification [
	"Resolve references in this request body"
	
	content keysAndValuesDo: [ :mediaType :schema |
		(schema isKindOf: OpenAPIReference)
			ifTrue: [ content at: mediaType put: (schema resolveWithSpecification: aSpecification) ]
			ifFalse: [ schema resolveReferencesWithSpecification: aSpecification ]
	].
]