using System.Collections.Immutable;

namespace Aoc13;

class Graph(bool remap)
{
    Dictionary<string, Node> Nodes { get; } = new();
    public bool Remap => remap;

    class Node(string id)
    {
        public string Id => id;
        public List<(int, Node)> Next { get; } = new();

        public override int GetHashCode()
        {
            return id.GetHashCode();
        }

        public override bool Equals(object? obj)
        {
            return obj is Node n && (object.ReferenceEquals(n, this) || Id == n.Id);
        }
    }

    public IEnumerable<string> GetNodes() => Nodes.Select(a => a.Key);

    public void AddEdge(string a, string b, int weight)
    {
        Nodes.TryAdd(a, new(a));
        Nodes.TryAdd(b, new(b));

        var an = Nodes[a];
        var bn = Nodes[b];

        if (Remap)
        {
            weight = short.MaxValue - weight;
        }

        an.Next.Add((weight, bn));
        bn.Next.Add((weight, an));
    }

    public int ShortestCircle()
    {
        var (_, node) = Nodes.First();
        SortedDictionary<int, List<(Node, ImmutableHashSet<Node>)>> q = new()
        {
            { 0, [(node, [node])] }
        };

        while (true)
        {
            var (w, nodes) = q.First();

            var (n, visited) = nodes[^1];
            nodes.RemoveAt(nodes.Count - 1);
            if (nodes.Count == 0)
            {
                q.Remove(w);
            }

            if (visited.Count == Nodes.Count)
            {
                if (n == node)
                {
                    return short.MaxValue * visited.Count - w;
                }
                var (nw, nn) = n.Next.Find(a => a.Item2 == node);
                if (nn is not null)
                {
                    nw += w;
                    q.TryAdd(nw, new());
                    q[nw].Add((node, visited));
                }
                continue;
            }

            foreach (var (fw, f) in n.Next)
            {
                if (!visited.Contains(f))
                {
                    var nw = fw + w;
                    q.TryAdd(nw, new());
                    q[nw].Add((f, visited.Add(f)));
                }
            }
        }
    }
}