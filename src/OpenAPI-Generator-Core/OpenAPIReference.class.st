Class {
	#name : #OpenAPIReference,
	#superclass : #OpenAPIComponent,
	#instVars : [
		'refString',
		'resolvedComponent'
	],
	#category : #'OpenAPI-Generator-Core-Model',
	#package : 'OpenAPI-Generator-Core'
}

{ #category : #'instance creation' }
OpenAPIReference class >> fromJSON: aJSONObject [
	"Create a reference from a JSON object containing $ref"
	^ self new
		initializeWithJSON: aJSONObject;
		yourself
]

{ #category : #'instance creation' }
OpenAPIReference class >> fromRefString: aString [
	"Create a reference from a reference string"
	^ self new
		initializeWithRefString: aString;
		yourself
]

{ #category : #testing }
OpenAPIReference class >> isReference: aJSONObject [
	"Check if a JSON object is a reference"
	^ aJSONObject isDictionary and: [ aJSONObject includesKey: '$ref' ]
]

{ #category : #initialization }
OpenAPIReference >> initializeWithJSON: aJSONObject [
	super initializeWithJSON: aJSONObject.
	refString := aJSONObject at: '$ref'.
]

{ #category : #initialization }
OpenAPIReference >> initializeWithRefString: aString [
	refString := aString.
	rawData := Dictionary new
		at: '$ref' put: aString;
		yourself.
]

{ #category : #accessing }
OpenAPIReference >> refString [
	"Get the reference string"
	^ refString
]

{ #category : #accessing }
OpenAPIReference >> resolvedComponent [
	"Get the resolved component"
	^ resolvedComponent
]

{ #category : #accessing }
OpenAPIReference >> resolvedComponent: aComponent [
	"Set the resolved component"
	resolvedComponent := aComponent
]

{ #category : #resolving }
OpenAPIReference >> resolveWithSpecification: aSpecification [
	"Resolve this reference using the given specification"
	resolvedComponent := aSpecification resolveReference: refString.
	^ resolvedComponent
]