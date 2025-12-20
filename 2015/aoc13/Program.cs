namespace Aoc13;

internal class Program
{
    private static void Main(string[] args)
    {
        var graph = BuildGraph(File.ReadAllLines(args[0]).Select(ParseLine), true);
        var happ = graph.ShortestCircle();

        Console.WriteLine($"part1: {happ}");

        foreach (var n in graph.GetNodes().ToList())
        {
            graph.AddEdge("me", n, 0);
        }

        Console.WriteLine($"part2: {graph.ShortestCircle()}");
    }

    static Graph BuildGraph(IEnumerable<(string, string, int)> edges, bool remap)
    {
        Dictionary<(string, string), int> edg = new();
        foreach (var (a, b, w) in edges)
        {
            var (sa, sb) = a.CompareTo(b) < 0 ? (a, b) : (b, a);
            if (!edg.TryAdd((sa, sb), w))
            {
                edg[(sa, sb)] += w;
            }
        }

        Graph res = new(remap);
        foreach (var ((a, b), w) in edg)
        {
            res.AddEdge(a, b, w);
        }

        return res;
    }

    static (string, string, int) ParseLine(string s)
    {
        var spl = s.Split(' ', StringSplitOptions.RemoveEmptyEntries | StringSplitOptions.TrimEntries);
        switch (spl)
        {
            case [var a, "would", var g, var p, "happiness", "units", "by", "sitting", "next", "to", var b]:
                b = b.TrimEnd('.');
                int pts = int.Parse(p);
                return g switch
                {
                    "gain" => (a, b, pts),
                    "lose" => (a, b, -pts),
                    _ => throw new ArgumentException($"Unknown gain option `{g}`"),
                };
            default:
                throw new ArgumentException($"Unknown edge `{s}`");
        }
    }
}