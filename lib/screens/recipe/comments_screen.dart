import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../../models/recipe.dart';
import '../../services/recipe_comment_service.dart';

class RecipeCommentsSection extends StatefulWidget {
  final Recipe recipe;

  const RecipeCommentsSection({super.key, required this.recipe});

  @override
  State<RecipeCommentsSection> createState() => _RecipeCommentsSectionState();
}

class _RecipeCommentsSectionState extends State<RecipeCommentsSection> {
  final RecipeCommentService _commentService = RecipeCommentService();
  final TextEditingController _commentController = TextEditingController();

  bool isSending = false;

  @override
  void dispose() {
    _commentController.dispose();
    super.dispose();
  }

  Future<void> _sendComment() async {
    final user = FirebaseAuth.instance.currentUser;
    final text = _commentController.text.trim();

    if (user == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Yorum yapmak için giriş yapmalısın')),
      );
      return;
    }

    if (text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Yorum alanı boş bırakılamaz')),
      );
      return;
    }

    setState(() {
      isSending = true;
    });

    try {
      await _commentService.addComment(
        user: user,
        recipe: widget.recipe,
        text: text,
      );

      _commentController.clear();
    } catch (_) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Yorum kaydedilirken hata oluştu')),
      );
    } finally {
      if (mounted) {
        setState(() {
          isSending = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Expanded(
          child: StreamBuilder<List<Map<String, dynamic>>>(
            stream: _commentService.watchComments(widget.recipe),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }

              if (snapshot.hasError) {
                return const Center(child: Text('Yorumlar yüklenemedi'));
              }

              final comments = snapshot.data ?? [];

              if (comments.isEmpty) {
                return Center(
                  child: Text(
                    'Bu tarife henüz yorum yapılmadı.',
                    style: TextStyle(color: Colors.grey.shade600),
                  ),
                );
              }

              return ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: comments.length,
                itemBuilder: (context, index) {
                  return _buildCommentCard(comments[index]);
                },
              );
            },
          ),
        ),
        _buildCommentInput(),
      ],
    );
  }

  Widget _buildCommentCard(Map<String, dynamic> comment) {
    final userName = comment['userName']?.toString() ?? 'Kullanıcı';
    final text = comment['text']?.toString() ?? '';
    final createdAt = comment['createdAt'];

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CircleAvatar(
            radius: 20,
            backgroundColor: const Color(0xFFE8F5E9),
            child: Text(
              _initials(userName),
              style: const TextStyle(
                color: Color(0xFF4CAF50),
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        userName,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ),
                    Text(
                      _formatDate(createdAt),
                      style: TextStyle(
                        color: Colors.grey.shade600,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                Text(text),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCommentInput() {
    final user = FirebaseAuth.instance.currentUser;
    final canComment = user != null;

    return SafeArea(
      top: false,
      child: Container(
        padding: const EdgeInsets.fromLTRB(16, 10, 16, 12),
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.06),
              blurRadius: 10,
              offset: const Offset(0, -3),
            ),
          ],
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Expanded(
              child: TextField(
                controller: _commentController,
                enabled: canComment && !isSending,
                minLines: 1,
                maxLines: 3,
                textInputAction: TextInputAction.newline,
                decoration: InputDecoration(
                  hintText: canComment
                      ? 'Yorumunu yaz...'
                      : 'Yorum yapmak için giriş yapmalısın',
                  filled: true,
                  fillColor: const Color(0xFFF7F9F7),
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 12,
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 10),
            IconButton.filled(
              style: IconButton.styleFrom(
                backgroundColor: const Color(0xFF4CAF50),
                foregroundColor: Colors.white,
              ),
              onPressed: canComment && !isSending ? _sendComment : null,
              icon: isSending
                  ? const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
                    )
                  : const Icon(Icons.send),
            ),
          ],
        ),
      ),
    );
  }

  String _initials(String name) {
    final parts = name
        .trim()
        .split(RegExp(r'\s+'))
        .where((part) => part.isNotEmpty)
        .toList();

    if (parts.isEmpty) {
      return 'K';
    }

    if (parts.length == 1) {
      return parts.first.characters.first.toUpperCase();
    }

    return '${parts.first.characters.first}${parts.last.characters.first}'
        .toUpperCase();
  }

  String _formatDate(dynamic value) {
    DateTime? date;

    if (value is Timestamp) {
      date = value.toDate();
    } else if (value is String) {
      date = DateTime.tryParse(value);
    }

    if (date == null) {
      return 'Şimdi';
    }

    final localDate = date.toLocal();
    final day = localDate.day.toString().padLeft(2, '0');
    final month = localDate.month.toString().padLeft(2, '0');
    final hour = localDate.hour.toString().padLeft(2, '0');
    final minute = localDate.minute.toString().padLeft(2, '0');

    return '$day.$month $hour:$minute';
  }
}
