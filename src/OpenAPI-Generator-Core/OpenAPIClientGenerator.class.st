Class {
	#name : #OpenAPIClientGenerator,
	#superclass : #Object,
	#instVars : [
		'specification',
		'packageName',
		'prefix',
		'baseUrl'
	],
	#category : #'OpenAPI-Generator-Core-Generators'
}

{ #category : #'instance creation' }
OpenAPIClientGenerator class >> forSpecification: anOpenAPISpecification [
	^ self new
		specification: anOpenAPISpecification;
		yourself
]

{ #category : #accessing }
OpenAPIClientGenerator >> baseUrl [
	^ baseUrl ifNil: [ 
		| servers |
		servers := specification jsonSpec at: 'servers' ifAbsent: [ #() ].
		servers ifEmpty: [ baseUrl := 'http://localhost' ]
			ifNotEmpty: [ baseUrl := (servers first at: 'url') ]
	]
]

{ #category : #accessing }
OpenAPIClientGenerator >> baseUrl: aString [
	baseUrl := aString
]

{ #category : #generation }
OpenAPIClientGenerator >> generate [
	"Generate API client classes from the OpenAPI specification"
	| apiClass |
	
	apiClass := self generateAPIClientClass.
	self generateEndpointMethodsInClass: apiClass.
	
	^ apiClass
]

{ #category : #'private - generation' }
OpenAPIClientGenerator >> generateAPIClientClass [
	"Generate the main API client class"
	| className |
	
	className := (self prefix, (specification title asValidClassName), 'Client') asSymbol.
	
	^ Object subclass: className
		instanceVariableNames: 'baseUrl httpClient'
		classVariableNames: ''
		package: self packageName.
]

{ #category : #'private - generation' }
OpenAPIClientGenerator >> generateEndpointMethodsInClass: apiClass [
	"Generate methods for each API endpoint"
	| paths |
	
	"Generate initialization method"
	apiClass compile: 'initialize
	super initialize.
	baseUrl := ''{1}''.
	httpClient := ZnClient new.' format: {self baseUrl}.
	
	"Generate baseUrl accessor"
	apiClass compile: 'baseUrl
	^ baseUrl'.
	
	apiClass compile: 'baseUrl: aString
	baseUrl := aString'.
	
	paths := specification paths.
	paths keysAndValuesDo: [ :path :pathItem |
		pathItem keysAndValuesDo: [ :httpMethod :operation |
			(#('get' 'post' 'put' 'delete' 'patch' 'head' 'options') includes: httpMethod) ifTrue: [
				self 
					generateMethodForPath: path 
					httpMethod: httpMethod 
					operation: operation 
					inClass: apiClass
			]
		]
	]
]

{ #category : #'private - generation' }
OpenAPIClientGenerator >> generateMethodForPath: path httpMethod: httpMethod operation: operation inClass: apiClass [
	"Generate a method for a specific API endpoint"
	| methodName methodSource parameters returnType |
	
	methodName := self methodNameForOperation: operation path: path httpMethod: httpMethod.
	parameters := operation at: 'parameters' ifAbsent: [ #() ].
	returnType := self returnTypeForOperation: operation.
	
	methodSource := String streamContents: [ :stream |
		| paramNames paramString |
		
		"Method signature"
		paramNames := parameters collect: [ :param | (param at: 'name') asValidVariableName ].
		paramString := paramNames ifEmpty: [ '' ] ifNotEmpty: [ ' ' , (paramNames joinUsing: ' ') ].
		
		stream 
			nextPutAll: methodName;
			nextPutAll: paramString; cr;
			nextPutAll: '	"'; cr;
			nextPutAll: '	', (operation at: 'summary' ifAbsent: [ methodName ]); cr.
			
		(operation includesKey: 'description') ifTrue: [ 
			stream nextPutAll: '	'; nextPutAll: (operation at: 'description'); cr.
		].
		
		stream nextPutAll: '	"'; cr;
			nextPutAll: '	| url response |'; cr;
			nextPutAll: '	url := baseUrl, ''', path, '''.'; cr.
			
		"Path parameters"
		parameters do: [ :param |
			| paramName |
			paramName := (param at: 'name') asValidVariableName.
			(param at: 'in' ifAbsent: ['']) = 'path' ifTrue: [
				stream nextPutAll: '	url := url copyReplaceAll: ''{',(param at: 'name'),'}'' with: ', paramName, ' asString.'; cr.
			].
		].
		
		"Query parameters"
		| queryParams |
		queryParams := parameters select: [ :param | (param at: 'in' ifAbsent: ['']) = 'query' ].
		
		queryParams ifNotEmpty: [
			stream nextPutAll: '	url := url, ''?''.'; cr.
			queryParams doWithIndex: [ :param :index |
				| paramName |
				paramName := (param at: 'name') asValidVariableName.
				stream nextPutAll: '	', paramName, ' ifNotNil: ['; cr.
				stream nextPutAll: '		url := url, ''', (param at: 'name'), '='', ', paramName, ' asString.'; cr.
				index < queryParams size ifTrue: [
					stream nextPutAll: '		url := url, ''&''.'; cr.
				].
				stream nextPutAll: '	].'; cr.
			].
		].
		
		"HTTP request"
		stream 
			nextPutAll: '	httpClient'; cr;
			nextPutAll: '		url: url;'; cr;
			nextPutAll: '		method: #', httpMethod asUppercase, ';'; cr.
			
		"Request body"
		(operation includesKey: 'requestBody') ifTrue: [
			stream 
				nextPutAll: '		entity: (ZnEntity json: requestBody asJSON);'; cr;
				nextPutAll: '		contentType: ZnMimeType applicationJson;'; cr.
		].
		
		stream 
			nextPutAll: '		enforceHttpSuccess: true.'; cr;
			nextPutAll: '	response := httpClient execute.'; cr;
			nextPutAll: '	^ response isSuccess'; cr;
			nextPutAll: '		ifTrue: ['; cr.
			
		"Handle response"
		returnType 
			ifNil: [ stream nextPutAll: '			response contents' ]
			ifNotNil: [ stream nextPutAll: '			', returnType, ' new fromJSON: (NeoJSONReader fromString: response contents)' ].
			
		stream 
			nextPutAll: ''; cr;
			nextPutAll: '		]'; cr;
			nextPutAll: '		ifFalse: [ self error: response statusLine reason ]'.
	].
	
	apiClass compile: methodSource.
]

{ #category : #'private - utilities' }
OpenAPIClientGenerator >> methodNameForOperation: operation path: path httpMethod: httpMethod [
	"Generate a method name for the operation"
	| name |
	
	"Use operationId if available"
	(operation includesKey: 'operationId') ifTrue: [
		^ (operation at: 'operationId') asValidMethodName
	].
	
	"Otherwise generate from path and HTTP method"
	name := httpMethod, (path 
		copyReplaceAll: '/' with: '_'
		copyReplaceAll: '{' with: ''
		copyReplaceAll: '}' with: '').
		
	^ name asValidMethodName
]

{ #category : #accessing }
OpenAPIClientGenerator >> packageName [
	^ packageName ifNil: [ packageName := 'OpenAPI-Generated-Client' ]
]

{ #category : #accessing }
OpenAPIClientGenerator >> packageName: aString [
	packageName := aString
]

{ #category : #accessing }
OpenAPIClientGenerator >> prefix [
	^ prefix ifNil: [ prefix := '' ]
]

{ #category : #accessing }
OpenAPIClientGenerator >> prefix: aString [
	prefix := aString
]

{ #category : #'private - utilities' }
OpenAPIClientGenerator >> returnTypeForOperation: operation [
	"Determine the return type for an operation"
	| responses successResponse schema ref |
	
	responses := operation at: 'responses' ifAbsent: [ Dictionary new ].
	successResponse := responses at: '200' ifAbsent: [ 
		responses at: '201' ifAbsent: [ nil ]
	].
	
	successResponse ifNil: [ ^ nil ].
	
	schema := ((successResponse at: 'content' ifAbsent: [ Dictionary new ])
		at: 'application/json' ifAbsent: [ Dictionary new ])
		at: 'schema' ifAbsent: [ Dictionary new ].
		
	(schema includesKey: '$ref') ifTrue: [
		ref := schema at: '$ref'.
		^ self typeFromRef: ref
	].
	
	^ nil
]

{ #category : #accessing }
OpenAPIClientGenerator >> specification [
	^ specification
]

{ #category : #accessing }
OpenAPIClientGenerator >> specification: anOpenAPISpecification [
	specification := anOpenAPISpecification
]

{ #category : #'private - utilities' }
OpenAPIClientGenerator >> typeFromRef: refString [
	"Extract type name from a $ref string"
	| parts |
	parts := refString splitOn: '/'.
	^ (self prefix, parts last) asValidClassName
]