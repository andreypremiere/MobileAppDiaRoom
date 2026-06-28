// Базовый адрес API
const String baseUrl = String.fromEnvironment(
  'API_BASE_URL',
  defaultValue: 'https://diaroom.me/api',
);

// Базовый адрес S3 хранилища
const String s3BaseUrl = String.fromEnvironment(
  'S3_BASE_URL',
  defaultValue: 'https://storage.yandexcloud.net/',
);

// Базовый адрес
const String baseUrlClean = String.fromEnvironment(
  'S3_BASE_URL_CLEAN',
  defaultValue: 'https://diaroom.me',
);