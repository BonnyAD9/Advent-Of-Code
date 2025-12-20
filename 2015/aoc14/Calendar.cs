namespace Aoc14;

class Calendar {
    OrderedDictionary<int, List<IEvent>> Events { get; } = new();

    public int Time { get; private set; } = 0;

    public void AddEvent(int time, IEvent action) {
        Events.TryAdd(time, new());
        Events[time].Add(action);
    }
    
    public void Run(int duration) {
        while (true) {
            var (time, events) = Events.First();
            if (time >= duration) {
                return;
            }
            Events.Remove(time);
            Time = time;
            foreach (var ev in events) {
                ev.Run(this);
            }
        }
    }
}