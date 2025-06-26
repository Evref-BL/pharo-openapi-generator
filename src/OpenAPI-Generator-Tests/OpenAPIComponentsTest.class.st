Class {
	#name : #OpenAPIComponentsTest,
	#superclass : #TestCase,
	#category : #'OpenAPI-Generator-Tests',
	#package : 'OpenAPI-Generator-Tests'
}

{ #category : #tests }
OpenAPIComponentsTest >> testInitializeWithJSON [
	| json components |
	json := Dictionary new
		at: 'schemas' put: (Dictionary new
			at: 'Pet' put: (Dictionary new
				at: 'type' put: 'object';
				at: 'properties' put: (Dictionary new
					at: 'name' put: (Dictionary new
						at: 'type' put: 'string';
						yourself);
					yourself);
				yourself);
			at: 'Error' put: (Dictionary new
				at: 'type' put: 'object';
				at: 'properties' put: (Dictionary new
					at: 'code' put: (Dictionary new
						at: 'type' put: 'integer';
						yourself);
					at: 'message' put: (Dictionary new
						at: 'type' put: 'string';
						yourself);
					yourself);
				yourself);
			yourself);
		at: 'parameters' put: (Dictionary new
			at: 'petId' put: (Dictionary new
				at: 'name' put: 'petId';
				at: 'in' put: 'path';
				at: 'required' put: true;
				at: 'schema' put: (Dictionary new
					at: 'type' put: 'integer';
					yourself);
				yourself);
			yourself);
		at: 'responses' put: (Dictionary new
			at: 'NotFound' put: (Dictionary new
				at: 'description' put: 'Entity not found';
				yourself);
			yourself);
		yourself.
		
	components := OpenAPIComponents fromJSON: json.
	
	"Test schemas"
	self assert: components schemas size equals: 2.
	self assert: (components schemas includesKey: 'Pet').
	self assert: (components schemas includesKey: 'Error').
	self assert: (components schemas at: 'Pet') name equals: 'Pet'.
	self assert: (components schemas at: 'Error') name equals: 'Error'.
	
	"Test parameters"
	self assert: components parameters size equals: 1.
	self assert: (components parameters includesKey: 'petId').
	self assert: (components parameters at: 'petId') name equals: 'petId'.
	
	"Test responses"
	self assert: components responses size equals: 1.
	self assert: (components responses includesKey: 'NotFound').
	self assert: (components responses at: 'NotFound') description equals: 'Entity not found'.
]

{ #category : #tests }
OpenAPIComponentsTest >> testResolveReferencesWithSpecification [
	| components mockSpec petSchema ownerSchema |
	
	"Create components with schemas that reference each other"
	components := OpenAPIComponents new.
	
	petSchema := OpenAPISchema fromJSON: (Dictionary new
		at: 'type' put: 'object';
		at: 'properties' put: (Dictionary new
			at: 'owner' put: (Dictionary new
				at: '$ref' put: '#/components/schemas/Owner';
				yourself);
			yourself);
		yourself) named: 'Pet'.
		
	ownerSchema := OpenAPISchema fromJSON: (Dictionary new
		at: 'type' put: 'object';
		at: 'properties' put: (Dictionary new
			at: 'pets' put: (Dictionary new
				at: 'type' put: 'array';
				at: 'items' put: (Dictionary new
					at: '$ref' put: '#/components/schemas/Pet';
					yourself);
				yourself);
			yourself);
		yourself) named: 'Owner'.
	
	components instVarNamed: 'schemas' put: (Dictionary new
		at: 'Pet' put: petSchema;
		at: 'Owner' put: ownerSchema;
		yourself).
	
	"Create a mock specification"
	mockSpec := Object new.
	mockSpec stub
		resolveReference: '#/components/schemas/Pet';
		willReturn: petSchema.
	mockSpec stub
		resolveReference: '#/components/schemas/Owner';
		willReturn: ownerSchema.
	
	"Resolve references"
	components resolveReferencesWithSpecification: mockSpec.
	
	"Verify the references were resolved"
	self assert: (((components schemas at: 'Pet') properties at: 'owner') isKindOf: OpenAPISchema).
	self assert: ((components schemas at: 'Pet') properties at: 'owner') name equals: 'Owner'.
	
	self assert: (((components schemas at: 'Owner') properties at: 'pets') items isKindOf: OpenAPISchema).
	self assert: ((components schemas at: 'Owner') properties at: 'pets') items name equals: 'Pet'.
]