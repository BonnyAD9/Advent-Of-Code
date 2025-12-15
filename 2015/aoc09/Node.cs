namespace Aoc09;

public class Node(string name)
{
    public List<(int, Node)> Follow { get; } = [];
    public string Name { get; } = name;

    public override int GetHashCode() {
        return Name.GetHashCode();
    }
    
    public override bool Equals(object? obj)
    {
        return obj is Node n && n.Name == Name;
    }
}
