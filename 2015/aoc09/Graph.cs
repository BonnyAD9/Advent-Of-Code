using System.Collections.Immutable;

namespace Aoc09;

class Graph
{
    private Dictionary<string, Node> Data { get; } = [];
    public bool Inverse { get; init; } = false;

    public void AddEdge(string edge)
    {
        switch (edge.Split(" ", StringSplitOptions.RemoveEmptyEntries | StringSplitOptions.TrimEntries))
        {
            case [var a, "to", var b, "=", var len]:
                AddEdge(a, b, int.Parse(len));
                break;
            default:
                throw new ArgumentException($"Invalid edge `{edge}`");
        }
    }

    public void AddEdge(string a, string b, int weight)
    {
        if (Inverse)
        {
            weight = ushort.MaxValue - weight;
        }

        Data.TryAdd(a, new(a));
        Data.TryAdd(b, new(b));

        var na = Data[a];
        var nb = Data[b];

        na.Follow.Add((weight, nb));
        nb.Follow.Add((weight, na));
    }

    public IEnumerable<Node> Nodes => Data.Values;

    public (int, Node) LongestEdge() =>
        Nodes.SelectMany(a => a.Follow).MaxBy(p => p.Item1);

    public int ShortestPathThroughAll()
    {
        var first = LongestEdge().Item2;
        SortedDictionary<int, List<(Node, ImmutableHashSet<Node>)>> nodes = new()
        {
            { 0, [(first, [first])] }
        };

        while (true)
        {
            var (len, list) = nodes.First();
            var (node, visited) = list[^1];
            
            if (visited.Count == Data.Count)
            {
                return Inverse ? ushort.MaxValue * (visited.Count - 1) - len : len;
            }
            
            list.RemoveAt(list.Count - 1);
            if (list.Count == 0)
            {
                nodes.Remove(len);
            }
            
            foreach (var (w, n) in node.Follow)
            {
                if (visited.Contains(n))
                {
                    continue;
                }
                var nlen = len + w;
                nodes.TryAdd(nlen, []);
                nodes[nlen].Add((n, visited.Add(n)));
            }
        }
    }
}
