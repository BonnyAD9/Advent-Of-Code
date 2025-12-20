namespace Aoc14;

class Reindeer(int speed, int duration, int restTime, string name)
{
    int Speed { get; init; } = speed;
    int Duration { get; init; } = duration;
    int RestTime { get; init; } = restTime;
    public string Name => name;

    public int Points { get; set; } = 0;

    public int DistanceAfter(int time)
    {
        int cycle = Duration + RestTime;
        return Speed * (time / cycle * Duration + int.Min(time % cycle, Duration));
    }

    public static Reindeer Parse(string s) => s.Split(
        ' ',
        StringSplitOptions.RemoveEmptyEntries | StringSplitOptions.TrimEntries
    ) switch
    {
        [var name, "can", "fly", var speed, "km/s", "for", var duration, "seconds,",
            "but", "then", "must", "rest", "for", var restTime, "seconds."]
        => new(int.Parse(speed), int.Parse(duration), int.Parse(restTime), name),
        _ => throw new ArgumentException($"Invalid reindeer `{s}`.")
    };
}