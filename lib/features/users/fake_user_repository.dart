import '../../core/api/api_exception.dart';
import 'user.dart';
import 'user_repository.dart';

class FakeUserRepository implements UserRepository {
  FakeUserRepository({this.fail = false, this.delay = Duration.zero});

  final bool fail;
  final Duration delay;
  int _nextId = 3;

  static const _users = [
    User(
      id: 1,
      name: 'Leanne Graham',
      username: 'Bret',
      email: 'Sincere@april.biz',
      phone: '1-770-736-8031',
      website: 'hildegard.org',
      address: Address(
        street: 'Kulas Light',
        suite: 'Apt. 556',
        city: 'Gwenborough',
        zipcode: '92998-3874',
        geo: Geo(lat: -37.3159, lng: 81.1496),
      ),
      company: (
        name: 'Romaguera-Crona',
        catchPhrase: 'Multi-layered client-server neural-net',
      ),
      companyBs: 'harness real-time e-markets',
    ),
    User(
      id: 2,
      name: 'Ervin Howell',
      username: 'Antonette',
      email: 'Shanna@melissa.tv',
      phone: '010-692-6593',
      website: 'anastasia.net',
      address: Address(
        street: 'Victor Plains',
        suite: 'Suite 879',
        city: 'Wisokyburgh',
        zipcode: '90566-7771',
        geo: Geo(lat: -43.9509, lng: -34.4618),
      ),
      company: (
        name: 'Deckow-Crist',
        catchPhrase: 'Proactive didactic contingency',
      ),
      companyBs: 'synergize scalable supply-chains',
    ),
  ];

  Future<void> _check() async {
    if (delay != Duration.zero) await Future<void>.delayed(delay);
    if (fail) throw const NoConnectionException();
  }

  @override
  Future<UsersResult> getAll() async {
    await _check();
    return (items: _users, fromCache: false);
  }

  @override
  Future<User> getById(int id) async {
    await _check();
    return _users.firstWhere(
      (user) => user.id == id,
      orElse: () => throw const NotFoundException(),
    );
  }

  @override
  Future<User> create(User draft) async {
    await _check();
    return User.fromJson({...draft.toJson(), 'id': _nextId++});
  }
}
