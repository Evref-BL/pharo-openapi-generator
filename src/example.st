"Example script to generate classes from an OpenAPI specification"

| generator fileRef |

"Load the OpenAPI specification from a file"
fileRef := 'gitlab-v2_openapi.json' asFileReference.

"Create the generator"
generator := OpenAPIGenerator fromFile: fileRef.

"Configure the generator"
generator
	prefix: 'GitLab';
	modelPackageName: 'GitLab-API-Models';
	clientPackageName: 'GitLab-API-Client'.

"Generate the classes"
generator generate.

"Print a success message"
Transcript show: 'Generated classes for ', generator specification title; cr.
Transcript show: 'Models package: ', generator modelPackageName; cr.
Transcript show: 'Client package: ', generator clientPackageName; cr.