part of '../../../dash_chat_2.dart';

/// {@category Default widgets}
class DefaultUserName extends StatelessWidget {
  const DefaultUserName({
    required this.user,
    this.style,
    this.padding,
    super.key,
  });

  /// User to show
  final ChatUser user;

  /// Style of the text
  final TextStyle? style;

  /// Padding around the text
  final EdgeInsets? padding;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: padding ?? const EdgeInsets.symmetric(horizontal: 10),
      child: Text(
        user.getFullName(),
        style: style ??
            const TextStyle(
              fontSize: 10,
              color: Colors.grey,
            ),
      ),
    );
  }
}
