Extension { #name : 'String' }

{ #category : '*OpenAPI-Generator-Core' }
String >> asValidClassName [
	"Convert a string to a valid Pharo class name"
	
	^ self asPharoClassName
]

{ #category : '*OpenAPI-Generator-Core' }
String >> asValidInstanceVariableName [
	"Convert a string to a valid Pharo instance variable name"

	self asValidVariableName 
]

{ #category : '*OpenAPI-Generator-Core' }
String >> asValidMethodName [
	"Convert a string to a valid Pharo method name"

	^ self asValidSelector
]

{ #category : '*OpenAPI-Generator-Core' }
String >> asValidVariableName [
	"Convert a string to a valid Pharo variable name"

	^self asCamelCase asValidSelector
]
