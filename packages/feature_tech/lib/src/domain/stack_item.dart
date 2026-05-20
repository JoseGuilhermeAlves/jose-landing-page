import 'package:equatable/equatable.dart';
import 'package:feature_tech/src/domain/stack_category.dart';

/// Item do stack — nome + versao mostrada inline + breve role
/// explicando o por que ele esta no projeto.
class StackItem extends Equatable {
  const StackItem({
    required this.name,
    required this.version,
    required this.role,
    required this.category,
  });

  final String name;
  final String version;
  final String role;
  final StackCategory category;

  @override
  List<Object?> get props => [name, version, role, category];
}
