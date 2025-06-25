Extension { #name : #String }

{ #category : #'*OpenAPI-Generator-Core' }
String >> asValidClassName [
	"Convert a string to a valid Pharo class name"
	| result |
	result := self copy.
	
	"Replace special characters"
	result := result 
		copyReplaceAll: '-' with: '_'
		copyReplaceAll: ' ' with: '_'.
		
	"Ensure first character is uppercase"
	result := result first asUppercase asString, result allButFirst.
	
	"Remove invalid characters"
	result := result select: [ :char | char isAlphaNumeric or: [ char = $_ ] ].
	
	"Ensure it starts with a letter"
	(result first isLetter) ifFalse: [ result := 'C', result ].
	
	^ result
]

{ #category : #'*OpenAPI-Generator-Core' }
String >> asValidInstanceVariableName [
	"Convert a string to a valid Pharo instance variable name"
	| result |
	result := self copy.
	
	"Replace special characters"
	result := result 
		copyReplaceAll: '-' with: '_'
		copyReplaceAll: ' ' with: '_'.
		
	"Ensure first character is lowercase"
	result := result first asLowercase asString, result allButFirst.
	
	"Remove invalid characters"
	result := result select: [ :char | char isAlphaNumeric or: [ char = $_ ] ].
	
	"Ensure it starts with a letter"
	(result first isLetter) ifFalse: [ result := 'v', result ].
	
	^ result
]

{ #category : #'*OpenAPI-Generator-Core' }
String >> asValidMethodName [
	"Convert a string to a valid Pharo method name"
	| result |
	result := self copy.
	
	"Replace special characters"
	result := result 
		copyReplaceAll: '-' with: '_'
		copyReplaceAll: ' ' with: '_'.
		
	"Ensure first character is lowercase"
	result := result first asLowercase asString, result allButFirst.
	
	"Remove invalid characters"
	result := result select: [ :char | char isAlphaNumeric or: [ char = $_ ] ].
	
	"Ensure it starts with a letter"
	(result first isLetter) ifFalse: [ result := 'do', result ].
	
	^ result
]

{ #category : #'*OpenAPI-Generator-Core' }
String >> asValidVariableName [
	"Convert a string to a valid Pharo variable name"
	| result |
	result := self copy.
	
	"Replace special characters"
	result := result 
		copyReplaceAll: '-' with: '_'
		copyReplaceAll: ' ' with: '_'.
		
	"Ensure first character is lowercase"
	result := result first asLowercase asString, result allButFirst.
	
	"Remove invalid characters"
	result := result select: [ :char | char isAlphaNumeric or: [ char = $_ ] ].
	
	"Ensure it starts with a letter"
	(result first isLetter) ifFalse: [ result := 'var', result ].
	
	^ result
]