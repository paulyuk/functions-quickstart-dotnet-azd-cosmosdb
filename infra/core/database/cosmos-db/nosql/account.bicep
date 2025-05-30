metadata description = 'Create an Azure Cosmos DB for NoSQL account.'

param name string
param location string = resourceGroup().location
param tags object = {}

@description('Enables serverless for this account. Defaults to false.')
param enableServerless bool = false

@description('Disables key-based authentication. Defaults to false.')
param disableKeyBasedAuth bool = false

@description('Enables vector search for this account. Defaults to false.')
param enableVectorSearch bool = false

@description('Enables NoSQL full text search for this account. Defaults to false.')
param enableNoSQLFullTextSearch bool = false

module account '../account.bicep' = {
  name: 'cosmos-db-nosql-account'
  params: {
    name: name
    location: location
    tags: tags
    kind: 'GlobalDocumentDB'
    enableServerless: enableServerless
    enableNoSQLVectorSearch: enableVectorSearch
    enableNoSQLFullTextSearch: enableNoSQLFullTextSearch
    disableKeyBasedAuth: disableKeyBasedAuth
  }
}

output endpoint string = account.outputs.endpoint
output key string = account.outputs.key
output connectionString string = account.outputs.connectionString
output name string = account.outputs.name
