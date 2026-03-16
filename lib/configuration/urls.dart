// Базовый адрес сервера
const String baseUrl = 'http://192.168.0.101:8080';
// const String baseUrl = 'http://10.142.132.227:8080';


// Urls для user-microservice
const String newUserUrl = '$baseUrl/auth/newUser';
const String verifyUserUrl = '$baseUrl/auth/verifyUser';
const String findUser = '$baseUrl/auth/login';

// Urls для room-microservice
const String getRoomByRoomId = '$baseUrl/rooms/getRoomByRoomId';

// Urls для объектного хранилища
const String objectStoragePath = 'https://storage.yandexcloud.net/avatars-diaroom-1';
const String defaultAvatarPath = 'avatars/default/default.jpg';