Class {
	#name : #OpenAPIComponent,
	#superclass : #Object,
	#instVars : [
		'rawData'
	],
	#category : #'OpenAPI-Generator-Core-Model',
	#package : 'OpenAPI-Generator-Core'
}

{ #category : #'instance creation' }
OpenAPIComponent class >> fromJSON: aJSONObject [
	"Create a new component from a JSON object"
	^ self new
		initializeWithJSON: aJSONObject;
		yourself
]

{ #category : #initialization }
OpenAPIComponent >> initializeWithJSON: aJSONObject [
	"Initialize the component with a JSON object"
	rawData := aJSONObject
]

{ #category : #accessing }
OpenAPIComponent >> rawData [
	"Return the raw JSON data"
	^ rawData
]

{ #category : #resolving }
OpenAPIComponent >> resolveReferencesWithSpecification: aSpecification [
	"Resolve references in this component using the given specification"
	"Subclasses should override this method"
]