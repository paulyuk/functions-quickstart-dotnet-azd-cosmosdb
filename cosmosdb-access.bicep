metadata description = 'Create role assignment and definition resources.'

// Cosmos DB RBAC (Data Plane) - Custom Role Definition and Assignments using native resources
@description('Id of the service principals to assign database and application roles.')
param appPrincipalId string = ''

@description('Id of the user principals to assign database and application roles.')
param userPrincipalId string = ''

param databaseAccountName string
resource database 'Microsoft.DocumentDB/databaseAccounts@2023-04-15' existing = {
  name: databaseAccountName
}

// Custom Cosmos DB SQL Role Definition (as child resource)
resource nosqlRoleDefinition 'Microsoft.DocumentDB/databaseAccounts/sqlRoleDefinitions@2023-04-15' = {
  name: 'custom-nosql-writer-role'
  parent: database
  properties: {
    roleName: 'Write to Azure Cosmos DB for NoSQL data plane'
    type: 'CustomRole'
    assignableScopes: [database.id]
    permissions: [
      {
        dataActions: [
          'Microsoft.DocumentDB/databaseAccounts/readMetadata'
          'Microsoft.DocumentDB/databaseAccounts/sqlDatabases/containers/items/*'
          'Microsoft.DocumentDB/databaseAccounts/sqlDatabases/containers/*'
        ]
        notDataActions: []
      }
    ]
  }
}

// Cosmos DB SQL Role Assignment (App Principal)
resource nosqlAppAssignment 'Microsoft.DocumentDB/databaseAccounts/sqlRoleAssignments@2023-04-15' = if (!empty(appPrincipalId)) {
  name: guid(database.id, appPrincipalId, nosqlRoleDefinition.id)
  parent: database
  properties: {
    roleDefinitionId: nosqlRoleDefinition.id
    principalId: appPrincipalId
    scope: database.id
  }
}

// Cosmos DB SQL Role Assignment (User Principal)
resource nosqlUserAssignment 'Microsoft.DocumentDB/databaseAccounts/sqlRoleAssignments@2023-04-15' = if (!empty(userPrincipalId)) {
  name: guid(database.id, userPrincipalId, nosqlRoleDefinition.id)
  parent: database
  properties: {
    roleDefinitionId: nosqlRoleDefinition.id
    principalId: userPrincipalId
    scope: database.id
  }
}
