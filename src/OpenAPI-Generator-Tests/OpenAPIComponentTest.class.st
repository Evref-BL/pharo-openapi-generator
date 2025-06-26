Class {
	#name : #OpenAPIComponentTest,
	#superclass : #TestCase,
	#instVars : [
		'sampleJSON'
	],
	#category : #'OpenAPI-Generator-Tests',
	#package : 'OpenAPI-Generator-Tests'
}

{ #category : #running }
OpenAPIComponentTest >> setUp [
	super setUp.
	
	"Setup a simple JSON object for testing"
	sampleJSON := Dictionary new
		at: 'property1' put: 'value1';
		at: 'property2' put: 'value2';
		yourself
]

{ #category : #tests }
OpenAPIComponentTest >> testFromJSON [
	| component |
	component := OpenAPIComponent fromJSON: sampleJSON.
	
	self assert: component class equals: OpenAPIComponent.
	self assert: component rawData equals: sampleJSON
]

{ #category : #tests }
OpenAPIComponentTest >> testInitializeWithJSON [
	| component |
	component := OpenAPIComponent new.
	component initializeWithJSON: sampleJSON.
	
	self assert: component rawData equals: sampleJSON
]