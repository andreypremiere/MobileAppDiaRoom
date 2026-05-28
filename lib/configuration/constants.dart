const String uuidNil = '00000000-0000-0000-0000-000000000000';

// Лимит на фотографии в дневнике на одно сообщение
const int limitPhotosDiaryInMessage = 5;
// Лимит на видео в дневнике на одно сообщение
const int limitVideosDiaryInMessage = 2;

// Лимит на размер прикрепляемого видео в дневнике
const int limitSizeVideoInMessageDiary = 20 * 1024 * 1024; // байт (20мб)

// Лимит на запись видео квадратика в дневнике
const int limitRecordVideoNoteInDiary = 15; //секунд

const int limitPhotosForLoadInWorkshop = 15; // 15 фотографий за раз можно загрузить только
const int limitVideosForLoadInWorkshop = 3; // 3 видеороликов можно только загрузить за раз
const int limitSizeForVideoInWorkshop = 20 * 1024 * 1024; // Лимит на одно видео в воркшопе (20мб)

const int limitPhotosForBlockInPost = 5;

const int limitSizeVideoInPost = 25 * 1024 * 1024;

const int limitCountVideoBlockInPost = 4;
const int limitCountPhotoBlockInPost = 4;

const int limitGeneralCountBlockInPost = 100;

const String messageErrorCatch = "Возникла ошибка в работе приложения. Пожалуйста, сообщите в поддержку.";