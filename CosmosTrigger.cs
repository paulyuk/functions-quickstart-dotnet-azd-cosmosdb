using System;
using System.Collections.Generic;
using Microsoft.Azure.Functions.Worker;
using Microsoft.Extensions.Logging;

namespace Company.Function
{
    /// <summary>
    /// Cosmos DB Trigger function that responds to changes in a Cosmos DB container.
    /// This function automatically executes when documents are added, updated, or deleted in the configured container.
    /// </summary>
    /// <remarks>
    /// Configuration is loaded from environment variables:
    /// - COSMOS_CONNECTION__accountEndpoint: The Cosmos DB account endpoint
    /// - COSMOS_DATABASE_NAME: The name of the database to monitor
    /// - COSMOS_CONTAINER_NAME: The name of the container to monitor
    /// 
    /// The function uses a lease container to track processed changes and support multiple instances.
    /// 
    /// Example document that would trigger this function when added/modified in Cosmos DB:
    /// ```json
    /// {
    ///   "id": "doc-001",
    ///   "Text": "This is a sample document",
    ///   "Number": 42,
    ///   "Boolean": true
    /// }
    /// ```
    /// 
    /// To trigger this function:
    /// 1. Add or modify a document in the configured Cosmos DB container
    /// 2. The function will automatically execute in response to the change
    /// 3. Check the function logs to see processing details
    /// </remarks>
    public class CosmosTrigger
    {
        private readonly ILogger _logger;

        public CosmosTrigger(ILoggerFactory loggerFactory)
        {
            _logger = loggerFactory.CreateLogger<CosmosTrigger>();
        }

        /// <summary>
        /// Processes changes to documents in the Cosmos DB container.
        /// </summary>
        /// <param name="input">List of documents that have been modified.</param>
        /// <remarks>
        /// This function is triggered automatically by the Cosmos DB change feed.
        /// It logs the number of documents modified and the ID of the first modified document.
        /// </remarks>
        [Function("cosmos_trigger")]
        public void Run([CosmosDBTrigger(
            databaseName: "%COSMOS_DATABASE_NAME%",
            containerName: "%COSMOS_CONTAINER_NAME%",
            Connection = "COSMOS_CONNECTION",
            LeaseContainerName = "leases",
            CreateLeaseContainerIfNotExists = true)] IReadOnlyList<MyDocument> input)
        {
            if (input != null && input.Count > 0)
            {
                _logger.LogInformation("Documents modified: " + input.Count);
                _logger.LogInformation("First document Id: " + input[0].id);
            }
        }
    }

    /// <summary>
    /// Represents the structure of documents in the Cosmos DB container being monitored.
    /// </summary>
    public class MyDocument
    {
        /// <summary>
        /// The unique identifier for the document.
        /// </summary>
        public required string id { get; set; }

        /// <summary>
        /// A text field in the document.
        /// </summary>
        public required string Text { get; set; }

        /// <summary>
        /// A numeric field in the document.
        /// </summary>
        public int Number { get; set; }

        /// <summary>
        /// A boolean field in the document.
        /// </summary>
        public bool Boolean { get; set; }
    }
}
