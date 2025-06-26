Class {
	#name : 'OpenAPISpecificationV2',
	#superclass : 'OpenAPIComponent',
	#instVars : [
		'info',
		'paths',
		'components',
		'servers'
	],
	#category : 'OpenAPI-Generator-Core-Model',
	#package : 'OpenAPI-Generator-Core'
}

{ #category : 'instance creation' }
OpenAPISpecificationV2 class >> fromFile: aFileReference [
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
OpenAPISpecificationV2 class >> fromJSONFile: aFileReference [
	"Create a new specification from a JSON file"
	| json |
	json := NeoJSONReader fromString: aFileReference contents.
	^ self fromJSON: json
]

{ #category : 'instance creation' }
OpenAPISpecificationV2 class >> fromJSONString: aString [
	"Create a new specification from a JSON string"
	| json |
	json := NeoJSONReader fromString: aString.
	^ self fromJSON: json
]

{ #category : 'instance creation' }
OpenAPISpecificationV2 class >> fromYAMLFile: aFileReference [
	"Create a new specification from a YAML file"
	| yaml json |
	yaml := aFileReference contents.
	json := OpenAPIYAMLConverter convertToJSON: yaml.
	^ self fromJSON: json
]

{ #category : 'accessing' }
OpenAPISpecificationV2 >> components [
	^ components
]

{ #category : 'accessing' }
OpenAPISpecificationV2 >> info [
	^ info
]

{ #category : 'initialization' }
OpenAPISpecificationV2 >> initializeWithJSON: aJSONObject [
	super initializeWithJSON: aJSONObject.
	
	"Extract main sections"
	info := OpenAPIInfo fromJSON: (aJSONObject at: 'info' ifAbsent: [ Dictionary new ]).
	paths := OpenAPIPaths fromJSON: (aJSONObject at: 'paths' ifAbsent: [ Dictionary new ]).
	components := OpenAPIComponents fromJSON: (aJSONObject at: 'components' ifAbsent: [ Dictionary new ]).
	servers := (aJSONObject at: 'servers' ifAbsent: [ #() ]) 
		collect: [ :serverData | OpenAPIServer fromJSON: serverData ].
]

{ #category : 'accessing' }
OpenAPISpecificationV2 >> jsonSpec [
	"For backward compatibility"
	^ rawData
]

{ #category : 'accessing' }
OpenAPISpecificationV2 >> paths [
	^ paths
]

{ #category : 'resolving' }
OpenAPISpecificationV2 >> resolveReference: refString [
	"Resolve a reference to its actual object"
	| parts path currentObject |
	
	parts := refString splitOn: '/'.
	
	"Skip the first part if it's '#'"
	path := parts copyWithoutFirst.
	path first = '' ifTrue: [ path := path copyWithoutFirst ].
	
	"Navigate through the JSON structure to find the referenced object"
	currentObject := rawData.
	path do: [ :part |
		currentObject := currentObject at: part ifAbsent: [ Dictionary new ].
	].
	
	^ currentObject copy
]

{ #category : 'resolving' }
OpenAPISpecificationV2 >> resolveSpecification [
	"Resolve all $ref references in the specification"
	components resolveReferencesWithSpecification: self.
	paths resolveReferencesWithSpecification: self.
]

{ #category : 'accessing' }
OpenAPISpecificationV2 >> servers [
	^ servers
]

{ #category : 'accessing' }
OpenAPISpecificationV2 >> title [
	^ info title
]

{ #category : 'accessing' }
OpenAPISpecificationV2 >> version [
	^ info version
]