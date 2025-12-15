namespace Aoc09;

public class Node
{
    public List<(int, Node)> Follow { get; } = [];
    public string Name { get; init; }

    public Node(string name)
    {
        Name = name;
    }
}
