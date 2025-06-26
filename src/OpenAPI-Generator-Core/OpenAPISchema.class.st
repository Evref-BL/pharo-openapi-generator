Class {
	#name : #OpenAPISchema,
	#superclass : #OpenAPIComponent,
	#instVars : [
		'name',
		'type',
		'properties',
		'items',
		'required',
		'reference',
		'allOf',
		'oneOf',
		'anyOf'
	],
	#category : #'OpenAPI-Generator-Core-Model',
	#package : 'OpenAPI-Generator-Core'
}

{ #category : #'instance creation' }
OpenAPISchema class >> fromJSON: aJSONObject [
	"Create a schema from a JSON object"
	(OpenAPIReference isReference: aJSONObject) ifTrue: [
		^ OpenAPIReference fromJSON: aJSONObject
	].
	
	^ super fromJSON: aJSONObject
]

{ #category : #'instance creation' }
OpenAPISchema class >> fromJSON: aJSONObject named: aString [
	"Create a schema from a JSON object with a name"
	^ (self fromJSON: aJSONObject)
		name: aString;
		yourself
]

{ #category : #accessing }
OpenAPISchema >> allOf [
	^ allOf
]

{ #category : #accessing }
OpenAPISchema >> anyOf [
	^ anyOf
]

{ #category : #initialization }
OpenAPISchema >> initializeWithJSON: aJSONObject [
	| props |
	super initializeWithJSON: aJSONObject.
	
	type := aJSONObject at: 'type' ifAbsent: [ nil ].
	required := aJSONObject at: 'required' ifAbsent: [ #() ].
	
	"Handle properties"
	props := aJSONObject at: 'properties' ifAbsent: [ Dictionary new ].
	properties := Dictionary new.
	props keysAndValuesDo: [ :propName :propDef |
		properties at: propName put: (OpenAPISchema fromJSON: propDef named: propName)
	].
	
	"Handle items for array types"
	(aJSONObject includesKey: 'items') ifTrue: [
		items := OpenAPISchema fromJSON: (aJSONObject at: 'items')
	].
	
	"Handle composition schemas"
	(aJSONObject includesKey: 'allOf') ifTrue: [
		allOf := (aJSONObject at: 'allOf') collect: [ :schema |
			OpenAPISchema fromJSON: schema
		]
	].
	
	(aJSONObject includesKey: 'oneOf') ifTrue: [
		oneOf := (aJSONObject at: 'oneOf') collect: [ :schema |
			OpenAPISchema fromJSON: schema
		]
	].
	
	(aJSONObject includesKey: 'anyOf') ifTrue: [
		anyOf := (aJSONObject at: 'anyOf') collect: [ :schema |
			OpenAPISchema fromJSON: schema
		]
	].
]

{ #category : #accessing }
OpenAPISchema >> items [
	^ items
]

{ #category : #accessing }
OpenAPISchema >> name [
	^ name
]

{ #category : #accessing }
OpenAPISchema >> name: aString [
	name := aString
]

{ #category : #accessing }
OpenAPISchema >> oneOf [
	^ oneOf
]

{ #category : #accessing }
OpenAPISchema >> properties [
	^ properties
]

{ #category : #accessing }
OpenAPISchema >> required [
	^ required
]

{ #category : #resolving }
OpenAPISchema >> resolveReferencesWithSpecification: aSpecification [
	"Resolve references in this schema"
	
	"Resolve properties"
	properties ifNotNil: [
		properties keysAndValuesDo: [ :propName :propSchema |
			(propSchema isKindOf: OpenAPIReference)
				ifTrue: [ properties at: propName put: (propSchema resolveWithSpecification: aSpecification) ]
				ifFalse: [ propSchema resolveReferencesWithSpecification: aSpecification ]
		]
	].
	
	"Resolve items for array types"
	items ifNotNil: [
		(items isKindOf: OpenAPIReference)
			ifTrue: [ items := items resolveWithSpecification: aSpecification ]
			ifFalse: [ items resolveReferencesWithSpecification: aSpecification ]
	].
	
	"Resolve composition schemas"
	allOf ifNotNil: [
		allOf := allOf collect: [ :schema |
			(schema isKindOf: OpenAPIReference)
				ifTrue: [ schema resolveWithSpecification: aSpecification ]
				ifFalse: [ 
					schema resolveReferencesWithSpecification: aSpecification.
					schema
				]
		]
	].
	
	oneOf ifNotNil: [
		oneOf := oneOf collect: [ :schema |
			(schema isKindOf: OpenAPIReference)
				ifTrue: [ schema resolveWithSpecification: aSpecification ]
				ifFalse: [ 
					schema resolveReferencesWithSpecification: aSpecification.
					schema
				]
		]
	].
	
	anyOf ifNotNil: [
		anyOf := anyOf collect: [ :schema |
			(schema isKindOf: OpenAPIReference)
				ifTrue: [ schema resolveWithSpecification: aSpecification ]
				ifFalse: [ 
					schema resolveReferencesWithSpecification: aSpecification.
					schema
				]
		]
	].
]

{ #category : #accessing }
OpenAPISchema >> type [
	^ type
]