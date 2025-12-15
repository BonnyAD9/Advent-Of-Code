namespace Aoc07;

class Gate
{
    string[] inputs;
    public ReadOnlySpan<string> Inputs => inputs;
    Func<ReadOnlySpan<ushort>, ushort> implementation;
    ushort? cache;

    Gate(string[] inputs, Func<ReadOnlySpan<ushort>, ushort> impl)
    {
        this.inputs = inputs;
        this.implementation = impl;
    }

    public ushort Execute(ReadOnlySpan<ushort> pars)
    {
        if (cache.HasValue) {
            return cache.Value;
        }
        inputs = [];
        return (cache = implementation(pars)).Value;
    }

    public static Gate Parse(string data)
    {
        return data.Trim().Split(" ", StringSplitOptions.RemoveEmptyEntries) switch
        {
            [var n] => new([n], a => a[0]),
            ["NOT", var a] => new([a], a => (ushort)~a[0]),
            [var a, "AND", var b] => new([a, b], a => (ushort)(a[0] & a[1])),
            [var a, "OR", var b] => new([a, b], a => (ushort)(a[0] | a[1])),
            [var a, "LSHIFT", var b] => new([a, b], a => (ushort)(a[0] << a[1])),
            [var a, "RSHIFT", var b] => new([a, b], a => (ushort)(a[0] >> a[1])),
            _ => throw new ArgumentException($"Invalid expression `{data}`"),
        };
    }
}