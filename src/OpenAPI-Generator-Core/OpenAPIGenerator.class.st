Class {
	#name : #OpenAPIGenerator,
	#superclass : #Object,
	#instVars : [
		'specification',
		'modelGenerator',
		'clientGenerator',
		'modelPackageName',
		'clientPackageName',
		'prefix'
	],
	#category : #'OpenAPI-Generator-Core-Main'
}

{ #category : #'instance creation' }
OpenAPIGenerator class >> fromFile: aFileReference [
	"Create a generator from an OpenAPI file"
	| spec |
	spec := OpenAPISpecification fromFile: aFileReference.
	^ self new
		specification: spec;
		yourself
]

{ #category : #'instance creation' }
OpenAPIGenerator class >> fromJSONString: aString [
	"Create a generator from a JSON string"
	| spec |
	spec := OpenAPISpecification fromJSONString: aString.
	^ self new
		specification: spec;
		yourself
]

{ #category : #accessing }
OpenAPIGenerator >> clientGenerator [
	^ clientGenerator ifNil: [
		clientGenerator := OpenAPIClientGenerator forSpecification: self specification.
		clientGenerator 
			packageName: self clientPackageName;
			prefix: self prefix.
		clientGenerator
	]
]

{ #category : #accessing }
OpenAPIGenerator >> clientPackageName [
	^ clientPackageName ifNil: [ 
		| title |
		title := specification title asValidClassName.
		clientPackageName := 'OpenAPI-Generated-', title, '-Client'
	]
]

{ #category : #accessing }
OpenAPIGenerator >> clientPackageName: aString [
	clientPackageName := aString
]

{ #category : #generation }
OpenAPIGenerator >> generate [
	"Generate all classes from the OpenAPI specification"
	| models client |
	
	"Generate model classes"
	models := self modelGenerator generate.
	
	"Generate API client"
	client := self clientGenerator generate.
	
	^ Dictionary new
		at: 'models' put: models;
		at: 'client' put: client;
		yourself
]

{ #category : #accessing }
OpenAPIGenerator >> modelGenerator [
	^ modelGenerator ifNil: [
		modelGenerator := OpenAPIModelGenerator forSpecification: self specification.
		modelGenerator 
			packageName: self modelPackageName;
			prefix: self prefix.
		modelGenerator
	]
]

{ #category : #accessing }
OpenAPIGenerator >> modelPackageName [
	^ modelPackageName ifNil: [ 
		| title |
		title := specification title asValidClassName.
		modelPackageName := 'OpenAPI-Generated-', title, '-Models'
	]
]

{ #category : #accessing }
OpenAPIGenerator >> modelPackageName: aString [
	modelPackageName := aString
]

{ #category : #accessing }
OpenAPIGenerator >> prefix [
	^ prefix ifNil: [ prefix := '' ]
]

{ #category : #accessing }
OpenAPIGenerator >> prefix: aString [
	prefix := aString
]

{ #category : #accessing }
OpenAPIGenerator >> specification [
	^ specification
]

{ #category : #accessing }
OpenAPIGenerator >> specification: anOpenAPISpecification [
	specification := anOpenAPISpecification
]