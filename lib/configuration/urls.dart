// 1. Базовый адрес API (по умолчанию — прод)
const String baseUrl = String.fromEnvironment(
  'API_BASE_URL',
  defaultValue: 'https://diaroom.me/api',
);

// 2. Базовый адрес S3 хранилища (по умолчанию — Яндекс)
const String s3BaseUrl = String.fromEnvironment(
  'S3_BASE_URL',
  defaultValue: 'https://storage.yandexcloud.net/',
);

const String baseUrlClean = String.fromEnvironment(
  'S3_BASE_URL_CLEAN',
  defaultValue: 'https://diaroom.me',
);