Class {
	#name : #OpenAPISpecification,
	#superclass : #OpenAPIComponent,
	#instVars : [
		'info',
		'paths',
		'components',
		'servers',
		'openapi'
	],
	#category : #'OpenAPI-Generator-Core-Model',
	#package : 'OpenAPI-Generator-Core'
}

{ #category : #'instance creation' }
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

{ #category : #'instance creation' }
OpenAPISpecification class >> fromJSONFile: aFileReference [
	"Create a new specification from a JSON file"
	| json |
	json := NeoJSONReader fromString: aFileReference contents.
	^ self fromJSON: json
]

{ #category : #'instance creation' }
OpenAPISpecification class >> fromJSONString: aString [
	"Create a new specification from a JSON string"
	| json |
	json := NeoJSONReader fromString: aString.
	^ self fromJSON: json
]

{ #category : #'instance creation' }
OpenAPISpecification class >> fromYAMLFile: aFileReference [
	"Create a new specification from a YAML file"
	| yaml json |
	yaml := aFileReference contents.
	json := OpenAPIYAMLConverter convertToJSON: yaml.
	^ self fromJSON: json
]

{ #category : #accessing }
OpenAPISpecification >> components [
	^ components
]

{ #category : #accessing }
OpenAPISpecification >> info [
	^ info
]

{ #category : #initialization }
OpenAPISpecification >> initializeWithJSON: aJSONObject [
	super initializeWithJSON: aJSONObject.
	
	openapi := aJSONObject at: 'openapi' ifAbsent: [ 
		aJSONObject at: 'swagger' ifAbsent: [ '3.0.0' ]
	].
	
	"Initialize main sections"
	info := OpenAPIInfo fromJSON: (aJSONObject at: 'info' ifAbsent: [ Dictionary new ]).
	paths := OpenAPIPaths fromJSON: (aJSONObject at: 'paths' ifAbsent: [ Dictionary new ]).
	components := OpenAPIComponents fromJSON: (aJSONObject at: 'components' ifAbsent: [ Dictionary new ]).
	
	"Initialize servers"
	servers := (aJSONObject at: 'servers' ifAbsent: [ #() ]) 
		collect: [ :serverData | OpenAPIServer fromJSON: serverData ].
]

{ #category : #accessing }
OpenAPISpecification >> jsonSpec [
	"For backward compatibility"
	^ rawData
]

{ #category : #accessing }
OpenAPISpecification >> openapi [
	^ openapi
]

{ #category : #accessing }
OpenAPISpecification >> paths [
	^ paths
]

{ #category : #resolving }
OpenAPISpecification >> resolveReference: refString [
	"Resolve a reference to its actual component"
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
	
	"Create the appropriate component based on the path"
	path second = 'schemas' ifTrue: [
		^ OpenAPISchema fromJSON: currentObject named: path last
	].
	
	path second = 'parameters' ifTrue: [
		^ OpenAPIParameter fromJSON: currentObject
	].
	
	path second = 'responses' ifTrue: [
		^ OpenAPIResponse fromJSON: currentObject
	].
	
	path second = 'requestBodies' ifTrue: [
		^ OpenAPIRequestBody fromJSON: currentObject
	].
	
	"Default case"
	^ OpenAPIComponent fromJSON: currentObject
]

{ #category : #resolving }
OpenAPISpecification >> resolveSpecification [
	"Resolve all $ref references in the specification"
	
	"First phase: resolve all references in components"
	components resolveReferencesWithSpecification: self.
	
	"Second phase: resolve all references in paths"
	paths resolveReferencesWithSpecification: self.
]

{ #category : #accessing }
OpenAPISpecification >> servers [
	^ servers
]

{ #category : #accessing }
OpenAPISpecification >> title [
	^ info title
]

{ #category : #accessing }
OpenAPISpecification >> version [
	^ info version
]