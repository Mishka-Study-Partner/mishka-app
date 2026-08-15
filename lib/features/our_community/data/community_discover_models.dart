import 'community_json_helpers.dart';
import 'community_models.dart';

class CommunityDiscoverCard {
  const CommunityDiscoverCard({
    required this.id,
    required this.name,
    this.description,
    this.imageUrl,
    this.visibility = 'public',
    this.category = '',
    this.educationStatus,
    this.schoolTrack,
    this.schoolGrade,
    this.universityYear,
    this.subjectKeys = const [],
    this.purpose,
    this.locale = 'en',
    this.createdAt,
    this.memberCount = 0,
    this.channelCount = 0,
    this.primarySubjectLabel = '',
  });

  final String id;
  final String name;
  final String? description;
  final String? imageUrl;
  final String visibility;
  final String category;
  final String? educationStatus;
  final String? schoolTrack;
  final int? schoolGrade;
  final int? universityYear;
  final List<String> subjectKeys;
  final String? purpose;
  final String locale;
  final DateTime? createdAt;
  final int memberCount;
  final int channelCount;
  final String primarySubjectLabel;

  bool get isPublic => isPublicVisibility(visibility);

  static CommunityDiscoverCard fromJson(Map<String, dynamic> json) {
    final subjects = json['subjectKeys'];
    final subjectKeys = subjects is List
        ? subjects.map((e) => e.toString()).where((e) => e.isNotEmpty).toList()
        : const <String>[];

    DateTime? createdAt;
    final rawCreated = json['createdAt'];
    if (rawCreated != null) {
      createdAt = DateTime.tryParse(rawCreated.toString());
    }

    return CommunityDiscoverCard(
      id: readString(json, const ['id', 'communityId']),
      name: readString(json, const ['name', 'title']),
      description: readString(json, const ['description', 'about']).isEmpty
          ? null
          : readString(json, const ['description', 'about']),
      imageUrl: readString(json, const ['imageUrl', 'avatarUrl']).isEmpty
          ? null
          : readString(json, const ['imageUrl', 'avatarUrl']),
      visibility: visibilityFromRow(json),
      category: readString(json, const ['category']),
      educationStatus: readString(json, const ['educationStatus']).isEmpty
          ? null
          : readString(json, const ['educationStatus']),
      schoolTrack: readString(json, const ['schoolTrack']).isEmpty
          ? null
          : readString(json, const ['schoolTrack']),
      schoolGrade: parseInt(json['schoolGrade']) == 0
          ? null
          : parseInt(json['schoolGrade']),
      universityYear: parseInt(json['universityYear']) == 0
          ? null
          : parseInt(json['universityYear']),
      subjectKeys: subjectKeys,
      purpose: readString(json, const ['purpose']).isEmpty
          ? null
          : readString(json, const ['purpose']),
      locale: readString(json, const ['locale']).isEmpty
          ? 'en'
          : readString(json, const ['locale']),
      createdAt: createdAt,
      memberCount: parseInt(json['memberCount'] ?? json['membersCount']),
      channelCount: parseInt(
        json['channelCount'] ?? json['channelsCount'] ?? json['groupCount'],
      ),
      primarySubjectLabel:
          readString(json, const ['primarySubjectLabel', 'category']),
    );
  }

  CommunityModel toCommunityModel({String? subtitleOverride}) {
    final subtitle = subtitleOverride ??
        (primarySubjectLabel.isNotEmpty
            ? '$primarySubjectLabel · ${memberCountLabel(memberCount)}'
            : memberCountLabel(memberCount));

    return CommunityModel(
      id: id,
      name: name,
      subtitle: subtitle,
      description: description,
      imageUrl: imageUrl,
      memberCount: memberCount,
      groupCount: channelCount,
      isPublic: isPublic,
      isMember: false,
    );
  }
}

class RecommendedCommunityItem {
  const RecommendedCommunityItem({
    required this.community,
    this.score = 0,
    this.matchReason = '',
    this.matchReasonCode = '',
    this.matchTags = const [],
  });

  final CommunityDiscoverCard community;
  final int score;
  final String matchReason;
  final String matchReasonCode;
  final List<String> matchTags;

  static RecommendedCommunityItem fromJson(Map<String, dynamic> json) {
    final communityRaw = json['community'];
    final communityMap = communityRaw is Map
        ? Map<String, dynamic>.from(communityRaw)
        : json;

    final tags = json['matchTags'];
    return RecommendedCommunityItem(
      community: CommunityDiscoverCard.fromJson(communityMap),
      score: parseInt(json['score']),
      matchReason: readString(json, const ['matchReason']),
      matchReasonCode: readString(json, const ['matchReasonCode']),
      matchTags: tags is List
          ? tags.map((e) => e.toString()).toList()
          : const [],
    );
  }
}

class RecommendedFeed {
  const RecommendedFeed({
    required this.section,
    this.profileHints = const {},
    this.items = const [],
  });

  final String section;
  final Map<String, dynamic> profileHints;
  final List<RecommendedCommunityItem> items;

  bool get needsProfileEducation =>
      profileHints['educationStatus'] == null &&
      section == 'for_you' &&
      items.isEmpty;

  static RecommendedFeed fromJson(Map<String, dynamic> json) {
    final hints = json['profileHints'];
    final itemsRaw = json['items'];
    return RecommendedFeed(
      section: readString(json, const ['section']).isEmpty
          ? 'for_you'
          : readString(json, const ['section']),
      profileHints:
          hints is Map ? Map<String, dynamic>.from(hints) : const {},
      items: itemsRaw is List
          ? itemsRaw
              .whereType<Map>()
              .map(
                (row) => RecommendedCommunityItem.fromJson(
                  Map<String, dynamic>.from(row),
                ),
              )
              .toList()
          : const [],
    );
  }
}

class DiscoverCategoryChip {
  const DiscoverCategoryChip({
    required this.key,
    required this.label,
    this.communityCount = 0,
  });

  final String key;
  final String label;
  final int communityCount;

  static DiscoverCategoryChip fromJson(Map<String, dynamic> json) {
    return DiscoverCategoryChip(
      key: readString(json, const ['key']),
      label: readString(json, const ['label']),
      communityCount: parseInt(json['communityCount']),
    );
  }
}

class CommunityCategoryTitle {
  const CommunityCategoryTitle({
    required this.title,
    this.communityCount = 0,
  });

  final String title;
  final int communityCount;

  static CommunityCategoryTitle fromJson(Map<String, dynamic> json) {
    return CommunityCategoryTitle(
      title: readString(json, const ['title']),
      communityCount: parseInt(json['communityCount']),
    );
  }
}

class DiscoverCategories {
  const DiscoverCategories({
    this.subjects = const [],
    this.purposes = const [],
    this.educationLevels = const [],
    this.categoryTitles = const [],
  });

  final List<DiscoverCategoryChip> subjects;
  final List<DiscoverCategoryChip> purposes;
  final List<DiscoverCategoryChip> educationLevels;
  final List<CommunityCategoryTitle> categoryTitles;

  static DiscoverCategories fromJson(Map<String, dynamic> json) {
    List<DiscoverCategoryChip> parseList(Object? raw) {
      if (raw is! List) return const [];
      return raw
          .whereType<Map>()
          .map((e) => DiscoverCategoryChip.fromJson(Map<String, dynamic>.from(e)))
          .where((c) => c.key.isNotEmpty)
          .toList();
    }

    List<CommunityCategoryTitle> parseTitles(Object? raw) {
      if (raw is! List) return const [];
      return raw
          .whereType<Map>()
          .map(
            (e) => CommunityCategoryTitle.fromJson(
              Map<String, dynamic>.from(e),
            ),
          )
          .where((t) => t.title.isNotEmpty)
          .toList();
    }

    return DiscoverCategories(
      subjects: parseList(json['subjects']),
      purposes: parseList(json['purposes']),
      educationLevels: parseList(json['educationLevels']),
      categoryTitles: parseTitles(json['categoryTitles']),
    );
  }
}

class DiscoverBrowsePage {
  const DiscoverBrowsePage({
    this.total = 0,
    this.limit = 20,
    this.offset = 0,
    this.items = const [],
  });

  final int total;
  final int limit;
  final int offset;
  final List<CommunityDiscoverCard> items;

  bool get hasMore => offset + items.length < total;

  static DiscoverBrowsePage fromJson(Map<String, dynamic> json) {
    final itemsRaw = json['items'];
    return DiscoverBrowsePage(
      total: parseInt(json['total']),
      limit: parseInt(json['limit']) == 0 ? 20 : parseInt(json['limit']),
      offset: parseInt(json['offset']),
      items: itemsRaw is List
          ? itemsRaw
              .whereType<Map>()
              .map(
                (row) => CommunityDiscoverCard.fromJson(
                  Map<String, dynamic>.from(row),
                ),
              )
              .toList()
          : const [],
    );
  }
}
