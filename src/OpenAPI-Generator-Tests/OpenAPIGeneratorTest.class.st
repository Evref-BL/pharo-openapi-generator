Class {
	#name : 'OpenAPIGeneratorTest',
	#superclass : 'TestCase',
	#category : 'OpenAPI-Generator-Tests',
	#package : 'OpenAPI-Generator-Tests'
}

{ #category : 'tests' }
OpenAPIGeneratorTest >> testGenerateFromJSONString [
	| json generator result |
	
	json := '{
		"openapi": "3.0.1",
		"info": {
			"title": "Test API",
			"version": "1.0.0"
		},
		"paths": {
			"/pets": {
				"get": {
					"summary": "List all pets",
					"operationId": "listPets",
					"responses": {
						"200": {
							"description": "A list of pets",
							"content": {
								"application/json": {
									"schema": {
										"type": "array",
										"items": {
											"$ref": "#/components/schemas/Pet"
										}
									}
								}
							}
						}
					}
				}
			}
		},
		"components": {
			"schemas": {
				"Pet": {
					"type": "object",
					"properties": {
						"id": {
							"type": "integer"
						},
						"name": {
							"type": "string"
						},
						"tag": {
							"type": "string"
						}
					}
				}
			}
		}
	}'.
	
	generator := OpenAPIGenerator fromJSONString: json.
	generator prefix: 'Test'.
	
	result := generator generate.
	
	self assert: result isNotNil.
	self assert: (result at: 'models') isNotNil.
	self assert: (result at: 'client') isNotNil.
]

{ #category : 'tests' }
OpenAPIGeneratorTest >> testStringExtensions [
	self assert: 'my-class-name' asValidClassName equals: 'MyClassName'.
	self assert: 'my variable' asValidVariableName equals: 'myVariable'.
	self assert: 'My-Method Name'  asValidMethodName equals: 'myMethodName'.
	self assert: 'my_instance_var' asValidInstanceVariableName equals: 'my_instance_var'.
]
