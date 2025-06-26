Class {
	#name : #OpenAPISpecificationTest,
	#superclass : #TestCase,
	#instVars : [
		'sampleJSON'
	],
	#category : #'OpenAPI-Generator-Tests',
	#package : 'OpenAPI-Generator-Tests'
}

{ #category : #running }
OpenAPISpecificationTest >> setUp [
	super setUp.
	
	"Setup a sample OpenAPI specification JSON"
	sampleJSON := Dictionary new
		at: 'openapi' put: '3.0.0';
		at: 'info' put: (Dictionary new
			at: 'title' put: 'Test API';
			at: 'version' put: '1.0.0';
			yourself);
		at: 'paths' put: (Dictionary new
			at: '/pets' put: (Dictionary new
				at: 'get' put: (Dictionary new
					at: 'summary' put: 'List all pets';
					at: 'operationId' put: 'listPets';
					at: 'responses' put: (Dictionary new
						at: '200' put: (Dictionary new
							at: 'description' put: 'A list of pets';
							at: 'content' put: (Dictionary new
								at: 'application/json' put: (Dictionary new
									at: 'schema' put: (Dictionary new
										at: '$ref' put: '#/components/schemas/Pets';
										yourself);
									yourself);
								yourself);
							yourself);
						yourself);
					yourself);
				yourself);
			yourself);
		at: 'components' put: (Dictionary new
			at: 'schemas' put: (Dictionary new
				at: 'Pet' put: (Dictionary new
					at: 'type' put: 'object';
					at: 'properties' put: (Dictionary new
						at: 'id' put: (Dictionary new
							at: 'type' put: 'integer';
							yourself);
						at: 'name' put: (Dictionary new
							at: 'type' put: 'string';
							yourself);
						yourself);
					yourself);
				at: 'Pets' put: (Dictionary new
					at: 'type' put: 'array';
					at: 'items' put: (Dictionary new
						at: '$ref' put: '#/components/schemas/Pet';
						yourself);
					yourself);
				yourself);
			yourself);
		yourself
]

{ #category : #tests }
OpenAPISpecificationTest >> testFromJSON [
	| spec |
	spec := OpenAPISpecification fromJSON: sampleJSON.
	
	self assert: spec openapi equals: '3.0.0'.
	self assert: spec title equals: 'Test API'.
	self assert: spec version equals: '1.0.0'.
	
	"Test components"
	self assert: spec components schemas size equals: 2.
	self assert: (spec components schemas includesKey: 'Pet').
	self assert: (spec components schemas includesKey: 'Pets').
	
	"Test paths"
	self assert: spec paths paths size equals: 1.
	self assert: (spec paths paths includesKey: '/pets').
]

{ #category : #tests }
OpenAPISpecificationTest >> testResolveReference [
	| spec resolvedSchema |
	spec := OpenAPISpecification fromJSON: sampleJSON.
	
	resolvedSchema := spec resolveReference: '#/components/schemas/Pet'.
	
	self assert: resolvedSchema name equals: 'Pet'.
	self assert: resolvedSchema type equals: 'object'.
	self assert: resolvedSchema properties size equals: 2.
	self assert: (resolvedSchema properties at: 'id') type equals: 'integer'.
	self assert: (resolvedSchema properties at: 'name') type equals: 'string'.
]

{ #category : #tests }
OpenAPISpecificationTest >> testResolveSpecification [
	| spec petsSchema |
	spec := OpenAPISpecification fromJSON: sampleJSON.
	
	"Before resolution, Pets.items should be a reference"
	petsSchema := spec components schemas at: 'Pets'.
	self assert: (petsSchema items isKindOf: OpenAPIReference).
	
	"Resolve the specification"
	spec resolveSpecification.
	
	"After resolution, Pets.items should be a schema"
	petsSchema := spec components schemas at: 'Pets'.
	self assert: (petsSchema items isKindOf: OpenAPISchema).
	self assert: petsSchema items name equals: 'Pet'.
	
	"Check that the path operation response is also resolved"
	self assert: ((((spec paths paths at: '/pets') operations at: 'get') responses at: '200') content 
		at: 'application/json' ifAbsent: [ nil ]) notNil.
]