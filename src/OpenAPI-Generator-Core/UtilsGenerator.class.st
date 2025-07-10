Class {
	#name : 'UtilsGenerator',
	#superclass : 'Object',
	#instVars : [
		'packageName',
		'prefix',
		'createdClasses'
	],
	#category : 'OpenAPI-Generator-Core',
	#package : 'OpenAPI-Generator-Core'
}

{ #category : 'instance creation' }
UtilsGenerator class >> newWithPrefix: aPrefixAsString forPackage: aPackageNameAsSymbolOrString [
	^ self new prefix: aPrefixAsString; packageName: aPackageNameAsSymbolOrString; yourself. 
]

{ #category : 'adding' }
UtilsGenerator >> addComment: aComment inMethod: aMethodName inClass: aClass [

	| transformation |
	transformation := (RBAddMethodCommentTransformation
		                   comment: aComment
		                   inMethod: aMethodName asSymbol
		                   inClass: aClass name asSymbol) generateChanges.
	RBRefactoryChangeManager instance performChange:
		transformation model changes.
	^ aClass
]

{ #category : 'adding' }
UtilsGenerator >> addMethodWithCode: aSourceCode toClass: aClass withProtocol: protocolSymbol [ 

	| transformation |
	transformation := (RBAddMethodTransformation
		                   sourceCode: aSourceCode
		                   in: aClass
		                   withProtocol: protocolSymbol) generateChanges.

	RBRefactoryChangeManager instance performChange:
		transformation model changes.
		
	^ aClass 
]

{ #category : 'adding' }
UtilsGenerator >> addPrintOnToClass: aClass [

	| sourceCode |
	sourceCode := 'printOn: aStream
		aStream nextPutAll: self name.'.
	self
		addMethodWithCode: sourceCode
		toClass: aClass
		withProtocol: #printOn.
	^ aClass
]

{ #category : 'adding' }
UtilsGenerator >> addVariable: aVarName inClass: aClass [ 

	| transformation |
	
	((aClass instanceVariables collect: #name) includes: aVarName) ifFalse: [ 
		transformation := (RBAddVariableTransformation
		                   variable: aVarName
		                   class: aClass name asSymbol
		                   classVariable: false) generateChanges.
	RBRefactoryChangeManager instance performChange:
		transformation model changes.
		 ] .
	
	
	^ aClass
]

{ #category : 'as yet unclassified' }
UtilsGenerator >> createAccessorsFromProperties: properties inClass: newClass [ 

	properties keysDo: [ :key | "Generate instance variable"
		| comment |
		comment := (properties at: key)
			           at: #description
			           ifAbsent: [ 'TODO comment' ].

		"Generate Accessor Methods"
		self createAccessorsInClass: newClass ForVarNamed: key.
		self addComment: comment inMethod: key inClass: newClass ].

	^ newClass
]

{ #category : 'as yet unclassified' }
UtilsGenerator >> createAccessorsInClass: aClass ForVarNamed: aVarName [ 

	| transformation |
	self addVariable: aVarName inClass: aClass.  

	transformation := (RBAddVariableAccessorTransformation
		                   variable: aVarName
		                   class: aClass name asSymbol
		                   classVariable: false) generateChanges.

	RBRefactoryChangeManager instance performChange:
		transformation model changes.
	^ aClass
]

{ #category : 'as yet unclassified' }
UtilsGenerator >> createClassNamed: className fromApiSchemaDic: schema [ 
	|newClass|
	self
		  createClassNamed: className
		  fromApiSchemaDic: schema
		  withParentClass: nil.
	newClass := (prefix, className) asClassInEnvironment: self class environment.
	
	self flag: 'move importer specific creation to new method logic'.
"	self ensureNeoJSONReaderInitializerFor: newClass.
	self ensureImporterFromJsonFor: newClass. "
	
	
	^ newClass 
]

{ #category : 'as yet unclassified' }
UtilsGenerator >> createClassNamed: className fromApiSchemaDic: schema withParentClass: parentClass [ 

	| properties newClass arrayItems |
	"Determine if this is an object or array"
	schema isTypeObject ifTrue: [ "Step 1: Create a New Class
		Step 2: Add Instance Variables
		Step 3: Generate Accessor Methods
		Step 4: Add a Reference to Parent Class
		Step 5: Handle Nested Objects"
		newClass := self createNewClass: className inPackage: packageName.

		properties := schema at: 'properties' ifAbsent: [ Dictionary new ].
		self createAccessorsFromProperties: properties inClass: newClass.


		parentClass ifNotNil: [
			self
				createAccessorsInClass: newClass
				ForVarNamed: parentClass asVariableName ].

		self addPrintOnToClass: newClass. 
		self createNeoJSONReaderFor: newClass withShemaProperty: properties.

		properties keysAndValuesDo: [ :key :value |
			value isCombinedType
				ifTrue: [
					value valuesDo: [ :v |
						v do: [ :subSchema |
							self
								createClassNamed: key
								fromApiSchemaDic: subSchema
								withParentClass: newClass ] ] ]
				ifFalse: [
					self
						createClassNamed: key
						fromApiSchemaDic: value
						withParentClass: newClass ] ] ].

	schema isTypeArray ifTrue: [ "Step 6: Handle Arrays"
		arrayItems := schema at: 'items'.
		arrayItems isTypeObject ifTrue: [
			self
				createClassNamed: className
				fromApiSchemaDic: arrayItems
				withParentClass: parentClass ] ].

	^ newClass
]

{ #category : 'as yet unclassified' }
UtilsGenerator >> createNeoJSONReaderFor: aClass withShemaProperty: properties [

	| attributs sourceCode objAttributs arrayOfObjAttributs |
	sourceCode := 'configureNeoJSONReader: aNeoJSONReader
	
	"reader behavier with arrays"
	{3}
	
	"configures reader for object attributs"
	aNeoJSONReader for: self do: [ :mapping |
		mapping mapInstVars: {1}. 
		
		"all custom reader"
		{2}
		 ].
	^ aNeoJSONReader. 
	'.

	objAttributs := (properties keys select: [ :key |
		                 (properties at: key) isTypeObject ])
		                asOrderedCollection.


	arrayOfObjAttributs := (properties keys select: [ :key |
		                        (properties at: key) isTypeArrayOfObjects ])
		                       asOrderedCollection.


	"go throught the combined types"
	properties keys
		select: [ :key | (properties at: key) isCombinedType ]
		thenDo: [ :key |
			(properties at: key) valuesDo: [ :v |
				v do: [ :schema |
					schema isTypeObject ifTrue: [ objAttributs add: key ].
					schema isTypeArray ifTrue: [ arrayOfObjAttributs add: key ] ] ] ].


	attributs := properties keys copyWithoutAll:
		             arrayOfObjAttributs , objAttributs.



	sourceCode := sourceCode format: {
			              attributs asArray.
			              (String cr join: {
					               (String cr join: (objAttributs collect: [ :attr |
							                 '(mapping mapInstVar: #' , attr
							                 , ') valueSchema: ' ,  prefix
							                 , attr asPharoClassName , '.' ])).
					               (String cr join:
						                (arrayOfObjAttributs collect: [ :attr |
							                 '(mapping mapInstVar: #' , attr
							                 , ') valueSchema: #ArraysOf' ,  prefix
							                 , attr asPharoClassName , '.' ])) }).
			              (String cr join:
				               (arrayOfObjAttributs collect: [ :attr |
					                'aNeoJSONReader
					for: #ArraysOf{1}
					customDo: [ :mapping | mapping listOfElementSchema: {1} ].'
						                format:
						                { ( prefix , attr asPharoClassName) } ])) }.


	self
		addMethodWithCode: sourceCode
		toClass: aClass class
		withProtocol: #neoJSONReader.


	^ aClass
]

{ #category : 'as yet unclassified' }
UtilsGenerator >> createNewClass: aClassName inPackage: aPackageName [ 

	| transformation className |
	className := prefix , aClassName asPharoClassName.

	self class environment at: className asSymbol ifAbsent: [
		transformation := (RBInsertNewClassTransformation className:
				                   className)
			                  superclass: #Object;
			                  packageName: aPackageName asSymbol;
			                  execute.
			createdClasses add: (self class environment at: className asSymbol). 
			 ].


	^ self class environment at: className asSymbol
]

{ #category : 'as yet unclassified' }
UtilsGenerator >> ensureImporterFromJsonFor: aClass [
	|sourceCode|
	sourceCode := 'importFromJSON: aJsonString
	^ self initReader
		  on: aJsonString readStream;
		  nextAs: #ArrayOf{1}' format: { aClass name }.
		
	^ self addMethodWithCode: sourceCode toClass: aClass class  withProtocol: #import
]

{ #category : 'as yet unclassified' }
UtilsGenerator >> ensureNeoJSONReaderInitializerFor: aClass [ 
	|sourceCode|
	
	sourceCode := 'initReader
	| reader |
	reader := NeoJSONReader new.

	"initialize with all reader inside the generated package"
	#''{1}'' asPackage classes do: [ :class |
		class configureNeoJSONReader: reader ].

	reader
		for: #ArrayOf{2}
		customDo: [ :mapping | mapping listOfElementSchema: self ].


	^ reader' format: { packageName . aClass name }.
	
	^ self addMethodWithCode: sourceCode toClass: aClass class  withProtocol: #neoJSONReader.
]

{ #category : 'initialization' }
UtilsGenerator >> initialize [ 
	super initialize. 
	createdClasses := Set new. 
]

{ #category : 'accessing' }
UtilsGenerator >> packageName: aString [ 
	packageName := aString asSymbol 
]

{ #category : 'accessing' }
UtilsGenerator >> prefix: aString [ 
	prefix := aString
]
