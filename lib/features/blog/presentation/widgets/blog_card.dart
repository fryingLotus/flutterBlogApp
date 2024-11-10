import 'package:blogapp/core/utils/calculate_reading_time.dart';
import 'package:blogapp/features/blog/domain/entities/blog.dart';
import 'package:blogapp/features/blog/presentation/pages/blog_viewer_page.dart';
import 'package:flutter/material.dart';

class BlogCard extends StatefulWidget {
  final Blog blog;
  final Color color;
  final bool isLiked;
  final bool isBookmarked;
  final VoidCallback onToggleBookmarked;
  final VoidCallback onToggleLike;

  const BlogCard({
    super.key,
    required this.blog,
    required this.color,
    required this.isLiked,
    required this.onToggleLike,
    required this.isBookmarked,
    required this.onToggleBookmarked,
  });

  @override
  State<BlogCard> createState() => _BlogCardState();
}

class _BlogCardState extends State<BlogCard> {
  late bool _isBookmarked;
  late bool _isLiked;

  @override
  void initState() {
    super.initState();
    _isBookmarked = widget.isBookmarked;
    _isLiked = widget.isLiked;
  }

// Technique to update bookmark with hive
  @override
  void didUpdateWidget(BlogCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.isBookmarked != widget.isBookmarked) {
      _isBookmarked = widget.isBookmarked;
    }
    if (oldWidget.isLiked != widget.isLiked) {
      _isLiked = widget.isLiked;
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => Navigator.push(context, BlogViewerPage.route(widget.blog)),
      child: Container(
        height: 200,
        margin: const EdgeInsets.all(16).copyWith(bottom: 4),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: widget.color,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: widget.blog.topics
                        .map(
                          (e) => Padding(
                            padding: const EdgeInsets.all(5.0),
                            child: Chip(
                              label: Text(e),
                            ),
                          ),
                        )
                        .toList(),
                  ),
                ),
                Text(
                  widget.blog.title,
                  style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                  overflow: TextOverflow.ellipsis,
                  maxLines: 1,
                )
              ],
            ),
            Text('${calculateReadingTime(widget.blog.content)} min'),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Likes: ${widget.blog.likes_count}'),
                Row(
                  children: [
                    IconButton(
                      icon: Icon(
                        _isBookmarked ? Icons.bookmark : Icons.bookmark_outline,
                        color: _isBookmarked ? Colors.blue : null,
                      ),
                      onPressed: () {
                        setState(() {
                          _isBookmarked = !_isBookmarked;
                        });
                        widget.onToggleBookmarked();
                      },
                    ),
                    IconButton(
                      icon: Icon(
                        _isLiked ? Icons.favorite : Icons.favorite_border,
                        color: _isLiked ? Colors.red : null,
                      ),
                      onPressed: () {
                        setState(() {
                          _isLiked = !_isLiked;
                        });
                        widget.onToggleLike();
                      },
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

