class BackDropArguments {
  final dynamic cateId;
  final String? cateName;
  final String? tag;
  final List? data;
  final Map? config;
  final String? brandId;
  final String? brandName;
  final String? brandImg;
  final bool showCountdown;
  final bool showAppBar;
  Duration countdownDuration = Duration.zero;

  BackDropArguments({
    this.cateId,
    this.cateName,
    this.tag,
    this.data,
    this.config,
    this.brandId,
    this.brandName,
    this.brandImg,
    this.showCountdown = false,
    this.showAppBar=true,
    this.countdownDuration = Duration.zero,
  });
}
