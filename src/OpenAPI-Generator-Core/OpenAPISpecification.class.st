Class {
	#name : 'OpenAPISpecification',
	#superclass : 'Object',
	#instVars : [
		'jsonSpec',
		'paths',
		'components',
		'info'
	],
	#category : 'OpenAPI-Generator-Core',
	#package : 'OpenAPI-Generator-Core'
}

{ #category : 'instance creation' }
OpenAPISpecification class >> fromFile: aFileReference [
	"Create a new specification from a file (JSON or YAML)"
	| extension |
	extension := aFileReference extension asLowercase.
	
	extension = 'json' ifTrue: [ 
		^ self fromJSONFile: aFileReference ].
	
	extension = 'yaml' ifTrue: [ 
		^ self fromYAMLFile: aFileReference ].
	
	self error: 'Unsupported file format: ', extension
]

{ #category : 'instance creation' }
OpenAPISpecification class >> fromJSONFile: aFileReference [
	"Create a new specification from a JSON file"
	| json |
	json := NeoJSONReader fromString: aFileReference contents.
	^ self new initializeWithJSON: json
]

{ #category : 'instance creation' }
OpenAPISpecification class >> fromJSONString: aString [
	"Create a new specification from a JSON string"
	| json |
	json := NeoJSONReader fromString: aString.
	^ self new initializeWithJSON: json
]

{ #category : 'instance creation' }
OpenAPISpecification class >> fromYAMLFile: aFileReference [
	"Create a new specification from a YAML file"
	| yaml json |
	yaml := aFileReference contents.
	json := OpenAPIYAMLConverter convertToJSON: yaml.
	^ self new initializeWithJSON: json
]

{ #category : 'accessing' }
OpenAPISpecification >> components [
	^ components
]

{ #category : 'accessing' }
OpenAPISpecification >> info [
	^ info
]

{ #category : 'initialization' }
OpenAPISpecification >> initializeWithJSON: aJSONObject [
	jsonSpec := aJSONObject.
	
	"Extract main sections"
	info := jsonSpec at: 'info' ifAbsent: [ Dictionary new ].
	paths := jsonSpec at: 'paths' ifAbsent: [ Dictionary new ].
	components := jsonSpec at: 'components' ifAbsent: [ Dictionary new ].
]

{ #category : 'accessing' }
OpenAPISpecification >> jsonSpec [
	^ jsonSpec
]

{ #category : 'accessing' }
OpenAPISpecification >> paths [
	^ paths
]

{ #category : 'accessing' }
OpenAPISpecification >> title [
	^ info at: 'title' ifAbsent: [ 'Untitled API' ]
]

{ #category : 'accessing' }
OpenAPISpecification >> version [
	^ info at: 'version' ifAbsent: [ '1.0.0' ]
]
