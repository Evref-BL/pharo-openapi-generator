Class {
	#name : #OpenAPIInfo,
	#superclass : #OpenAPIComponent,
	#instVars : [
		'title',
		'description',
		'version',
		'contact',
		'license'
	],
	#category : #'OpenAPI-Generator-Core-Model',
	#package : 'OpenAPI-Generator-Core'
}

{ #category : #initialization }
OpenAPIInfo >> initializeWithJSON: aJSONObject [
	super initializeWithJSON: aJSONObject.
	
	title := aJSONObject at: 'title' ifAbsent: [ 'Untitled API' ].
	description := aJSONObject at: 'description' ifAbsent: [ '' ].
	version := aJSONObject at: 'version' ifAbsent: [ '1.0.0' ].
	
	(aJSONObject includesKey: 'contact') ifTrue: [
		contact := aJSONObject at: 'contact'
	].
	
	(aJSONObject includesKey: 'license') ifTrue: [
		license := aJSONObject at: 'license'
	].
]

{ #category : #accessing }
OpenAPIInfo >> description [
	^ description
]

{ #category : #accessing }
OpenAPIInfo >> title [
	^ title
]

{ #category : #accessing }
OpenAPIInfo >> version [
	^ version
]