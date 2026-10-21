sealed class Countdown {
  const Countdown();
}

class Upcoming extends Countdown {
  const Upcoming(this.until);
  final Duration until;
}

class Started extends Countdown {
  const Started(this.since);
  final Duration since;
}

class Ended extends Countdown {
  const Ended();
}
