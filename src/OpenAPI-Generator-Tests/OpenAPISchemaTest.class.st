Class {
	#name : #OpenAPISchemaTest,
	#superclass : #TestCase,
	#category : #'OpenAPI-Generator-Tests',
	#package : 'OpenAPI-Generator-Tests'
}

{ #category : #tests }
OpenAPISchemaTest >> testFromJSON [
	| json schema |
	json := Dictionary new
		at: 'type' put: 'object';
		at: 'properties' put: (Dictionary new
			at: 'id' put: (Dictionary new
				at: 'type' put: 'integer';
				yourself);
			at: 'name' put: (Dictionary new
				at: 'type' put: 'string';
				yourself);
			yourself);
		at: 'required' put: #('id' 'name');
		yourself.
		
	schema := OpenAPISchema fromJSON: json.
	
	self assert: schema class equals: OpenAPISchema.
	self assert: schema type equals: 'object'.
	self assert: schema required equals: #('id' 'name').
	self assert: schema properties size equals: 2.
	self assert: (schema properties at: 'id') type equals: 'integer'.
	self assert: (schema properties at: 'name') type equals: 'string'.
]

{ #category : #tests }
OpenAPISchemaTest >> testFromJSONHandlesReference [
	| json result |
	json := Dictionary new
		at: '$ref' put: '#/components/schemas/Pet';
		yourself.
		
	result := OpenAPISchema fromJSON: json.
	
	self assert: result class equals: OpenAPIReference.
	self assert: result refString equals: '#/components/schemas/Pet'.
]

{ #category : #tests }
OpenAPISchemaTest >> testFromJSONWithName [
	| json schema |
	json := Dictionary new
		at: 'type' put: 'object';
		yourself.
		
	schema := OpenAPISchema fromJSON: json named: 'Pet'.
	
	self assert: schema name equals: 'Pet'.
]

{ #category : #tests }
OpenAPISchemaTest >> testResolveReferencesWithSpecification [
	| schema mockSpec petRef |
	
	"Create a schema with a property that references another schema"
	schema := OpenAPISchema new.
	schema initializeWithJSON: (Dictionary new
		at: 'type' put: 'object';
		at: 'properties' put: (Dictionary new
			at: 'pet' put: (Dictionary new
				at: '$ref' put: '#/components/schemas/Pet';
				yourself);
			yourself);
		yourself).
	
	"Create a mock specification and a resolved pet schema"
	petRef := OpenAPIReference fromRefString: '#/components/schemas/Pet'.
	mockSpec := Object new.
	mockSpec stub
		resolveReference: '#/components/schemas/Pet';
		willReturn: (OpenAPISchema fromJSON: (Dictionary new
			at: 'type' put: 'object';
			at: 'properties' put: (Dictionary new
				at: 'name' put: (Dictionary new
					at: 'type' put: 'string';
					yourself);
				yourself);
			yourself) named: 'Pet').
	
	"Resolve references"
	schema resolveReferencesWithSpecification: mockSpec.
	
	"Verify the reference was resolved"
	self assert: ((schema properties at: 'pet') isKindOf: OpenAPISchema).
	self assert: (schema properties at: 'pet') name equals: 'Pet'.
]