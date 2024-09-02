part of '../../../dash_chat_2.dart';

/// {@category Default widgets}
class DefaultMessageText extends StatelessWidget {
  const DefaultMessageText({
    required this.message,
    required this.isOwnMessage,
    this.messageOptions = const MessageOptions(),
    super.key,
  });

  /// Message tha contains the text to show
  final ChatMessage message;

  /// If the message is from the current user
  final bool isOwnMessage;

  /// Options to customize the behaviour and design of the messages
  final MessageOptions messageOptions;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment:
          isOwnMessage ? CrossAxisAlignment.end : CrossAxisAlignment.start,
      children: <Widget>[
        Wrap(
          children: getMessage(context),
        ),
        if (messageOptions.showTime)
          messageOptions.messageTimeBuilder != null
              ? messageOptions.messageTimeBuilder!(message, isOwnMessage)
              : Padding(
                  padding: messageOptions.timePadding,
                  child: Text(
                    (messageOptions.timeFormat ?? intl.DateFormat('HH:mm'))
                        .format(message.createdAt),
                    style: TextStyle(
                      color: isOwnMessage
                          ? messageOptions.currentUserTimeTextColor(context)
                          : messageOptions.timeTextColor(),
                      fontSize: messageOptions.timeFontSize,
                    ),
                  ),
                ),
      ],
    );
  }

  List<Widget> getMessage(BuildContext context) {
    if (message.mentions != null && message.mentions!.isNotEmpty) {
      String stringRegex = r'([\s\S]*)';
      String stringMentionRegex = '';
      for (final Mention mention in message.mentions!) {
        stringRegex += '(${mention.title})' r'([\s\S]*)';
        stringMentionRegex += stringMentionRegex.isEmpty
            ? '(${mention.title})'
            : '|(${mention.title})';
      }
      final RegExp mentionRegex = RegExp(stringMentionRegex);
      final RegExp regexp = RegExp(stringRegex);

      RegExpMatch? match = regexp.firstMatch(message.text);
      if (match != null) {
        List<Widget> res = <Widget>[];
        match
            .groups(List<int>.generate(match.groupCount, (int i) => i + 1))
            .forEach((String? part) {
          Mention? mention;
          if (mentionRegex.hasMatch(part!)) {
            try {
              mention = message.mentions?.firstWhere(
                (Mention m) => m.title == part,
              );
            } catch (e) {
              // There is no mention
            }
          }
          if (mention != null) {
            res.add(getMention(context, mention));
          } else {
            res.add(getParsePattern(context, part, message.isHtml));
          }
        });
        if (res.isNotEmpty) {
          return res;
        }
      }
    }
    return <Widget>[getParsePattern(context, message.text, message.isHtml)];
  }

  Widget _renderHtml(BuildContext context, String html) {
    Map<String, Style> styles = messageOptions.htmlStyleSheet ?? <String, Style> {};
    styles['.message-body'] = Style(
      color: messageOptions.getTextColor(context, isOwnMessage, message.isSelected),
      //textAlign: isOwnMessage ? TextAlign.right : TextAlign.left,
      //display: Display.inline
    );
    styles['.highlight-text'] = Style(
      color: messageOptions.highlightTextColor ?? Theme.of(context).colorScheme.onPrimary,
      backgroundColor: messageOptions.highlightBackgroundColor ?? Theme.of(context).colorScheme.primary,
    );
    styles['mark'] = Style(
      color: messageOptions.highlightTextColor ?? Theme.of(context).colorScheme.onPrimary,
      backgroundColor: messageOptions.highlightBackgroundColor ?? Theme.of(context).colorScheme.primary,
    );

    return Html(
        data: '<div class="message-body">$html</div>',
        style: styles,
        extensions: messageOptions.htmlExtensions,
        onLinkTap: (url, attributes,element) {
          if (url == null) {
            return;
          }
          openLink(url);
        }
    );
  }

  Widget getParsePattern(BuildContext context, String text, bool isHtml) {
    final highlightText = message.highlightText;
    if (highlightText != null && highlightText != '') {
      String html = text;
      if (!isHtml) {
        html = html.replaceAllMapped(RegExp(emailPattern), (match) {
          return '<a href="${match.group(0)}">${match.group(0)}</a>';
        });
        html = html.replaceAllMapped(RegExp(emailPattern), (match) {
          return '<a href="mailto:${match.group(0)}">${match.group(0)}</a>';
        });
        html = html.replaceAllMapped(RegExp(phonePattern), (match) {
          return '<a href="tel:${match.group(0)}">${match.group(0)}</a>';
        });
      }
      html = html.replaceAllMapped(RegExp("$highlightText(?![^<>]*(([\/\"']|]]|\b)>))"), (match) {
        return '<span class=".highlight-text">${match.group(0)}</span>';
      });
      isHtml = true;
    }

    if (isHtml) {
      return _renderHtml(context, text);
    }

    return ParsedText(
      parse: messageOptions.parsePatterns != null
          ? messageOptions.parsePatterns!
          : defaultParsePatterns,
      text: text,
      style: TextStyle(
        color: messageOptions.getTextColor(context, isOwnMessage, message.isSelected),
      ),
    );
  }

  Widget getMention(BuildContext context, Mention mention) {
    return RichText(
      text: TextSpan(
        text: mention.title,
        recognizer: TapGestureRecognizer()
          ..onTap = () => messageOptions.onPressMention != null
              ? messageOptions.onPressMention!(mention)
              : null,
        style: TextStyle(
          color: messageOptions.getTextColor(context, isOwnMessage, message.isSelected),
          decoration: TextDecoration.none,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}
