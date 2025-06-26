Class {
	#name : #OpenAPIOperationTest,
	#superclass : #TestCase,
	#category : #'OpenAPI-Generator-Tests',
	#package : 'OpenAPI-Generator-Tests'
}

{ #category : #tests }
OpenAPIOperationTest >> testInitializeWithJSON [
	| json operation |
	json := Dictionary new
		at: 'operationId' put: 'getPetById';
		at: 'summary' put: 'Find pet by ID';
		at: 'description' put: 'Returns a single pet';
		at: 'tags' put: #('pets');
		at: 'parameters' put: {
			Dictionary new
				at: 'name' put: 'petId';
				at: 'in' put: 'path';
				at: 'required' put: true;
				at: 'schema' put: (Dictionary new
					at: 'type' put: 'integer';
					yourself);
				yourself
		};
		at: 'responses' put: (Dictionary new
			at: '200' put: (Dictionary new
				at: 'description' put: 'Successful operation';
				at: 'content' put: (Dictionary new
					at: 'application/json' put: (Dictionary new
						at: 'schema' put: (Dictionary new
							at: '$ref' put: '#/components/schemas/Pet';
							yourself);
						yourself);
					yourself);
				yourself);
			at: '404' put: (Dictionary new
				at: 'description' put: 'Pet not found';
				yourself);
			yourself);
		yourself.
		
	operation := OpenAPIOperation fromJSON: json.
	
	self assert: operation operationId equals: 'getPetById'.
	self assert: operation summary equals: 'Find pet by ID'.
	self assert: operation description equals: 'Returns a single pet'.
	self assert: operation tags equals: #('pets').
	
	"Test parameters"
	self assert: operation parameters size equals: 1.
	self assert: operation parameters first name equals: 'petId'.
	self assert: operation parameters first location equals: 'path'.
	self assert: operation parameters first required equals: true.
	
	"Test responses"
	self assert: operation responses size equals: 2.
	self assert: (operation responses includesKey: '200').
	self assert: (operation responses includesKey: '404').
	self assert: (operation responses at: '200') description equals: 'Successful operation'.
	self assert: (operation responses at: '404') description equals: 'Pet not found'.
]

{ #category : #tests }
OpenAPIOperationTest >> testResolveReferencesWithSpecification [
	| operation mockSpec petSchema |
	
	"Create an operation with a response that references a schema"
	operation := OpenAPIOperation new.
	operation initializeWithJSON: (Dictionary new
		at: 'operationId' put: 'getPetById';
		at: 'responses' put: (Dictionary new
			at: '200' put: (Dictionary new
				at: 'description' put: 'Successful operation';
				at: 'content' put: (Dictionary new
					at: 'application/json' put: (Dictionary new
						at: 'schema' put: (Dictionary new
							at: '$ref' put: '#/components/schemas/Pet';
							yourself);
						yourself);
					yourself);
				yourself);
			yourself);
		yourself).
	
	"Create a mock specification and a pet schema"
	petSchema := OpenAPISchema fromJSON: (Dictionary new
		at: 'type' put: 'object';
		at: 'properties' put: (Dictionary new
			at: 'name' put: (Dictionary new
				at: 'type' put: 'string';
				yourself);
			yourself);
		yourself) named: 'Pet'.
		
	mockSpec := Object new.
	mockSpec stub
		resolveReference: '#/components/schemas/Pet';
		willReturn: petSchema.
	
	"Resolve references"
	operation resolveReferencesWithSpecification: mockSpec.
	
	"Verify the reference was resolved"
	self assert: (((operation responses at: '200') content at: 'application/json') isKindOf: OpenAPISchema).
	self assert: ((operation responses at: '200') content at: 'application/json') name equals: 'Pet'.
]