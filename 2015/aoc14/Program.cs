namespace Aoc14;

internal class Program
{
    private static void Main(string[] args)
    {
        var reindeers = File.ReadAllLines(args[0]).Select(Reindeer.Parse).ToArray();

        var part1 = reindeers.Max(r => r.DistanceAfter(2503));
        Console.WriteLine($"part1: {part1}");

        foreach (var t in Enumerable.Range(1, 2503))
        {
            var max = reindeers.Max(r => r.DistanceAfter(t));
            foreach (var r in reindeers.Where(r => r.DistanceAfter(t) == max))
            {
                ++r.Points;
            }
        }

        var part2 = reindeers.Max(r => r.Points);
        Console.WriteLine($"part2: {part2}");
    }
}