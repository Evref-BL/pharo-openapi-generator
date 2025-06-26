Class {
	#name : #OpenAPIParameter,
	#superclass : #OpenAPIComponent,
	#instVars : [
		'name',
		'location',
		'description',
		'required',
		'schema'
	],
	#category : #'OpenAPI-Generator-Core-Model',
	#package : 'OpenAPI-Generator-Core'
}

{ #category : #'instance creation' }
OpenAPIParameter class >> fromJSON: aJSONObject [
	"Create a parameter from a JSON object"
	(OpenAPIReference isReference: aJSONObject) ifTrue: [
		^ OpenAPIReference fromJSON: aJSONObject
	].
	
	^ super fromJSON: aJSONObject
]

{ #category : #accessing }
OpenAPIParameter >> description [
	^ description
]

{ #category : #initialization }
OpenAPIParameter >> initializeWithJSON: aJSONObject [
	super initializeWithJSON: aJSONObject.
	
	name := aJSONObject at: 'name' ifAbsent: [ '' ].
	location := aJSONObject at: 'in' ifAbsent: [ '' ].
	description := aJSONObject at: 'description' ifAbsent: [ '' ].
	required := aJSONObject at: 'required' ifAbsent: [ false ].
	
	(aJSONObject includesKey: 'schema') ifTrue: [
		schema := OpenAPISchema fromJSON: (aJSONObject at: 'schema')
	].
]

{ #category : #accessing }
OpenAPIParameter >> location [
	^ location
]

{ #category : #accessing }
OpenAPIParameter >> name [
	^ name
]

{ #category : #accessing }
OpenAPIParameter >> required [
	^ required
]

{ #category : #resolving }
OpenAPIParameter >> resolveReferencesWithSpecification: aSpecification [
	"Resolve references in this parameter"
	
	schema ifNotNil: [
		(schema isKindOf: OpenAPIReference)
			ifTrue: [ schema := schema resolveWithSpecification: aSpecification ]
			ifFalse: [ schema resolveReferencesWithSpecification: aSpecification ]
	].
]

{ #category : #accessing }
OpenAPIParameter >> schema [
	^ schema
]