import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../models/recipe.dart';
import '../services/user_profile_service.dart';

class FavoriteRecipeButton extends StatefulWidget {
  final Recipe recipe;
  final double iconSize;
  final double buttonSize;
  final Color activeColor;
  final Color inactiveColor;
  final Color? backgroundColor;

  const FavoriteRecipeButton({
    super.key,
    required this.recipe,
    this.iconSize = 24,
    this.buttonSize = 40,
    this.activeColor = Colors.red,
    this.inactiveColor = Colors.grey,
    this.backgroundColor,
  });

  @override
  State<FavoriteRecipeButton> createState() => _FavoriteRecipeButtonState();
}

class _FavoriteRecipeButtonState extends State<FavoriteRecipeButton> {
  static final UserProfileService _profileService = UserProfileService();

  bool isBusy = false;

  Future<void> _toggleFavorite(bool isFavorite) async {
    final user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Favorilere eklemek için giriş yapmalısın'),
        ),
      );
      return;
    }

    setState(() {
      isBusy = true;
    });

    try {
      await _profileService.toggleFavoriteRecipe(user, widget.recipe);

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            isFavorite ? 'Favorilerden çıkarıldı' : 'Favorilere eklendi',
          ),
        ),
      );
    } catch (_) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Favori güncellenirken hata oluştu')),
      );
    } finally {
      if (mounted) {
        setState(() {
          isBusy = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      return _buildButton(isFavorite: false);
    }

    return StreamBuilder<DocumentSnapshot<Map<String, dynamic>>>(
      stream: _profileService.watchFavoriteRecipe(user.uid, widget.recipe),
      builder: (context, snapshot) {
        final isFavorite = snapshot.data?.exists ?? false;

        return _buildButton(isFavorite: isFavorite);
      },
    );
  }

  Widget _buildButton({required bool isFavorite}) {
    final button = IconButton(
      tooltip: isFavorite ? 'Favorilerden çıkar' : 'Favorilere ekle',
      padding: EdgeInsets.zero,
      constraints: BoxConstraints.tightFor(
        width: widget.buttonSize,
        height: widget.buttonSize,
      ),
      iconSize: widget.iconSize,
      onPressed: isBusy ? null : () => _toggleFavorite(isFavorite),
      icon: Icon(
        isFavorite ? Icons.favorite : Icons.favorite_border,
        color: isFavorite ? widget.activeColor : widget.inactiveColor,
      ),
    );

    if (widget.backgroundColor == null) {
      return SizedBox.square(dimension: widget.buttonSize, child: button);
    }

    return Container(
      width: widget.buttonSize,
      height: widget.buttonSize,
      decoration: BoxDecoration(
        color: widget.backgroundColor,
        shape: BoxShape.circle,
      ),
      child: button,
    );
  }
}
