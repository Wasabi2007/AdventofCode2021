#include <iostream>
#include <sstream>
#include <string>
#include <vector>
#include <algorithm>
#include <cmath>

using namespace std;

string input = "3,1,5,4,4,4,5,3,4,4,1,4,2,3,1,3,3,2,3,2,5,1,1,4,4,3,2,4,2,4,1,5,3,3,2,2,2,5,5,1,3,4,5,1,5,5,1,1,1,4,3,2,3,3,3,4,4,4,5,5,1,3,3,5,4,5,5,5,1,1,2,4,3,4,5,4,5,2,2,3,5,2,1,2,4,3,5,1,3,1,4,4,1,3,2,3,2,4,5,2,4,1,4,3,1,3,1,5,1,3,5,4,3,1,5,3,3,5,4,2,3,4,1,2,1,1,4,4,4,3,1,1,1,1,1,4,2,5,1,1,2,1,5,3,4,1,5,4,1,3,3,1,4,4,5,3,1,1,3,3,3,1,1,5,4,2,5,1,1,5,5,1,4,2,2,5,3,1,1,3,3,5,3,3,2,4,3,2,5,2,5,4,5,4,3,2,4,3,5,1,2,2,4,3,1,5,5,1,3,1,3,2,2,4,5,4,2,3,2,3,4,1,3,4,2,5,4,4,2,2,1,4,1,5,1,5,4,3,3,3,3,3,5,2,1,5,5,3,5,2,1,1,4,2,2,5,1,4,3,3,4,4,2,3,2,1,3,1,5,2,1,5,1,3,1,4,2,4,5,1,4,5,5,3,5,1,5,4,1,3,4,1,1,4,5,5,2,1,3,3";
int daysOfSimulation = 256;

long long Offsprings(int timeTillNextOffspring){
    long long newfishcount = 0;
    auto offspringCount = static_cast<long long>(floor(((daysOfSimulation-1)-(timeTillNextOffspring))/7.0))+1;
    newfishcount += offspringCount;
    for(long long offspring = 0; offspring < offspringCount; offspring++)
    {
        auto nextTimeTillNextOfspring = timeTillNextOffspring+8 + (offspring*7)+1;
        if(nextTimeTillNextOfspring > daysOfSimulation){
            continue;
        }

        newfishcount += Offsprings(nextTimeTillNextOfspring);
    }
    return newfishcount;
}

vector<string> split (string s, string delimiter) {
    size_t pos_start = 0, pos_end, delim_len = delimiter.length();
    string token;
    vector<string> res;

    while ((pos_end = s.find (delimiter, pos_start)) != string::npos) {
        token = s.substr (pos_start, pos_end - pos_start);
        pos_start = pos_end + delim_len;
        res.push_back (token);
    }

    res.push_back (s.substr (pos_start));
    return res;
}

int main()
{
	auto splitValues = split(input,",");
	vector<int> inputValues;
	transform(splitValues.begin(), splitValues.end(), std::back_inserter(inputValues), [](const auto& value) { return std::stoi(value); });
	sort(inputValues.begin(), inputValues.end());
	vector<int> uniqueInputValues;
	unique_copy(inputValues.begin(), inputValues.end(),std::back_inserter(uniqueInputValues));
	auto maxValue = uniqueInputValues.back(); //posiblie because we sorted the container
	vector<long long> precomputedOutcomes;
	precomputedOutcomes.resize(maxValue+1,0);
	std::cout << "Bigest value: " << maxValue << std::endl;
	for(auto& value : uniqueInputValues)
	{
		precomputedOutcomes[value] = Offsprings(value);
		std::cout << value << ": " << precomputedOutcomes[value] << std::endl;
	}	
	
	auto overallfishcount = inputValues.size();
	for(auto& value : inputValues)
	{
		overallfishcount += precomputedOutcomes[value];
	}
	
	std::cout << "overallfishcount: " << overallfishcount << std::endl;
	return 0;
}