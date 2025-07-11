Extension { #name : 'String' }

{ #category : '*OpenAPI-Generator-Core' }
String >> asNormalizedIdentifier [

	| newString |
	newString := self collect: [ :c |
		             (c isLetter or: [ c isDigit ])
			             ifTrue: [ c asCharacter ]
			             ifFalse: [ Character space ] ].
	newString first isDigit ifTrue: [ newString := 'T' , newString ].

	^ newString asCamelCase
]

{ #category : '*OpenAPI-Generator-Core' }
String >> asPharoClassName [ 

	| newString |
	newString := self collect: [ :c |
		             (c isLetter or: [ c isDigit ])
			             ifTrue: [ c asCharacter ]
			             ifFalse: [ Character space ] ].
	newString first isDigit ifTrue: [ newString := 'T' , newString ].

	^ newString asCamelCase
]

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
	|symbol2word|
	"Convert a string to a valid Pharo variable name"
	
	symbol2word := {
    '+'-> 'plus'.
    '-'-> 'minus'.
    '*'-> 'times'.
    '/'-> 'div'.
    '%'-> 'mod'.
    '='-> 'eq'.
    '=='-> 'eqeq'.
    '!='-> 'noteq'.
    '>'-> 'gt'.
    '<'-> 'lt'.
    '>='-> 'gte'.
    '<='-> 'lte'
} asDictionary .
	
	^ ('' join: (self asArray collect: [:c | symbol2word at: (c asString) ifAbsent:[c]])) asCamelCase asValidSelector
]
