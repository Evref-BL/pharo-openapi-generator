Class {
	#name : #OpenAPIOperation,
	#superclass : #OpenAPIComponent,
	#instVars : [
		'operationId',
		'summary',
		'description',
		'parameters',
		'requestBody',
		'responses',
		'tags'
	],
	#category : #'OpenAPI-Generator-Core-Model',
	#package : 'OpenAPI-Generator-Core'
}

{ #category : #accessing }
OpenAPIOperation >> description [
	^ description
]

{ #category : #initialization }
OpenAPIOperation >> initializeWithJSON: aJSONObject [
	super initializeWithJSON: aJSONObject.
	
	operationId := aJSONObject at: 'operationId' ifAbsent: [ '' ].
	summary := aJSONObject at: 'summary' ifAbsent: [ '' ].
	description := aJSONObject at: 'description' ifAbsent: [ '' ].
	tags := aJSONObject at: 'tags' ifAbsent: [ #() ].
	
	"Initialize parameters"
	parameters := (aJSONObject at: 'parameters' ifAbsent: [ #() ]) collect: [ :paramDef |
		OpenAPIParameter fromJSON: paramDef
	].
	
	"Initialize request body"
	(aJSONObject includesKey: 'requestBody') ifTrue: [
		requestBody := OpenAPIRequestBody fromJSON: (aJSONObject at: 'requestBody')
	].
	
	"Initialize responses"
	responses := Dictionary new.
	(aJSONObject at: 'responses' ifAbsent: [ Dictionary new ]) keysAndValuesDo: [ :statusCode :respDef |
		responses at: statusCode put: (OpenAPIResponse fromJSON: respDef)
	].
]

{ #category : #accessing }
OpenAPIOperation >> operationId [
	^ operationId
]

{ #category : #accessing }
OpenAPIOperation >> parameters [
	^ parameters
]

{ #category : #accessing }
OpenAPIOperation >> requestBody [
	^ requestBody
]

{ #category : #resolving }
OpenAPIOperation >> resolveReferencesWithSpecification: aSpecification [
	"Resolve references in this operation"
	
	"Resolve parameters"
	parameters := parameters collect: [ :param |
		(param isKindOf: OpenAPIReference)
			ifTrue: [ param resolveWithSpecification: aSpecification ]
			ifFalse: [ 
				param resolveReferencesWithSpecification: aSpecification.
				param
			]
	].
	
	"Resolve request body"
	requestBody ifNotNil: [
		(requestBody isKindOf: OpenAPIReference)
			ifTrue: [ requestBody := requestBody resolveWithSpecification: aSpecification ]
			ifFalse: [ requestBody resolveReferencesWithSpecification: aSpecification ]
	].
	
	"Resolve responses"
	responses keysAndValuesDo: [ :statusCode :resp |
		(resp isKindOf: OpenAPIReference)
			ifTrue: [ responses at: statusCode put: (resp resolveWithSpecification: aSpecification) ]
			ifFalse: [ resp resolveReferencesWithSpecification: aSpecification ]
	].
]

{ #category : #accessing }
OpenAPIOperation >> responses [
	^ responses
]

{ #category : #accessing }
OpenAPIOperation >> summary [
	^ summary
]

{ #category : #accessing }
OpenAPIOperation >> tags [
	^ tags
]