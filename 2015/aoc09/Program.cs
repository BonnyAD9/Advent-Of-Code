namespace Aoc09;

internal class Program
{
    private static void Main(string[] args)
    {
        var graph = new Graph()
        {
            Inverse = true // part2
        };
        foreach (var l in File.ReadAllLines(args[0]))
        {
            graph.AddEdge(l);
        }

        Console.WriteLine(graph.ShortestPathThroughAll());
    }
}
