Extension { #name : 'Dictionary' }

{ #category : '*OpenAPI-Generator-Core' }
Dictionary >> isCombinedType [ 

	^ (self includesKey: #anyOf) or: [ (self includesKey: #oneOf) or: [ (self includesKey: #allOf)  ]  ]
]

{ #category : '*OpenAPI-Generator-Core' }
Dictionary >> isTypeArray [ 
	^ ({ self at: 'type' ifAbsent:[{}] } flattened includes: 'array')
]

{ #category : '*OpenAPI-Generator-Core' }
Dictionary >> isTypeArrayOfObjects [ 

	^ self isTypeArray and: [ (self at: #items) isTypeObject  ]
]

{ #category : '*OpenAPI-Generator-Core' }
Dictionary >> isTypeBoolean [ 

	^ { (self at: 'type' ifAbsent: [ {  } ]) } flattened includes:
		  'boolean'
]

{ #category : '*OpenAPI-Generator-Core' }
Dictionary >> isTypeInteger [ 

	^ { (self at: 'type' ifAbsent: [ {  } ]) } flattened includes:
		  'integer'
]

{ #category : '*OpenAPI-Generator-Core' }
Dictionary >> isTypeNumber [ 

	^ { (self at: 'type' ifAbsent: [ {  } ]) } flattened includes:
		  'number'
]

{ #category : '*OpenAPI-Generator-Core' }
Dictionary >> isTypeNumberOrInterger [ 

	^ self isTypeNumber or: [ self isInteger]. 
]

{ #category : '*OpenAPI-Generator-Core' }
Dictionary >> isTypeObject [ 

	^ { (self at: 'type' ifAbsent: [ {  } ]) } flattened includes:
		  'object'
]

{ #category : '*OpenAPI-Generator-Core' }
Dictionary >> isTypeString [ 

	^ { (self at: 'type' ifAbsent: [ {  } ]) } flattened includes:
		  'string'
]
