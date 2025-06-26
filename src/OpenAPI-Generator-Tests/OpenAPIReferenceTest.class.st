Class {
	#name : #OpenAPIReferenceTest,
	#superclass : #TestCase,
	#category : #'OpenAPI-Generator-Tests',
	#package : 'OpenAPI-Generator-Tests'
}

{ #category : #tests }
OpenAPIReferenceTest >> testFromJSON [
	| json reference |
	json := Dictionary new
		at: '$ref' put: '#/components/schemas/Pet';
		yourself.
		
	reference := OpenAPIReference fromJSON: json.
	
	self assert: reference class equals: OpenAPIReference.
	self assert: reference refString equals: '#/components/schemas/Pet'.
]

{ #category : #tests }
OpenAPIReferenceTest >> testFromRefString [
	| reference |
	reference := OpenAPIReference fromRefString: '#/components/schemas/Pet'.
	
	self assert: reference class equals: OpenAPIReference.
	self assert: reference refString equals: '#/components/schemas/Pet'.
	self assert: (reference rawData at: '$ref') equals: '#/components/schemas/Pet'.
]

{ #category : #tests }
OpenAPIReferenceTest >> testIsReference [
	| refObject nonRefObject |
	refObject := Dictionary new
		at: '$ref' put: '#/components/schemas/Pet';
		yourself.
		
	nonRefObject := Dictionary new
		at: 'type' put: 'object';
		yourself.
		
	self assert: (OpenAPIReference isReference: refObject).
	self deny: (OpenAPIReference isReference: nonRefObject).
]

{ #category : #tests }
OpenAPIReferenceTest >> testResolveWithSpecification [
	| reference mockSpec resolvedComponent |
	reference := OpenAPIReference fromRefString: '#/components/schemas/Pet'.
	
	resolvedComponent := OpenAPISchema new.
	
	mockSpec := Object new.
	mockSpec stub
		resolveReference: '#/components/schemas/Pet';
		willReturn: resolvedComponent.
		
	self assert: (reference resolveWithSpecification: mockSpec) equals: resolvedComponent.
	self assert: reference resolvedComponent equals: resolvedComponent.
]