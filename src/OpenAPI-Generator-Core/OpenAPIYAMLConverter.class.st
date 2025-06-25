Class {
	#name : #OpenAPIYAMLConverter,
	#superclass : #Object,
	#category : #'OpenAPI-Generator-Core-Utilities'
}

{ #category : #conversion }
OpenAPIYAMLConverter class >> convertToJSON: yamlString [
	"Convert a YAML string to a JSON object"
	| result |
	
	"Try to use the YAML parser if available"
	self environment 
		at: #YAMLParser 
		ifPresent: [ :yamlParserClass | 
			result := yamlParserClass parse: yamlString.
			^ result ].
	
	"Fallback to our simple YAML parser"
	^ self parseYAML: yamlString
]

{ #category : #'private - parsing' }
OpenAPIYAMLConverter class >> parseYAML: yamlString [
	"A simple YAML parser for OpenAPI specifications"
	| lines currentIndent currentKey currentObject stack result |
	
	lines := yamlString lines.
	stack := OrderedCollection new.
	result := Dictionary new.
	stack addLast: result.
	currentIndent := 0.
	
	lines do: [ :line |
		| trimmedLine indent keyValue |
		trimmedLine := line trimLeft.
		
		"Skip empty lines and comments"
		(trimmedLine isEmpty or: [ trimmedLine beginsWith: '#' ]) ifFalse: [
			indent := line size - trimmedLine size.
			
			"Handle indentation changes"
			indent > currentIndent 
				ifTrue: [ 
					"Going deeper in the hierarchy"
					| newObject |
					newObject := (trimmedLine beginsWith: '- ') 
						ifTrue: [ OrderedCollection new ]
						ifFalse: [ Dictionary new ].
					
					currentObject at: currentKey put: newObject.
					stack addLast: newObject.
					currentObject := newObject.
				]
				ifFalse: [ 
					"Going back up in the hierarchy"
					[ indent < currentIndent ] whileTrue: [
						stack removeLast.
						currentIndent := currentIndent - 2.
						currentObject := stack last.
					].
				].
			
			currentIndent := indent.
			
			"Parse the line content"
			(trimmedLine beginsWith: '- ') 
				ifTrue: [
					"List item"
					| value |
					value := (trimmedLine allButFirst: 2) trimBoth.
					currentObject add: value.
				]
				ifFalse: [
					"Key-value pair"
					keyValue := trimmedLine splitOn: ':'.
					currentKey := keyValue first trimBoth.
					
					keyValue size > 1 ifTrue: [
						| value |
						value := (keyValue second trimBoth).
						value isEmpty 
							ifFalse: [ currentObject at: currentKey put: value ].
					].
				].
		].
	].

	^ result
]