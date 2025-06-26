Class {
	#name : #OpenAPIReferenceResolutionTest,
	#superclass : #TestCase,
	#category : #'OpenAPI-Generator-Tests',
	#package : 'OpenAPI-Generator-Tests'
}

{ #category : #tests }
OpenAPIReferenceResolutionTest >> testComplexReferenceResolution [
	| json spec |
	
	"Create a specification with circular references"
	json := Dictionary new
		at: 'openapi' put: '3.0.0';
		at: 'info' put: (Dictionary new
			at: 'title' put: 'Test API';
			at: 'version' put: '1.0.0';
			yourself);
		at: 'paths' put: (Dictionary new
			at: '/pets/{petId}' put: (Dictionary new
				at: 'get' put: (Dictionary new
					at: 'operationId' put: 'getPetById';
					at: 'parameters' put: {
						Dictionary new
							at: '$ref' put: '#/components/parameters/petId';
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
						at: 'owner' put: (Dictionary new
							at: '$ref' put: '#/components/schemas/Owner';
							yourself);
						yourself);
					yourself);
				at: 'Owner' put: (Dictionary new
					at: 'type' put: 'object';
					at: 'properties' put: (Dictionary new
						at: 'id' put: (Dictionary new
							at: 'type' put: 'integer';
							yourself);
						at: 'name' put: (Dictionary new
							at: 'type' put: 'string';
							yourself);
						at: 'pets' put: (Dictionary new
							at: 'type' put: 'array';
							at: 'items' put: (Dictionary new
								at: '$ref' put: '#/components/schemas/Pet';
								yourself);
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
			yourself);
		yourself.
		
	spec := OpenAPISpecification fromJSON: json.
	
	"Before resolution"
	self assert: ((spec components schemas at: 'Pet') properties at: 'owner') class equals: OpenAPIReference.
	self assert: ((spec components schemas at: 'Owner') properties at: 'pets') items class equals: OpenAPIReference.
	self assert: ((spec paths paths at: '/pets/{petId}') operations at: 'get') parameters first class equals: OpenAPIReference.
	
	"Resolve references"
	spec resolveSpecification.
	
	"After resolution - verify Pet.owner reference"
	self assert: ((spec components schemas at: 'Pet') properties at: 'owner') class equals: OpenAPISchema.
	self assert: ((spec components schemas at: 'Pet') properties at: 'owner') name equals: 'Owner'.
	
	"Verify Owner.pets.items reference"
	self assert: ((spec components schemas at: 'Owner') properties at: 'pets') items class equals: OpenAPISchema.
	self assert: ((spec components schemas at: 'Owner') properties at: 'pets') items name equals: 'Pet'.
	
	"Verify parameter reference in path"
	self assert: ((spec paths paths at: '/pets/{petId}') operations at: 'get') parameters first class equals: OpenAPIParameter.
	self assert: ((spec paths paths at: '/pets/{petId}') operations at: 'get') parameters first name equals: 'petId'.
	
	"Verify response schema reference"
	self assert: ((((spec paths paths at: '/pets/{petId}') operations at: 'get') responses at: '200') content at: 'application/json') class equals: OpenAPISchema.
	self assert: ((((spec paths paths at: '/pets/{petId}') operations at: 'get') responses at: '200') content at: 'application/json') name equals: 'Pet'.
]