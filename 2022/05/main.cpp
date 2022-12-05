#include <iostream>
#include <vector>

void Part2();
void Part1();
std::vector<std::vector<char>> readCrateStacks();

int main()
{
    //Part1();
    Part2();
}

void Part2()
{
    auto stacks = readCrateStacks();
    std::string str; // dummy data
    while (!std::cin.eof())
    {
        int count, source, destination;
        std::cin >> str >> count >> str >> source >> str >> destination;

        auto &sourceVec = stacks[source - 1];
        auto &destinationVec = stacks[destination - 1];

        auto start = sourceVec.end() - count;
        auto end = sourceVec.end();

        while (start != end)
            destinationVec.push_back(*start++);
        sourceVec.resize(sourceVec.size() - count);
    }

    for (auto &s : stacks)
        std::cout << s[s.size() - 1];
    std::cout << std::endl;
}

void Part1()
{
    auto stacks = readCrateStacks();
    std::string str; // dummy data
    while (!std::cin.eof())
    {
        int count, source, destination;
        std::cin >> str >> count >> str >> source >> str >> destination;

        auto &sourceVec = stacks[source - 1];
        auto &destinationVec = stacks[destination - 1];

        while (count--)
        {
            destinationVec.push_back(sourceVec[sourceVec.size() - 1]);
            sourceVec.pop_back();
        }
    }

    for (auto &s : stacks)
        std::cout << s[s.size() - 1];
    std::cout << std::endl;
}

/* Read the first part of the file eg.:
 *     [D]    
 * [N] [C]    
 * [Z] [M] [P]
 *  1   2   3 
 * into vector of vectors e.g.:
 *  {
 *      { 'Z', 'N', },
 *      { 'M', 'C', 'D', },
 *      { 'P' }
 *  }
 */
std::vector<std::vector<char>> readCrateStacks()
{
    std::string line;
    std::vector<std::string> lines;

    while (!std::cin.eof())
    {
        std::getline(std::cin, line);
        if (line.size() == 0)
            break;
        lines.push_back(line);
    }

    int count = (lines[0].size() + 1) / 4;
    lines.pop_back();

    std::vector<std::vector<char>> stacks(count);

    auto end = lines.begin() - 1;
    for (auto elem = lines.end() - 1; elem != end; --elem)
    {
        for (int i = 0; i < count; ++i)
        {
            char chr = (*elem)[i * 4 + 1];
            if (chr != ' ')
                stacks[i].push_back(chr);
        }
    }

    return stacks;
}
