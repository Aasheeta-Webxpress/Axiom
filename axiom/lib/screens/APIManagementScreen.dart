import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/ApiProvider.dart';
import '../Library/CommonWidgets/APICard.dart';
import '../Library/Utils.dart';
import '../widgets/ai_api_creator.dart';
import '../../models/ApiEndpointmodel.dart';
import '../../models/ApiFieldModel.dart';

class APIManagementScreen extends StatelessWidget {
  const APIManagementScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Load APIs when screen is first built
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ApiProvider>().loadAPIs();
    });

    return Scaffold(
      appBar: AppBar(
        title: const Text('API Management'),
        actions: [
          // AI Creator Button
          IconButton(
            icon: const Icon(Icons.auto_awesome),
            onPressed: () async {
              final result = await showDialog<Map<String, dynamic>>(
                context: context,
                builder: (context) => const AIApiCreatorDialog(),
              );

              if (result != null && context.mounted) {
                // Convert AI config to ApiEndpoint and create it
                final apiEndpoint = _convertAIConfigToApiEndpoint(result);
                final success = await context.read<ApiProvider>().createAPI(apiEndpoint);

                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        success ? '✅ AI-generated API created successfully' : '❌ Failed to create API',
                      ),
                    ),
                  );
                }
              }
            },
            tooltip: 'Create API with AI',
          ),
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () => Utils().showAddAPIDialog(context),
          ),
        ],
      ),
      body: Consumer<ApiProvider>(
        builder: (context, apiProvider, child) {
          if (apiProvider.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (apiProvider.endpoints.isEmpty) {
            return Utils().buildEmptyState(context,'api');
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: apiProvider.endpoints.length,
            itemBuilder: (context, index) {
              return APICard(
                endpoint: apiProvider.endpoints[index],
                onEdit: () => Utils().showEditAPIDialog(
                  context,
                  apiProvider.endpoints[index],
                ),
                onDelete: () => Utils().deleteAPI(
                  context,
                  apiProvider.endpoints[index],
                ),
                onTest: () => Utils().testAPI(
                  context,
                  apiProvider.endpoints[index],
                ),
              );
            },
          );
        },
      ),
    );
  }

  // Helper method to convert AI config to ApiEndpoint
  ApiEndpoint _convertAIConfigToApiEndpoint(Map<String, dynamic> config) {
    return ApiEndpoint(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      name: config['name'] ?? 'Generated API',
      method: config['method'] ?? 'POST',
      path: config['path'] ?? '/api/generated',
      purpose: config['purpose'] ?? 'create',
      collectionName: config['collection'] ?? 'generated_data',
      auth: config['auth'] ?? false,
      fields: (config['fields'] as List<dynamic>?)?.map((field) {
        return ApiField(
          name: field['name'] ?? '',
          type: _mapFieldType(field['type'] ?? 'string'),
          required: field['required'] ?? false,
          description: field['description'] ?? '',
        );
      }).toList() ?? [],
    );
  }

  // Helper method to map AI field types to ApiField types
  String _mapFieldType(String aiType) {
    switch (aiType.toLowerCase()) {
      case 'email':
      case 'phone':
      case 'password':
      case 'url':
        return 'String';
      case 'number':
      case 'integer':
        return 'Number';
      case 'boolean':
      case 'bool':
        return 'Boolean';
      case 'date':
        return 'Date';
      case 'array':
        return 'Array';
      case 'object':
        return 'Object';
      default:
        return 'String';
    }
  }
}