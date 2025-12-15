namespace Aoc07;

class GateStore
{
    Dictionary<string, Gate> gates = new();

    public void AddGate(string gate)
    {
        var (expr, res) = gate.Split("->", StringSplitOptions.TrimEntries) switch
        {
            [var a, var b] => (a, b),
            _ => throw new ArgumentException($"Invalid gate line {gate}"),
        };

        var pexpr = Gate.Parse(expr);
        if (!gates.TryAdd(res, pexpr)) {
            gates[res] = pexpr;
        }
    }
    
    public ushort GetValue(string name)
    {
        ushort res;
        if (ushort.TryParse(name, out res)) {
            return res;
        }

        var gate = gates[name];
        var names = gate.Inputs;
        Span<ushort> inp = new ushort[names.Length];
        for (int i = 0; i < inp.Length; ++i) {
            inp[i] = GetValue(names[i]);
        }

        return gate.Execute(inp);
    }
}
