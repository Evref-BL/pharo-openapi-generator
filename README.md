# OpenAPI Generator pour Pharo Smalltalk

Ce projet est un générateur de classes Pharo Smalltalk à partir de spécifications OpenAPI 3.0.1. Il permet de générer automatiquement des modèles et un client API à partir d'un fichier de spécification OpenAPI au format JSON ou YAML.

## Fonctionnalités

- Conversion de fichiers YAML en JSON
- Génération de classes de modèles à partir des schémas OpenAPI
- Génération d'un client API avec des méthodes pour chaque endpoint
- Support des paramètres de chemin, de requête et de corps
- Support des réponses typées

## Installation

Pour installer ce projet dans Pharo 12, exécutez le code suivant dans un Playground :

```smalltalk
Metacello new
    baseline: 'OpenAPIGenerator';
    repository: 'github://votre-utilisateur/pharo-openapi-generator:main';
    load.
```

## Utilisation

### Génération à partir d'un fichier JSON

```smalltalk
| generator fileRef |

"Load the OpenAPI specification from a file"
fileRef := '/path/to/openapi.json' asFileReference.

"Create the generator"
generator := OpenAPIGenerator fromFile: fileRef.

"Configure the generator"
generator
    prefix: 'MyAPI';
    modelPackageName: 'MyAPI-Models';
    clientPackageName: 'MyAPI-Client'.

"Generate the classes"
generator generate.
```

### Génération à partir d'un fichier YAML

```smalltalk
| generator fileRef |

"Load the OpenAPI specification from a file"
fileRef := '/path/to/openapi.yaml' asFileReference.

"Create the generator"
generator := OpenAPIGenerator fromFile: fileRef.

"Configure the generator"
generator
    prefix: 'MyAPI';
    modelPackageName: 'MyAPI-Models';
    clientPackageName: 'MyAPI-Client'.

"Generate the classes"
generator generate.
```

### Utilisation du client généré

```smalltalk
| client pets |

"Create a client instance"
client := MyAPIPetstoreClient new.
client baseUrl: 'https://petstore.swagger.io/v2'.

"Call an API endpoint"
pets := client listPets.
pets do: [ :pet |
    Transcript show: pet name; cr.
].
```

## Structure du projet

- `OpenAPISpecification` : Classe principale pour représenter une spécification OpenAPI
- `OpenAPIYAMLConverter` : Convertisseur de YAML vers JSON
- `OpenAPIModelGenerator` : Générateur de classes de modèles
- `OpenAPIClientGenerator` : Générateur de client API
- `OpenAPIGenerator` : Classe principale qui coordonne la génération

## Limitations

- Support limité des types complexes (oneOf, anyOf, allOf)
- Pas de support pour les fichiers de spécification séparés (références externes)
- Le convertisseur YAML vers JSON est basique et peut ne pas supporter toutes les fonctionnalités YAML

## Contribution

Les contributions sont les bienvenues ! N'hésitez pas à ouvrir une issue ou une pull request pour améliorer ce projet.