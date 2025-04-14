import 'package:chat_interface/pages/chat/messages/message_formatter.dart';
import 'package:chat_interface/util/logging_framework.dart';
import 'package:flutter/rendering.dart';
import 'package:test/test.dart';

void main() {
  group("message formatter expectations", () {
    group("normal text", () {
      test("should keep text unchanged", () {
        TextEvaluator eval = TextEvaluator();
        final spans = eval.evaluate("hello world", TextStyle(fontSize: 14));

        expect(spans.length, equals(1));
        expect(spans[0].text, equals("hello world"));
        expect(spans[0].style!, equals(TextStyle(fontSize: 14.0)));
      });
    });

    group("bold formatting", () {
      test("should apply bold formatting", () {
        TextEvaluator eval = TextEvaluator();
        final spans = eval.evaluate("**hello world**", TextStyle(fontSize: 14));

        expect(spans.length, equals(3));
        expect(spans[1].text, equals("hello world"));
        expect(spans[1].style!.fontWeight, equals(FontWeight.bold));
      });

      test("should skip bold formatting patterns", () {
        TextEvaluator eval = TextEvaluator();
        final spans = eval.evaluate("**hello world**", TextStyle(fontSize: 14), skipPatterns: true);

        expect(spans.length, equals(1));
        expect(spans[0].text, equals("hello world"));
        expect(spans[0].style!.fontWeight, equals(FontWeight.bold));
      });

      test("should handle broken bold patterns (left)", () {
        TextEvaluator eval = TextEvaluator();
        final spans = eval.evaluate("***hello world**", TextStyle(fontSize: 14));

        expect(spans.length, equals(1));
        expect(spans[0].text, equals("***hello world**"));
        expect(spans[0].style!, equals(TextStyle(fontSize: 14.0)));
      });

      test("should handle broken bold patterns (right)", () {
        TextEvaluator eval = TextEvaluator();
        final spans = eval.evaluate("*hello world**", TextStyle(fontSize: 14));

        expect(spans.length, equals(1));
        expect(spans[0].text, equals("*hello world**"));
        expect(spans[0].style!, equals(TextStyle(fontSize: 14.0)));
      });
    });

    group("italic formatting", () {
      test("should apply italic formatting", () {
        TextEvaluator eval = TextEvaluator();
        final spans = eval.evaluate("*hello world*", TextStyle(fontSize: 14));

        expect(spans.length, equals(3));
        expect(spans[1].text, equals("hello world"));
        expect(spans[1].style!.fontStyle, equals(FontStyle.italic));
      });

      test("should skip italic formatting patterns", () {
        TextEvaluator eval = TextEvaluator();
        final spans = eval.evaluate("*hello world*", TextStyle(fontSize: 14), skipPatterns: true);

        expect(spans.length, equals(1));
        expect(spans[0].text, equals("hello world"));
        expect(spans[0].style!.fontStyle, equals(FontStyle.italic));
      });
    });

    group("bold and italic formatting", () {
      test("should apply both bold and italic together", () {
        TextEvaluator eval = TextEvaluator();
        final spans = eval.evaluate("***hello world***", TextStyle(fontSize: 14));

        expect(spans.length, equals(3));
        expect(spans[1].text, equals("hello world"));
        expect(spans[1].style!.fontStyle, equals(FontStyle.italic));
        expect(spans[1].style!.fontWeight, equals(FontWeight.bold));
      });

      test("should skip bold and italic formatting patterns", () {
        TextEvaluator eval = TextEvaluator();
        final spans = eval.evaluate(
          "***hello world***",
          TextStyle(fontSize: 14),
          skipPatterns: true,
        );

        expect(spans.length, equals(1));
        expect(spans[0].text, equals("hello world"));
        expect(spans[0].style!.fontWeight, equals(FontWeight.bold));
        expect(spans[0].style!.fontStyle, equals(FontStyle.italic));
      });
    });

    group("underline formatting", () {
      test("should apply underline formatting", () {
        TextEvaluator eval = TextEvaluator();
        final spans = eval.evaluate("__hello world__", TextStyle(fontSize: 14));

        expect(spans.length, equals(3));
        expect(spans[1].text, equals("hello world"));
        expect(spans[1].style!.decoration, equals(TextDecoration.underline));
      });

      test("should skip underline formatting patterns", () {
        TextEvaluator eval = TextEvaluator();
        final spans = eval.evaluate("__hello world__", TextStyle(fontSize: 14), skipPatterns: true);

        expect(spans.length, equals(1));
        expect(spans[0].text, equals("hello world"));
        expect(spans[0].style!.decoration, equals(TextDecoration.underline));
      });

      test("should handle broken underline patterns (left)", () {
        TextEvaluator eval = TextEvaluator();
        final spans = eval.evaluate("__hello world_", TextStyle(fontSize: 14));

        expect(spans.length, equals(1));
        expect(spans[0].text, equals("__hello world_"));
        expect(spans[0].style!, equals(TextStyle(fontSize: 14.0)));
      });

      test("should handle broken underline patterns (right)", () {
        TextEvaluator eval = TextEvaluator();
        final spans = eval.evaluate("_hello world__", TextStyle(fontSize: 14));

        expect(spans.length, equals(1));
        expect(spans[0].text, equals("_hello world__"));
        expect(spans[0].style!, equals(TextStyle(fontSize: 14.0)));
      });
    });

    group("strikethrough formatting", () {
      test("should apply strikethrough formatting", () {
        TextEvaluator eval = TextEvaluator();
        final spans = eval.evaluate("~~hello world~~", TextStyle(fontSize: 14));

        expect(spans.length, equals(3));
        expect(spans[1].text, equals("hello world"));
        expect(spans[1].style!.decoration, equals(TextDecoration.lineThrough));
      });

      test("should skip strikethrough formatting patterns", () {
        TextEvaluator eval = TextEvaluator();
        final spans = eval.evaluate("~~hello world~~", TextStyle(fontSize: 14), skipPatterns: true);

        expect(spans.length, equals(1));
        expect(spans[0].text, equals("hello world"));
        expect(spans[0].style!.decoration, equals(TextDecoration.lineThrough));
      });

      test("should handle broken strikethrough patterns (left)", () {
        TextEvaluator eval = TextEvaluator();
        final spans = eval.evaluate("~~hello world~", TextStyle(fontSize: 14));

        expect(spans.length, equals(1));
        expect(spans[0].text, equals("~~hello world~"));
        expect(spans[0].style!, equals(TextStyle(fontSize: 14.0)));
      });

      test("should handle broken strikethrough patterns (right)", () {
        TextEvaluator eval = TextEvaluator();
        final spans = eval.evaluate("~hello world~~", TextStyle(fontSize: 14));

        expect(spans.length, equals(1));
        expect(spans[0].text, equals("~hello world~~"));
        expect(spans[0].style!, equals(TextStyle(fontSize: 14.0)));
      });
    });

    group("combined formatting", () {
      test("should handle bold and italic sequentially", () {
        TextEvaluator eval = TextEvaluator();
        final spans = eval.evaluate("**bold** *italic*", TextStyle(fontSize: 14));

        expect(spans.length, equals(7));
        expect(spans[1].text, equals("bold"));
        expect(spans[1].style!.fontWeight, equals(FontWeight.bold));
        expect(spans[5].text, equals("italic"));
        expect(spans[5].style!.fontStyle, equals(FontStyle.italic));
      });

      test("should handle normal text between formatted text", () {
        TextEvaluator eval = TextEvaluator();
        final spans = eval.evaluate("**bold** normal *italic*", TextStyle(fontSize: 14));

        expect(spans.length, equals(7));
        expect(spans[1].text, equals("bold"));
        expect(spans[1].style!.fontWeight, equals(FontWeight.bold));
        expect(spans[3].text, equals(" normal "));
        expect(spans[5].text, equals("italic"));
        expect(spans[5].style!.fontStyle, equals(FontStyle.italic));
      });

      test("should handle underline and strikethrough combination", () {
        TextEvaluator eval = TextEvaluator();
        final spans = eval.evaluate("__underlined__ ~~strikethrough~~", TextStyle(fontSize: 14));

        expect(spans.length, equals(7));
        expect(spans[1].text, equals("underlined"));
        expect(spans[1].style!.decoration, equals(TextDecoration.underline));
        expect(spans[5].text, equals("strikethrough"));
        expect(spans[5].style!.decoration, equals(TextDecoration.lineThrough));
      });

      test("should handle all formatting types together", () {
        TextEvaluator eval = TextEvaluator();
        final spans = eval.evaluate(
          "**bold** *italic* ~~strike~~ __underline__",
          TextStyle(fontSize: 14),
        );

        expect(spans.length, equals(15));
        expect(spans[1].text, equals("bold"));
        expect(spans[1].style!.fontWeight, equals(FontWeight.bold));
        expect(spans[5].text, equals("italic"));
        expect(spans[5].style!.fontStyle, equals(FontStyle.italic));
        expect(spans[9].text, equals("strike"));
        expect(spans[9].style!.decoration, equals(TextDecoration.lineThrough));
        expect(spans[13].text, equals("underline"));
        expect(spans[13].style!.decoration, equals(TextDecoration.underline));
      });
    });

    group("nested formatting", () {
      test("should nest underline inside bold", () {
        TextEvaluator eval = TextEvaluator();
        final spans = eval.evaluate("**bold __underline inside__ bold**", TextStyle(fontSize: 14));

        expect(spans.length, equals(7));
        expect(spans[1].text, equals("bold "));
        expect(spans[1].style!.fontWeight, equals(FontWeight.bold));
        expect(spans[3].text, equals("underline inside"));
        expect(spans[3].style!.fontWeight, equals(FontWeight.bold));
        expect(spans[3].style!.decoration, equals(TextDecoration.underline));
        expect(spans[5].text, equals(" bold"));
        expect(spans[5].style!.fontWeight, equals(FontWeight.bold));
      });

      test("should nest even when no text inbetween", () {
        TextEvaluator eval = TextEvaluator();
        final spans = eval.evaluate("**__underline inside__**", TextStyle(fontSize: 14));

        sendLog(spans);
        expect(spans.length, equals(5));
        expect(spans[2].text, equals("underline inside"));
        expect(spans[2].style!.fontWeight, equals(FontWeight.bold));
        expect(spans[2].style!.decoration, equals(TextDecoration.underline));
      });

      test("should skip patterns in nested", () {
        TextEvaluator eval = TextEvaluator();
        final spans = eval.evaluate(
          "**__underline inside__**",
          TextStyle(fontSize: 14),
          skipPatterns: true,
        );

        expect(spans.length, equals(1));
        expect(spans[0].text, equals("underline inside"));
        expect(spans[0].style!.fontWeight, equals(FontWeight.bold));
        expect(spans[0].style!.decoration, equals(TextDecoration.underline));
      });

      test("should skip patterns in nested 2", () {
        TextEvaluator eval = TextEvaluator();
        final spans = eval.evaluate(
          "__**underline inside**__",
          TextStyle(fontSize: 14),
          skipPatterns: true,
        );

        sendLog(spans);

        expect(spans.length, equals(1));
        expect(spans[0].text, equals("underline inside"));
        expect(spans[0].style!.fontWeight, equals(FontWeight.bold));
        expect(spans[0].style!.decoration, equals(TextDecoration.underline));
      });

      test("should nest strikethrough inside underline", () {
        TextEvaluator eval = TextEvaluator();
        final spans = eval.evaluate(
          "__underline ~~strikethrough inside~~ underline__",
          TextStyle(fontSize: 14),
        );

        expect(spans.length, equals(7));
        expect(spans[1].text, equals("underline "));
        expect(spans[1].style!.decoration, equals(TextDecoration.underline));
        expect(spans[3].text, equals("strikethrough inside"));
        expect(
          spans[3].style!.decoration,
          equals(TextDecoration.combine([TextDecoration.underline, TextDecoration.lineThrough])),
        );
        expect(spans[5].text, equals(" underline"));
        expect(spans[5].style!.decoration, equals(TextDecoration.underline));
      });

      test("should handle overlapping bold and strikethrough", () {
        TextEvaluator eval = TextEvaluator();
        final spans = eval.evaluate("~~strike **bold strike** strike~~", TextStyle(fontSize: 14));

        expect(spans.length, equals(7));
        expect(spans[1].text, equals("strike "));
        expect(spans[1].style!.decoration, equals(TextDecoration.lineThrough));
        expect(spans[3].text, equals("bold strike"));
        expect(spans[3].style!.fontWeight, equals(FontWeight.bold));
        expect(spans[3].style!.decoration, equals(TextDecoration.lineThrough));
        expect(spans[5].text, equals(" strike"));
        expect(spans[5].style!.decoration, equals(TextDecoration.lineThrough));
      });

      test("should handle complex nesting with multiple formats", () {
        TextEvaluator eval = TextEvaluator();
        final spans = eval.evaluate(
          "**bold ~~strike __underline__ strike~~ bold**",
          TextStyle(fontSize: 14),
        );

        expect(spans.length, equals(11));
        expect(spans[1].text, equals("bold "));
        expect(spans[1].style!.fontWeight, equals(FontWeight.bold));
        expect(spans[3].text, equals("strike "));
        expect(spans[3].style!.fontWeight, equals(FontWeight.bold));
        expect(spans[3].style!.decoration, equals(TextDecoration.lineThrough));
        expect(spans[5].text, equals("underline"));
        expect(spans[5].style!.fontWeight, equals(FontWeight.bold));
        expect(
          spans[5].style!.decoration,
          equals(TextDecoration.combine([TextDecoration.underline, TextDecoration.lineThrough])),
        );
        expect(spans[7].text, equals(" strike"));
        expect(spans[7].style!.fontWeight, equals(FontWeight.bold));
        expect(spans[7].style!.decoration, equals(TextDecoration.lineThrough));
        expect(spans[9].text, equals(" bold"));
        expect(spans[9].style!.fontWeight, equals(FontWeight.bold));
      });
    });

    group("works while typing", () {
      test("should handle incomplete bold during typing", () {
        TextEvaluator eval = TextEvaluator();

        // Typing "*"
        var spans = eval.evaluate("*", TextStyle(fontSize: 14));
        expect(spans.length, equals(1));
        expect(spans[0].text, equals("*"));

        // Typing "**"
        spans = eval.evaluate("**", TextStyle(fontSize: 14));
        expect(spans.length, equals(1));
        expect(spans[0].text, equals("**"));

        // Typing "**h"
        spans = eval.evaluate("**h", TextStyle(fontSize: 14));
        expect(spans.length, equals(1));
        expect(spans[0].text, equals("**h"));

        // Typing "**hello"
        spans = eval.evaluate("**hello", TextStyle(fontSize: 14));
        expect(spans.length, equals(1));
        expect(spans[0].text, equals("**hello"));
      });

      test("should handle incomplete italic during typing", () {
        TextEvaluator eval = TextEvaluator();

        // Typing "*i"
        var spans = eval.evaluate("*i", TextStyle(fontSize: 14));
        expect(spans.length, equals(1));
        expect(spans[0].text, equals("*i"));

        // Typing "*italic"
        spans = eval.evaluate("*italic", TextStyle(fontSize: 14));
        expect(spans.length, equals(1));
        expect(spans[0].text, equals("*italic"));
      });

      test("should handle incomplete strikethrough during typing", () {
        TextEvaluator eval = TextEvaluator();

        // Typing "~"
        var spans = eval.evaluate("~", TextStyle(fontSize: 14));
        expect(spans.length, equals(1));
        expect(spans[0].text, equals("~"));

        // Typing "~~"
        spans = eval.evaluate("~~", TextStyle(fontSize: 14));
        expect(spans.length, equals(1));
        expect(spans[0].text, equals("~~"));

        // Typing "~~s"
        spans = eval.evaluate("~~s", TextStyle(fontSize: 14));
        expect(spans.length, equals(1));
        expect(spans[0].text, equals("~~s"));

        // Typing "~~s~~"
        spans = eval.evaluate("~~s~~", TextStyle(fontSize: 14));
        expect(spans.length, equals(3));
        expect(spans[1].text, equals("s"));
        expect(spans[1].style!.decoration, equals(TextDecoration.lineThrough));
      });

      test("should handle incomplete underline during typing", () {
        TextEvaluator eval = TextEvaluator();

        // Typing "_"
        var spans = eval.evaluate("_", TextStyle(fontSize: 14));
        expect(spans.length, equals(1));
        expect(spans[0].text, equals("_"));

        // Typing "__"
        spans = eval.evaluate("__", TextStyle(fontSize: 14));
        expect(spans.length, equals(1));
        expect(spans[0].text, equals("__"));

        // Typing "__u"
        spans = eval.evaluate("__u", TextStyle(fontSize: 14));
        expect(spans.length, equals(1));
        expect(spans[0].text, equals("__u"));
      });

      test("should handle formatting completing during typing", () {
        TextEvaluator eval = TextEvaluator();

        // Typing "**bold*"
        var spans = eval.evaluate("**bold*", TextStyle(fontSize: 14));
        expect(spans.length, equals(1));
        expect(spans[0].text, equals("**bold*"));

        // Typing "**bold**"
        spans = eval.evaluate("**bold**", TextStyle(fontSize: 14));
        expect(spans.length, equals(3));
        expect(spans[1].text, equals("bold"));
        expect(spans[1].style!.fontWeight, equals(FontWeight.bold));
      });

      test("should handle nested formatting during typing", () {
        TextEvaluator eval = TextEvaluator();

        // Typing "**bold __"
        var spans = eval.evaluate("**bold __", TextStyle(fontSize: 14));
        expect(spans.length, equals(1));
        expect(spans[0].text, equals("**bold __"));
        sendLog("'**bold __' completed");

        // Typing "**bold __under"
        spans = eval.evaluate("**bold __under", TextStyle(fontSize: 14));
        expect(spans.length, equals(1));
        expect(spans[0].text, equals("**bold __under"));
        sendLog("'**bold __under' completed");

        // Complete underline inside bold
        spans = eval.evaluate("**bold __under__", TextStyle(fontSize: 14));
        expect(spans.length, equals(4));
        expect(spans[0].text, equals("**bold "));
        expect(spans[2].text, equals("under"));
        expect(spans[2].style!.decoration, equals(TextDecoration.underline));
        sendLog("'**bold __under__' completed");
      });
    });
  });
}
