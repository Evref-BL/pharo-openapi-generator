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

{ #category : 'private - resolving' }
OpenAPISpecification >> resolveReference: refString [
	"Resolve a reference to its actual object"
	| parts path currentObject |
	
	parts := refString splitOn: '/'.
	
	"Skip the first part if it's '#'"
	path := parts copyWithoutFirst.
	path first = '' ifTrue: [ path := path copyWithoutFirst ].
	
	"Navigate through the JSON structure to find the referenced object"
	currentObject := jsonSpec.
	path do: [ :part |
		currentObject := currentObject at: part ifAbsent: [ Dictionary new ].
	].
	
	^ currentObject copy
]

{ #category : 'private - resolving' }
OpenAPISpecification >> resolveReferencesIn: dictionary at: key resolvedObjects: resolvedObjects [
	"Resolve references in a dictionary at a specific key using a cache of resolved objects"
	| container |
	container := dictionary at: key ifAbsent: [ Dictionary new ].
	
	container keysAndValuesDo: [ :itemKey :itemValue |
		self resolveReferencesInObject: itemValue resolvedObjects: resolvedObjects.
	].
]

{ #category : 'private - resolving' }
OpenAPISpecification >> resolveReferencesInObject: anObject resolvedObjects: resolvedObjects [
	"Recursively resolve references in an object using a cache of resolved objects"
	
	anObject isDictionary ifTrue: [
		anObject at: '$ref' ifPresent: [ :ref |
			| resolvedObject |
			
			"Check if we've already resolved this reference"
			resolvedObject := resolvedObjects at: ref ifAbsent: [
				"Not yet resolved, get the raw object"
				| rawObject |
				rawObject := self resolveReference: ref.
				
				"Store an empty dictionary as placeholder to break cycles"
				resolvedObjects at: ref put: Dictionary new.
				
				"Resolve any nested references"
				self resolveReferencesInObject: rawObject resolvedObjects: resolvedObjects.
				
				"Update the cache with the fully resolved object"
				resolvedObjects at: ref put: rawObject.
				
				rawObject
			].
			
			"Copy properties from resolved object"
			resolvedObject keysAndValuesDo: [ :key :value |
				anObject at: key put: value.
			].
			
			"Remove the $ref property"
			anObject removeKey: '$ref'.
		].
		
		"Continue resolving nested objects"
		anObject keysAndValuesDo: [ :key :value |
			self resolveReferencesInObject: value resolvedObjects: resolvedObjects.
		].
	].
	
	anObject isArray ifTrue: [
		anObject doWithIndex: [ :item :index |
			self resolveReferencesInObject: item resolvedObjects: resolvedObjects.
		].
	].
	
	^ anObject
]

{ #category : 'resolving' }
OpenAPISpecification >> resolveSpecification [
	"Resolve all $ref references in the specification"
	| resolvedObjects |
	
	"Initialize cache for resolved objects"
	resolvedObjects := Dictionary new.
	
	"First phase: resolve all references in components schemas"
	self resolveReferencesIn: components at: 'schemas' resolvedObjects: resolvedObjects.
	
	"Second phase: resolve all references in paths"
	paths keysAndValuesDo: [ :path :pathItem |
		self resolveReferencesInObject: pathItem resolvedObjects: resolvedObjects.
	].
]

{ #category : 'accessing' }
OpenAPISpecification >> title [
	^ info at: 'title' ifAbsent: [ 'Untitled API' ]
]

{ #category : 'accessing' }
OpenAPISpecification >> version [
	^ info at: 'version' ifAbsent: [ '1.0.0' ]
]
