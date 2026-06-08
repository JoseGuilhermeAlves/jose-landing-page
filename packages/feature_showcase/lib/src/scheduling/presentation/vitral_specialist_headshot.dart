import 'package:design_system/design_system.dart';
import 'package:feature_showcase/src/scheduling/domain/specialist.dart';
import 'package:feature_showcase/src/scheduling/presentation/vitral_specialist_avatar.dart';
import 'package:feature_showcase/src/shared/presentation/showcase_photo.dart';
import 'package:flutter/material.dart';

/// Headshot do profissional Vitral. Usa `ShowcasePhoto` com a foto real
/// (`specialist.photoAsset`) e cai automaticamente no
/// `VitralSpecialistAvatar` (monograma desenhado em painter) enquanto o
/// `.webp` nao existe ou falha — o painter segue como rede de seguranca.
///
/// Centraliza o wiring foto+fallback pra que home, lista de servicos e
/// pagina de perfil usem exatamente a mesma composicao.
class VitralSpecialistHeadshot extends StatelessWidget {
  const VitralSpecialistHeadshot({
    required this.specialist,
    required this.size,
    this.borderRadius,
    super.key,
  });

  final Specialist specialist;

  /// Lado do headshot (quadrado quando ha foto, circular no fallback).
  final double size;

  /// Raio das bordas da foto. Null = quadrado com `AppRadius.md`.
  /// O fallback (avatar monograma) e sempre circular.
  final BorderRadius? borderRadius;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final radius = borderRadius ?? BorderRadius.circular(AppRadius.md);
    final fallback = VitralSpecialistAvatar(
      monogram: specialist.monogram,
      size: size,
      backgroundColor: colors.primary,
      foregroundColor: colors.onPrimary,
    );

    return SizedBox(
      width: size,
      height: size,
      child: ClipRRect(
        borderRadius: radius,
        child: ShowcasePhoto(
          assetPath: specialist.photoAsset,
          width: size,
          height: size,
          semanticLabel: 'Foto de ${specialist.name}, ${specialist.role}',
          fallback: fallback,
        ),
      ),
    );
  }
}
