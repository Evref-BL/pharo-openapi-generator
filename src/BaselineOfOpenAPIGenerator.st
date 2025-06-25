Class {
	#name : #BaselineOfOpenAPIGenerator,
	#superclass : #BaselineOf,
	#category : #BaselineOfOpenAPIGenerator
}

{ #category : #baselines }
BaselineOfOpenAPIGenerator >> baseline: spec [
	<baseline>
	spec for: #common do: [
		"Dependencies"
		spec
			baseline: 'NeoJSON' 
			with: [ spec repository: 'github://svenvc/NeoJSON/repository' ].
			
		"Packages"
		spec 
			package: 'OpenAPI-Generator-Core' with: [ spec requires: #('NeoJSON') ];
			package: 'OpenAPI-Generator-Tests' with: [ spec requires: #('OpenAPI-Generator-Core') ].
			
		"Groups"
		spec
			group: 'Core' with: #('OpenAPI-Generator-Core');
			group: 'Tests' with: #('OpenAPI-Generator-Tests');
			group: 'default' with: #('Core' 'Tests')
	]
]