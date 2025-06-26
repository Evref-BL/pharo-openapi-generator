Class {
	#name : #OpenAPIComponents,
	#superclass : #OpenAPIComponent,
	#instVars : [
		'schemas',
		'parameters',
		'responses',
		'securitySchemes'
	],
	#category : #'OpenAPI-Generator-Core-Model',
	#package : 'OpenAPI-Generator-Core'
}

{ #category : #initialization }
OpenAPIComponents >> initializeWithJSON: aJSONObject [
	| schemaObjects |
	super initializeWithJSON: aJSONObject.
	
	"Initialize schemas"
	schemaObjects := aJSONObject at: 'schemas' ifAbsent: [ Dictionary new ].
	schemas := Dictionary new.
	schemaObjects keysAndValuesDo: [ :schemaName :schemaDef |
		schemas at: schemaName put: (OpenAPISchema fromJSON: schemaDef named: schemaName)
	].
	
	"Initialize parameters"
	parameters := Dictionary new.
	(aJSONObject at: 'parameters' ifAbsent: [ Dictionary new ]) keysAndValuesDo: [ :paramName :paramDef |
		parameters at: paramName put: (OpenAPIParameter fromJSON: paramDef)
	].
	
	"Initialize responses"
	responses := Dictionary new.
	(aJSONObject at: 'responses' ifAbsent: [ Dictionary new ]) keysAndValuesDo: [ :respName :respDef |
		responses at: respName put: (OpenAPIResponse fromJSON: respDef)
	].
	
	"Initialize security schemes"
	securitySchemes := Dictionary new.
	(aJSONObject at: 'securitySchemes' ifAbsent: [ Dictionary new ]) keysAndValuesDo: [ :schemeName :schemeDef |
		securitySchemes at: schemeName put: (OpenAPISecurityScheme fromJSON: schemeDef)
	].
]

{ #category : #accessing }
OpenAPIComponents >> parameters [
	^ parameters
]

{ #category : #resolving }
OpenAPIComponents >> resolveReferencesWithSpecification: aSpecification [
	"Resolve references in all components"
	
	"Resolve schemas"
	schemas keysAndValuesDo: [ :schemaName :schema |
		schema resolveReferencesWithSpecification: aSpecification
	].
	
	"Resolve parameters"
	parameters keysAndValuesDo: [ :paramName :param |
		(param isKindOf: OpenAPIReference)
			ifTrue: [ parameters at: paramName put: (param resolveWithSpecification: aSpecification) ]
			ifFalse: [ param resolveReferencesWithSpecification: aSpecification ]
	].
	
	"Resolve responses"
	responses keysAndValuesDo: [ :respName :resp |
		(resp isKindOf: OpenAPIReference)
			ifTrue: [ responses at: respName put: (resp resolveWithSpecification: aSpecification) ]
			ifFalse: [ resp resolveReferencesWithSpecification: aSpecification ]
	].
]

{ #category : #accessing }
OpenAPIComponents >> responses [
	^ responses
]

{ #category : #accessing }
OpenAPIComponents >> schemas [
	^ schemas
]

{ #category : #accessing }
OpenAPIComponents >> securitySchemes [
	^ securitySchemes
]