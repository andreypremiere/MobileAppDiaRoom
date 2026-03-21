enum PostCategory {
  visualArts('visual-arts', 'Арт и Иллюстрация'),
  traditionalArt('traditional-art', 'Живопись и Рисование'),
  photography('photography', 'Фотография'),
  threeDModeling('3d-modeling', '3D Моделирование'),
  graphicDesign('graphic-design', 'Графический дизайн'),
  videoProduction('video-production', 'Видеопроизводство'),
  motionDesign('motion-design', 'Моушн дизайн'),
  animation('animation', 'Анимация'),
  music('music', 'Музыка'),
  soundDesign('sound-design', 'Саунд-дизайн'),
  podcasts('podcasts', 'Подкасты'),
  literature('literature', 'Литература и Статьи'),
  gamedev('gamedev', 'Игры'),
  itTech('it-tech', 'Код и Технологии'),
  fashion('fashion', 'Мода и Стиль'),
  architecture('architecture-interior', 'Архитектура и Интерьер'),
  craftDiy('craft-diy', 'Крафт и DIY'),
  lifestyle('lifestyle-blog', 'Жизнь и Блог');

  final String id;
  final String label;
  const PostCategory(this.id, this.label);
}