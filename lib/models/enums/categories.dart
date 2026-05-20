enum Categories {
  defaultVal('not-selected', 'Не выбрана'),
  visualArts('visual-arts', 'Арт и Иллюстрация'),
  traditionalArt('traditional-art', 'Живопись и Рисование'),
  photography('photography', 'Фотография'),
  threeDModeling('3d-modeling', '3D Моделирование'),
  graphicDesign('graphic-design', 'Графический дизайн'),
  videoProduction('video-production', 'Видеопроизводство'),
  motionDesign('motion-design', 'Моушн дизайн'),
  animation('animation', 'Анимация'),
  podcasts('podcasts', 'Подкасты'),
  literature('literature', 'Литература и Статьи'),
  gamedev('gamedev', 'Игры'),
  fashion('fashion', 'Мода и Стиль'),
  architecture('architecture-interior', 'Архитектура и Интерьер'),
  craftDiy('craft-diy', 'Крафт и DIY'),
  cars("cars", "Автомобили"),
  lifestyle('lifestyle-blog', 'Жизнь и Блог');

  final String slug;
  final String label;
  const Categories(this.slug, this.label);

  static Categories fromSlug(String? slug) {
    return Categories.values.firstWhere(
          (element) => element.slug == slug,
      orElse: () => Categories.defaultVal,
    );
  }
}