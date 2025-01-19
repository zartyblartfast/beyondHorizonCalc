/// Defines style properties for SVG text elements
class SvgTextStyle {
  final String? fontSize;    // e.g., '14px', '1.2em'
  final String? fontFamily;  // e.g., 'Arial', 'Helvetica'
  final String? fontWeight;  // e.g., 'normal', 'bold', '600'
  final String? color;       // e.g., '#000000', 'rgb(0,0,0)', 'black'

  const SvgTextStyle({
    this.fontSize,
    this.fontFamily,
    this.fontWeight,
    this.color,
  });

  /// Converts style properties to SVG attributes
  Map<String, String> toAttributes() {
    final attrs = <String, String>{};
    if (fontSize != null) attrs['font-size'] = fontSize!;
    if (fontFamily != null) attrs['font-family'] = fontFamily!;
    if (fontWeight != null) attrs['font-weight'] = fontWeight!;
    if (color != null) attrs['fill'] = color!;  // SVG uses 'fill' for text color
    return attrs;
  }

  /// Creates a copy of this style with some properties replaced
  SvgTextStyle copyWith({
    String? fontSize,
    String? fontFamily,
    String? fontWeight,
    String? color,
  }) {
    return SvgTextStyle(
      fontSize: fontSize ?? this.fontSize,
      fontFamily: fontFamily ?? this.fontFamily,
      fontWeight: fontWeight ?? this.fontWeight,
      color: color ?? this.color,
    );
  }
}
