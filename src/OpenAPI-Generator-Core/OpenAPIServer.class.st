Class {
	#name : #OpenAPIServer,
	#superclass : #OpenAPIComponent,
	#instVars : [
		'url',
		'description',
		'variables'
	],
	#category : #'OpenAPI-Generator-Core-Model',
	#package : 'OpenAPI-Generator-Core'
}

{ #category : #accessing }
OpenAPIServer >> description [
	^ description
]

{ #category : #initialization }
OpenAPIServer >> initializeWithJSON: aJSONObject [
	super initializeWithJSON: aJSONObject.
	
	url := aJSONObject at: 'url' ifAbsent: [ '' ].
	description := aJSONObject at: 'description' ifAbsent: [ '' ].
	
	"Initialize variables"
	variables := Dictionary new.
	(aJSONObject at: 'variables' ifAbsent: [ Dictionary new ]) keysAndValuesDo: [ :varName :varDef |
		variables at: varName put: varDef
	].
]

{ #category : #accessing }
OpenAPIServer >> url [
	^ url
]

{ #category : #accessing }
OpenAPIServer >> variables [
	^ variables
]