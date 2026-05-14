import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../../core/utils/app_colors.dart';

class ToolPreviewRenderer extends StatefulWidget {
  final Map<String, dynamic> toolData;

  const ToolPreviewRenderer({
    super.key,
    required this.toolData,
  });

  @override
  State<ToolPreviewRenderer> createState() => _ToolPreviewRendererState();
}

class _ToolPreviewRendererState extends State<ToolPreviewRenderer> {
  int currentQuestionIndex = 0;
  int? selectedAnswerIndex;
  bool answered = false;
  Map<int, bool> flashcardFlipped = {}; // Track which flashcards are flipped

  @override
  Widget build(BuildContext context) {
    final toolType = widget.toolData['tool_type'] ?? 'unknown';

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
      child: switch (toolType) {
        'flashcards' => _buildFlashcardsPreview(),
        'quiz' => _buildQuizPreview(), // Fixed: was 'quizzes'
        'quizzes' => _buildQuizPreview(), // Also support plural for compatibility
        'mind_maps' => _buildMindmapPreview(),
        'mindmap' => _buildMindmapPreview(), // Also support singular
        _ => const SizedBox.shrink(),
      },
    );
  }

  // ===========================
  // FLASHCARDS PREVIEW
  // ===========================
  Widget _buildFlashcardsPreview() {
    final cards = widget.toolData['cards'] as List<dynamic>? ?? [];

    if (cards.isEmpty) {
      return _buildEmptyState();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "📇 ${widget.toolData['title'] ?? 'Flashcards'}",
          style: TextStyle(
            fontSize: 14.sp,
            fontWeight: FontWeight.w600,
            color: AppColors.mainDark,
            fontFamily: 'Pridi',
          ),
        ),
        SizedBox(height: 12.h),
        SizedBox(
          height: 220.h, // Increased for bigger cards
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: cards.length,
            itemBuilder: (context, index) {
              final card = cards[index] as Map<String, dynamic>;
              return _buildFlashcardItem(card, index);
            },
          ),
        ),
      ],
    );
  }

  Widget _buildFlashcardItem(Map<String, dynamic> card, int index) {
    final isFlipped = flashcardFlipped[index] ?? false;

    return GestureDetector(
      onTap: () {
        setState(() {
          flashcardFlipped[index] = !isFlipped;
        });
      },
      child: AnimatedSwitcher(
        duration: const Duration(milliseconds: 300),
        transitionBuilder: (child, animation) {
          return RotationTransition(
            turns: Tween<double>(begin: 0.5, end: 1.0).animate(animation),
            child: FadeTransition(
              opacity: animation,
              child: child,
            ),
          );
        },
        child: Container(
          key: ValueKey<bool>(isFlipped),
          width: 180.w, // Made bigger
          margin: EdgeInsets.only(right: 12.w),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(14.r),
            border: Border.all(color: AppColors.mainDark, width: 1.5),
            color: Colors.white,
          ),
          child: Column(
            children: [
              // Small icon on top center
              if (card['image'] != null)
                Padding(
                  padding: EdgeInsets.only(top: 10.h),
                  child: Container(
                    height: 40.h,
                    width: 40.w,
                    decoration: BoxDecoration(
                      color: AppColors.screenBackground,
                      shape: BoxShape.circle,
                    ),
                    child: ClipOval(
                      child: Image.asset(
                        card['image'] as String,
                        fit: BoxFit.contain,
                        width: 40.w,
                        height: 40.h,
                        errorBuilder: (context, error, stackTrace) {
                          return Icon(
                            Icons.image_not_supported,
                            size: 20.sp,
                            color: AppColors.greyText,
                          );
                        },
                      ),
                    ),
                  ),
                ),
              // Content
              Expanded(
                child: Padding(
                  padding: EdgeInsets.all(12.r),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      // Front or back text
                      Expanded(
                        child: Center(
                          child: Text(
                            isFlipped
                                ? (card['back'] as String? ?? 'Answer')
                                : (card['front'] as String? ?? card['title'] as String? ?? 'Card'),
                            style: TextStyle(
                              fontSize: 12.sp,
                              fontWeight: FontWeight.w600,
                              color: AppColors.mainDark,
                              fontFamily: 'Pridi',
                            ),
                            textAlign: TextAlign.center,
                            maxLines: 6,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ),
                      SizedBox(height: 8.h),
                      // Flip indicator
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.flip,
                            size: 14.sp,
                            color: AppColors.mainDark,
                          ),
                          SizedBox(width: 4.w),
                          Text(
                            isFlipped ? 'Tap to flip back' : 'Tap to flip',
                            style: TextStyle(
                              fontSize: 10.sp,
                              color: AppColors.greyText,
                              fontFamily: 'Pridi',
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ===========================
  // QUIZ PREVIEW
  // ===========================
  Widget _buildQuizPreview() {
    final questions = widget.toolData['questions'] as List<dynamic>? ?? [];
    final total = widget.toolData['totalQuestions'] as int? ?? questions.length;

    if (questions.isEmpty) {
      return _buildEmptyState();
    }

    final question = questions[currentQuestionIndex] as Map<String, dynamic>;
    final options = List<String>.from(question['options'] as List<dynamic>? ?? []);
    final correctIndex = question['correctOptionIndex'] as int? ?? -1;

    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(color: AppColors.mainDark, width: 1.5),
        color: Colors.white,
      ),
      padding: EdgeInsets.all(14.r),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Progress
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                "❓ Question ${currentQuestionIndex + 1}/$total",
                style: TextStyle(
                  fontSize: 12.sp,
                  fontWeight: FontWeight.w600,
                  color: AppColors.mainDark,
                  fontFamily: 'Pridi',
                ),
              ),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
                decoration: BoxDecoration(
                  color: AppColors.screenBackground,
                  borderRadius: BorderRadius.circular(8.r),
                ),
                child: Text(
                  "${currentQuestionIndex + 1}/$total",
                  style: TextStyle(
                    fontSize: 11.sp,
                    fontWeight: FontWeight.w600,
                    color: AppColors.mainDark,
                    fontFamily: 'Pridi',
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 12.h),
          // Question
          Text(
            question['questionText'] as String? ?? 'Question?',
            style: TextStyle(
              fontSize: 13.sp,
              fontWeight: FontWeight.w600,
              color: AppColors.mainDark,
              fontFamily: 'Pridi',
              height: 1.4,
            ),
          ),
          SizedBox(height: 12.h),
          // Options with cat image stacked over them
          Stack(
            children: [
              // Options (behind cat)
              Column(
                children: List.generate(options.length, (optIndex) {
                  final isSelected = selectedAnswerIndex == optIndex;
                  final isCorrect = optIndex == correctIndex;
                  final showResult = answered && isSelected;

                  Color bgColor = Colors.white;
                  Color borderColor = AppColors.mainDark;
                  IconData? iconData;

                  if (showResult) {
                    if (isCorrect) {
                      bgColor = const Color(0xFFE8F5E9); // light green
                      borderColor = const Color(0xFF4CAF50); // green
                      iconData = Icons.check_circle;
                    } else {
                      bgColor = const Color(0xFFFFEBEE); // light red
                      borderColor = const Color(0xFFF44336); // red
                      iconData = Icons.cancel;
                    }
                  } else if (answered && isCorrect && !isSelected) {
                    // Show correct answer even if user selected wrong
                    bgColor = const Color(0xFFE8F5E9).withValues(alpha: 0.3);
                    borderColor = const Color(0xFF4CAF50).withValues(alpha: 0.5);
                  }

                  return GestureDetector(
                    onTap: !answered
                        ? () {
                            setState(() {
                              selectedAnswerIndex = optIndex;
                            });
                          }
                        : null,
                    child: Container(
                      width: double.infinity,
                      padding: EdgeInsets.all(10.r),
                      margin: EdgeInsets.only(bottom: 8.h),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(8.r),
                        border: Border.all(
                          color: isSelected && !answered
                              ? AppColors.mainDark.withValues(alpha: 0.5)
                              : borderColor,
                          width: isSelected && !answered ? 2.0 : 1.5,
                        ),
                        color: isSelected && !answered
                            ? AppColors.screenBackground
                            : bgColor,
                      ),
                      child: Row(
                        children: [
                          if (!answered)
                            Container(
                              width: 20.w,
                              height: 20.h,
                              margin: EdgeInsets.only(right: 8.w),
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                border: Border.all(
                                  color: isSelected
                                      ? AppColors.mainDark
                                      : AppColors.greyText,
                                  width: 2,
                                ),
                                color: isSelected
                                    ? AppColors.mainDark
                                    : Colors.transparent,
                              ),
                              child: isSelected
                                  ? Icon(
                                      Icons.check,
                                      size: 14.sp,
                                      color: Colors.white,
                                    )
                                  : null,
                            ),
                          Expanded(
                            child: Text(
                              options[optIndex],
                              style: TextStyle(
                                fontSize: 12.sp,
                                color: AppColors.mainDark,
                                fontFamily: 'Pridi',
                                fontWeight: answered ? FontWeight.w500 : FontWeight.w400,
                              ),
                            ),
                          ),
                          if (showResult && iconData != null)
                            Icon(
                              iconData,
                              color: borderColor,
                              size: 20.sp,
                            ),
                        ],
                      ),
                    ),
                  );
                }),
              ),
              // Cat image stacked over answers on the right
              if (answered)
                Positioned(
                  right: 0,
                  bottom: 0,
                  child: IgnorePointer(
                    child: selectedAnswerIndex == correctIndex
                        ? _buildHappyCat()
                        : _buildSadCat(),
                  ),
                ),
            ],
          ),
          SizedBox(height: 12.h),
          // Navigation buttons
          if (answered)
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                if (currentQuestionIndex > 0)
                  ElevatedButton.icon(
                    onPressed: _previousQuestion,
                    icon: const Icon(Icons.arrow_back),
                    label: const Text('Prev'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.mainDark,
                      foregroundColor: Colors.white,
                    ),
                  ),
                const Spacer(),
                if (currentQuestionIndex < questions.length - 1)
                  ElevatedButton.icon(
                    onPressed: _nextQuestion,
                    icon: const Icon(Icons.arrow_forward),
                    label: const Text('Next'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.mainDark,
                      foregroundColor: Colors.white,
                    ),
                  ),
              ],
            )
          else if (!answered)
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: selectedAnswerIndex != null
                    ? () {
                        setState(() {
                          answered = true;
                        });
                      }
                    : null,
                style: ElevatedButton.styleFrom(
                  backgroundColor: selectedAnswerIndex != null
                      ? AppColors.mainDark
                      : AppColors.greyText,
                  foregroundColor: Colors.white,
                ),
                child: Text(selectedAnswerIndex != null
                    ? 'Submit Answer'
                    : 'Select an answer'),
              ),
            ),
        ],
      ),
    );
  }

  // ===========================
  // MINDMAP PREVIEW
  // ===========================
  Widget _buildMindmapPreview() {
    final root = widget.toolData['root'] as String? ?? 'Root';
    final nodes = widget.toolData['nodes'] as List<dynamic>? ?? [];

    return Container(
      padding: EdgeInsets.all(16.r),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(14.r),
        border: Border.all(color: AppColors.mainDark, width: 1.5),
        color: Colors.white,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "🗺️ ${widget.toolData['title'] ?? 'Mind Map'}",
            style: TextStyle(
              fontSize: 14.sp,
              fontWeight: FontWeight.w600,
              color: AppColors.mainDark,
              fontFamily: 'Pridi',
            ),
          ),
          SizedBox(height: 16.h),
          // Real mind map visualization - scrollable in all directions
          SizedBox(
            height: 400.h,
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: SingleChildScrollView(
                scrollDirection: Axis.vertical,
                child: _buildMindMapTree(root, nodes),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMindMapTree(String root, List<dynamic> nodes) {
    // Calculate dimensions - simpler horizontal tree layout
    final nodeCount = nodes.length;
    final maxChildren = nodes.fold<int>(0, (max, node) {
      final children = (node as Map<String, dynamic>)['children'] as List<dynamic>? ?? [];
      return children.length > max ? children.length : max;
    });
    
    // Calculate width: space for nodes spread horizontally
    final width = (200 + (nodeCount * 200)).w;
    // Calculate height: root + main nodes + children
    final height = (150 + (maxChildren * 60)).h;
    final centerX = width / 2;

    return SizedBox(
      width: width,
      height: height,
      child: CustomPaint(
        painter: _MindMapPainter(root, nodes, width, height, centerX),
        child: Stack(
          children: [
            // Root node at top center
            Positioned(
              left: centerX - 90.w,
              top: 20.h,
              child: _buildMindMapNode(root, isRoot: true),
            ),
            // Main nodes spread horizontally below root
            ...List.generate(nodes.length, (index) {
              final node = nodes[index] as Map<String, dynamic>;
              final title = node['title'] as String? ?? 'Node';
              final children = node['children'] as List<dynamic>? ?? [];
              
              // Position main nodes horizontally, evenly spaced
              final nodeSpacing = width / (nodeCount + 1);
              final nodeX = (nodeSpacing * (index + 1)) - 90.w;
              final nodeY = 120.h; // Below root
              
              return Positioned(
                left: nodeX,
                top: nodeY,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    _buildMindMapNode(title, isRoot: false),
                    if (children.isNotEmpty)
                      Padding(
                        padding: EdgeInsets.only(top: 12.h),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: List.generate(children.length, (childIndex) {
                            return Padding(
                              padding: EdgeInsets.only(top: 8.h),
                              child: _buildMindMapNode(
                                children[childIndex] as String? ?? 'Child',
                                isRoot: false,
                                isChild: true,
                              ),
                            );
                          }),
                        ),
                      ),
                  ],
                ),
              );
            }),
          ],
        ),
      ),
    );
  }

  Widget _buildMindMapNode(String text, {required bool isRoot, bool isChild = false}) {
    return Container(
      constraints: BoxConstraints(
        maxWidth: isRoot ? 180.w : (isChild ? 140.w : 160.w),
        minWidth: 80.w,
      ),
      padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 10.h),
      decoration: BoxDecoration(
        color: isRoot ? AppColors.mainDark : (isChild ? Colors.white : AppColors.screenBackground),
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(
          color: AppColors.mainDark,
          width: isRoot ? 2.5 : (isChild ? 1 : 1.5),
        ),
        boxShadow: isRoot
            ? [
                BoxShadow(
                  color: AppColors.mainDark.withValues(alpha: 0.2),
                  blurRadius: 4,
                  offset: const Offset(0, 2),
                ),
              ]
            : null,
      ),
      child: Text(
        text,
        style: TextStyle(
          fontSize: isRoot ? 14.sp : (isChild ? 11.sp : 12.sp),
          fontWeight: isRoot ? FontWeight.w700 : (isChild ? FontWeight.w400 : FontWeight.w600),
          color: isRoot ? Colors.white : AppColors.mainDark,
          fontFamily: 'Pridi',
        ),
        textAlign: TextAlign.center,
        maxLines: 2,
        overflow: TextOverflow.ellipsis,
      ),
    );
  }

  // ===========================
  // CAT IMAGES
  // ===========================
  Widget _buildHappyCat() {
    return Container(
      height: 100.h,
      width: 100.w,
      alignment: Alignment.center,
      child: Image.asset(
        'assets/images/mishka_happy.png',
        height: 90.h,
        width: 90.w,
        fit: BoxFit.contain,
        errorBuilder: (context, error, stackTrace) {
          return Icon(
            Icons.sentiment_very_satisfied,
            size: 60.sp,
            color: const Color(0xFF4CAF50),
          );
        },
      ),
    );
  }

  Widget _buildSadCat() {
    return Container(
      height: 100.h,
      width: 100.w,
      alignment: Alignment.center,
      child: Image.asset(
        'assets/images/mishka_sad.png',
        height: 90.h,
        width: 90.w,
        fit: BoxFit.contain,
        errorBuilder: (context, error, stackTrace) {
          return Icon(
            Icons.sentiment_very_dissatisfied,
            size: 60.sp,
            color: const Color(0xFFF44336),
          );
        },
      ),
    );
  }

  // ===========================
  // HELPERS
  // ===========================
  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: EdgeInsets.all(12.r),
        child: Text(
          "No content to display",
          style: TextStyle(
            fontSize: 12.sp,
            color: AppColors.greyText,
            fontFamily: 'Pridi',
          ),
        ),
      ),
    );
  }

  void _nextQuestion() {
    final questions = widget.toolData['questions'] as List<dynamic>? ?? [];
    if (currentQuestionIndex < questions.length - 1) {
      setState(() {
        currentQuestionIndex++;
        selectedAnswerIndex = null;
        answered = false;
      });
    }
  }

  void _previousQuestion() {
    if (currentQuestionIndex > 0) {
      setState(() {
        currentQuestionIndex--;
        selectedAnswerIndex = null;
        answered = false;
      });
    }
  }

}

// ===========================
// MIND MAP PAINTER
// ===========================
class _MindMapPainter extends CustomPainter {
  final String root;
  final List<dynamic> nodes;
  final double width;
  final double height;
  final double centerX;

  _MindMapPainter(this.root, this.nodes, this.width, this.height, this.centerX);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = AppColors.mainDark.withValues(alpha: 0.5)
      ..strokeWidth = 2.0
      ..style = PaintingStyle.stroke;

    final nodeCount = nodes.length;
    if (nodeCount == 0) return;

    // Root position (top center)
    final rootX = centerX;
    final rootY = 70.0; // Root node center Y
    final nodeSpacing = width / (nodeCount + 1);

    // Draw connections from root to main nodes
    for (int i = 0; i < nodes.length; i++) {
      final node = nodes[i] as Map<String, dynamic>;
      final children = node['children'] as List<dynamic>? ?? [];
      
      // Calculate main node position (matching widget layout)
      final nodeX = nodeSpacing * (i + 1);
      final nodeY = 180.0; // Main node center Y (120 + 60 for node height)

      // Draw line from root bottom to main node top
      canvas.drawLine(
        Offset(rootX, rootY + 30), // Root node bottom
        Offset(nodeX, nodeY - 10), // Main node top
        paint,
      );

      // Draw connections from main nodes to their children
      for (int j = 0; j < children.length; j++) {
        final childY = nodeY + 50 + (j * 60); // Child node center Y
        canvas.drawLine(
          Offset(nodeX, nodeY + 30), // Main node bottom
          Offset(nodeX, childY - 10), // Child node top
          paint,
        );
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

