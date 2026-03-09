// Базовый адрес сервера
const String baseUrl = 'http://192.168.0.101:8080';

// Urls для эндпоинтов
const String newUserUrl = '$baseUrl/auth/newUser';
const String verifyUserUrl = '$baseUrl/auth/verifyUser';
const String findUser = '$baseUrl/auth/login';

// Urls для объектного хранилища
const String objectStoragePath = 'https://storage.yandexcloud.net/avatars-diaroom-1';
const String defaultAvatarPath = 'avatars/default/default.jpg';