import '../domain/tag.dart';

enum TagError {
  deleted,
  invalidName,
  alreadyInactive,
}

class TagException implements Exception {
  final TagError error;

  const TagException(this.error);
}

class TagService {
  const TagService();

  Tag create({
    required String id,
    required String ledgerId,
    String? tagTypeId,
    required String name,
    required DateTime now,
  }) {
    _validateName(name);

    return Tag(
      id: id,
      ledgerId: ledgerId,
      tagTypeId: tagTypeId,
      name: name.trim(),
      isActive: true,
      createdAt: now,
      updatedAt: now,
      deletedAt: null,
    );
  }

  Tag update({
    required Tag tag,
    String? tagTypeId,
    required String name,
    required DateTime now,
  }) {
    _ensureActive(tag);
    _validateName(name);

    return Tag(
      id: tag.id,
      ledgerId: tag.ledgerId,
      tagTypeId: tagTypeId,
      name: name.trim(),
      isActive: tag.isActive,
      createdAt: tag.createdAt,
      updatedAt: now,
      deletedAt: tag.deletedAt,
    );
  }

  Tag deactivate({
    required Tag tag,
    required DateTime now,
  }) {
    _ensureActive(tag);

    return Tag(
      id: tag.id,
      ledgerId: tag.ledgerId,
      tagTypeId: tag.tagTypeId,
      name: tag.name,
      isActive: false,
      createdAt: tag.createdAt,
      updatedAt: now,
      deletedAt: tag.deletedAt,
    );
  }

  Tag delete({
    required Tag tag,
    required DateTime now,
  }) {
    if (tag.deletedAt != null) {
      throw const TagException(
        TagError.deleted,
      );
    }

    return Tag(
      id: tag.id,
      ledgerId: tag.ledgerId,
      tagTypeId: tag.tagTypeId,
      name: tag.name,
      isActive: false,
      createdAt: tag.createdAt,
      updatedAt: now,
      deletedAt: now,
    );
  }

  void _ensureActive(Tag tag) {
    if (tag.deletedAt != null) {
      throw const TagException(
        TagError.deleted,
      );
    }

    if (!tag.isActive) {
      throw const TagException(
        TagError.alreadyInactive,
      );
    }
  }

  void _validateName(String name) {
    if (name.trim().isEmpty) {
      throw const TagException(
        TagError.invalidName,
      );
    }
  }
}
