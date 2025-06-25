Class {
	#name : 'OpenAPIModelGenerator',
	#superclass : 'Object',
	#instVars : [
		'specification',
		'packageName',
		'prefix'
	],
	#category : 'OpenAPI-Generator-Core',
	#package : 'OpenAPI-Generator-Core'
}

{ #category : 'instance creation' }
OpenAPIModelGenerator class >> forSpecification: anOpenAPISpecification [
	^ self new
		specification: anOpenAPISpecification;
		yourself
]

{ #category : 'generation' }
OpenAPIModelGenerator >> generate [
	"Generate model classes from the OpenAPI specification"
	| schemas |
	
	schemas := self specification components at: 'schemas' ifAbsent: [ Dictionary new ].
	schemas keysAndValuesDo: [ :schemaName :schemaDefinition |
		self generateModelForSchema: schemaDefinition named: schemaName
	].
]

{ #category : 'private - generation' }
OpenAPIModelGenerator >> generateJSONMappingMethodsFor: cls withSchema: schemaDefinition [
	"Generate methods for JSON serialization/deserialization"
	| properties fromJSONMethod toJSONMethod |
	
	properties := schemaDefinition at: 'properties' ifAbsent: [ Dictionary new ].
	
	"Generate fromJSON: method"
	fromJSONMethod := String streamContents: [ :stream |
		stream 
			nextPutAll: 'fromJSON: jsonObject'; cr;
			nextPutAll: '	"Initialize from JSON object"'; cr.
			
		properties keysAndValuesDo: [ :propName :propDef |
			| varName |
			varName := propName asValidInstanceVariableName.
			stream nextPutAll: ('	{1} := jsonObject at: ''{2}'' ifAbsent: [ nil ].' format: {varName. propName}); cr.
			
			"Handle nested objects"
			(propDef includesKey: '$ref') ifTrue: [
				| refType |
				refType := self typeFromRef: (propDef at: '$ref').
				stream nextPutAll: ('	{1} ifNotNil: [ {1} := {2} new fromJSON: {1} ].' format: {varName. refType}); cr.
			].
			
			"Handle arrays of objects"
			((propDef at: 'type' ifAbsent: ['']) = 'array' and: [ (propDef at: 'items' ifAbsent: [Dictionary new]) includesKey: '$ref' ]) ifTrue: [
				| refType |
				refType := self typeFromRef: ((propDef at: 'items') at: '$ref').
				stream nextPutAll: ('	{1} ifNotNil: [ {1} := {1} collect: [ :item | {2} new fromJSON: item ] ].' format: {varName. refType}); cr.
			].
		].
		
		stream nextPutAll: '	^ self'.
	].
	
	cls compile: fromJSONMethod.
	
	"Generate asJSON method"
	toJSONMethod := String streamContents: [ :stream |
		stream 
			nextPutAll: 'asJSON'; cr;
			nextPutAll: '	"Convert to JSON object"'; cr;
			nextPutAll: '	| json |'; cr;
			nextPutAll: '	json := Dictionary new.'; cr.
			
		properties keysAndValuesDo: [ :propName :propDef |
			| varName |
			varName := propName asValidInstanceVariableName.
			
			"Handle nested objects and arrays"
			stream nextPutAll: ('	{1} ifNotNil: [' format: {varName}); cr.
			
			((propDef at: 'type' ifAbsent: ['']) = 'array') 
				ifTrue: [
					stream nextPutAll: ('		json at: ''{1}'' put: ({2} collect: [ :each | each isString ifTrue: [ each ] ifFalse: [ each asJSON ] ]).' format: {propName. varName}); cr.
				]
				ifFalse: [
					stream nextPutAll: ('		json at: ''{1}'' put: ({2} isString ifTrue: [ {2} ] ifFalse: [ {2} asJSON ]).' format: {propName. varName}); cr.
				].
			
			stream nextPutAll: '	].'; cr.
		].
		
		stream nextPutAll: '	^ json'.
	].
	
	cls compile: toJSONMethod.
]

{ #category : 'private - generation' }
OpenAPIModelGenerator >> generateModelClass: className withInstanceVariables: instanceVariables schema: schemaDefinition [
	"Generate a Pharo class for the model"

	| cls |
	cls := Object classInstaller make: [ :builder |
		       builder
			       superclass: Object;
			       name: className asSymbol;
			       slotsFromString: (instanceVariables joinUsing: ' ');
			       sharedVariablesFromString: '';
			       package: self packageName;
			       environment: Object environment ].

	"Generate accessors"
	instanceVariables do: [ :ivar |
		cls compile: ('{1}
	^ {1}' format: { ivar }).

		cls compile: ('{1}: anObject
	{1} := anObject' format: { ivar }) ].

	"Generate JSON mapping methods"
	self generateJSONMappingMethodsFor: cls withSchema: schemaDefinition.

	^ cls
]

{ #category : 'private - generation' }
OpenAPIModelGenerator >> generateModelForSchema: schemaDefinition named: schemaName [
	"Generate a model class for the given schema"
	| className instanceVariables |
	
	className := self modelClassNameFor: schemaName.
	instanceVariables := self instanceVariablesForSchema: schemaDefinition.
	
	^ self generateModelClass: className withInstanceVariables: instanceVariables schema: schemaDefinition
]

{ #category : 'private - utilities' }
OpenAPIModelGenerator >> instanceVariablesForSchema: schemaDefinition [
	"Extract instance variables from schema properties"
	| properties |
	
	properties := schemaDefinition at: 'properties' ifAbsent: [ Dictionary new ].
	^ properties keys collect: [ :propName | propName asValidInstanceVariableName ]
]

{ #category : 'private - utilities' }
OpenAPIModelGenerator >> modelClassNameFor: schemaName [
	"Generate a class name for the schema"
	^ (self prefix, schemaName) asValidClassName
]

{ #category : 'accessing' }
OpenAPIModelGenerator >> packageName [
	^ packageName ifNil: [ packageName := 'OpenAPI-Generated-Models' ]
]

{ #category : 'accessing' }
OpenAPIModelGenerator >> packageName: aString [
	packageName := aString
]

{ #category : 'accessing' }
OpenAPIModelGenerator >> prefix [
	^ prefix ifNil: [ prefix := '' ]
]

{ #category : 'accessing' }
OpenAPIModelGenerator >> prefix: aString [
	prefix := aString
]

{ #category : 'accessing' }
OpenAPIModelGenerator >> specification [
	^ specification
]

{ #category : 'accessing' }
OpenAPIModelGenerator >> specification: anOpenAPISpecification [
	specification := anOpenAPISpecification
]

{ #category : 'private - utilities' }
OpenAPIModelGenerator >> typeFromRef: refString [
	"Extract type name from a $ref string"
	| parts |
	parts := refString splitOn: '/'.
	^ self modelClassNameFor: parts last
]
