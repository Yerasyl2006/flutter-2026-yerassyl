abstract final class Env {
  static const defaultHost = 'jsonplaceholder.typicode.com';
  static const host = String.fromEnvironment(
    'API_HOST',
    defaultValue: defaultHost,
  );
  static const useFakes = bool.fromEnvironment('USE_FAKES');
  static const name = String.fromEnvironment('ENV', defaultValue: 'local');
}
