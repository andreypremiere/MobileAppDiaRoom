enum RoomCategory {
  lifestyleBlog('Жизнь и Блог', 'lifestyle-blog'),
  visualArts('Арт и Иллюстрация', 'visual-arts'),
  traditionalArt('Живопись и Рисование', 'traditional-art'),
  photography('Фотография', 'photography'),
  threeDModeling('3D Моделирование', '3d-modeling'),
  graphicDesign('Графический дизайн', 'graphic-design'),
  videoProduction('Видеопроизводство', 'video-production'),
  motionDesign('Моушн дизайн', 'motion-design'),
  animation('Анимация', 'animation'),
  literature('Литература и Статьи', 'literature'),
  fashion('Мода и Стиль', 'fashion'),
  architectureInterior('Архитектура и Интерьер', 'architecture-interior'),
  craftDiy('Крафт и DIY', 'craft-diy');

  final String label;
  final String slug;

  const RoomCategory(this.label, this.slug);

  static RoomCategory? fromSlug(String slug) {
    return RoomCategory.values.firstWhere(
          (e) => e.slug == slug,
      orElse: () => RoomCategory.lifestyleBlog,
    );
  }
}