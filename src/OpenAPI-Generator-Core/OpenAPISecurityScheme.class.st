Class {
	#name : #OpenAPISecurityScheme,
	#superclass : #OpenAPIComponent,
	#instVars : [
		'type',
		'description',
		'name',
		'location',
		'scheme',
		'bearerFormat'
	],
	#category : #'OpenAPI-Generator-Core-Model',
	#package : 'OpenAPI-Generator-Core'
}

{ #category : #initialization }
OpenAPISecurityScheme >> initializeWithJSON: aJSONObject [
	super initializeWithJSON: aJSONObject.
	
	type := aJSONObject at: 'type' ifAbsent: [ '' ].
	description := aJSONObject at: 'description' ifAbsent: [ '' ].
	
	"API key properties"
	name := aJSONObject at: 'name' ifAbsent: [ '' ].
	location := aJSONObject at: 'in' ifAbsent: [ '' ].
	
	"HTTP properties"
	scheme := aJSONObject at: 'scheme' ifAbsent: [ '' ].
	bearerFormat := aJSONObject at: 'bearerFormat' ifAbsent: [ '' ].
]