part of '../../../dash_chat_2.dart';

/// @nodoc
class MediaContainer extends StatelessWidget {
  const MediaContainer({
    required this.message,
    required this.isOwnMessage,
    this.messageOptions = const MessageOptions(),
    this.isPreviousSameAuthor = false,
    this.isNextSameAuthor = false,
    this.isAfterDateSeparator = false,
    this.isBeforeDateSeparator = false,
    Key? key,
  }) : super(key: key);

  /// Message that contains the media to show
  final ChatMessage message;

  /// If the message is from the current user
  final bool isOwnMessage;

  /// Options to customize the behaviour and design of the messages
  final MessageOptions messageOptions;

  /// If the previous message is from the same author as the current one
  final bool isPreviousSameAuthor;

  /// If the next message is from the same author as the current one
  final bool isNextSameAuthor;

  /// If the message is preceded by a date separator
  final bool isAfterDateSeparator;

  /// If the message is before by a date separator
  final bool isBeforeDateSeparator;

  /// Get the right media widget according to its type
  Widget getMedia(
    BuildContext context,
    ChatMedia media,
    double? height,
    double? width,
  ) {
    final Widget loading = Container(
      width: 15,
      height: 15,
      margin: const EdgeInsets.all(10),
      child: const CircularProgressIndicator(),
    );
    switch (media.type) {
      case MediaType.video:
        return Stack(
          alignment: AlignmentDirectional.bottomEnd,
          children: <Widget>[
            VideoPlayer(url: media.url, key: Key(media.url)),
            if (media.isUploading) loading
          ],
        );
      case MediaType.image:
        return Stack(
          alignment: AlignmentDirectional.bottomEnd,
          children: <Widget>[
            Image(
              height: height,
              width: width,
              fit: BoxFit.cover,
              alignment: isOwnMessage ? Alignment.topRight : Alignment.topLeft,
              image: getImageProvider(media.url),
            ),
            if (media.isUploading) loading
          ],
        );
      default:
        return TextContainer(
          isOwnMessage: isOwnMessage,
          messageOptions: messageOptions,
          isNextSameAuthor: isNextSameAuthor,
          isPreviousSameAuthor: isPreviousSameAuthor,
          isAfterDateSeparator: isAfterDateSeparator,
          isBeforeDateSeparator: isBeforeDateSeparator,
          message: message,
          messageTextBuilder: (ChatMessage m, ChatMessage? p, ChatMessage? n) {
            return Row(
              children: <Widget>[
                Padding(
                  padding: const EdgeInsets.only(right: 8.0),
                  child: !media.isUploading
                      ? Icon(
                          Icons.description,
                          size: 18,
                          color: isOwnMessage
                              ? messageOptions.currentUserTextColor(context)
                              : messageOptions.textColor,
                        )
                      : loading,
                ),
                Flexible(
                  child: Text(
                    media.fileName,
                    style: TextStyle(
                      decoration: TextDecoration.underline,
                      color: isOwnMessage
                          ? messageOptions.currentUserTextColor(context)
                          : messageOptions.textColor,
                    ),
                  ),
                ),
              ],
            );
          },
        );
    }
  }

  @override
  Widget build(BuildContext context) {
    if (message.medias != null && message.medias!.isNotEmpty) {
      final List<ChatMedia> media = message.medias!;
      return Wrap(
        alignment: isOwnMessage ? WrapAlignment.end : WrapAlignment.start,
        children: media.map(
          (ChatMedia m) {
            final double gallerySize =
                (MediaQuery.of(context).size.width * 0.7) / 2 - 5;
            final bool isImage = m.type == MediaType.image;
            return Container(
              color: Colors.transparent,
              margin: const EdgeInsets.only(top: 5, right: 5),
              width: media.length > 1 && isImage ? gallerySize : null,
              height: media.length > 1 && isImage ? gallerySize : null,
              constraints: BoxConstraints(
                maxHeight: MediaQuery.of(context).size.height * 0.5,
                maxWidth: MediaQuery.of(context).size.width * 0.7,
              ),
              child: GestureDetector(
                onTap: messageOptions.onTapMedia != null
                    ? () => messageOptions.onTapMedia!(m)
                    : null,
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(8.0),
                  child: ColorFiltered(
                    colorFilter: ColorFilter.mode(
                      m.isUploading
                          ? Colors.white54
                          : Colors.white.withOpacity(
                              0.1,
                            ), // Because transparent is causing an issue on flutter web
                      BlendMode.srcATop,
                    ),
                    child: getMedia(
                      context,
                      m,
                      media.length > 1 ? gallerySize : null,
                      media.length > 1 ? gallerySize : null,
                    ),
                  ),
                ),
              ),
            );
          },
        ).toList(),
      );
    }
    return const SizedBox();
  }
}
