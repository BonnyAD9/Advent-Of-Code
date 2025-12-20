namespace Aoc14;

internal class Program
{
    private static void Main(string[] args)
    {
        var reindeers = File.ReadAllLines(args[0]).Select(Reindeer.Parse).ToArray();
        Calendar calendar = new();
        
        foreach (var r in reindeers) {
            calendar.AddEvent(0, r);
        }

        calendar.Run(11);

        var res = reindeers.Max(r => r.Distance);
        foreach (var r in reindeers) {
            Console.WriteLine($"{r.Name}: {r.Distance}");
        }
        Console.WriteLine(res);
    }
}